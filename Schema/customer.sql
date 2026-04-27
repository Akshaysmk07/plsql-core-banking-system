/* ============================================================
   MODULE:       Core Banking - Customer Management
   OBJECT:       CUSTOMERS
   DESCRIPTION:  Stores customer master data (CIF).
                 One customer can have multiple accounts.
   AUTHOR:       Akshay
   CREATED ON:   27/04/2026
   ============================================================ */


/* ============================================================
   STEP 1: CREATE CUSTOMERS TABLE
   ============================================================ */

CREATE TABLE customers (
    
    -- Unique customer identifier (Primary Key)
    customer_id     NUMBER PRIMARY KEY,
    
    -- Customer full name
    customer_name   VARCHAR2(100),
    
    -- Mobile number (used for notifications/contact)
    mobile_number   VARCHAR2(15),
    
    -- Email address (optional)
    email           VARCHAR2(100),
    
    -- Record creation date (defaults to system date)
    created_date    DATE DEFAULT SYSDATE
);


/* ============================================================
   STEP 2: INSERT SAMPLE DATA
   ============================================================ */

-- Example: Create a new customer
INSERT INTO customers (
    customer_id,
    customer_name,
    mobile_number,
    email
)
VALUES (
    1,
    'Akshay Kumar',
    '9876543210',
    'akshay@example.com'
);


/* ============================================================
   STEP 3: COMMIT TRANSACTION
   ============================================================ */

-- Persist customer data (Durability - ACID property)
COMMIT;


/* ============================================================
   STEP 4: VERIFY DATA
   ============================================================ */

-- Retrieve all customer records
SELECT * FROM customers;

