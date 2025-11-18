# Council Management System

The **Council Management System** is a web-based application built using **JSP**, **Servlets**, and **MySQL**, designed to automate and streamline the student council selection process in educational institutions. The system ensures a structured, transparent, and efficient workflow for **students**, **admins**, and the **interview panel**, while also supporting yearly data reset for new sessions.

## Features

### 👤 User Management
- Secure login for **Students** and **Admins**
- Sessions maintained using server-side authentication  
- Role-based access control  
- Login credentials remain intact across academic years

### 📝 Application Management
- Students can:
  - Apply for available council positions
  - Edit or update their submitted details
  - Track the status of their applications
- Server-side validation and persistent storage

### 🎙 Interview Management
- Admins can:
  - Schedule interviews for applicants  
  - Update interview scores and remarks  
  - Manage multiple evaluation parameters
- Centralized interview result processing

### 🏆 Result Processing
- Automatic generation of final council results based on interview performance  
- Admin can modify, verify, and finalize results  
- Students can view their final status once published

### 🔁 Yearly Session Reset
A built-in **Session Reset Module** lets the admin begin a fresh council selection cycle every academic year.

The system automatically **clears:**
- `application_table`
- `interview_table`
- `result_table`
- Any other session-based council data

The system **retains:**
- `login_table` (Admin and Student accounts remain saved)

This ensures fresh recruitment every year while keeping user credentials unchanged.

## 🌐 Technology Stack

| Component | Technology |
|----------|------------|
| Frontend | JSP, HTML5, CSS, JavaScript |
| Backend | Java Servlets |
| Server | Apache Tomcat |
| Database | MySQL |
| Architecture | MVC Web Application |
| Version Control | Git + GitHub |


## 🎥 Demo Video
Watch the project demo her: https://youtu.be/A8peVDuWVf4



