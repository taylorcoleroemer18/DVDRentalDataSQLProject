-- Advanced Data Management - D326

-- B. USER-DEFINED FUNCTION
CREATE OR REPLACE FUNCTION get_full_name(first_name VARCHAR, last_name VARCHAR)
      RETURNS VARCHAR AS $$
BEGIN
      RETURN INITCAP(first_name) || ' ' || INITCAP(last_name);
END;
$$ LANGUAGE plpgsql;

-- TEST THE FUNCTION FOR SUCCESS
SELECT customer_id, get_full_name(first_name, last_name) AS customer_full_name
FROM customer;

-- C. CREATE THE DETAILED AND SUMMARY TABLES
--Detailed
DROP TABLE IF EXISTS report_detailed;
DROP TABLE IF EXISTS report_summary;

CREATE TABLE report_detailed (
      payment_id INT PRIMARY KEY,
      customer_id INT,
      first_name VARCHAR(50),
      last_name VARCHAR(50),
      amount DECIMAL(5,2),
      payment_date TIMESTAMP
);
--Summary
CREATE TABLE report_summary (
      customer_id INT PRIMARY KEY,
      customer_full_name VARCHAR(100),
      total_amount_paid DECIMAL(7,2)
);

-- MAKE SURE TABLES WERE CREATED SUCCESSFULLY
SELECT * FROM report_detailed;
SELECT * FROM report_summary;

-- E. TRIGGER
DROP FUNCTION IF EXISTS update_summary_table() CASCADE;
DROP TRIGGER IF EXISTS trg_update_summary ON report_detailed;

CREATE OR REPLACE FUNCTION update_summary_table()
      RETURNS TRIGGER AS $$
BEGIN
    -- If the customer already exists in the summary, update total
    IF EXISTS (SELECT 1 FROM report_summary WHERE customer_id = NEW.customer_id) THEN
        UPDATE report_summary
        SET total_amount_paid = total_amount_paid + NEW.amount
        WHERE customer_id = NEW.customer_id;
    ELSE
        -- If not, insert a new row
        INSERT INTO report_summary (customer_id, customer_full_name, total_amount_paid)
        VALUES (
            NEW.customer_id,
            get_full_name(NEW.first_name, NEW.last_name),
            NEW.amount
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_summary
AFTER INSERT ON report_detailed
FOR EACH ROW
EXECUTE FUNCTION update_summary_table();

-- D. EXTRACT RAW DATA
INSERT INTO report_detailed (
      payment_id,
      customer_id,
      first_name,
      last_name,
      amount,
      payment_date
)
SELECT
      pay.payment_id,
      cust.customer_id,
      cust.first_name,
      cust.last_name,
      pay.amount,
      pay.payment_date
FROM
      payment pay
JOIN
      customer cust ON pay.customer_id = cust.customer_id;

-- MAKE SURE DATA WAS INSERTED FOR BOTH TABLES
SELECT * FROM report_detailed; --14596 rows
SELECT * FROM report_summary; --599 rows

--TEST IT WITH INSERTING INTO DETAILED TABLE
INSERT INTO report_detailed (
      payment_id,
      customer_id,
      first_name,
      last_name,
      amount,
      payment_date
) VALUES (
      88888,
      77777,
      'Taylor',
      'Roemer',
      7.77,
      CURRENT_TIMESTAMP
);

SELECT * FROM report_detailed; --14597 rows
SELECT * FROM report_summary; --600 rows

-- F. STORED PROCEDURE
DROP PROCEDURE IF EXISTS refresh_report_data;

CREATE OR REPLACE PROCEDURE refresh_report_data ()
      LANGUAGE plpgsql AS $$
BEGIN
      -- Step 1: Clear the existing data
      DELETE FROM report_detailed;
      DELETE FROM report_summary;
      
      -- Step 2: Re-insert data into report_detailed
      INSERT INTO report_detailed (
            payment_id,
            customer_id,
            first_name,
            last_name,
            amount,
            payment_date
      )
      SELECT
            pay.payment_id,
            cust.customer_id,
            cust.first_name,
            cust.last_name,
            pay.amount,
            pay.payment_date
      FROM payment pay
      JOIN customer cust ON pay.customer_id = cust.customer_id;
      -- Step 3: Trigger will automatically populate report_summary
END;
$$;

-- TEST PROCEDURE
CALL refresh_report_data()

-- VERIFY RESULTS
SELECT * FROM report_detailed;
SELECT * FROM report_summary;