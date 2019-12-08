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

go

use lab9;
go



if OBJECT_ID(N'authors') is not null
	drop table authors
go

create table authors(
	id				int PRIMARY KEY identity(1,1),
	name			varchar(35)
);
go


if OBJECT_ID(N'books') is not null
	drop table books;
go

create table books (
	title			varchar(254) PRIMARY KEY,
	authorsId		int DEFAULT(0),
	year			int,
	loading			int  DEFAULT(0),
    FOREIGN KEY (authorsId)
    REFERENCES authors (id)
	);
go


if OBJECT_ID(N'view_book') is not null
	drop view view_book;
go
create view view_book as
	select
		b.title  as title,
		a.name   as author,
		b.year   as year,
		b.loading as loading
	from books b
	inner join authors a
		on b.authorsId = a.id;
go

insert authors values
	('j kien'),
	('george martin'),
	('george orwell'),
	('an weir'),
	('herbert s'),
	('dan brown');
go

insert books values
	('the lord ', 1, 1954, 110),
	('the  back again', 3, 1937, 18),
	('a game ', 2, 1996, 37)
go

--2.Для представления пункта 2 задания 7 создать триггеры на вставку, удаление и добавление,
	--обеспечивающие возможность выполнения операций с данными непосредственно через представление.

if OBJECT_ID(N'view_book_insert') is not null
	drop trigger view_book_insert
go
create trigger view_book_insert
	on view_book
	instead of insert
	as
	begin
		insert into authors
			select distinct i.author
				from inserted as i
				where i.author not in (select name
					from authors)

		insert into books
			select
					i.title,
					(select id from authors as w where i.author = w.name),
					i.year,
					i.loading
				from inserted as i
	end
go


insert into view_book values
	('the man', 'herbert s', 1897, 6)
insert into view_book values
	('a spring', 'e martin', 2010, 79)
select * from view_book
select * from books
select * from authors




if OBJECT_ID(N'view_book_delete') is not null
	drop trigger view_book_delete
go
create trigger view_book_delete
	on view_book
	instead of delete
	as
	begin
		delete from books
			where title in (select d.title
				from deleted as d)
	end
go


delete from view_book
	where view_book.author in ('dan brown', 'an weir')
delete from view_book
	where view_book.title = 'the man'
delete from view_book
	where view_book.loading = 10
select * from view_book
select * from books



if OBJECT_ID(N'view_book_update') is not null
	drop trigger view_book_update
go
create trigger view_book_update
	on view_book
	instead of update
	as
	begin

		if UPDATE(title) or UPDATE(author)
			RAISERROR('[UPD TRIGGER]: "title" and "author" cant be modified', 16, 1)

		if UPDATE(year) or UPDATE(loading)
			update books
				set
					books.year = (select year from inserted where inserted.title = books.title),
					books.loading = (select loading from inserted where inserted.title = books.title)
				where books.title = (select title from inserted where inserted.title = books.title)

	end
go


update view_book
	set loading = 10
	where view_book.author = 'e martin';
update view_book
	set year = 2045
	where view_book.title = 'a spring';

select * from view_book
select * from books
