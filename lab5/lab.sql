USE master;
GO



IF DB_ID('lab5') IS NOT NULL
DROP DATABASE lab5;

CREATE DATABASE lab5
ON ( NAME =data5,
    FILENAME = '/DB/lab5/data5.mdf',
    SIZE = 10,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5 )
LOG ON
( NAME = log5,
    FILENAME = '/DB/lab5/log5.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB );
GO



USE lab5;
GO

IF OBJECT_ID(N'USERS') is NOT NULL
 DROP TABLE USERS

CREATE TABLE USERS (
    id INT IDENTITY (1, 1),
	name VARCHAR(80) NOT NULL,
	email VARCHAR(100) NOT NULL
);
GO



ALTER DATABASE lab5
ADD FILEGROUP Filegroup5;
GO

ALTER DATABASE lab5
ADD FILE
(
    NAME = FGdata5,
    FILENAME = '/DB/lab5/FGdata5.ndf',
    SIZE = 5MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5%
)
TO FILEGROUP Filegroup5;
GO



ALTER DATABASE lab5
MODIFY FILEGROUP Filegroup5 DEFAULT;
GO



CREATE TABLE BOOKS (
    id INT IDENTITY (1, 1),
	title VARCHAR(100) NOT NULL,
	author VARCHAR(100) NOT NULL
) ;
GO



CREATE CLUSTERED INDEX IX_BOOKS_id
    ON BOOKS (id)
	ON [PRIMARY];
GO

ALTER DATABASE lab5
MODIFY FILEGROUP [PRIMARY] DEFAULT;
GO

ALTER DATABASE lab5
REMOVE FILE FGdata5;
GO

ALTER DATABASE lab5
REMOVE FILEGROUP Filegroup5;
GO



CREATE SCHEMA lab5Schema;
GO

ALTER SCHEMA lab5Schema TRANSFER BOOKS;
GO

DROP TABLE lab5Schema.BOOKS;
GO

DROP SCHEMA lab5Schema;
GO
