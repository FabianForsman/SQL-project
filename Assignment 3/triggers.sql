
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
        IF NOT EXISTS (
            SELECT COUNT(prerequisite) FROM PrerequisiteCourse
            WHERE course = NEW.course 
            AND prerequisite NOT IN(
                SELECT course FROM Registrations 
                WHERE student = NEW.student
                UNION ALL
                SELECT course FROM WaitingList
                WHERE student = NEW.student
            )
        ) THEN RAISE EXCEPTION '% does not fulfill prerequisites for course %', NEW.student, NEW.course;
        END IF;

        --Check if student is already registred for this course
        IF EXISTS (
            SELECT student 
            FROM Registrations 
            WHERE student = NEW.student 
            AND course = NEW.course
        )
            THEN RAISE EXCEPTION '% is already registered for course %', NEW.student, NEW.course;
        END IF;

        -- Check if the student is not already on the waiting list for the course
        IF EXISTS (
            SELECT student FROM WaitingList
            WHERE course = NEW.course
            AND student = NEW.student
        ) THEN
            RAISE EXCEPTION '% is already on the waiting list for course %.', NEW.student, NEW.course;
        END IF;

         --Check if course is limited, if not then register for course.
		IF NOT EXISTS (
            SELECT code 
            FROM LimitedCourses 
            WHERE code = NEW.course)
			THEN 
			--Insert into registered
			INSERT INTO Registered(student, course) 
            VALUES (NEW.student, NEW.course);	
			RETURN NEW;
		END IF;

        -- Check if the student has not already passed the course
        IF EXISTS (
            SELECT student FROM Registrations
            WHERE course = NEW.course
            AND student = NEW.student
            AND grade >= pass_grade
        ) THEN
            RAISE EXCEPTION '% has already passed course %.', NEW.student, NEW.course;
        END IF;

        -- Check if there is room for the student to register for the course
        IF EXISTS (
            SELECT 1 FROM Courses
            WHERE course_code = NEW.course
            AND num_students >= max_students
        ) THEN
            -- If the course is full, add the student to the waiting list
            INSERT INTO WaitingList (course, student)
            VALUES (NEW.course, NEW.student);
            RETURN NULL;
        ELSE
            -- If there is room, add the student to the Registrations view
            INSERT INTO Registrations (course, student)
            VALUES (NEW.course, NEW.student);
            -- Update the number of students enrolled in the course
            UPDATE Courses
            SET num_students = num_students + 1
            WHERE course_code = NEW.course;
            RETURN NEW;
        END IF;
    END;
$$LANGUAGE plpgsql;

CREATE FUNCTION unregister() RETURNS TRIGGER AS $$
BEGIN
    -- CODE HERE
END
$$LANGUAGE plpgsql;

CREATE TRIGGER addingToQueue
    INSTEAD OF INSERT ON Registrations
    FOR EACH ROW
    EXECUTE FUNCTION register();

CREATE TRIGGER removeFromQueue
    INSTEAD OF DELETE ON Registrations
    FOR EACH ROW
    EXECUTE FUNCTION unregister();
