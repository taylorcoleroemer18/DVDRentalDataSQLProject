# 🧠 Advanced Data Management - D326 (WGU)

This project demonstrates advanced SQL concepts including user-defined functions, triggers, stored procedures, and dynamic data reporting using PostgreSQL. Built for the **WGU D326 - Advanced Data Management** course, this codebase showcases how to automate data workflows for a reporting system.

---

## 📁 Project Structure

- **User-Defined Function:** Generates a properly capitalized full name from raw customer data.
- **Detailed Report Table:** Stores transactional payment data for each customer.
- **Summary Report Table:** Aggregates total payments per customer with their full name.
- **Trigger & Function:** Automatically updates the summary table when new detailed data is inserted.
- **Stored Procedure:** Rebuilds both tables to ensure accuracy and freshness of reports.

---

## 🛠️ Technologies

- PostgreSQL (PL/pgSQL)
- SQL DDL & DML
- Triggers & Stored Procedures
- WGU course-aligned logic

---

## 🧩 Features

- ✅ User-defined function `get_full_name()` to clean and format names.
- ✅ `report_detailed` and `report_summary` tables to support granular and aggregated insights.
- ✅ Trigger `trg_update_summary` that automatically updates the summary table after inserts.
- ✅ Stored procedure `refresh_report_data()` for rebuilding the report pipeline with fresh data.

  ## 📖 License
This project is part of the coursework for WGU and is intended for educational use. Feel free to fork and adapt for learning purposes.

