-- 1-Generate an exam for a course with random MCQ + TF questions
CREATE OR ALTER PROCEDURE ExamGeneration
    @CourseName   VARCHAR(50),
    @MCQ_Count    INT,
    @TF_Count     INT,
    @ExamDate     DATE,
    @Duration     INT,
    @NewExamID    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRAN;

    DECLARE @CourseID INT;

    /* ==============================
       1️⃣ Validate inputs
    ============================== */
    IF @MCQ_Count < 0 OR @TF_Count < 0
    BEGIN
        ROLLBACK;
        RAISERROR('Question counts must be non-negative',16,1);
        RETURN;
    END;

    IF @MCQ_Count = 0 AND @TF_Count = 0
    BEGIN
        ROLLBACK;
        RAISERROR('At least one question must be selected',16,1);
        RETURN;
    END;

    IF @Duration <= 0
    BEGIN
        ROLLBACK;
        RAISERROR('Exam duration must be greater than zero',16,1);
        RETURN;
    END;

    IF @ExamDate IS NULL
    BEGIN
        ROLLBACK;
        RAISERROR('Exam date is required',16,1);
        RETURN;
    END;

    /* ==============================
       2️⃣ Resolve course
    ============================== */
    SELECT @CourseID = course_id
    FROM Course
    WHERE course_name = @CourseName;

    IF @CourseID IS NULL
    BEGIN
        ROLLBACK;
        RAISERROR('Course not found',16,1);
        RETURN;
    END;

    /* ==============================
       3️⃣ Validate question availability
    ============================== */
    IF (SELECT COUNT(*) FROM Question WHERE course_id = @CourseID AND type = 'MCQ') < @MCQ_Count
       OR
       (SELECT COUNT(*) FROM Question WHERE course_id = @CourseID AND type = 'TF') < @TF_Count
    BEGIN
        ROLLBACK;
        RAISERROR('Not enough questions for this course',16,1);
        RETURN;
    END;

    /* ==============================
       4️⃣ Generate safe Exam ID
    ============================== */
    SELECT @NewExamID = ISNULL(MAX(exam_id), 5000) + 1
    FROM Exam WITH (TABLOCKX);

    INSERT INTO Exam (exam_id, exam_date, duration, course_id)
    VALUES (@NewExamID, @ExamDate, @Duration, @CourseID);

    /* ==============================
       5️⃣ Collect questions
    ============================== */
    DECLARE @SelectedQuestions TABLE (
        course_id   INT,
        question_id INT
    );

    -- MCQ questions
    INSERT INTO @SelectedQuestions
    SELECT TOP (@MCQ_Count)
        course_id, question_id
    FROM Question
    WHERE course_id = @CourseID
      AND type = 'MCQ'
    ORDER BY NEWID();

    -- TF questions
    INSERT INTO @SelectedQuestions
    SELECT TOP (@TF_Count)
        course_id, question_id
    FROM Question
    WHERE course_id = @CourseID
      AND type = 'TF'
    ORDER BY NEWID();

    /* ==============================
       6️⃣ Final shuffle & attach
    ============================== */
    INSERT INTO Exam_Question (exam_id, course_id, question_id)
    SELECT
        @NewExamID,
        course_id,
        question_id
    FROM @SelectedQuestions
    ORDER BY NEWID();  -- 🔥 final shuffle

    COMMIT;
END;
GO




---------------------------------------------------------------------
--2
DROP PROCEDURE IF EXISTS ExamAnswer;
GO

CREATE OR ALTER PROCEDURE ExamAnswer
    @ExamID INT,
    @StudentFName VARCHAR(50),
    @StudentLName VARCHAR(50),
    @AnswersCSV VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRAN;

    DECLARE @StudentID INT;

    /* 1️⃣ Validate student */
    SELECT @StudentID = student_id
    FROM Student
    WHERE student_fname = @StudentFName
      AND student_lname = @StudentLName;

    IF @StudentID IS NULL
    BEGIN
        ROLLBACK;
        RAISERROR('Student not found',16,1);
        RETURN;
    END;

    /* 2️⃣ Validate exam */
    IF NOT EXISTS (SELECT 1 FROM Exam WHERE exam_id = @ExamID)
    BEGIN
        ROLLBACK;
        RAISERROR('Exam not found',16,1);
        RETURN;
    END;

    /* 3️⃣ Ensure student IS ASSIGNED to this exam */
    IF NOT EXISTS (
        SELECT 1
        FROM Student_Exam
        WHERE student_id = @StudentID
          AND exam_id = @ExamID
    )
    BEGIN
        ROLLBACK;
        RAISERROR('Student is not assigned to this exam',16,1);
        RETURN;
    END;

    /* 4️⃣ Ensure student has NOT answered yet */
    IF EXISTS (
        SELECT 1
        FROM Student_Exam_Answer
        WHERE student_id = @StudentID
          AND exam_id = @ExamID
    )
    BEGIN
        ROLLBACK;
        RAISERROR('Student already submitted this exam',16,1);
        RETURN;
    END;

		/* 5️⃣ Parse answers */
	DECLARE @Answers TABLE (
		seq INT IDENTITY(1,1),
		choice_id INT
	);

	INSERT INTO @Answers(choice_id)
	SELECT TRY_CAST(LTRIM(RTRIM(value)) AS INT)
	FROM STRING_SPLIT(@AnswersCSV, ',');

	IF EXISTS (SELECT 1 FROM @Answers WHERE choice_id IS NULL)
	BEGIN
		ROLLBACK;
		RAISERROR('Invalid answer format. Answers must be choice numbers.',16,1);
		RETURN;
	END;

	/* 6️⃣ Load exam questions in deterministic order */
	DECLARE @Questions TABLE (
		seq INT IDENTITY(1,1),
		course_id INT,
		question_id INT
	);

	INSERT INTO @Questions(course_id, question_id)
	SELECT course_id, question_id
	FROM Exam_Question
	WHERE exam_id = @ExamID
	ORDER BY question_id;

	/* 7️⃣ Validate count */
	IF (SELECT COUNT(*) FROM @Answers) <> (SELECT COUNT(*) FROM @Questions)
	BEGIN
		ROLLBACK;
		RAISERROR('Answer count does not match number of questions',16,1);
		RETURN;
	END;

	/* 8️⃣ Insert answers with correct evaluation */
	INSERT INTO Student_Exam_Answer
		(student_id, exam_id, course_id, question_id, stud_answer, is_correct)
	SELECT
		@StudentID,
		@ExamID,
		q.course_id,
		q.question_id,
		CAST(a.choice_id AS VARCHAR(10)),
		CASE
			WHEN c.is_correct = 1 THEN 1
			ELSE 0
		END
	FROM @Questions q
	JOIN @Answers a
		ON q.seq = a.seq
	JOIN Choice c
		ON c.course_id = q.course_id
	   AND c.question_id = q.question_id
	   AND c.choice_id = a.choice_id;

    COMMIT;
END;
GO



-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--3 ExamCorrection
CREATE OR ALTER PROCEDURE ExamCorrection
    @ExamID        INT,
    @StudentFName  VARCHAR(50),
    @StudentLName  VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @StudentID INT,
        @Total INT,
        @Correct INT,
        @Grade INT;

    /* 1️⃣ Validate student */
    SELECT @StudentID = student_id
    FROM Student
    WHERE student_fname = @StudentFName
      AND student_lname = @StudentLName;

    IF @StudentID IS NULL
    BEGIN
        RAISERROR('Student not found',16,1);
        RETURN;
    END;

	 IF NOT EXISTS (SELECT 1 FROM Exam WHERE exam_id = @ExamID)
    BEGIN
        ROLLBACK;
        RAISERROR('Exam not found',16,1);
        RETURN;
    END;

    /* 2️⃣ Ensure student is assigned to exam */
    IF NOT EXISTS (
        SELECT 1
        FROM Student_Exam
        WHERE student_id = @StudentID
          AND exam_id = @ExamID
    )
    BEGIN
        RAISERROR('Student is not assigned to this exam',16,1);
        RETURN;
    END;

    /* 3️⃣ Ensure answers exist */
    SELECT @Total = COUNT(*)
    FROM Student_Exam_Answer
    WHERE student_id = @StudentID
      AND exam_id = @ExamID;

    IF @Total = 0
    BEGIN
        RAISERROR('No answers found for this exam',16,1);
        RETURN;
    END;

    /* 4️⃣ Prevent double correction */
    IF EXISTS (
        SELECT 1
        FROM Student_Exam
        WHERE student_id = @StudentID
          AND exam_id = @ExamID
          AND total_grade IS NOT NULL
    )
    BEGIN
        RAISERROR('Exam already corrected for this student',16,1);
        RETURN;
    END;

    /* 5️⃣ Count correct answers */
    SELECT @Correct = COUNT(*)
    FROM Student_Exam_Answer
    WHERE student_id = @StudentID
      AND exam_id = @ExamID
      AND is_correct = 1;

    /* 6️⃣ Calculate grade */
    SET @Grade = CAST((@Correct * 100.0) / @Total AS INT);

    /* 7️⃣ Update final grade */
    UPDATE Student_Exam
    SET total_grade = @Grade
    WHERE student_id = @StudentID
      AND exam_id = @ExamID;

    /* 8️⃣ Return result */
    SELECT
        @StudentID AS student_id,
        @ExamID AS exam_id,
        @Correct AS correct_answers,
        @Total AS total_questions,
        @Grade AS final_grade_percent;
END;
GO
