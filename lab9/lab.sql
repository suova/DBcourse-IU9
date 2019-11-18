USE master;
GO

IF DB_ID('lab9') IS NOT NULL
    DROP DATABASE lab9;
GO

CREATE DATABASE lab9
    ON (
    NAME = lab9data,
    FILENAME = '/DB/lab9/data9.mdf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5% )
    LOG ON (
    NAME = lab9log,
    FILENAME = '/DB/lab9/log9.ldf',
    SIZE = 5 MB,
    MAXSIZE = 25 MB,
    FILEGROWTH = 5 MB );
GO

USE lab9
GO

IF OBJECT_ID('users') is NOT NULL
    DROP TABLE users
GO

CREATE TABLE users
(
    ID       INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    username VARCHAR(32)            NOT NULL,
    email    VARCHAR(128)           NOT NULL UNIQUE,
    phone    VARCHAR(12),
    money    INT CHECK (0 < money AND money < 100000)
);

INSERT INTO users(username, email, money)
VALUES ('DD', 'z@bmstu.ru', 119)
GO

INSERT INTO users(username, email, phone, money)
VALUES ('VV', 'g@bmstu.ru', '79384627354', 230)
GO

INSERT INTO users(username, email,money)
VALUES ('vw', 'w@bmstu.ru', 220)
GO

SELECT * FROM users

-- 1. Для одной из таблиц пункта 2 задания 7 создать триггеры на вставку, удаление и добавление, при
-- выполнении заданных условий один из триггеров должен инициировать возникновение ошибки
-- (RAISERROR / THROW).


IF OBJECT_ID(N'deleteUser') IS NOT NULL
	DROP TRIGGER updateUser
go

CREATE TRIGGER updateUser
	ON users
	INSTEAD OF DELETE
AS
    SELECT * FROM deleted;
	THROW 66666, N'Some mistake', 1
GO


DELETE FROM users WHERE userName LIKE 'DD'

IF OBJECT_ID(N'updateUser') IS NOT NULL
	DROP TRIGGER updateUser
go

CREATE TRIGGER updateUser
	ON users
	AFTER  UPDATE
AS
    SELECT * FROM users;
GO

UPDATE users
SET money = money + 100
WHERE userName = 'VV';
GO

IF OBJECT_ID(N'insertUser') IS NOT NULL
	DROP TRIGGER insertUser
go

CREATE TRIGGER insertUser
	ON users
	AFTER  INSERT
AS
    SELECT * FROM users;
GO

INSERT INTO users(username, email, money)
VALUES ('AA', 'A@bmstu.ru', 140)
GO

-- 2. Для представления пункта 2 задания 7 создать триггеры на вставку, удаление и добавление,
-- обеспечивающие возможность выполнения операций с данными непосредственно через представление.
USE lab9
GO

IF OBJECT_ID('lesson') is NOT NULL
    DROP TABLE lesson
GO

CREATE TABLE lesson
(
    ID        INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    name      VARCHAR(128)           NULL,
    teacherID INT,
    FOREIGN KEY (teacherID) REFERENCES users (ID) ON DELETE CASCADE
);

INSERT INTO lesson(name)
VALUES ('OBJ'), ('Russki')
GO

UPDATE lesson
SET teacherID = (SELECT ID FROM users WHERE username = 'VV')
WHERE name LIKE 'OBJ'
GO

SELECT * FROM lesson


IF OBJECT_ID('lessonView') IS NOT NULL
    DROP VIEW lessonView
GO

CREATE VIEW lessonView AS
SELECT w.name, u.username AS teacher, u.email AS teachersEmail
FROM lesson AS w JOIN users u ON w.teacherID = u.ID
GO

SELECT *
FROM lessonView
GO

IF OBJECT_ID(N'insertIntoView') IS NOT NULL
	DROP TRIGGER insertIntoView
go

CREATE TRIGGER insertIntoView
	ON lessonView
	INSTEAD OF INSERT
AS
	BEGIN
	    PRINT 'add lesson'

		DECLARE @table TABLE (
					name VARCHAR(128), teacherUsername VARCHAR(32), teachersEmail VARCHAR(128), teacherID INT
				);


		INSERT INTO @table(name, teacherUsername, teachersEmail)
		SELECT inserted.name, inserted.teacher, inserted.teachersEmail
		FROM inserted


		INSERT INTO users(username, email)
		SELECT DISTINCT teacherUsername, teachersEmail
		FROM @table

		UPDATE @table SET teacherID = (SELECT ID FROM users WHERE username = teacherUsername)

		INSERT INTO lesson(name, teacherID)
		SELECT DISTINCT name, teacherID
		FROM @table

	END
GO

INSERT INTO lessonView(name, teacher, teachersEmail) VALUES ('topol', 'll', 'l@l.ru')

SELECT * FROM lessonView
