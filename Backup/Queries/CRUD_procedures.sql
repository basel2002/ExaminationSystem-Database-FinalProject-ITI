USE ExaminationSystem;
GO

SET NOCOUNT ON;
GO

/* =========================================================
   BRANCH
========================================================= */
CREATE OR ALTER PROCEDURE Branch_Insert
    @id INT,
    @name VARCHAR(50),
    @loc VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF EXISTS (SELECT 1 FROM Branch WHERE branch_id = @id)
            THROW 50001, 'Branch id already exists.', 1;

        INSERT INTO Branch(branch_id, branch_name, branch_location)
        VALUES(@id, @name, @loc);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Branch_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Branch;
END;
GO

CREATE OR ALTER PROCEDURE Branch_GetById
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Branch WHERE branch_id = @id;
END;
GO

CREATE OR ALTER PROCEDURE Branch_Update
    @id INT,
    @name VARCHAR(50),
    @loc VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Branch WHERE branch_id = @id)
            THROW 50002, 'Branch not found.', 1;

        UPDATE Branch
        SET branch_name = @name,
            branch_location = @loc
        WHERE branch_id = @id;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Branch_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        -- Prevent deletion if related Branch_Track rows exist
        IF EXISTS (SELECT 1 FROM Branch_Track WHERE branch_id = @id)
            THROW 50003, 'Cannot delete branch: related tracks exist.', 1;

        DELETE FROM Branch WHERE branch_id = @id;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   COURSE
========================================================= */
CREATE OR ALTER PROCEDURE Course_Insert
    @id INT,
    @name VARCHAR(50),
    @hours INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF EXISTS (SELECT 1 FROM Course WHERE course_id = @id)
            THROW 51001, 'Course id already exists.', 1;

        INSERT INTO Course(course_id, course_name, hours)
        VALUES(@id, @name, @hours);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Course_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Course;
END;
GO

CREATE OR ALTER PROCEDURE Course_GetById
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Course WHERE course_id = @id;
END;
GO

CREATE OR ALTER PROCEDURE Course_Update
    @id INT,
    @name VARCHAR(50),
    @hours INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Course WHERE course_id = @id)
            THROW 51002, 'Course not found.', 1;

        UPDATE Course
        SET course_name = @name,
            hours = @hours
        WHERE course_id = @id;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Course_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        -- Prevent delete if dependent entities exist (Topic, Track_Course, Exam, Question)
        IF EXISTS (SELECT 1 FROM Topic WHERE course_id = @id)
            THROW 51003, 'Cannot delete course: related topics exist.', 1;
        IF EXISTS (SELECT 1 FROM Track_Course WHERE course_id = @id)
            THROW 51004, 'Cannot delete course: course assigned to tracks.', 1;
        IF EXISTS (SELECT 1 FROM Exam WHERE course_id = @id)
            THROW 51005, 'Cannot delete course: exams exist.', 1;
        IF EXISTS (SELECT 1 FROM Question WHERE course_id = @id)
            THROW 51006, 'Cannot delete course: question bank exists.', 1;

        DELETE FROM Course WHERE course_id = @id;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   TRACK
========================================================= */
CREATE OR ALTER PROCEDURE Track_Insert
    @id INT,
    @name VARCHAR(50),
    @sup INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF EXISTS (SELECT 1 FROM Track WHERE track_id = @id)
            THROW 52001, 'Track id already exists.', 1;

        -- If supervisor provided, ensure instructor exists
        IF @sup IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Instructor WHERE ins_id = @sup)
            THROW 52002, 'Supervisor instructor not found.', 1;

        INSERT INTO Track(track_id, track_name, supervisor_id)
        VALUES(@id, @name, @sup);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Track_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Track;
END;
GO

CREATE OR ALTER PROCEDURE Track_GetById
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Track WHERE track_id = @id;
END;
GO

CREATE OR ALTER PROCEDURE Track_Update
    @id INT,
    @name VARCHAR(50),
    @sup INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Track WHERE track_id = @id)
            THROW 52003, 'Track not found.', 1;

        IF @sup IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Instructor WHERE ins_id = @sup)
            THROW 52004, 'Supervisor instructor not found.', 1;

        UPDATE Track
        SET track_name = @name,
            supervisor_id = @sup
        WHERE track_id = @id;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Track_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF EXISTS (SELECT 1 FROM Branch_Track WHERE track_id = @id)
            THROW 52005, 'Cannot delete track: offered in branches.', 1;
        IF EXISTS (SELECT 1 FROM Track_Course WHERE track_id = @id)
            THROW 52006, 'Cannot delete track: assigned courses exist.', 1;
        IF EXISTS (SELECT 1 FROM Instructor WHERE track_id = @id)
            THROW 52007, 'Cannot delete track: instructors assigned.', 1;

        DELETE FROM Track WHERE track_id = @id;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   TOPIC
========================================================= */
CREATE OR ALTER PROCEDURE Topic_Insert
    @id INT,
    @name VARCHAR(50),
    @course INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Course WHERE course_id = @course)
            THROW 53001, 'Course not found for topic.', 1;
        IF EXISTS (SELECT 1 FROM Topic WHERE topic_id = @id)
            THROW 53002, 'Topic id already exists.', 1;

        INSERT INTO Topic(topic_id, topic_name, course_id)
        VALUES(@id, @name, @course);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Topic_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Topic;
END;
GO

CREATE OR ALTER PROCEDURE Topic_GetById
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Topic WHERE topic_id = @id;
END;
GO

CREATE OR ALTER PROCEDURE Topic_Update
    @id INT,
    @name VARCHAR(50),
    @course INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Topic WHERE topic_id = @id)
            THROW 53003, 'Topic not found.', 1;
        IF NOT EXISTS (SELECT 1 FROM Course WHERE course_id = @course)
            THROW 53004, 'Course not found.', 1;

        UPDATE Topic
        SET Topic_Name = @name, course_id = @course
        WHERE topic_id = @id;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Topic_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF EXISTS (SELECT 1 FROM Topic WHERE topic_id = @id)
        BEGIN
            DELETE FROM Topic WHERE topic_id = @id;
        END
        ELSE
            THROW 53005, 'Topic not found.', 1;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   INSTRUCTOR
========================================================= */
CREATE OR ALTER PROCEDURE Instructor_Insert
    @id INT,
    @fn VARCHAR(50),
    @ln VARCHAR(50),
    @g CHAR(1),
    @age INT,
    @track INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF EXISTS (SELECT 1 FROM Instructor WHERE ins_id = @id)
            THROW 54001, 'Instructor id already exists.', 1;
        IF @track IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Track WHERE track_id = @track)
            THROW 54002, 'Track not found.', 1;

        INSERT INTO Instructor(ins_id, ins_fname, ins_lname, gender, age, Track_ID)
        VALUES(@id, @fn, @ln, @g, @age, @track);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Instructor_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Instructor;
END;
GO

CREATE OR ALTER PROCEDURE Instructor_GetById
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Instructor WHERE Ins_Id = @id;
END;
GO

CREATE OR ALTER PROCEDURE Instructor_Update
    @id INT,
    @fn VARCHAR(50),
    @ln VARCHAR(50),
    @g CHAR(1),
    @age INT,
    @track INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Instructor WHERE ins_id = @id)
            THROW 54003, 'Instructor not found.', 1;
        IF @track IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Track WHERE track_id = @track)
            THROW 54004, 'Track not found.', 1;

        UPDATE Instructor
        SET ins_fname = @fn,
            ins_lname = @ln,
            gender = @g,
            age = @age,
            Track_ID = @track
        WHERE ins_id = @id;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Instructor_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        -- prevent delete if instructor supervises a Track
        IF EXISTS (SELECT 1 FROM Track WHERE supervisor_id = @id)
            THROW 54005, 'Cannot delete instructor: supervises a track.', 1;
        -- prevent delete if assigned to Instructor_Course
        IF EXISTS (SELECT 1 FROM Instructor_Course WHERE ins_id = @id)
            THROW 54006, 'Cannot delete instructor: assigned to courses.', 1;

        DELETE FROM Instructor WHERE ins_id = @id;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   STUDENT
========================================================= */
CREATE OR ALTER PROCEDURE Student_Insert
    @id INT,
    @fn VARCHAR(50),
    @ln VARCHAR(50),
    @age INT,
    @g CHAR(1),
    @track INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF EXISTS (SELECT 1 FROM Student WHERE student_id = @id)
            THROW 55001, 'Student id already exists.', 1;
        IF NOT EXISTS (SELECT 1 FROM Track WHERE track_id = @track)
            THROW 55002, 'Track not found.', 1;

        INSERT INTO Student(student_id, student_fname, student_lname, Student_Age, Student_gender, Track_Id)
        VALUES (@id, @fn, @ln, @age, @g, @track);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Student_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Student;
END;
GO

CREATE OR ALTER PROCEDURE Student_GetById
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Student WHERE student_id = @id;
END;
GO

CREATE OR ALTER PROCEDURE Student_Update
    @id INT,
    @fn VARCHAR(50),
    @ln VARCHAR(50),
    @age INT,
    @g CHAR(1),
    @track INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Student WHERE student_id = @id)
            THROW 55003, 'Student not found.', 1;
        IF NOT EXISTS (SELECT 1 FROM Track WHERE track_id = @track)
            THROW 55004, 'Track not found.', 1;

        UPDATE Student
        SET student_fname = @fn,
            student_lname = @ln,
            Student_Age = @age,
            Student_gender = @g,
            Track_Id = @track
        WHERE student_id = @id;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Student_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        -- prevent delete if student has course enrollments or answers
        IF EXISTS (SELECT 1 FROM Student_Course WHERE student_id = @id)
            THROW 55005, 'Cannot delete student: enrolled in courses.', 1;
        IF EXISTS (SELECT 1 FROM Student_Exam_Answer WHERE student_id = @id)
            THROW 55006, 'Cannot delete student: has exam answers.', 1;

        DELETE FROM Student WHERE student_id = @id;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   QUESTION (COMPOSITE PK)
========================================================= */
CREATE OR ALTER PROCEDURE Question_Insert
    @course INT,
    @qid INT,
    @type VARCHAR(10),
    @desc VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Course WHERE course_id = @course)
            THROW 56001, 'Course not found.', 1;
        IF EXISTS (SELECT 1 FROM Question WHERE course_id = @course AND question_id = @qid)
            THROW 56002, 'Question already exists.', 1;

        INSERT INTO Question(course_id, question_id, [Type],description)
        VALUES(@course, @qid, @type, @desc);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Question_Get
    @course INT,
    @qid INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Question WHERE course_id = @course AND question_id = @qid;
END;
GO

CREATE OR ALTER PROCEDURE Question_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Question;
END;
GO

CREATE OR ALTER PROCEDURE Question_Update
    @course INT,
    @qid INT,
    @type VARCHAR(10),
    @desc VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Question WHERE course_id = @course AND question_id = @qid)
            THROW 56003, 'Question not found.', 1;

        UPDATE Question
        SET [Type] = @type,
            description = @desc
        WHERE course_id = @course AND question_id = @qid;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Question_Delete
    @course INT,
    @qid INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF EXISTS (SELECT 1 FROM Choice WHERE course_id = @course AND question_id = @qid)
            THROW 56004, 'Cannot delete question: choices exist.', 1;

        DELETE FROM Question WHERE course_id = @course AND question_id = @qid;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   CHOICE (COMPOSITE PK)
========================================================= */
CREATE OR ALTER PROCEDURE Choice_Insert
    @course INT,
    @qid INT,
    @cid INT,
    @text VARCHAR(150),
    @correct BIT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Question WHERE course_id = @course AND question_id = @qid)
            THROW 57001, 'Question not found.', 1;
        IF EXISTS (SELECT 1 FROM Choice WHERE course_id = @course AND question_id = @qid AND choice_id = @cid)
            THROW 57002, 'Choice id already exists for this question.', 1;

        INSERT INTO Choice(course_id, question_id, choice_id, choice_text, is_correct)
        VALUES (@course, @qid, @cid, @text, @correct);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Choice_Get
    @course INT,
    @qid INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Choice WHERE course_id = @course AND question_id = @qid ORDER BY choice_id;
END;
GO

CREATE OR ALTER PROCEDURE Choice_GetById
    @course INT,
    @qid INT,
    @cid INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Choice WHERE course_id = @course AND question_id = @qid AND choice_id = @cid;
END;
GO

CREATE OR ALTER PROCEDURE Choice_Update
    @course INT,
    @qid INT,
    @cid INT,
    @text VARCHAR(150),
    @correct BIT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Choice WHERE course_id = @course AND question_id = @qid AND choice_id = @cid)
            THROW 57003, 'Choice not found.', 1;

        UPDATE Choice
        SET choice_text = @text, is_correct = @correct
        WHERE course_id = @course AND question_id = @qid AND choice_id = @cid;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Choice_Delete
    @course INT,
    @qid INT,
    @cid INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        DELETE FROM Choice
        WHERE course_id = @course AND question_id = @qid AND choice_id = @cid;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   EXAM
========================================================= */
CREATE OR ALTER PROCEDURE Exam_Insert
    @id INT,
    @date DATE,
    @dur INT,
    @course INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF EXISTS (SELECT 1 FROM Exam WHERE exam_id = @id)
            THROW 58001, 'Exam id already exists.', 1;
        IF NOT EXISTS (SELECT 1 FROM Course WHERE course_id = @course)
            THROW 58002, 'Course not found.', 1;

        INSERT INTO Exam(exam_id, exam_date, Duration, Course_ID)
        VALUES(@id, @date, @dur, @course);
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Exam_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Exam;
END;
GO

CREATE OR ALTER PROCEDURE Exam_GetById
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Exam WHERE exam_id = @id;
END;
GO

CREATE OR ALTER PROCEDURE Exam_Update
    @id INT,
    @date DATE,
    @dur INT,
    @course INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Exam WHERE exam_id = @id)
            THROW 58003, 'Exam not found.', 1;
        IF NOT EXISTS (SELECT 1 FROM Course WHERE course_id = @course)
            THROW 58004, 'Course not found.', 1;

        UPDATE Exam
        SET exam_date = @date, Duration = @dur, Course_ID = @course
        WHERE exam_id = @id;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Exam_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF EXISTS (SELECT 1 FROM Student_Exam_Answer WHERE exam_id = @id)
            THROW 58005, 'Cannot delete exam: student answers exist.', 1;

        DELETE FROM Exam WHERE exam_id = @id;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   EXAM_QUESTION (JUNCTION)
========================================================= */
CREATE OR ALTER PROCEDURE ExamQuestion_Insert
    @e INT,
    @c INT,
    @q INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Exam WHERE exam_id = @e)
            THROW 59001, 'Exam not found.', 1;
        IF NOT EXISTS (SELECT 1 FROM Question WHERE course_id = @c AND question_id = @q)
            THROW 59002, 'Question not found.', 1;
        IF EXISTS (SELECT 1 FROM Exam_Question WHERE exam_id = @e AND course_id = @c AND question_id = @q)
            THROW 59003, 'Question already added to exam.', 1;

        INSERT INTO Exam_Question(exam_id, course_id, question_id)
        VALUES(@e, @c, @q);
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ExamQuestion_Get
    @e INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Exam_Question WHERE exam_id = @e ORDER BY question_id;
END;
GO

CREATE OR ALTER PROCEDURE ExamQuestion_Delete
    @e INT,
    @c INT,
    @q INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        DELETE FROM Exam_Question WHERE exam_id = @e AND course_id = @c AND question_id = @q;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   JUNCTION TABLES: Branch_Track, Track_Course, Instructor_Course
========================================================= */
CREATE OR ALTER PROCEDURE BranchTrack_Insert
    @b INT,
    @t INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Branch WHERE branch_id = @b)
            THROW 60001, 'Branch not found.', 1;
        IF NOT EXISTS (SELECT 1 FROM Track WHERE track_id = @t)
            THROW 60002, 'Track not found.', 1;
        IF EXISTS (SELECT 1 FROM Branch_Track WHERE branch_id = @b AND track_id = @t)
            THROW 60003, 'Mapping already exists.', 1;

        INSERT INTO Branch_Track(branch_id, track_id) VALUES(@b, @t);
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE BranchTrack_Delete
    @b INT,
    @t INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Branch_Track WHERE branch_id = @b AND track_id = @t;
END;
GO

CREATE OR ALTER PROCEDURE TrackCourse_Insert
    @t INT,
    @c INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Track WHERE track_id = @t)
            THROW 60011, 'Track not found.', 1;
        IF NOT EXISTS (SELECT 1 FROM Course WHERE course_id = @c)
            THROW 60012, 'Course not found.', 1;
        IF EXISTS (SELECT 1 FROM Track_Course WHERE track_id = @t AND course_id = @c)
            THROW 60013, 'Mapping exists.', 1;

        INSERT INTO Track_Course(track_id, course_id) VALUES(@t, @c);
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE TrackCourse_Delete
    @t INT,
    @c INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Track_Course WHERE track_id = @t AND course_id = @c;
END;
GO

CREATE OR ALTER PROCEDURE InstructorCourse_Insert
    @i INT,
    @c INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Instructor WHERE ins_id = @i)
            THROW 60021, 'Instructor not found.', 1;
        IF NOT EXISTS (SELECT 1 FROM Course WHERE course_id = @c)
            THROW 60022, 'Course not found.', 1;
        IF EXISTS (SELECT 1 FROM Instructor_Course WHERE ins_id = @i AND course_id = @c)
            THROW 60023, 'Mapping exists.', 1;

        INSERT INTO Instructor_Course(ins_id, course_id) VALUES(@i, @c);
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE InstructorCourse_Delete
    @i INT,
    @c INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Instructor_Course WHERE ins_id = @i AND course_id = @c;
END;
GO

/* =========================================================
   STUDENT_COURSE
========================================================= */
CREATE OR ALTER PROCEDURE StudentCourse_Insert
    @s INT,
    @c INT,
    @g INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Student WHERE student_id = @s)
            THROW 61001, 'Student not found.', 1;
        IF NOT EXISTS (SELECT 1 FROM Course WHERE course_id = @c)
            THROW 61002, 'Course not found.', 1;
        IF EXISTS (SELECT 1 FROM Student_Course WHERE student_id = @s AND course_id = @c)
            THROW 61003, 'Student already enrolled in this course.', 1;

        INSERT INTO Student_Course(student_id, course_id, grade)
        VALUES(@s, @c, @g);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE StudentCourse_Update
    @s INT,
    @c INT,
    @g INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Student_Course WHERE student_id = @s AND course_id = @c)
            THROW 61004, 'Enrollment not found.', 1;

        UPDATE Student_Course SET grade = @g WHERE student_id = @s AND course_id = @c;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE StudentCourse_Delete
    @s INT,
    @c INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Student_Course WHERE student_id = @s AND course_id = @c;
END;
GO

/* =========================================================
   STUDENT_EXAM
========================================================= */
CREATE OR ALTER PROCEDURE StudentExam_Insert
    @s INT,
    @e INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM Student WHERE student_id = @s)
            THROW 62001, 'Student not found.', 1;
        IF NOT EXISTS (SELECT 1 FROM Exam WHERE exam_id = @e)
            THROW 62002, 'Exam not found.', 1;
        IF EXISTS (SELECT 1 FROM Student_Exam WHERE student_id = @s AND exam_id = @e)
            THROW 62003, 'Student already assigned to this exam.', 1;

        INSERT INTO Student_Exam(student_id, exam_id, total_grade)
        VALUES(@s, @e, NULL);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE StudentExam_Get
    @s INT,
    @e INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Student_Exam WHERE student_id = @s AND exam_id = @e;
END;
GO

CREATE OR ALTER PROCEDURE StudentExam_Delete
    @s INT,
    @e INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        -- Do not allow deleting an assignment if answers exist
        IF EXISTS (SELECT 1 FROM Student_Exam_Answer WHERE student_id = @s AND exam_id = @e)
            THROW 62004, 'Cannot delete student_exam: answers exist.', 1;

        DELETE FROM Student_Exam WHERE student_id = @s AND exam_id = @e;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   STUDENT_EXAM_ANSWER (READ ONLY)
   -- This is intentionally read-only via SP. Answers are inserted
   -- via ExamAnswer procedure only (your existing logic).
========================================================= */
CREATE OR ALTER PROCEDURE StudentExamAnswer_Get
    @s INT,
    @e INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Student_Exam_Answer
    WHERE student_id = @s AND exam_id = @e
    ORDER BY course_id, question_id;
END;
GO

-- End of CRUD procedures script
