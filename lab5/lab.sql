USE master;
GO

--1. Создать базу данных (CREATE DATABASE…,определение настроек размеров файлов).
IF DB_ID(N'lab5') IS NOT NULL
DROP DATABASE lab5;
GO

CREATE DATABASE lab5
ON (
NAME =data5,
filename = '/DB/lab5/data5.mdf',
size = 10 MB,
MAXSIZE = UNLIMITED,
FILEGROWTH = 5%)
log on (
NAME = log5,
FILENAME = '/DB/lab5/log5.ldf',
SIZE = 5 MB,
MAXSIZE = 25 MB,
FILEGROWTH = 5 MB );
GO

--2. Создать произвольную таблицу (CREATE TABLE…).
USE lab5
GO

IF OBJECT_ID(N'users') is NOT NULL
DROP TABLE users
GO

CREATE TABLE users
(
id INT IDENTITY (1, 1),
name VARCHAR(128),
email VARCHAR(128) NOT NULL,
phone VARCHAR(12)
) ON [PRIMARY];
GO


--3. Добавить файловую группу и файл данных (ALTER DATABASE…).
USE lab5;
GO

ALTER DATABASE lab5
ADD FILEGROUP Filegrouplab5
GO

ALTER DATABASE lab5
ADD FILE (
NAME = FGdata5,
FILENAME = '/DB/lab5/FGdata5.mdf',
SIZE = 10 MB,
MAXSIZE = UNLIMITED,
FILEGROWTH = 5%
)
TO FILEGROUP Filegrouplab5
GO


--4. Сделать созданную файловую группу файловой группой по умолчанию.
ALTER DATABASE lab5
MODIFY FILEGROUP Filegrouplab5 DEFAULT
GO


--5. (*) Создать еще одну произвольную таблицу.
CREATE TABLE BOOKS
(
    id     INT NOT NULL IDENTITY (1, 1)
        CONSTRAINT I_books PRIMARY KEY,
    author VARCHAR(255),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
)ON [PRIMARY]
GO


--6. (*) Удалить созданную вручную файловую группу.
--
-- CREATE UNIQUE CLUSTERED INDEX I_books
--     ON dbo.BOOKS (id)
--     WITH (DROP_EXISTING = ON)
--     ON [PRIMARY]
-- GO

ALTER DATABASE lab5
MODIFY FILEGROUP [PRIMARY] DEFAULT;
GO

ALTER DATABASE lab5
REMOVE FILE FGdata5;
GO


ALTER DATABASE lab5
REMOVE FILEGROUP Filegrouplab5;
GO


-- 7. Создать схему, переместить в нее одну из таблиц,удалить схему.
CREATE SCHEMA mySchema;
GO

ALTER SCHEMA mySchema TRANSFER users;
GO

DROP TABLE mySchema.users;

DROP SCHEMA mySchema;
GO

