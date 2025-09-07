-- Project :- Library Management System (LMS)
/* *features included :- 
   1. tables for books, members, borrowed books and payments
   2. functions, stored procedures
   3. views for reports
   4. sample data + expected output
*/
-- step 1:- create database & tables :-
drop database librarydb;
create database librarydb;
use librarydb;

-- member table :-
create table members (
member_id int auto_increment primary key,
name varchar (50),
city varchar (50),
join_date datetime default current_timestamp
);
-- books table :-
create table books (
book_id int auto_increment primary key,
title varchar(200),
author varchar(100),
price decimal (10,2),
stock int
);
-- borrow table :-
create table borrow(
borrow_id int auto_increment primary key,
member_id int,
book_id int,
borrow_date datetime default current_timestamp,
return_date date,
status varchar(20) default "borrowed",
foreign key (member_id) references members(member_id),
foreign key (book_id) references books(book_id)
);
-- payments table :-
create table payments(
payment_id int auto_increment primary key,
member_id int,
amount decimal (10,2),
payment_date datetime default current_timestamp,
payment_mode varchar (50),
foreign key (member_id) references members (member_id)
);

-- step 2: insert sample data:-
-- members:
insert into members(name, city) values
("ravi kumar", "mumbai"),
("sneha joshi", "pune"),
("karan mehta", "delhi");
-- books:
insert into books (title, author, price, stock)values
("sql for beginners", "john smith", 500, 5),
("data structure in c", "N.wirth", 400, 3),
("operating system concepts" , "silber s chatz", 700, 2),
("database design", "elmasri",600, 4);

-- step 3: function- late return fine
delimiter //
create function
fn_calculate_fine (p_borrow_date date, p_return_date date)
returns decimal (10,2)
deterministic
begin
     declare v_days int;
     declare v_fine decimal (10,2);
set v_days = datediff (p_return_date, p_borrow_date);

if v_days > 7 then
   set v_fine = (v_days - 7) * 10;
   -- rs 10 per extra day
   else 
       set v_fine = 0;
end if;
  return v_fine;
  end //
  delimiter ;

-- step 4: stored procedure - borrow book:
delimiter //
create procedure sp_borrow_book(
      in p_member_id int,
      in p_book_id int
)
begin
     declare v_stock int;
     
     -- check stock
     select stock into v_stock
     from books
     where book_id = p_book_id;
     
     if v_stock > 0 then
        -- insert borrow record
        insert into borrow (member_id, book_id)
        values (p_member_id, p_book_id);
        
        -- decrease stock
        update books
        set stock = stock -1
        where book_id = p_book_id;
        
        select "book borrowed successfully" as message;
        else
             select "book not available" as message;
             end if;
	end //
    delimiter ;
    
-- step 5: stored procedure - return book:
delimiter //
create procedure sp_return_book(
in p_borrow_id int,
in p_return_date date,
in p_payment_mode varchar(50)
)
begin
     declare v_borrow_date date;
     declare v_member_id int;
     declare v_book_id int;
     declare v_fine decimal (10,2);

-- get borrow details
select borrow_date , member_id, book_id
into v_borrow_date, v_member_id, v_book_id
from borrow where borrow_id = p_borrow_id;

-- calculate fine
set v_fine = fn_calculate_fine (v_borrow_date, p_return_date);

-- update borrow table
update borrow
set return_date = p_return_date,
status= "returned"
where borrow_id = p_borrow_id;

-- increase stock back
update books set stock = stock + 1
where book_id = v_book_id;

-- insert payment if fine > 0
   if v_fine > 0 then 
   insert into payments (member_id, amount, payment_mode)
   values (v_member_id, v_fine, p_payment_mode);
   end if;
   
-- show result :
select p_borrow_id as borrow_id, v_fine as fine_charged,
p_payment_mode as payment_mode;

end //
delimiter ;

-- step 6:- test the project:
-- borrow a book (ravi borrows sql for beginners)
call sp_borrow_book(1,1);

-- ravi returns the book after 10 days
set @return_date := date_add(curdate(), interval 10 day);

call sp_return_book(1, @return_date, 'cash');

-- step 7:- views for reports:
-- borrow summary:
create view v_borrow_summary as
select b.borrow_id, m.name as
member_name, bk.title, b.borrow_date,
b.return_date, b.status
from borrow b
join members m on b.member_id = m.member_id
join books bk on b.book_id = bk.book_id;

-- member payment summary:
create view v_member_payments as
select m.member_id, m.name, sum(p.amount)
as total_fines, count(p.payment_id)
as payments_made
from members m
left join payments p on m.member_id = p.member_id
group by m.member_id, m.name;

select * from books;
select * from borrow;






      




