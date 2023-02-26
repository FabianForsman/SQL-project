
-- This script deletes everything in your database
\set QUIET true
SET client_min_messages TO WARNING; -- Less talk please.
-- This script deletes everything in your database
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO CURRENT_USER;
-- This line makes psql stop on the first error it encounters
-- You may want to remove this when running tests that are intended to fail
\set ON_ERROR_STOP ON
SET client_min_messages TO NOTICE; -- More talk
\set QUIET false


-- \ir is for include relative, it will run files in the same directory as this file
-- Note that these are not SQL statements but rather Postgres commands (no terminating ;). 
\ir setup.sql
\ir triggers.sql


-- Tests various queries from the assignment, uncomment these as you make progress
SELECT course, student, place FROM CourseQueuePosition ORDER BY course;

--INSERT INTO Registrations VALUES('3333333333','CCC222'); -- Already registered for this course. 
--INSERT INTO Registrations VALUES('3333333333', 'CCC555'); -- Doesn't work yet. 
--INSERT INTO Registrations VALUES('2222222222', 'CCC444'); 

SELECT course, student, place FROM CourseQueuePosition ORDER BY course;


-- TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('2222222222', 'CCC444');

-- TEST #2: Register an already registered student.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('2222222222', 'CCC444');

-- TEST #3: Unregister from an unlimited course. 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC444';



SELECT student, course, status FROM Registrations ORDER BY student;
