-- Create Database
CREATE DATABASE OnlineBookstore;

-- Switch to the database
\c OnlineBookstore;

-- Create Tables
DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);
DROP TABLE IF EXISTS customers;
CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);
DROP TABLE IF EXISTS orders;
CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);

SELECT * FROM Books;
SELECT * FROM Customers;
SELECT * FROM Orders;


-- 1) Retrieve all books in the "Fiction" genre:

SELECT * FROM books WHERE genre IN('Fiction');


-- 2) Find books published after the year 1950:

SELECT title, genre, published_year FROM books WHERE published_year > 1950

-- 3) List all customers from the Canada:

SELECT name, country FROM customers WHERE country IN('Canada')

-- 4) Show orders placed in November 2023:

SELECT * FROM orders WHERE order_date > '2023-11-01' AND order_date < '2023-11-30'

-- 5) Retrieve the total stock of books available:

SELECT title, SUM(stock) AS total_stock FROM books
GROUP BY title ORDER BY total_stock DESC

-- 6) Find the details of the most expensive book:

SELECT * FROM books ORDER BY price DESC

-- 7) Show all customers who ordered more than 1 quantity of a book:

SELECT customer_id, COUNT(quantity) FROM orders
GROUP BY customer_id
HAVING COUNT(quantity) > 1

-- 8) Retrieve all orders where the total amount exceeds $20:

SELECT order_id, customer_id,book_id, total_amount FROM orders WHERE total_amount > 30

-- 9) List all genres available in the Books table:

SELECT DISTINCT genre FROM books

-- 10) Find the book with the lowest stock:

SELECT title, genre, stock FROM books ORDER BY stock ASC

-- 11) Calculate the total revenue generated from all orders:

SELECT SUM(total_amount) AS total_revenue FROM orders

-- Advance Questions : 

-- 1) Retrieve the total number of books sold for each genre:

SELECT b.genre, SUM(o.quantity) AS books_solds
FROM books b JOIN orders o
ON b.book_id=o.book_id
GROUP BY b.genre;

-- OR

SELECT DISTINCT b.genre, SUM(o.quantity) OVER (PARTITION BY b.genre) AS total_quantity_sold
FROM books b JOIN orders o
ON b.book_id=o.book_id;

-- 2) Find the average price of books in the "Fantasy" genre:

SELECT AVG(price) AS Average_price_of_fantasy FROM books WHERE genre='Fantasy';


-- 3) List customers who have placed at least 2 orders:

SELECT customer_id, COUNT(order_id) AS at_least_2_order FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) >= 2 ORDER BY customer_id ASC;


-- OR

SELECT c.name, o.customer_id, COUNT(o.order_id) AS at_least_2_order
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY o.customer_id, c.name
HAVING COUNT(o.order_id) >= 2 ORDER BY o.customer_id

-- 4) Find the most frequently ordered book

SELECT book_id, COUNT(order_id) most_frequently_ordered FROM orders
GROUP BY book_id  ORDER BY most_frequently_ordered DESC

-- OR

SELECT b.title AS Book_Title, o.book_id, COUNT(o.order_id) most_frequently_ordered FROM books b
JOIN orders o ON
b.book_id=o.book_id
GROUP BY o.book_id, b.title
ORDER BY most_frequently_ordered DESC

-- 5) Show the top 3 most expensive books of 'Fantasy' Genre :

SELECT genre, price FROM books 
WHERE genre='Fantasy' 
ORDER BY price DESC LIMIT 3


-- 6) Retrieve the total quantity of books sold by each author:

SELECT b.book_id, b.author, SUM(o.quantity) total_quantity_sold FROM books b
JOIN orders o ON
b.book_id=o.book_id
GROUP BY b.author, b.book_id
ORDER BY total_quantity_sold DESC

-- 7) List the cities where customers who spent over $30 are located:

SELECT c.city, o.total_amount FROM customers c
JOIN orders o ON
c.customer_id=o.customer_id
WHERE o.total_amount>30

-- 8) Find the customer who spent the most on orders:

SELECT o.customer_id, c.name, SUM(o.total_amount) AS Most_Spent_in_order 
FROM orders o
JOIN customers c ON
o.customer_id=c.customer_id
GROUP BY o.customer_id, c.name
ORDER BY Most_Spent_in_order DESC LIMIT 1

--9) Calculate the stock remaining after fulfilling all orders:

SELECT b.book_id, b.title, b.stock, COALESCE(SUM(o.quantity),0),
b.stock-COALESCE(SUM(o.quantity),0) AS remaining_quantity
FROM books b LEFT JOIN orders o
ON b.book_id=o.book_id
GROUP BY b.book_id


