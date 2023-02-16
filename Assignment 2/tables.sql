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
    credits FLOAT NOT NULL
    CHECK (credits >= 0)
);

CREATE TABLE Students (
    idnr CHAR(10) PRIMARY KEY,
    name TEXT NOT NULL,
    login TEXT UNIQUE NOT NULL,
    program TEXT NOT NULL REFERENCES Programs
);

CREATE TABLE DepInProgram (
    department TEXT NOT NULL REFERENCES Departments,
    program TEXT NOT NULL REFERENCES Programs,
    PRIMARY KEY(department, program)
);

--CREATE TABLE GivenBy


CREATE TABLE MandatoryProgram (
    course CHAR(6) REFERENCES Courses(code),
    program TEXT NOT NULL,
    PRIMARY KEY (course, program)
);


--CREATE TABLE MandatoryCourses


--CREATE TABLE ReccomendedCourses


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

CREATE TABLE StudentBranches (
    student TEXT REFERENCES Students(idnr),
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    PRIMARY KEY (student)
);

CREATE TABLE Classifications(
    name TEXT PRIMARY KEY
);

CREATE TABLE Classified(
    course CHAR(6) REFERENCES Courses(code),
    classification TEXT REFERENCES Classifications(name),
    PRIMARY KEY(course, classification)
);



CREATE TABLE Registered(
    student CHAR(10) REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    PRIMARY KEY(student, course)
);

CREATE TABLE Taken(
    student CHAR(10) REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    grade CHAR(1) NOT NULL
    CHECK (grade IN ('3', '4', '5', 'U')),
    PRIMARY KEY(student, course)
);

CREATE TABLE WaitingList(
    student CHAR(10) REFERENCES Students(idnr),
    course CHAR(6) REFERENCES LimitedCourses(code),
    position SERIAL,
    PRIMARY KEY(student, course)
);