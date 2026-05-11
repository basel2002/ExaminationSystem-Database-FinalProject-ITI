--“Each student is in which track and enrolled in which courses?”

SELECT
    s.student_id,
    s.student_fname,
    s.student_lname,
    t.track_name,
    c.course_name
FROM Student s
JOIN Track t
    ON s.track_id = t.track_id
JOIN Student_Course sc
    ON s.student_id = sc.student_id
JOIN Course c
    ON sc.course_id = c.course_id
ORDER BY
    s.student_id,
    c.course_name;


--WICH Course have questions and how many(tf / mcq)!?

SELECT
    c.course_id,
    c.course_name,
    SUM(CASE WHEN q.type = 'MCQ' THEN 1 ELSE 0 END) AS mcq_count,
    SUM(CASE WHEN q.type = 'TF'  THEN 1 ELSE 0 END) AS tf_count,
    COUNT(*) AS total_questions
FROM Course c
JOIN Question q
    ON c.course_id = q.course_id
GROUP BY
    c.course_id,
    c.course_name
ORDER BY c.course_id;


--Which questions belong to which course (detailed)
SELECT
    c.course_name,
    q.question_id,
    q.type,
    q.description
FROM Course c
JOIN Question q
    ON c.course_id = q.course_id
ORDER BY
    c.course_name,
    q.question_id;





select q.description,
	sc.choice_text as student_answer
	, c.choice_text as correct_answer

from student_exam_answer sa 
inner join Question q 
on sa.question_id = q.question_id and sa.course_id = q.course_id

inner join choice c
on q.question_id = c.question_id and q.course_id = c.course_id
And c.is_correct = 1 and sa.exam_id =5001 and sa.student_id = 4001

inner JOIN Choice sc
on sc.course_id = sa.course_id
And sc.question_id = sa.question_id
And sc.choice_id = cast(sa.stud_answer AS int)


