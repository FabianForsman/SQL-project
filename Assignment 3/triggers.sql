
CREATE VIEW CourseQueuePosition AS
    SELECT
    course, 
    student,
    ROW_NUMBER() OVER (PARTITION BY course ORDER BY position) as place
    FROM
    WaitingList;

CREATE OR REPLACE FUNCTION register() RETURNS TRIGGER AS $$
    BEGIN
        --[] Om behörig
        --[] Upfyller prereqisites
        --[X] Inte redan är registrerad 
        --[] Inte på väntlistan
        --[] Inte redan klarat kursen

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
        ) THEN RAISE EXCEPTION '% does not fulfill prerequisites for this course', NEW.student;
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
        RETURN NEW;
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
