-- Student Management SQL Project
-- Combined schema, seed data, and queries
create database student_mgmt;
USE student_mgmt;
-- SCHEMA
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS grades;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS instructors;

CREATE TABLE instructors (
    instructor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    hire_date DATE
);

CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(10) NOT NULL UNIQUE,
    title VARCHAR(150) NOT NULL,
    credits INT DEFAULT 3,
    instructor_id INT,
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id) ON DELETE SET NULL
);

CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    dob DATE,
    enrollment_date DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrolled_on DATE DEFAULT (CURRENT_DATE),
    status ENUM('enrolled','completed','dropped') DEFAULT 'enrolled',
    UNIQUE (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);

CREATE TABLE grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL,
    grade VARCHAR(2),
    graded_on DATE,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE
);

-- SEED DATA
INSERT INTO instructors (first_name, last_name, email, hire_date) VALUES
('Anil', 'Patil', 'anil.patil@example.com', '2018-07-01'),
('Sima', 'Khan', 'sima.khan@example.com', '2019-09-10');

INSERT INTO courses (course_code, title, credits, instructor_id) VALUES
('DB101', 'Introduction to Databases', 4, 1),
('SQL201', 'Advanced SQL Queries', 3, 2),
('WD301', 'Web Development Basics', 3, NULL);

INSERT INTO students (first_name, last_name, email, dob, enrollment_date) VALUES
('Rahul', 'Sharma', 'rahul.sharma@example.com', '2001-05-15', '2023-08-01'),
('Meera', 'Joshi', 'meera.joshi@example.com', '2000-11-22', '2023-08-01'),
('Asha', 'Desai', 'asha.desai@example.com', '1999-03-02', '2023-09-10');

INSERT INTO enrollments (student_id, course_id, enrolled_on, status) VALUES
(1, 1, '2023-08-05', 'enrolled'),
(1, 2, '2023-09-01', 'enrolled'),
(2, 1, '2023-08-06', 'completed'),
(3, 3, '2023-09-12', 'enrolled');

INSERT INTO grades (enrollment_id, grade, graded_on) VALUES
(3, 'A', '2023-12-20');
