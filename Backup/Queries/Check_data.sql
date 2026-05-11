--Answers with no matching attempt (should be zero rows):

SELECT sea.*
FROM dbo.Student_Exam_Answer sea
LEFT JOIN dbo.Student_Exam se
  ON se.student_id = sea.student_id AND se.exam_id = sea.exam_id
WHERE se.student_id IS NULL;


--Tracks with supervisor that doesn't belong to track (should be zero):

SELECT t.track_id, t.track_name, t.supervisor_id, i.track_id AS instructor_track
FROM dbo.Track t
LEFT JOIN dbo.Instructor i ON i.ins_id = t.supervisor_id
WHERE t.supervisor_id IS NOT NULL AND (i.track_id IS NULL OR i.track_id <> t.track_id);


--Exams with questions from different courses (should be zero):

SELECT eq.*
FROM dbo.Exam_Question eq
JOIN dbo.Exam e ON e.exam_id = eq.exam_id
WHERE eq.course_id <> e.course_id;


--4Student exams count per exam (sanity):

SELECT exam_id, COUNT(*) AS attempts FROM dbo.Student_Exam GROUP BY exam_id;


