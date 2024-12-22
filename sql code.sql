use library_management_project;
select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);

DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

-- CRUD TASK
-- CREATE A NEW BOOK RECORD
INSERT  into books (isbn, book_title, category, rental_price, status, author, publisher)
values ( 978-1-60129-456-2 ,'To Kill a Mockinfbird', 'classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co'); 
select * from books where book_title='To Kill a Mockinfbird';

-- update an existing member's address
update members
set member_address = '125 Main St CHD'
where member_id = 'C101';
select* from members;

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_status 
where issued_id = 'IS121';
select * from issued_status;

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select issued_book_name from
issued_status where issued_emp_id='E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book
select  issued_emp_id, count(issued_emp_id) as total_count from issued_status
group by issued_emp_id having total_count >1 ;

-- OR

SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1;

-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
create table Total_book_issued_cnt as 
select books.book_title as book_name, count(issued_id) as total_book_issued from books 
join issued_status as ibs
on books.isbn = ibs.issued_book_isbn
group by book_name ;

-- Task 7. Retrieve All Books in a Specific Category
select book_title , category from books
where category = 'classic';

-- Task 8: Find Total Rental Income by Category:
select b.category , sum(rental_price) 
from books as b
join issued_status as ist
on b.isbn = ist.issued_book_isbn
group by category;

-- Task 9: List Members Who Registered in the Last 180 Days:
SELECT * FROM members 
WHERE reg_date >= CURDATE() - INTERVAL 180 DAY;

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

select b. manager_id, b.branch_address, e1.emp_id ,e1.emp_name, e2.emp_name as manager_name from branch as b 
join employees as e1
on b.branch_id = e1.branch_id
join employees as e2
on b.manager_id= e2.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

create table expensive_books as
select * from books where rental_price > 7;

-- Task 12: Retrieve the List of Books Not Yet Returned
select *   from issued_status as iss 
left join return_status as ret
on ret.issued_id= iss.issued_id
where  return_id is null;



INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', curdate() - INTERVAL 24 day,  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURDATE() - INTERVAL 13 day,  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', curdate() - INTERVAL 7 day,  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', curdate() - INTERVAL 32 day,  '978-0-375-50167-0', 'E101');

-- Adding new column in return_status

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;
select * from issued_status;
select * from members;
select * from books;

/*Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period).
 Display the member's_id, member's name, book title, issue date, and days overdue.*/

select m.member_id, m.member_name, b.book_title, ist.issued_date, 
datediff(curdate() ,ist.issued_date) as total_days
from issued_status as ist
join members as m
on ist.issued_member_id = m.member_id
join books as b
on b.isbn = ist.issued_book_isbn
left join return_status as rs
on rs.issued_id = ist.issued_id
where rs.return_date IS null and
datediff(curdate() ,ist.issued_date)  > 30
order by 1;

/* Task 14: Update Book Status on Return
 Write a query to update the status of books in the books table to "Yes" when they are 
returned (based on entries in the return_status table). */

-- there are to way fist is to mannually update the table and another one is procedural
select * from issued_status
where issued_book_isbn = '978-0-307-58837-1';
select* from books;
update books
set status = 'yes'
where isbn ='978-0-307-58837-1';

select * from return_status
where issued_id = 'IS135';
-- so we hat to update return table by inserting the value
insert into return_status(return_id, issued_id, return_date, book_quality)
values ('RS120', 'IS135', curdate(), 'Good');
-- procedural store is in file sql fie 3

/* Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of
 books issued, the number of books returned, and the total revenue generated from book rentals.*/
create table branch_reports as
select b.manager_id,b.branch_id, count(ist.issued_id), count(rs.return_id), sum(rental_price)
from issued_status as ist
join employees as emp
on emp.emp_id = ist.issued_emp_id
join branch as b 
on  b.branch_id = emp.branch_id
join return_status as rs
on ist.issued_id = rs.return_id
join books as bk
on bk.isbn = ist.issued_book_isbn
group by 1,2;

/* Task 16: CTAS: Create a Table of Active Members
 Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing 
 members who have issued at least one book in the last 2 months. */

 create table active_member as
 select* from members
 where member_id in
 (select distinct issued_member_id  from issued_status
 where issued_date >= date_sub(curdate(), interval 2 month) );
 select * from active_member;
 
/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.*/
 
 select emp.emp_name,b.branch_id, b.branch_address, count(ist.issued_book_name) as total_books
 from branch as b
 join employees as emp
 on b.branch_id= emp.branch_id
 join issued_status as ist
 on ist.issued_emp_id= emp.emp_id
 group by issued_emp_id order by total_books desc limit 3;
 
/* Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status
 "damaged" in the books table. Display the member name, book title, and the number of 
 times they've issued damaged books.*/
 select ist.issued_member_id , m.member_name , book_quality 
 from members as m
 join issued_status as ist
 on m.member_id = ist.issued_member_id
 join return_status as rs
 on ist.issued_id= rs.issued_id
 where book_quality = 'damaged';
 

