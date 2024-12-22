use library_management_project;

-- procedure store

delimiter $$
create PROCEDURE add_return_records
(in p_return_id varchar(20),in p_issued_id varchar(20),in p_book_quality varchar(20))
BEGIN
declare v_isbn varchar(50);
declare v_name varchar(80);

-- Insert a new return record
insert into return_status(return_id, issued_id, return_date, book_quality)
values( p_return_id, p_issued_id, curdate() ,p_book_quality);
-- Retrieve ISBN and book name for the issued record
select issued_book_isbn, issued_book_name into v_isbn,v_name from issued_status
where issued_id = p_issued_id;
 -- Update the status of the book to 'yes'
update books
set status ='yes'
where isbn = v_isbn;
-- Notify about the returned book
select concat('Thankyou for returning thr book',v_name)as message;
END $$

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8';
SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-375-41398-8';

SELECT * FROM return_status
WHERE issued_id='IS134';
-- CALL add_return_records('RS148','IS134','GOOD');

SELECT * FROM books
WHERE isbn = '978-0-7432-7357-1';
SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-7432-7357-1';
SELECT * FROM return_status
WHERE issued_id = 'IS136';

-- CALL add_return_records('RS149','IS136','GOOD');


select* from branch_reports