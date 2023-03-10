CREATE TABLE Departments (
    name TEXT NOT NULL,
    abbreviation TEXT UNIQUE NOT NULL,
    PRIMARY KEY (name)
);

CREATE TABLE Programs (
    name TEXT NOT NULL,
    abbreviation TEXT NOT NULL,
    PRIMARY KEY (name)
);

CREATE TABLE Branches (
    name TEXT NOT NULL,
    program TEXT NOT NULL REFERENCES Programs(name),
    PRIMARY KEY (name, program)
);

CREATE TABLE Courses (
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits FLOAT NOT NULL,
    department TEXT NOT NULL REFERENCES Departments(name),
    CHECK (credits >= 0)
);

CREATE TABLE Students (
    idnr CHAR(10) PRIMARY KEY,
    name TEXT NOT NULL,
    login TEXT UNIQUE NOT NULL,
    program TEXT NOT NULL REFERENCES Programs,
    UNIQUE(idnr, program)
);

--CREATE TABLE DepInProgram (
--    department TEXT NOT NULL REFERENCES Departments,
--    program TEXT NOT NULL REFERENCES Programs,
--    PRIMARY KEY(department, program)
--);


--CREATE TABLE GivenBy (
--    department TEXT NOT NULL REFERENCES Departments,
--    course CHAR(6) NOT NULL REFERENCES Courses(code),
--    PRIMARY KEY(course)
--);


CREATE TABLE MandatoryProgram (
    course CHAR(6) REFERENCES Courses(code),
    program TEXT NOT NULL REFERENCES Programs(name),
    PRIMARY KEY (course, program)
);

--CREATE TABLE MandatoryCourses (
--    code CHAR(6) NOT NULL PRIMARY KEY,
--    credits FLOAT NOT NULL
--);

CREATE TABLE RecommendedCourses (
    code CHAR(6) NOT NULL PRIMARY KEY,
    credits FLOAT NOT NULL
);

CREATE TABLE MandatoryBranch(
    course CHAR(6) REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    PRIMARY KEY(course, branch, program)
);

CREATE TABLE RecommendedBranch(
    course CHAR(6) REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    PRIMARY KEY(course, branch, program)
);

CREATE TABLE LimitedCourses (
    code CHAR(6) REFERENCES Courses(code),
    capacity INT NOT NULL,
    CHECK (capacity >= 0),
    PRIMARY KEY (code)
);

CREATE TABLE Classifications (
    name TEXT PRIMARY KEY
);

CREATE TABLE Classified (
    course CHAR(6) REFERENCES Courses(code),
    classification TEXT REFERENCES Classifications(name),
    PRIMARY KEY(course, classification)
);

CREATE TABLE PrerequisiteCourse (
    course CHAR(6) REFERENCES Courses(code),
    prerequisite CHAR(6) REFERENCES Courses(code),
    PRIMARY KEY (course, prerequisite)
);

CREATE TABLE StudentBranches (
    student TEXT NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (student, program) REFERENCES Students(idnr, program),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    PRIMARY KEY (student)
);

CREATE TABLE Taken(
    student CHAR(10) REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    grade CHAR(1) NOT NULL
    CHECK (grade IN ('3', '4', '5', 'U')),
    PRIMARY KEY(student, course)
);

CREATE TABLE Registered(
    student CHAR(10) REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    PRIMARY KEY(student, course)
);


CREATE TABLE WaitingList(
    student CHAR(10) REFERENCES Students(idnr),
    course CHAR(6) REFERENCES LimitedCourses(code),
    position INT NOT NULL CHECK (position >= 0),
    PRIMARY KEY(student, course)
);

INSERT INTO Programs VALUES ('Prog1', 'P1'); -- Ours
INSERT INTO Programs VALUES ('Prog2', 'P2'); -- Ours

INSERT INTO Departments VALUES ('Dep1', 'D1'); -- Ours

INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');

INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
INSERT INTO Students VALUES ('2222222222','N2','ls2','Prog1');
INSERT INTO Students VALUES ('3333333333','N3','ls3','Prog2');
INSERT INTO Students VALUES ('4444444444','N4','ls4','Prog1');
INSERT INTO Students VALUES ('5555555555','N5','ls5','Prog2');
INSERT INTO Students VALUES ('6666666666','N6','ls6','Prog2');
INSERT INTO Students VALUES ('7777777777','N7','ls7','Prog2'); -- Ours

INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dep1');
INSERT INTO Courses VALUES ('CCC444','C4',60,'Dep1');
INSERT INTO Courses VALUES ('CCC555','C5',50,'Dep1');
INSERT INTO Courses VALUES ('CCC666','C6',30,'Dep1'); -- Ours

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',3);
INSERT INTO LimitedCourses VALUES ('CCC666',1); -- Ours

INSERT INTO PrerequisiteCourse VALUES('CCC333', 'CCC111'); -- Ours

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');


INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
INSERT INTO StudentBranches VALUES ('3333333333','B1','Prog2');
INSERT INTO StudentBranches VALUES ('4444444444','B1','Prog1');
INSERT INTO StudentBranches VALUES ('5555555555','B1','Prog2');

INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');

INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC444', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
INSERT INTO RecommendedBranch VALUES ('CCC333', 'B1', 'Prog2');

INSERT INTO Registered VALUES ('1111111111','CCC111');
INSERT INTO Registered VALUES ('1111111111','CCC222');
INSERT INTO Registered VALUES ('1111111111','CCC333');
INSERT INTO Registered VALUES ('2222222222','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC333');
-- INSERT INTO Registered VALUES ('7777777777','CCC333'); -- Ours


INSERT INTO Taken VALUES('4444444444','CCC111','5');
INSERT INTO Taken VALUES('4444444444','CCC222','5');
INSERT INTO Taken VALUES('4444444444','CCC333','5');
INSERT INTO Taken VALUES('4444444444','CCC444','5');
INSERT INTO Taken VALUES('7777777777','CCC111','5'); -- Ours
INSERT INTO Taken VALUES('3333333333','CCC111','3'); -- Ours


INSERT INTO Taken VALUES('5555555555','CCC111','5');
--INSERT INTO Taken VALUES('5555555555','CCC222','4');
INSERT INTO Taken VALUES('5555555555','CCC444','3');

INSERT INTO Taken VALUES('2222222222','CCC111','U');
INSERT INTO Taken VALUES('2222222222','CCC222','U');
INSERT INTO Taken VALUES('2222222222','CCC444','U');

-- To help with 6666666666's registration on CCC333:
INSERT INTO Taken VALUES ('6666666666', 'CCC111', '5'); -- Ours

INSERT INTO WaitingList VALUES('3333333333','CCC222',1);
INSERT INTO WaitingList VALUES('3333333333','CCC333',1);
INSERT INTO WaitingList VALUES('2222222222','CCC333',2);
INSERT INTO WaitingList VALUES('7777777777','CCC222',2); --Ours



CREATE OR REPLACE VIEW BasicInformation AS
    SELECT 
    Students.idnr as idnr,
    Students.name as name,
    Students.login as login,
    Students.program as program,
    StudentBranches.branch as branch
    FROM Students
    LEFT JOIN StudentBranches ON idnr = student
    ORDER BY idnr;

CREATE OR REPLACE VIEW FinishedCourses AS
    SELECT 
    Taken.student as student,
    Taken.course as course,
    Taken.grade as grade,
    Courses.credits as credits
    FROM Taken, Courses
    WHERE Taken.course = Courses.code
    ORDER BY student;

CREATE OR REPLACE VIEW PassedCourses AS
    SELECT
    Taken.student as student,
    Taken.course as course,
    Courses.credits as credits
    FROM Taken, Courses
    WHERE Taken.course = Courses.code AND
    NOT Taken.grade = 'U';
    
CREATE OR REPLACE VIEW Registrations AS
    SELECT 
    student, course, 'registered' AS status 
    FROM Registered
    UNION
    SELECT 
    student, course, 'waiting' AS status
    FROM Waitinglist;

CREATE OR REPLACE VIEW MandatoryCourses AS
    SELECT 
    idnr, 
    BasicInformation.program, 
    BasicInformation.branch, 
    course
    FROM BasicInformation
    JOIN MandatoryProgram 
    ON MandatoryProgram.program = BasicInformation.program
    UNION
    SELECT 
    idnr, 
    BasicInformation.program, 
    BasicInformation.branch, 
    course
    FROM BasicInformation
    JOIN MandatoryBranch 
    ON MandatoryBranch.program=BasicInformation.program 
    AND MandatoryBranch.branch=BasicInformation.branch;


CREATE OR REPLACE VIEW UnreadMandatory AS
    SELECT 
    Students.idnr AS student, 
    MandatoryCourses.course
    FROM Students
    JOIN MandatoryCourses 
    ON Students.idnr=MandatoryCourses.idnr
    EXCEPT
    SELECT 
    student, 
    course
    FROM PassedCourses;
   
CREATE OR REPLACE VIEW TotalCredits AS
    SELECT 
    student,
    SUM(credits) as totalcredits
    FROM PassedCourses
    GROUP BY student;

CREATE OR REPLACE VIEW MandatoryLeft AS
    SELECT 
    student, 
    COUNT(student) as mandatoryleft
    FROM UnreadMandatory
    GROUP BY student;

CREATE OR REPLACE VIEW MathCredits AS
    SELECT 
    student, 
    SUM(credits) as mathcredits
    FROM PassedCourses, Classified
    WHERE
    PassedCourses.course = Classified.course 
    AND Classified.classification = 'math'
    GROUP BY student;

CREATE OR REPLACE VIEW ResearchCredits AS
    SELECT 
    student, 
    SUM(credits) as researchcredits
    FROM PassedCourses, Classified
    WHERE
    PassedCourses.course = Classified.course 
    AND Classified.classification = 'research'
    GROUP BY student;


CREATE OR REPLACE VIEW SeminarCourses AS
    SELECT 
    student, 
    COUNT(PassedCourses.course) as seminarcourses
    FROM PassedCourses, Classified
    WHERE
    PassedCourses.course = Classified.course 
    AND Classified.classification = 'seminar'
    GROUP BY student;


CREATE OR REPLACE VIEW PassedRecommendedCourses AS
    SELECT 
    student, 
    PassedCourses.course AS course,
    PassedCourses.credits as credits
    FROM PassedCourses
    LEFT JOIN BasicInformation 
    ON PassedCourses.student = BasicInformation.idnr
    JOIN RecommendedBranch
    ON RecommendedBranch.program = BasicInformation.program
    AND RecommendedBranch.branch = BasicInformation.branch
    AND RecommendedBranch.course = PassedCourses.course;


CREATE OR REPLACE VIEW PassedRecommendedCredit AS 
    SELECT 
    student,
    SUM(credits) as recommendedcredits
    FROM PassedRecommendedCourses
    GROUP BY student;
     

CREATE OR REPLACE VIEW PathToGraduation AS
    SELECT
    BasicInformation.idnr as student,
    COALESCE(TotalCredits.totalcredits, 0) as totalCredits,
    COALESCE(MandatoryLeft.mandatoryleft, 0) as mandatoryLeft,
    COALESCE(MathCredits.mathcredits, 0) as mathCredits,
    COALESCE(ResearchCredits.researchcredits, 0) as researchCredits,
    COALESCE(SeminarCourses.seminarcourses, 0) as seminarCourses,
    BasicInformation.branch IS NOT NULL
    AND COALESCE(MandatoryLeft.mandatoryleft, 0) = 0
    AND COALESCE(PassedRecommendedCredit.recommendedcredits, 0) >= 10
    AND COALESCE(MathCredits.mathcredits, 0) >= 20
    AND COALESCE(ResearchCredits.researchcredits, 0) >= 10
    AND COALESCE(SeminarCourses.seminarcourses, 0) >= 1
    AS qualified
    FROM BasicInformation
    LEFT JOIN TotalCredits ON idnr=TotalCredits.student
    LEFT JOIN MandatoryLeft ON idnr=MandatoryLeft.student
    LEFT JOIN MathCredits ON idnr=MathCredits.student
    LEFT JOIN ResearchCredits ON idnr=ResearchCredits.student
    LEFT JOIN SeminarCourses ON idnr=SeminarCourses.student
    LEFT JOIN PassedRecommendedCredit ON idnr=PassedRecommendedCredit.student;

