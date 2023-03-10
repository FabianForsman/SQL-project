
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

CREATE OR REPLACE FUNCTION unregister() RETURNS TRIGGER AS $$

    -- CODE HERE
    -- IF REGISTERED IN COURSE
        -- REMOVE STUDENT FROM COURSE REGISTRATION
        -- IF COURSE LIMTED
            -- CHECK IF ANY STUDENTS ON WATING LIST
            -- Remove top from Wait
            -- Add to Register
            -- Reshape Wait

    -- ELSE IF STUDENT IN WAITING LIST
        -- TAKE STUDENT FROM WATING LIST
        -- BUMP UP WAITING LIST aka UPDATE POSITIONS
        
    -- ELSE RAISE EXCEPTION 'Student not registred or on wait list'
    
    DECLARE 
        current_pos INT;
        max_capacity INT;

    BEGIN
        IF OLD.student IS NULL THEN
            RAISE EXCEPTION 'student cannot be null';
        ELSIF OLD.course IS NULL THEN
            RAISE EXCEPTION 'course cannot be null';
        END IF;

        -- IF NOT REGISTERED OR WAITING
       IF NOT EXISTS
           (SELECT student
           FROM Registered
           WHERE student = OLD.student
           AND course = OLD.course
       )
        THEN
            IF NOT EXISTS(
                SELECT student
                FROM WaitingList
                WHERE student = OLD.student
                AND course = OLD.course
            )
            THEN
            -- ELSE RAISE EXCEPTION 'Student not registred or on wait list'
            RAISE EXCEPTION '% is not registered to the %', OLD.student, OLD.course;
            END IF;
        END IF;

        -- IF REGISTERED IN COURSE
        IF EXISTS(
            SELECT student
            FROM Registered
            WHERE student = OLD.student
            AND course = OLD.course
        )
            THEN
            -- IF COURSE IS A LIMITED COURSE
            IF EXISTS (
                SELECT code
                FROM LimitedCourses
                WHERE code = OLD.course
            )
                THEN
                IF (
                    (SELECT COUNT(student)
                    FROM Registered
                    WHERE course = OLD.course)
                    <=
                    (SELECT capacity
                    FROM LimitedCourses
                    WHERE code = OLD.course)
                )
                THEN
                    --CHECK IF ANY STUDENTS ON WATING LIST
                    IF EXISTS (
                        SELECT *
                        FROM WaitingList
                        WHERE course = OLD.course
                    )                    
                        THEN
                        --RAISE EXCEPTION 'DEBUG';
                        -- Add first student from Wait to Register
                        INSERT INTO Registered (student, course)
                        SELECT student, course
                        FROM WaitingList
                        WHERE course = OLD.course
                        LIMIT 1;

                        -- Remove top from Wait
                        DELETE FROM WaitingList
                        WHERE position = 1 AND course = OLD.course;

                        -- Reshape Wait
                        UPDATE WaitingList 
                        SET position = position - 1 
                        WHERE course = OLD.course
                        AND position > 1;
                    END IF;
                END IF;
            END IF;

            -- REMOVE STUDENT FROM COURSE REGISTRATION
            DELETE FROM Registered 
            WHERE student = OLD.student
            AND course = OLD.course;
        
        -- ELSE IF STUDENT IN WAITING LIST
        ELSIF EXISTS (
            SELECT student
            FROM WaitingList
            WHERE student = OLD.student
            AND course = OLD.course
        )
            THEN
            -- FIND CURRENT POS
            SELECT position INTO current_pos
            FROM WaitingList
            WHERE student = OLD.student
            AND course = OLD.course;

            -- BUMP UP WAITING LIST aka UPDATE POSITIONS
            UPDATE WaitingList SET position = position - 1
            WHERE course = OLD.course
            AND position >= current_pos;

            -- REMOVE STUDENT FROM WATING LIST
            DELETE FROM WaitingList
            WHERE student = OLD.student
            AND course = OLD.course;
        END IF;
    RETURN OLD;
END;
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
