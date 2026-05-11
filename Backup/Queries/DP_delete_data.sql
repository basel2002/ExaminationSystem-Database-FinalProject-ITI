USE ExaminationSystem;
GO

-- Disable FK checks temporarily (safe for cleanup)
EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
GO

-- Delete in dependency order
DELETE FROM Student_Exam_Answer;
DELETE FROM Student_Exam;
DELETE FROM Exam_Question;
DELETE FROM Exam;

DELETE FROM Student_Course;
DELETE FROM Student;

DELETE FROM Instructor_Course;
DELETE FROM Instructor;

DELETE FROM Track_Course;
DELETE FROM Branch_Track;

DELETE FROM Topic;
DELETE FROM Choice;
DELETE FROM Question;

DELETE FROM Course;
DELETE FROM Track;
DELETE FROM Branch;
GO

-- Re-enable FK checks
EXEC sp_msforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
GO
