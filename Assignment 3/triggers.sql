
CREATE VIEW CourseQueuePositions AS
    SELECT
    course, 
    student,
    ROW_NUMBER() OVER (PARTITION BY course ORDER BY position) as place
    FROM
    WaitingList;

CREATE OR REPLACE FUNCTION register() RETURNS TRIGGER AS $$
    BEGIN
        --[] Om behörig
        --[X] Upfyller prereqisites
        --[X] Inte redan är registrerad 
        --[X] Inte på väntlistan
        --[X] Kursen är limited
        --[X] Inte redan klarat kursen

        --[] Om kursen är full -> sätt på väntlista

        IF NEW.student IS NULL THEN
            RAISE EXCEPTION 'student cannot be null';
        ELSIF NEW.course IS NULL THEN
            RAISE EXCEPTION 'course cannot be null';
        --ELSIF NEW.place IS NULL THEN
        --    RAISE EXCEPTION 'place cannot be null';
        END IF;

        --Check if student fulfills the prerequisites for the course
        If EXISTS (
            SELECT * FROM PrerequisiteCourse
            WHERE course = NEW.course
            )
            THEN
            IF EXISTS(
                SELECT prerequisite 
                FROM PrerequisiteCourse 
                WHERE course = NEW.course 
                EXCEPT SELECT course
                FROM PassedCourses
                WHERE PassedCourses.student = NEW.student
                ) 
                THEN RAISE EXCEPTION '% does not fulfill prerequisites for course %', NEW.student, NEW.course;
            END if;
        END if;
        
        --Check if student is already registred for this course
        IF EXISTS (
            SELECT student 
            FROM Registrations 
            WHERE student = NEW.student 
            AND course = NEW.course
        )
            THEN RAISE EXCEPTION '% is already registered for course %', NEW.student, NEW.course;
        END IF;

        -- Check if the student has not already passed the course
        IF EXISTS (
            SELECT * FROM PassedCourses
            WHERE course = NEW.course
            AND PassedCourses.student = NEW.student
        ) THEN
            RAISE EXCEPTION '% has already passed course %.', NEW.student, NEW.course;
        END IF;

        --Check if course is limited
        IF(
            SELECT code 
            FROM Courses 
            WHERE code = NEW.course) 
            IN (
                SELECT code 
                FROM LimitedCourses 
                WHERE code = NEW.course) 
                THEN 
            --If course is full
            IF (
                SELECT COUNT(*)
                FROM Registered 
                WHERE course = NEW.course) >= (
                    SELECT capacity 
                    FROM LimitedCourses 
                    WHERE code = NEW.course) 
                THEN
                    --Put student in waiting list
                    INSERT INTO WaitingList (student, course, position)
                    VALUES (NEW.student, NEW.course, nextStudentPos(NEW.course));
                    RAISE NOTICE 'Course % is full, % is put on the waiting list', NEW.course, NEW.student;
                    RETURN NULL;
            END IF;
            --course is not full
        END IF;

        -- Register student unless they are on waiting list
        INSERT INTO Registered (course, student)
        VALUES (NEW.course, NEW.student);
        RETURN NEW;

    END;
$$LANGUAGE plpgsql;

CREATE FUNCTION unregister() RETURNS TRIGGER AS $$
BEGIN
    -- CODE HERE
END
$$LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION nextStudentPos(CHAR(6)) RETURNS INT AS $nextStudentPos$
        SELECT COUNT(*)+1 FROM WaitingList WHERE course = $1
        $nextStudentPos$ LANGUAGE SQL;

CREATE TRIGGER addingToQueue
    INSTEAD OF INSERT OR UPDATE ON Registrations
    FOR EACH ROW
    EXECUTE FUNCTION register();

CREATE TRIGGER removeFromQueue
    INSTEAD OF DELETE OR UPDATE ON Registrations
    FOR EACH ROW
    EXECUTE FUNCTION unregister();
