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

--------------   Unregister tests   --------------

SELECT student, course FROM Registered ORDER BY student;

SELECT student, course, position FROM WaitingList ORDER BY course, position;

-- TEST #7: Unregister from an unlimited course. 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC555';

-- TEST #8: Unnregistered from a limited course with a waiting list, when the student is registered. 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC333';
 
-- TEST #9: Unnregistered from a limited course with a waiting list, when the student is in the middle of the waiting list. 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '7777777777' AND course = 'CCC222';

-- TEST #10: Unregistered from an overfull course with a waiting list.
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC222';


DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC333';

-- TEST #11 Unregistered from a limited course without a waiting list.
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '5555555555' AND course = 'CCC333';
