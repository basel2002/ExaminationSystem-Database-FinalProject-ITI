-- 1) Exam-question course match (INSERT or UPDATE)
CREATE OR ALTER TRIGGER dbo.trg_exam_question_course_match
ON dbo.Exam_Question
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN dbo.Exam e ON e.exam_id = i.exam_id
        WHERE e.course_id <> i.course_id
    )
    BEGIN
        RAISERROR('Question must belong to the same course as exam', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- 2) Track supervisor validation (single robust trigger)
-- Ensures: if supervisor_id is provided, the referenced instructor exists AND belongs to the same track.
CREATE OR ALTER TRIGGER dbo.trg_track_supervisor_validation
ON dbo.Track
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted t
        WHERE t.supervisor_id IS NOT NULL
          AND NOT EXISTS (
                SELECT 1
                FROM dbo.Instructor i
                WHERE i.ins_id = t.supervisor_id
                  AND i.track_id = t.track_id
          )
    )
    BEGIN
        RAISERROR('Supervisor must exist and belong to the same track (or assign instructor.track_id first)', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- 3) Prevent answers for non-attempted exams
CREATE OR ALTER TRIGGER dbo.trg_student_answer_invalid
ON dbo.Student_Exam_Answer
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN dbo.Student_Exam se
          ON se.student_id = i.student_id AND se.exam_id = i.exam_id
        WHERE se.student_id IS NULL
    )
    BEGIN
        RAISERROR('Cannot insert answer: student did not take the exam', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- 4) Validate is_correct values in answers
CREATE OR ALTER TRIGGER dbo.trg_answer_correctness
ON dbo.Student_Exam_Answer
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.is_correct NOT IN (0,1) OR i.is_correct IS NULL
    )
    BEGIN
        RAISERROR('is_correct must be 0 or 1 and not NULL', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO
