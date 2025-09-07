# library-management-sql
A simple library management system built using SQL with stored procedures, triggers, and functions
# Library Management System-
- Database design (tables with primary & foreign keys)
- Stored Procedures (borrow & return books)
- Triggers (stock control)
- Functions (fine calculation)
- Transactions and Error Handling

 Features
- Students can borrow and return books.
- Automatic stock update on borrow/return.
- Fine calculation if return is late.
- Payment mode stored for returns.

 Quick Test
```sql
CALL sp_borrow_book(1, 1);
CALL sp_return_book(1, DATE_ADD(CURDATE(), INTERVAL 10 DAY), 'Cash');
