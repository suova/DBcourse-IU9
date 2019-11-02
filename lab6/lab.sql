USE master;
GO



IF DB_ID('lab6') IS NOT NULL
DROP DATABASE lab6;

CREATE DATABASE lab6
ON ( NAME =data6,
    FILENAME = '/DB/lab6/data6.mdf',
    SIZE = 10,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5 )
LOG ON
( NAME = log6,
    FILENAME = '/DB/lab6/log6.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB );
GO



USE lab6;
GO

IF OBJECT_ID(N'USERS') is NOT NULL
 DROP TABLE USERS

CREATE TABLE USERS (
    id INT IDENTITY (1, 1) PRIMARY KEY ,
	email VARCHAR(100) NOT NULL,
	salary INT
);
GO

ALTER TABLE USERS
    ADD registrationDate  DATETIME  CHECK (registrationDate  > CONVERT(DATETIME, '1/1/1990', 103))
GO

ALTER TABLE USERS
    ADD name VARCHAR(70) DEFAULT 'JOHN DOE'
GO

SELECT GETDATE() AS 'Today''s Date and Time',
@@CONNECTIONS AS 'Login Attempts';

INSERT INTO dbo.USERS VALUES ('eMAIL',12345, '1/3/1990','nAME' );
GO
INSERT INTO dbo.USERS (email, salary, registrationDate) VALUES( 'eMAIL',87654, '1/2/1990');
GO

SELECT AVG(salary)AS 'Average salary'
FROM USERS

-- SELECT *
-- FROM USERS


IF OBJECT_ID(N'CUST') is NOT NULL
 DROP TABLE CUST

CREATE TABLE CUST
(
 CustomerID uniqueidentifier NOT NULL
   DEFAULT newid(),
 Company varchar(30) NOT NULL,
 ContactName varchar(60) NOT NULL,
 Address varchar(30) NOT NULL,
 Telephone varchar(15) NOT NULL
);
GO
-- Inserting 5 rows into cust table.
INSERT cust
(CustomerID, Company, ContactName, Address, Telephone)
VALUES
 (NEWID(), 'Wartian Herkku', 'Pirkko Koskitalo', 'Torikatu 38',  '981-443655')
,(NEWID(), 'Wellington Importadora', 'Paula Parente', 'Rua do Mercado, 12', '(14) 555-8122')
GO

-- SELECT *
-- FROM CUST


CREATE TABLE BOOKS(
    id INT PRIMARY KEY ,
	title VARCHAR(100) NOT NULL,
	author VARCHAR(100) NOT NULL
);
GO

CREATE SEQUENCE CountBy1
START WITH 1
INCREMENT BY 1;
GO

INSERT BOOKS (id, title, author)
VALUES (NEXT VALUE FOR CountBy1, 'Tire', 'Pushkin');
INSERT BOOKS (id, title, author)
VALUES (NEXT VALUE FOR CountBy1, 'Seat', 'Marks') ;

SELECT *
FROM BOOKS


IF OBJECT_ID(N'CLASSES') is NOT NULL
 DROP TABLE CLASSES

CREATE TABLE CLASSES (
	classID INT  IDENTITY(1,1) PRIMARY KEY,
	title VARCHAR(100) NOT NULL,
	teacher VARCHAR(100) NOT NULL,
);
GO

IF OBJECT_ID(N'STUDENTS') is NOT NULL
 DROP TABLE STUDENTS

CREATE TABLE STUDENTS (
	studentID INT IDENTITY(1,1) PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	classID INT ,
	CONSTRAINT FK_classID FOREIGN KEY (classID) REFERENCES CLASSES (classID) ON DELETE CASCADE,
);
GO

INSERT INTO CLASSES VALUES ('math', 'mr Smith'),('rus', 'mr Smith'), ('literature', 'mrs Seroj'), ('english', 'mr Valio');
GO
select *
from CLASSES

INSERT INTO STUDENTS VALUES ('masha', (SELECT DISTINCT classID FROM CLASSES WHERE (title = 'rus')))
GO

ALTER TABLE STUDENTS
DROP CONSTRAINT FK_classID;

ALTER TABLE STUDENTS
ADD CONSTRAINT Default_classID
DEFAULT 'PE' FOR classID;

ALTER TABLE STUDENTS
ADD CONSTRAINT FK_classID
FOREIGN KEY (classID) REFERENCES CLASSES (classID) ON DELETE SET DEFAULT;
GO

DELETE from CLASSES
WHERE (title = 'math');

SELECT * from STUDENTS;



DELETE from CLASSES
WHERE (title = 'literature');

SELECT * from STUDENTS;

ALTER TABLE STUDENTS
DROP CONSTRAINT FK_classID;

ALTER TABLE STUDENTS
ADD CONSTRAINT FK_classID
FOREIGN KEY (classID) REFERENCES CLASSES (classID) ON DELETE SET NULL;
GO

DELETE from CLASSES
WHERE (title = 'english');

SELECT * from STUDENTS;
