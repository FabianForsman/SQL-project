--\ir setup.sql

--SELECT student, course, status FROM Registrations ORDER BY student;
--SELECT student, course, credits FROM PassedCourses ORDER BY student;


--------------   Register tests   --------------

-- TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('2222222222', 'CCC555');

-- TEST #2: Register an already registered student.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('2222222222', 'CCC555');

-- TEST #3: Register to limited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('6666666666', 'CCC333');

-- TEST #4: Wait for limited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('6666666666', 'CCC222');

-- TEST #5: Try to register for course already passed.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('4444444444', 'CCC222');

-- TEST #6: Try to register for a course where the prerequisites haven't been taken.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('3333333333', 'CCC333');

--SELECT student, course, status FROM Registrations ORDER BY student;
