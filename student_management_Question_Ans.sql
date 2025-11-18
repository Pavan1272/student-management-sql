
-- queries.sql
USE student_mgmt;


-- 1. List all students
SELECT * FROM students;

-- 2. All instructors sorted by hire date
SELECT first_name, last_name, hire_date 
FROM instructors 
ORDER BY hire_date ASC;

-- 3. Students whose email ends with '@example.com'
SELECT * FROM students 
WHERE email LIKE '%@example.com';


-- 4. Students with their enrolled courses
SELECT s.student_id, s.first_name, s.last_name, c.course_code, c.title, e.status
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id;

-- 5. List students with course titles
SELECT s.first_name, s.last_name, c.title
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id;

-- 6. Count of courses each student enrolled in
SELECT s.first_name, s.last_name, COUNT(e.course_id) AS total_courses
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id;

-- 7 Course list with Instructor names
SELECT c.title, CONCAT(i.first_name, ' ', i.last_name) AS instructor
FROM courses c
LEFT JOIN instructors i ON c.instructor_id = i.instructor_id;

-- 8 Students who completed at least one course
SELECT DISTINCT s.first_name, s.last_name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
WHERE e.status = 'completed';

-- 9 Show students with their grades
SELECT s.first_name, s.last_name, c.title, g.grade
FROM grades g
JOIN enrollments e ON g.enrollment_id = e.enrollment_id
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id;

-- 10 Courses with no students
SELECT c.title 
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
WHERE e.course_id IS NULL;

-- 11 List students age (calculated from DOB)
SELECT first_name, last_name,
TIMESTAMPDIFF(YEAR, dob, CURDATE()) AS age
FROM students;

-- 12. Students enrolled in the most popular course
SELECT first_name, last_name 
FROM students
WHERE student_id IN (
    SELECT student_id 
    FROM enrollments
    WHERE course_id = (
        SELECT course_id 
        FROM enrollments 
        GROUP BY course_id 
        ORDER BY COUNT(*) DESC 
        LIMIT 1
    )
);

-- 13. Courses with above-average credits
SELECT * 
FROM courses
WHERE credits > (SELECT AVG(credits) FROM courses);

-- 14. Course enrollment counts
SELECT c.course_code, c.title, COUNT(e.enrollment_id) as num_students
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.title;


-- 15 Students without enrollments
SELECT s.* FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
WHERE e.enrollment_id IS NULL;


-- 16. Average grade per course (assumes grades are mapped to points externally)
-- Example: if you had numeric grades; here we'll show grade list
SELECT c.title, s.first_name, s.last_name, g.grade
FROM grades g
JOIN enrollments e ON g.enrollment_id = e.enrollment_id
JOIN courses c ON e.course_id = c.course_id
JOIN students s ON e.student_id = s.student_id;

-- 17. Subquery Example 1: Students enrolled in the most popular course
SELECT first_name, last_name
FROM students
WHERE student_id IN (
    SELECT student_id
    FROM enrollments
    WHERE course_id = (
        SELECT course_id
        FROM enrollments
        GROUP BY course_id
        ORDER BY COUNT(*) DESC
        LIMIT 1
    )
);

-- 18. Subquery Example 2: Courses with credits above average
SELECT *
FROM courses
WHERE credits > (SELECT AVG(credits) FROM courses);


-- 19. CTE Example 1: Students with more than 1 course
WITH course_count AS (
    SELECT student_id, COUNT(course_id) AS total_courses
    FROM enrollments
    GROUP BY student_id
)
SELECT s.first_name, s.last_name, c.total_courses
FROM students s
JOIN course_count c ON s.student_id = c.student_id
WHERE c.total_courses > 1;

-- 20. CTE Example 2: Average Credits and Courses Above Average
WITH avg_credit AS (
    SELECT AVG(credits) AS avg_credits FROM courses
)
SELECT course_id, title, credits
FROM courses, avg_credit
WHERE credits > avg_credit.avg_credits;


## PROCEDURE ##
-- Example 1: Student Insert Procedure
DELIMITER $$
CREATE PROCEDURE add_student(
    IN f_name VARCHAR(50),
    IN l_name VARCHAR(50),
    IN email_id VARCHAR(100),
    IN dob_date DATE
)
BEGIN
    INSERT INTO students(first_name, last_name, email, dob, enrollment_date)
    VALUES (f_name, l_name, email_id, dob_date, CURDATE());
END $$

DELIMITER ;

-- This statement for Calling procedure:
CALL add_student('Rohit', 'Kale', 'rohit@example.com', '2001-02-10');

-- Example 2: Get All Courses of a Student
DELIMITER $$
CREATE PROCEDURE student_courses(IN stud_id INT)
BEGIN
    SELECT s.first_name, s.last_name, c.title, e.status
    FROM students s
    JOIN enrollments e ON s.student_id = e.student_id
    JOIN courses c ON e.course_id = c.course_id
    WHERE s.student_id = stud_id;
END $$
DELIMITER ;

-- Call:
CALL student_courses(1);


## VIEW ##
-- Example 1: View of Student Full Details
CREATE VIEW student_full_info AS
SELECT student_id,
       CONCAT(first_name, ' ', last_name) AS full_name,
       email, dob, enrollment_date
FROM students;

SELECT * FROM student_full_info;

-- Example 2: View of Course Enrollment Count
CREATE VIEW course_enrollment_count AS
SELECT c.course_id, c.title,
       COUNT(e.enrollment_id) AS total_students
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.title;


SELECT * FROM course_enrollment_count;

## TRIGGER ##
-- Example 1: Automatically Log New Student
CREATE TABLE student_logs(
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    action VARCHAR(50),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE TRIGGER log_new_student
AFTER INSERT ON students
FOR EACH ROW
BEGIN
    INSERT INTO student_logs(student_id, action)
    VALUES (NEW.student_id, 'New student added');
END $$

DELIMITER ;

-- Example 2: Prevent Delete if Student Has Enrollments

DELIMITER $$
CREATE TRIGGER prevent_student_delete
BEFORE DELETE ON students
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM enrollments WHERE student_id = OLD.student_id) > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete student with active enrollments';
    END IF;
END $$
DELIMITER ;

## FUNCTION ##
-- Example 1: Calculate Student Age

DELIMITER $$
CREATE FUNCTION get_age(dob DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, dob, CURDATE());
END $$
DELIMITER ;

-- for execute
SELECT first_name, get_age(dob) AS age FROM students;

-- Example 2: Get Grade Points
-- (A = 10, B = 8, C = 6…)

DELIMITER $$
CREATE FUNCTION grade_points(g VARCHAR(2))
RETURNS INT
DETERMINISTIC
BEGIN
    IF g = 'A' THEN RETURN 10;
    ELSEIF g = 'B' THEN RETURN 8;
    ELSEIF g = 'C' THEN RETURN 6;
    ELSE RETURN 0;
    END IF;
END $$
DELIMITER ;

-- Use:
SELECT grade, grade_points(grade) FROM grades;



--  Transactions example (enroll student and add grade atomically)
START TRANSACTION;
INSERT INTO enrollments (student_id, course_id, enrolled_on) VALUES (2, 2, CURRENT_DATE());
-- assume new enrollment id is LAST_INSERT_ID(); use it to insert grade
-- INSERT INTO grades (enrollment_id, grade, graded_on) VALUES (LAST_INSERT_ID(), 'B+', CURRENT_DATE());
COMMIT;

