-- CREATE DATABASE --
CREATE DATABASE DBMSPRJ;
USE DBMSPRJ;

-- CREATING CUSTOMER TABLE --
CREATE TABLE Customer (
    Customer_ID INT AUTO_INCREMENT PRIMARY KEY,
    C_Name VARCHAR(100) NOT NULL,
    Contact_Info VARCHAR(200),
    Phone VARCHAR(15),
    Email VARCHAR(100) UNIQUE
) AUTO_INCREMENT = 1;

-- CREATING OWNER TABLE --
CREATE TABLE Owner (
    Owner_ID INT AUTO_INCREMENT PRIMARY KEY,
    Owner_Name VARCHAR(100) NOT NULL,
    City VARCHAR(50),
    Contact_Number VARCHAR(15)
) AUTO_INCREMENT = 1;

-- CREATING HOUSEBOAT TABLE --
CREATE TABLE Houseboat (
    HouseBoat_ID VARCHAR(10) PRIMARY KEY,
    H_Name VARCHAR(100) NOT NULL,
    Capacity INT NOT NULL,
    Owner_ID INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL, -- Added upfront
    FOREIGN KEY (Owner_ID) REFERENCES Owner(Owner_ID)
);

-- CREATING STAFF TABLE --
CREATE TABLE Staff (
    Staff_ID INT AUTO_INCREMENT PRIMARY KEY,
    HouseBoat_ID VARCHAR(10) NOT NULL,
    S_Name VARCHAR(100),
    Role VARCHAR(50),
    FOREIGN KEY (HouseBoat_ID) REFERENCES Houseboat(HouseBoat_ID)
) AUTO_INCREMENT = 1;

-- CREATING FEEDBACK TABLE --
CREATE TABLE Feedback (
    Feedback_ID INT AUTO_INCREMENT PRIMARY KEY,
    Customer_ID INT NOT NULL,
    Comments TEXT,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
) AUTO_INCREMENT = 1;

-- CREATING RENTAL TABLE --
CREATE TABLE Rental (
    Rental_ID INT AUTO_INCREMENT PRIMARY KEY,
    Customer_ID INT NOT NULL,
    HouseBoat_ID VARCHAR(10) NOT NULL,
    Rental_Date DATE NOT NULL,
    Return_Date DATE NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    Feedback_ID INT, -- Allowing NULL by default
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    FOREIGN KEY (HouseBoat_ID) REFERENCES Houseboat(HouseBoat_ID),
    FOREIGN KEY (Feedback_ID) REFERENCES Feedback(Feedback_ID)
) AUTO_INCREMENT = 1;

-- CREATING PAYMENT TABLE --
CREATE TABLE Payment (
    Payment_ID INT AUTO_INCREMENT PRIMARY KEY,
    Customer_ID INT NOT NULL,
    Payment_Method VARCHAR(50) NOT NULL,
    Payment_Status VARCHAR(50) CHECK (Payment_Status IN ('Paid', 'Pending')),
    Rental_ID INT NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    FOREIGN KEY (Rental_ID) REFERENCES Rental(Rental_ID)
) AUTO_INCREMENT = 1;




-- SAMPLE SELECT QUERIES --
SELECT * FROM Customer;
SELECT * FROM Houseboat;
SELECT * FROM Feedback;
SELECT * FROM Rental;
SELECT * FROM Payment;
select * from owner;
select * from staff;

-- TABLE STRUCTURES --
DESCRIBE Customer;
DESCRIBE Owner;
DESCRIBE Houseboat;
DESCRIBE Feedback;
DESCRIBE Rental;
DESCRIBE Payment;


-- INSERTING DATA INTO CUSTOMER TABLE --
INSERT INTO Customer (C_Name, Contact_Info, Phone, Email)
VALUES
('Alice Smith', '123 Main St, Springfield', '555-123-4567', 'alice@example.com'),
('Bob Johnson', '456 Elm St, Riverdale', '555-234-5678', 'bob@example.com'),
('Charlie Brown', '789 Oak St, Centerville', '555-345-6789', 'charlie@example.com'),
('Diana Prince', '321 Maple St, Brookfield', '555-456-7890', 'diana@example.com'),
('Eve Adams', '654 Pine St, Springfield', '555-567-8901', 'eve@example.com');

-- INSERTING DATA INTO OWNER TABLE --
INSERT INTO Owner (Owner_Name, City, Contact_Number)
VALUES
('Robert Johnson', 'Springfield', '555-555-1111'),
('Linda Williams', 'Riverdale', '555-555-2222'),
('William Brown', 'Centerville', '555-555-3333'),
('Elizabeth Miller', 'Brookfield', '555-555-4444');

-- INSERTING DATA INTO HOUSEBOAT TABLE --
INSERT INTO Houseboat (HouseBoat_ID, H_Name, Capacity, Owner_ID, Amount)
VALUES
('HB001', 'Sunset', 10, 1, 500.00),
('HB002', 'Sunrise', 8, 2, 400.00),
('HB003', 'MoonLight', 12, 3, 600.00),
('HB004', 'Star light', 15, 4, 700.00);

-- INSERTING DATA INTO STAFF TABLE --
INSERT INTO Staff (HouseBoat_ID, S_Name, Role)
VALUES
('HB001', 'John Doe', 'Captain'),
('HB002', 'Sarah Lee', 'Chef'),
('HB003', 'Michael Scott', 'First Mate'),
('HB004', 'Emma Stone', 'Deckhand');

-- INSERTING DATA INTO FEEDBACK TABLE --
INSERT INTO Feedback (Customer_ID, Comments, Rating)
VALUES
(1, 'Great experience, loved the houseboat!', 5),
(2, 'Very relaxing and well-maintained.', 4),
(3, 'Good service but a bit pricey.', 3),
(4, 'Excellent hospitality and views.', 5),
(5, 'Not up to the mark.', 2);

-- INSERTING DATA INTO RENTAL TABLE --
INSERT INTO Rental (Customer_ID, HouseBoat_ID, Rental_Date, Return_Date, Amount, Feedback_ID)
VALUES
(1, 'HB001', '2024-12-01', '2024-12-03', 1000.00,null),
(2, 'HB002', '2024-12-05', '2024-12-07', 800.00, 2),
(3, 'HB003', '2024-12-08', '2024-12-10', 1200.00, 3),
(4, 'HB004', '2024-12-12', '2024-12-14', 1400.00, 4);


-- INSERTING DATA INTO PAYMENT TABLE --
INSERT INTO Payment (Customer_ID, Payment_Method, Payment_Status, Rental_ID)
VALUES
(1, 'Credit Card', 'Paid', 1),
(2, 'PayPal', 'Pending', 2),
(3, 'Cash', 'Paid', 3),
(4, 'Debit Card', 'Paid', 4);


SELECT * FROM Customer;
SELECT * FROM Houseboat;
SELECT * FROM Feedback;
SELECT * FROM Rental;
SELECT * FROM Payment;
select * from owner;
select * from staff;


-- QUERIES --

-- GROUPBY WITH HAVING 
SELECT Feedback.Rating, AVG(Rental.Amount) AS Avg_Amount
FROM Feedback
JOIN Rental ON Feedback.Feedback_ID = Rental.Feedback_ID
GROUP BY Feedback.Rating
HAVING AVG(Rental.Amount) > 3.5;

-- ORDER BY
-- List all customers in descending order of their names.
SELECT * FROM Customer
ORDER BY C_Name DESC;

-- JOIN
-- Retrieve customer names and the houseboat names they rented.
SELECT Customer.C_Name, Houseboat.H_Name
FROM Customer
JOIN Rental ON Customer.Customer_ID = Rental.Customer_ID
JOIN Houseboat ON Rental.HouseBoat_ID = Houseboat.HouseBoat_ID;


-- Aggregate Functions -- 
-- Find the total rental amount paid for all houseboats.
SELECT SUM(Amount) AS Total_Amount
FROM Rental;

-- Query Having Boolean Operators
-- Find all customers who rented a houseboat but whose payments are pending.
SELECT Customer.C_Name, Payment.Payment_Status
FROM Customer
JOIN Payment ON Customer.Customer_ID = Payment.Customer_ID
WHERE Payment.Payment_Status = 'Pending';

-- Query Having Arithmetic Operators
-- Calculate the average daily rental amount for each rental.
SELECT Rental_ID, Amount / (RETURN_DATE - RENTAL_DATE) AS Avg_Daily_Rent
FROM Rental;

-- A Search Query Using String Operators
-- Find feedback comments containing the word "excellent" (case-insensitive).
SELECT *
FROM Feedback
WHERE LOWER(Comments) LIKE '%excellent%';

-- Usage of TO_CHAR, EXTRACT
-- Retrieve the rental month and format the rental date for display.
SELECT Rental_ID, DATE_FORMAT(Rental_Date, '%d-%b-%Y') AS Rental_Date, 
	MONTH(Rental_Date) AS Rental_Month FROM Rental LIMIT 0, 1000;

 -- BETWEEN, IN, NOT BETWEEN, NOT IN
-- Find customers whose rental amounts are between 1000 and 2000 but exclude specific houseboats.
SELECT Customer.C_Name, Rental.Amount FROM Customer
JOIN Rental ON Customer.Customer_ID = Rental.Customer_ID
WHERE Rental.Amount BETWEEN 1000 AND 2000
AND Rental.HouseBoat_ID NOT IN ('HB003', 'HB005');


-- Set Operations

-- intersect
-- SELECT HouseBoat_ID 
-- FROM Rental
-- INTERSECT
-- SELECT HouseBoat_ID 
-- FROM Staff;

SELECT DISTINCT r.HouseBoat_ID
FROM Rental r
INNER JOIN Staff s
ON r.HouseBoat_ID = s.HouseBoat_ID;

SELECT HouseBoat_ID 
FROM Rental
UNION
SELECT HouseBoat_ID 
FROM Staff;
