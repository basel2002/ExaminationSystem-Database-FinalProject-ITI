-- Course_Topics
USE [ExaminationSystem]
GO
/****** Object:  StoredProcedure [dbo].[Course_Topics]    Script Date: 12/30/2025 9:37:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER proc [dbo].[Course_Topics]
@crs_id int
as
select c.course_name, t.topic_name
from course c inner join topic t
on c.course_id = t.course_id
where c.course_id = @crs_id





--Exam_Question

USE [ExaminationSystem]
GO
/****** Object:  StoredProcedure [dbo].[Exam_Questions]    Script Date: 12/30/2025 9:38:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER proc [dbo].[Exam_Questions] 
@ex_id int 
as

select eq.exam_id,q.description , c.choice_text
from Exam_Question eq 
inner join question q
on  eq.question_id = q.question_id and eq.course_id = q.course_id
inner join  Choice c
on eq.question_id = c.question_id and eq.course_id = c.course_id
where eq.exam_id = @ex_id

--Gets_Student_By_Track_Id

USE [ExaminationSystem]
GO
/****** Object:  StoredProcedure [dbo].[GetStudentsByTrackId]    Script Date: 12/30/2025 9:39:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[GetStudentsByTrackId]
    @TrackId INT , @BranchId INT
AS
BEGIN

    SELECT
        s.Student_Id,
        s.student_fname,
        s.student_lname,
        s.student_age,
        s.student_gender,
        b.branch_name,
        t.track_name
    FROM Student s
    INNER JOIN Track t
        ON s.Track_Id = t.Track_Id
    INNER JOIN Branch_Track bt on t.track_id = bt.track_id 
    INNER JOIN  Branch b on bt.branch_id = b.branch_id
    WHERE s.Track_Id = @TrackId and b.branch_id = @BranchId
    ORDER BY s.student_fname;
END



--Instructor_Courses 

USE [ExaminationSystem]
GO
/****** Object:  StoredProcedure [dbo].[Instructor_Courses]    Script Date: 12/30/2025 9:40:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER proc [dbo].[Instructor_Courses]
@ins_id int
as
select ic.course_id as course ,count(sc.student_id) as Number_Of_Student
from instructor i inner join instructor_course ic 
on i.ins_id = ic.ins_id 
inner join student_course sc
on ic.course_id = sc.course_id
where i.ins_id = @ins_id
group by ic.course_id



--Student_Exam_Model_Answer
USE [ExaminationSystem]
GO
/****** Object:  StoredProcedure [dbo].[Student_Exam_Model_Answer]    Script Date: 12/30/2025 9:41:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER proc [dbo].[Student_Exam_Model_Answer]
@exam_id int ,
@student_id int
as

select q.description,
	sc.choice_text as student_answer
	, c.choice_text as correct_answer,sa.student_id,sa.exam_id

from student_exam_answer sa 
inner join Question q 
on sa.question_id = q.question_id and sa.course_id = q.course_id

inner join choice c
on q.question_id = c.question_id and q.course_id = c.course_id
And c.is_correct = 1 and sa.exam_id =@exam_id and sa.student_id = @student_id

inner JOIN Choice sc
on sc.course_id = sa.course_id
And sc.question_id = sa.question_id
And sc.choice_id = cast(sa.stud_answer AS int)


--Student_Grade

USE [ExaminationSystem]
GO
/****** Object:  StoredProcedure [dbo].[Student_grade]    Script Date: 12/30/2025 9:41:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER proc [dbo].[Student_grade] 
@st_id int
as
select concat(s.student_fname , ' ' ,s.student_lname) as  Full_Name ,course_name ,grade
from student s inner join student_course sc 
on s.student_id = sc.student_id
inner join course c
on c.course_id = sc.course_id
where s.student_id = @st_id







