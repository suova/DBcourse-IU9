USE master;
GO

IF DB_ID('lab8') IS NOT NULL
    DROP DATABASE lab8;
GO

CREATE DATABASE lab8
    ON (
    NAME = lab8data,
    FILENAME = '/DB/lab8/data8.mdf',
    SIZE = 10 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5% )
    LOG ON (
    NAME = lab8log,
    FILENAME = '/DB/lab7/log8.ldf',
    SIZE = 5 MB,
    MAXSIZE = 25 MB,
    FILEGROWTH = 5 MB );
GO

USE lab8
GO

IF OBJECT_ID('users') is NOT NULL
    DROP TABLE users
GO

CREATE TABLE users
(
    ID       INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    email    VARCHAR(128)           NOT NULL UNIQUE,
    userName     VARCHAR(128),
    phone    VARCHAR(12),
    money    INT CHECK (0 < money AND money < 100000)
);

INSERT INTO users( email, userName, money)
VALUES ('z@yandex.ru', 'DB', 129)
GO

INSERT INTO users( email, userName, phone, money)
VALUES ( 'k@bmstu.ru', 'KS', '73028374335', 220)
GO

INSERT INTO users( email, userName, money)
VALUES ('v@bmstu.ru', 'LL', 230)
GO

SELECT *
FROM users

-- 1. Создать хранимую процедуру, производящую выборку из некоторой таблицы и возвращающую результат
-- выборки в виде курсора.

IF OBJECT_ID('choosePerson') IS NOT NULL
    DROP PROCEDURE choosePerson
GO

CREATE PROCEDURE choosePerson @chooseCursor CURSOR VARYING OUTPUT -- Если тип данных cursor указан для
                                                    -- параметра, то как ключевое слово VARYING, так и
                                                    -- ключевое слов OUTPUT должны быть указаны для этого
                                                    -- параметра в определении процедуры. Параметр может
                                                    -- быть указан только как выходной, однако если в
                                                    -- объявлении параметра указано ключевое слово VARYING,
                                                    -- типом данных должен быть cursor , при этом также
                                                    -- следует указать ключевое слово OUTPUT.
AS
    SET @chooseCursor = CURSOR  --Курсоры являются расширением результирующих наборов, которые
                                -- предоставляют механизм, позволяющий обрабатывать одну строку или
                                -- небольшое их число за один раз
        FORWARD_ONLY STATIC FOR
        SELECT userName, phone
        FROM users
    OPEN @chooseCursor
GO

DECLARE @chooseCursor CURSOR     --Затем выполните пакет, который объявляет локальную
                                -- переменную курсора, выполняет процедуру, присваивающую курсор
                                -- локальной переменной, и затем выбирает строки из курсора.
EXEC choosePerson @chooseCursor OUTPUT

FETCH NEXT FROM @chooseCursor
WHILE (@@FETCH_STATUS = 0)
    BEGIN
        FETCH NEXT FROM @chooseCursor
    END

CLOSE @chooseCursor
DEALLOCATE @chooseCursor
GO


-- 2. Модифицировать хранимую процедуру п.1. таким образом, чтобы выборка осуществлялась с
-- формированием столбца, значение которого формируется пользовательской функцией.

IF OBJECT_ID('moneyLeft') IS NOT NULL
    DROP FUNCTION moneyLeft
GO

CREATE FUNCTION moneyLeft(@money int)
    RETURNS int AS
BEGIN
    DECLARE @moneyLeft int
    SET @moneyLeft = @money - 1234
    RETURN @moneyLeft
END
GO

IF OBJECT_ID('howMuchMoneyLeft') IS NOT NULL
    DROP PROCEDURE howMuchMoneyLeft
GO

CREATE PROCEDURE howMuchMoneyLeft @chooseCursor CURSOR VARYING OUTPUT
AS
    SET @chooseCursor = CURSOR
        FORWARD_ONLY STATIC FOR
        SELECT userName, email, phone, dbo.moneyLeft(money) AS money
        FROM users
    OPEN @chooseCursor
GO

DECLARE @chooseCursor CURSOR
EXEC howMuchMoneyLeft @chooseCursor OUTPUT

FETCH NEXT FROM @chooseCursor
WHILE (@@FETCH_STATUS = 0)
    BEGIN
        FETCH NEXT FROM @chooseCursor
    END

CLOSE @chooseCursor
DEALLOCATE @chooseCursor
GO


-- 3. Создать хранимую процедуру, вызывающую процедуру  п.1., осуществляющую прокрутку возвращаемого
-- курсора и выводящую сообщения, сформированные из записей при выполнении условия, заданного еще одной
-- пользовательской функцией.


IF OBJECT_ID('choosePerson') IS NOT NULL
    DROP PROCEDURE choosePerson
GO

CREATE PROCEDURE selectParticipants @chooseCursor CURSOR VARYING OUTPUT
AS
    SET @chooseCursor = CURSOR
        FORWARD_ONLY STATIC FOR
        SELECT userName, email, phone
        FROM users
    OPEN @chooseCursor
GO


IF OBJECT_ID('isMoreThanHundred') IS NOT NULL
    DROP FUNCTION dbo.isMoreThanHundred
GO

CREATE FUNCTION dbo.isMoreThanHundred(@money int)
    RETURNS BIT AS
BEGIN
    DECLARE @isMore BIT
    IF (@money > 200)
        SET @isMore = 1
    ELSE
        SET @isMore = 0
    RETURN @isMore
END
GO


IF OBJECT_ID('printRich') IS NOT NULL
    DROP PROCEDURE printRich
GO

CREATE PROCEDURE printRich
AS
DECLARE @chooseCursor CURSOR
DECLARE @name varchar(32)
DECLARE @email varchar(128)
DECLARE @phone varchar(128)
DECLARE @money int
    EXEC dbo.choosePerson @chooseCursor OUTPUT

    FETCH NEXT FROM @chooseCursor INTO @name, @email, @phone, @money
    WHILE (@@FETCH_STATUS = 0)
        BEGIN
            IF (dbo.isMoreThanHundred(@money) = 1)
                PRINT @name + ' ' + @email + ' ' + COALESCE(@phone, 'no phone')
            FETCH NEXT FROM @chooseCursor INTO @name, @email, @phone, @money
        END

    CLOSE @chooseCursor
    DEALLOCATE @chooseCursor
GO

EXEC printRich
GO



-- 4. Модифицировать хранимую процедуру п.2. таким образом, чтобы выборка
-- формировалась с помощью табличной функции.

IF OBJECT_ID('moneyLeft') IS NOT NULL
    DROP FUNCTION moneyLeft
GO

CREATE FUNCTION moneyLeft(@money int)
    RETURNS int AS
BEGIN
    DECLARE @moneyLeft int
    SET @moneyLeft = @money- 123
    RETURN @moneyLeft
END
GO

IF OBJECT_ID('returnTable') IS NOT NULL
    DROP FUNCTION returnTable
GO

CREATE FUNCTION returnTable()
    RETURNS TABLE AS
        RETURN
            (
                SELECT userName, email, phone, dbo.moneyLeft(money) AS money
                FROM users
            )
GO


IF OBJECT_ID('howMuchMoneyLeft') IS NOT NULL
    DROP PROCEDURE howMuchMoneyLeft
GO

CREATE PROCEDURE howMuchMoneyLeft @chooseCursor CURSOR VARYING OUTPUT
AS
    SET @chooseCursor = CURSOR
        FORWARD_ONLY STATIC FOR
        SELECT userName, email, money
        FROM returnTable()
    OPEN @chooseCursor
GO

DECLARE @chooseCursor CURSOR
EXEC howMuchMoneyLeft @chooseCursor OUTPUT

FETCH NEXT FROM @chooseCursor
WHILE (@@FETCH_STATUS = 0)
    BEGIN
        FETCH NEXT FROM @chooseCursor
    END

CLOSE @chooseCursor
DEALLOCATE @chooseCursor
GO
