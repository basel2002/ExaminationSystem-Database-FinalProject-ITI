--1List all branches with offered tracks
SELECT 
    b.branch_name,
    t.track_name
FROM Branch b
JOIN Branch_Track bt ON b.branch_id = bt.branch_id
JOIN Track t ON bt.track_id = t.track_id
ORDER BY b.branch_name;

--2️⃣ Tracks and their supervisors
SELECT 
    t.track_name,
    CONCAT(i.ins_fname,' ',i.ins_lname) AS supervisor
FROM Track t
LEFT JOIN Instructor i ON t.supervisor_id = i.ins_id;

--3️⃣ Instructors and their tracks
SELECT 
    i.ins_id,
    CONCAT(i.ins_fname,' ',i.ins_lname) AS instructor_name,
    t.track_name
FROM Instructor i
LEFT JOIN Track t ON i.track_id = t.track_id
ORDER BY instructor_name;

-- ACADEMIC STRUCTURE REVIEWS
--4️⃣ Tracks and courses taught in each track
SELECT 
    t.track_name,
    c.course_name
FROM Track t
JOIN Track_Course tc ON t.track_id = tc.track_id
JOIN Course c ON tc.course_id = c.course_id
ORDER BY t.track_name;

--5️⃣ Courses and their topics
SELECT 
    c.course_name,
    tp.topic_name
FROM Course c
JOIN Topic tp ON c.course_id = tp.course_id
ORDER BY c.course_name;

--6️⃣ Instructors and courses they teach
SELECT 
    CONCAT(i.ins_fname,' ',i.ins_lname) AS instructor,
    c.course_name
FROM Instructor i
JOIN Instructor_Course ic ON i.ins_id = ic.ins_id
JOIN Course c ON ic.course_id = c.course_id
ORDER BY instructor;

--STUDENT REVIEWS
--7️⃣ Students inside each track
SELECT 
    t.track_name,
    CONCAT(s.student_fname,' ',s.student_lname) AS student_name
FROM Student s
JOIN Track t ON s.track_id = t.track_id
ORDER BY t.track_name;

--8️ Student enrollments and grades
SELECT 
    CONCAT(s.student_fname,' ',s.student_lname) AS student,
    c.course_name,
    sc.grade
FROM Student_Course sc
JOIN Student s ON sc.student_id = s.student_id
JOIN Course c ON sc.course_id = c.course_id
where c.course_name = 'Full-Stack Web Development'
ORDER BY student;


SELECT
    eq.course_id,
    eq.question_id,
    (
        SELECT TOP 1 choice_id
        FROM Choice
        WHERE course_id = eq.course_id
            AND question_id = eq.question_id
            AND is_correct = 1
    )
FROM Exam_Question eq
WHERE eq.exam_id = 5001
ORDER BY eq.course_id, eq.question_id;


--------
 DECLARE @Answers TABLE (
        seq INT IDENTITY(1,1),
        answer VARCHAR(255)
    );

    INSERT INTO @Answers(answer)
    SELECT value
    FROM STRING_SPLIT('1,1,1,2,1', ',');
select * from @Answers

SELECT
        @StudentID,
        @ExamID,
        q.course_id,
        q.question_id,
        a.answer,
        CASE
            WHEN a.answer = q.model_answer THEN 1
            ELSE 0
        END
    FROM @Questions q
    JOIN @Answers a ON q.seq = a.seq;

-- EXAMS & QUESTIONS
--9 Exams per course
SELECT 
    e.exam_id,
    c.course_name,
    e.exam_date,
    e.duration
FROM Exam e
JOIN Course c ON e.course_id = c.course_id;

--10 Questions inside each exam
SELECT 
    e.exam_id,
    q.question_id,
    q.description,
    q.type
FROM Exam_Question eq
JOIN Exam e ON eq.exam_id = e.exam_id
JOIN Question q 
   ON eq.course_id = q.course_id 
  AND eq.question_id = q.question_id
ORDER BY e.exam_id;

--11 Questions with choices (FULL VIEW)
SELECT 
    q.question_id,
    q.description,
    ch.choice_text,
    ch.is_correct
FROM Question q
JOIN Choice ch 
  ON q.course_id = ch.course_id 
 AND q.question_id = ch.question_id

ORDER BY q.question_id;


--EXAM RESULTS & GRADING
--12 Student exam attempts
SELECT 
    CONCAT(s.student_fname,' ',s.student_lname) AS student,
    e.exam_id,
    e.course_id,
    se.total_grade
FROM Student_Exam se
JOIN Student s ON se.student_id = s.student_id
JOIN Exam e ON se.exam_id = e.exam_id;

--13 Student answers vs correct answers
SELECT 
    CONCAT(s.student_fname,' ',s.student_lname) AS student,
    q.description AS question,
    sea.stud_answer AS student_answer,
    ch.choice_text AS correct_answer
FROM Student_Exam_Answer sea
JOIN Student s ON sea.student_id = s.student_id
JOIN Question q 
  ON sea.course_id = q.course_id 
 AND sea.question_id = q.question_id
JOIN Choice ch 
  ON ch.course_id = q.course_id 
 AND ch.question_id = q.question_id
 AND ch.is_correct = 1
ORDER BY student;

-- BUSINESS REPORTS (REQURIED OUTPUT STYLE)
--14 Number of students per course (for instructors)
SELECT 
    c.course_name,
    COUNT(sc.student_id) AS number_of_students
FROM Course c
LEFT JOIN Student_Course sc ON c.course_id = sc.course_id
GROUP BY c.course_name;

--15 Instructor teaching load
SELECT 
    CONCAT(i.ins_fname,' ',i.ins_lname) AS instructor,
    COUNT(DISTINCT ic.course_id) AS courses_taught
FROM Instructor i
LEFT JOIN Instructor_Course ic ON i.ins_id = ic.ins_id
GROUP BY i.ins_fname, i.ins_lname;

--16 Average grade per course
SELECT 
    c.course_name,
    AVG(sc.grade) AS avg_grade
FROM Course c
JOIN Student_Course sc ON c.course_id = sc.course_id
GROUP BY c.course_name;

--DATA QUALITY CHECKS (IMPORTANT)
--17 Tracks without supervisors (should be 0 after setup)
SELECT *
FROM Track
WHERE supervisor_id IS NULL;

--18 Students enrolled in courses outside their track
SELECT 
    CONCAT(s.student_fname,' ',s.student_lname) AS student,
    c.course_name
FROM Student_Course sc
JOIN Student s ON sc.student_id = s.student_id
JOIN Course c ON sc.course_id = c.course_id
LEFT JOIN Track_Course tc 
  ON tc.course_id = c.course_id 
 AND tc.track_id = s.track_id
WHERE tc.track_id IS NULL;




HOW TO USE THESE

Run 1 → 6 to validate structure

Run 7 → 11 to validate exams & questions

Run 12 → 16 to validate grading & reports

Run 17 → 18 to detect logical problems