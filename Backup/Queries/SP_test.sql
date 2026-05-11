-- 1-Test ExamGeneration
--test1.1
DECLARE @ExamID INT;

EXEC ExamGeneration
    @CourseName = 'Full-Stack Web Development',
    @MCQ_Count  = 6,
    @TF_Count   = 4,
    @ExamDate   = '2026-01-15',
    @Duration   = 90,
    @NewExamID  = @ExamID OUTPUT;

SELECT @ExamID AS GeneratedExamID;



EXEC ExamGeneration
    @CourseName = 'Full-Stack Web Development',
    @MCQ_Count  = 5,
    @TF_Count   = 3,
    @NewExamID  = @ExamID OUTPUT;

SELECT @ExamID AS GeneratedExamID;

-- verify
select * from Exam


SELECT q.type, q.description
FROM Exam_Question eq
JOIN Question q
  ON eq.course_id = q.course_id
 AND eq.question_id = q.question_id
 where exam_id = 5005


SELECT COUNT(*) AS QuestionCount
FROM Exam_Question
WHERE exam_id = (SELECT MAX(exam_id) FROM Exam);








--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--Exam questions + correct answers (model solution)
SELECT
    e.exam_id,
    q.question_id,
    q.description AS question_text,
    c.choice_text AS correct_choice,c.choice_id
FROM Exam e
JOIN Exam_Question eq
    ON e.exam_id = eq.exam_id
JOIN Question q
    ON q.course_id = eq.course_id
   AND q.question_id = eq.question_id
JOIN Choice c
    ON c.course_id = q.course_id
   AND c.question_id = q.question_id
   AND c.is_correct = 1
WHERE e.exam_id = 5001
ORDER BY q.question_id;



----------------
--test1.2
--fail
DECLARE @ExamID INT;
EXEC ExamGeneration
    @CourseName = 'Quantum Computing',
    @MCQ_Count  = 5,
    @TF_Count   = 3,
    @NewExamID  = @ExamID OUTPUT;

--test1.3
--fail
DECLARE @ExamID INT;
EXEC ExamGeneration
    @CourseName = 'Full-Stack Web Development',
    @MCQ_Count  = 100,
    @TF_Count   = 50,
    @NewExamID  = @ExamID OUTPUT;
------------------------------------------------------------------------------------------------------------
-- 2-Test ExamAnswer
DECLARE @ExamID INT;
@ExamID        INT,
@StudentFName  VARCHAR(50), 
@StudentLName  VARCHAR(50),
@AnswersCSV    VARCHAR(MAX)


EXEC ExamAnswer
    @ExamID = 5001,
    @StudentFName = 'Mohamed',
	@StudentLName = 'Ali',
    @AnswersCSV = '1,1,1,1,1,2,2,1';

delete Student_Exam_Answer 
where student_id = 4001 and exam_id = 5001




SELECT *
FROM Student_Exam
WHERE exam_id = 5001;

SELECT question_id, stud_answer, is_correct
FROM Student_Exam_Answer
WHERE exam_id = 5002
  AND student_id =
      (SELECT student_id FROM Student
       WHERE student_fname='Mohamed' AND student_lname='Ali');


--Test 2.2 — Fewer answers than questions
--fails
EXEC ExamAnswer
    @ExamID = 5001,
    @StudentFName = 'Omar',
    @StudentLName = 'Hassan',
    @AnswersCSV = 'a,b,c';

--
EXEC ExamAnswer
    @ExamID = 5001,
    @StudentFName = 'John',
    @StudentLName = 'Smith',
    @AnswersCSV = 'a,b,c,d,true,false,true,false';

-----------------------------------------------------------------------------------------
--test 3
EXEC ExamCorrection
    @ExamID = 5001,
    @StudentFName = 'Mohamed',
    @StudentLName = 'Ali';

update student_Exam
set total_grade = NUll
where student_id = 4001 and exam_id = 5001



SELECT total_grade
FROM Student_Exam
WHERE exam_id = 5001
  AND student_id =
      (SELECT student_id FROM Student
       WHERE student_fname='Mohamed' AND student_lname='Ali');

-------
--Test 3.2 — Correction without answering
--fail
EXEC ExamCorrection
    @ExamID = 5002,
    @StudentFName = 'Mohamed',
    @StudentLName = 'Ali';


	SELECT *
FROM Student_Exam_Answer sea
LEFT JOIN Student_Exam se
  ON sea.student_id = se.student_id
 AND sea.exam_id = se.exam_id
WHERE se.student_id IS NULL;





EXEC ExamAnswer
    @ExamID = 5001,
    @StudentFName = 'Mohamed',
	@StudentLName = 'Ali',
    @AnswersCSV = '1,1,1,1,1,2,2,1';

delete Student_Exam_Answer 
where student_id = 4001 and exam_id = 5001


--test 3
EXEC ExamCorrection
    @ExamID = 5001,
    @StudentFName = 'Mohamed',
    @StudentLName = 'Ali';

update student_Exam
set total_grade = NUll
where student_id = 4001 and exam_id = 5001