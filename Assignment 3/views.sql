CREATE VIEW BasicInformation AS
    SELECT 
    Students.idnr as idnr,
    Students.name as name,
    Students.login as login,
    Students.program as program,
    StudentBranches.branch as branch
    FROM Students
    LEFT JOIN StudentBranches ON idnr = student
    ORDER BY idnr;

CREATE VIEW FinishedCourses AS
    SELECT 
    Taken.student as student,
    Taken.course as course,
    Taken.grade as grade,
    Courses.credits as credits
    FROM Taken, Courses
    WHERE Taken.course = Courses.code
    ORDER BY student;

CREATE VIEW PassedCourses AS
    SELECT
    Taken.student as student,
    Taken.course as course,
    Courses.credits as credits
    FROM Taken, Courses
    WHERE Taken.course = Courses.code AND
    NOT Taken.grade = 'U';
    
CREATE VIEW Registrations AS
    SELECT 
    student, course, 'registered' AS status 
    FROM Students, Registered
    WHERE Students.idnr = Registered.student
    UNION
    SELECT 
    student, course, 'waiting' AS status
    FROM Students, Waitinglist
    WHERE Students.idnr = Waitinglist.student;


CREATE VIEW MandatoryCourses AS
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


CREATE VIEW UnreadMandatory AS
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
   
CREATE VIEW TotalCredits AS
    SELECT 
    student,
    SUM(credits) as totalcredits
    FROM PassedCourses
    GROUP BY student;

CREATE VIEW MandatoryLeft AS
    SELECT 
    student, 
    COUNT(student) as mandatoryleft
    FROM UnreadMandatory
    GROUP BY student;

CREATE VIEW MathCredits AS
    SELECT 
    student, 
    SUM(credits) as mathcredits
    FROM PassedCourses, Classified
    WHERE
    PassedCourses.course = Classified.course 
    AND Classified.classification = 'math'
    GROUP BY student;

CREATE VIEW ResearchCredits AS
    SELECT 
    student, 
    SUM(credits) as researchcredits
    FROM PassedCourses, Classified
    WHERE
    PassedCourses.course = Classified.course 
    AND Classified.classification = 'research'
    GROUP BY student;


CREATE VIEW SeminarCourses AS
    SELECT 
    student, 
    COUNT(PassedCourses.course) as seminarcourses
    FROM PassedCourses, Classified
    WHERE
    PassedCourses.course = Classified.course 
    AND Classified.classification = 'seminar'
    GROUP BY student;


CREATE VIEW PassedRecommendedCourses AS
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


CREATE VIEW PassedRecommendedCredit AS 
    SELECT 
    student,
    SUM(credits) as recommendedcredits
    FROM PassedRecommendedCourses
    GROUP BY student;
     

CREATE VIEW PathToGraduation AS
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