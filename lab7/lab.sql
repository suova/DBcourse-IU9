USE master;
GO


IF DB_ID('lab7') IS NOT NULL
DROP DATABASE lab7;

CREATE DATABASE lab7
ON ( NAME =data7,
    FILENAME = '/DB/lab7/data7.mdf',
    SIZE = 10,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5 )
LOG ON
( NAME = log7,
    FILENAME = '/DB/lab7/log7.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB );
GO

-- Создать представление на основе одной из таблиц задания 6
IF OBJECT_ID(N'USERS') is NOT NULL
 DROP TABLE USERS
GO

CREATE TABLE USERS (
    id INT IDENTITY (1, 1) PRIMARY KEY ,
	email VARCHAR(100) NOT NULL,
	salary INT
);
GO
INSERT INTO dbo.USERS VALUES ('eMAIL',12345 );
GO
INSERT INTO dbo.USERS VALUES ('mail',99 );
GO

IF OBJECT_ID(N'salaryOK') is NOT NULL
 DROP View salaryOK
GO

CREATE VIEW salaryOK
          AS SELECT *
          FROM USERS
          WHERE salary > 100;
GO

SELECT * FROM salaryOK;
GO


--Создать представление на основе полей обеих связанных таблиц задания 6

IF OBJECT_ID(N'Orders') is NOT NULL
 DROP Table Orders
GO
IF OBJECT_ID (N'view_product_price') IS NOT NULL
   DROP VIEW view_product_price ;
GO
IF OBJECT_ID(N'Products') is NOT NULL
 DROP TABLE Products
GO
IF OBJECT_ID(N'Customers') is NOT NULL
 DROP TABLE Customers
GO
IF OBJECT_ID(N'OrdersProductsCustomers') is NOT NULL
 DROP View OrdersProductsCustomers
GO

CREATE TABLE Products
(
    Id INT IDENTITY PRIMARY KEY,
    ProductName NVARCHAR(30) NOT NULL,
    Manufacturer NVARCHAR(20) NOT NULL,
    ProductCount INT DEFAULT 0,
    Price MONEY NOT NULL
);
GO

CREATE TABLE Customers
(
    Id INT IDENTITY PRIMARY KEY,
    FirstName NVARCHAR(30) NOT NULL
);
GO

CREATE TABLE Orders
(
    Id INT IDENTITY PRIMARY KEY,
    ProductId INT NOT NULL REFERENCES Products(Id) ON DELETE CASCADE,
    CustomerId INT NOT NULL REFERENCES Customers(Id) ON DELETE CASCADE,
    CreatedAt DATE NOT NULL,
    ProductCount INT DEFAULT 1,
    Price MONEY NOT NULL
);
GO

CREATE VIEW OrdersProductsCustomers AS
SELECT Orders.CreatedAt AS OrderDate,
        Customers.FirstName AS Customer,
        Products.ProductName As Product
FROM Orders INNER JOIN Products ON Orders.ProductId = Products.Id
INNER JOIN Customers ON Orders.CustomerId = Customers.Id
GO

--Создать индекс для одной из таблиц задания 6,включив в него дополнительные неключевые поля

--Производительность повышается благодаря тому, что оптимизатор запросов может найти все значения
-- столбцов в этом индексе; при этом нет обращения к данным таблиц или кластеризованных индексов,
-- что приводит к меньшему количеству дисковых операций ввода-вывода.
CREATE NONCLUSTERED INDEX IX_Customers_id
ON Customers (Id)
INCLUDE (FirstName);
GO


--Создать индексированное представление
SET NUMERIC_ROUNDABORT OFF; --eсли при выполнении запроса активны разные параметры SET,
                            -- выполнение одного и того же выражения может дать разные
                            -- результаты в Компонент Database Engine

SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT,
   QUOTED_IDENTIFIER, ANSI_NULLS ON;
GO


CREATE VIEW view_product_price
    WITH SCHEMABINDING -- Привязывает представление к схеме базовой таблицы или таблиц.
                        -- нельзя изменить базовую таблицу или таблицы таким способом,
                        -- который может повлиять на определение представления.
    AS SELECT Id, ProductName, Price
    FROM dbo.Products;
GO

--Создание уникального кластеризованного индекса для представления повышает
-- производительность запросов, т. к. представление хранится в базе данных
-- так же, как и таблица с кластеризованным индексом.
CREATE UNIQUE CLUSTERED INDEX IDX_product_price
   ON view_product_price (Id, ProductName,Price);
GO
