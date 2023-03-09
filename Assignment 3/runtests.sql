-- This script deletes everything in your database
\set QUIET true
SET client_min_messages TO WARNING; -- Less talk please.
-- This script deletes everything in your database
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO CURRENT_USER;
\set QUIET false


-- \ir is for include relative, it will run files in the same directory as this file
-- Note that these are not SQL statements but rather Postgres commands (no terminating ;). 
\ir setup.sql
\ir triggers.sql

SELECT student, course FROM Registered ORDER BY student;

SELECT student, course, position FROM WaitingList ORDER BY position;


\ir tests.sql

SELECT student, course FROM Registered ORDER BY student;
 
SELECT student, course, position FROM WaitingList ORDER BY position;
