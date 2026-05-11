USE ExaminationSystem;
GO
SET NOCOUNT ON;
---------------------------------------------------------------------
-- OPTIONAL: CLEAN EXISTING DATA (UNCOMMENT IF YOU WANT A FRESH START)
---------------------------------------------------------------------
/*
EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

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

EXEC sp_msforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
GO
*/
---------------------------------------------------------------------
-- 1) Branches (real locations) 
---------------------------------------------------------------------
-- Comment: realistic branch entries including Ismailia
INSERT INTO Branch (branch_id, branch_name, branch_location) VALUES
(1, 'Smart Village', 'Smart Village, Giza'),
(2, 'Knowledge City', 'New Administrative Capital, Cairo'),
(3, 'Alexandria', 'Alexandria, Alexandria Governorate'),
(4, 'Mansoura', 'Mansoura, Dakahlia'),
(5, 'Assiut', 'Assiut, Upper Egypt'),
(6, 'Ismailia', 'Ismailia City, Ismailia Governorate');
GO

---------------------------------------------------------------------
-- 2) Tracks (insert with supervisor_id = NULL to avoid circular FK)
---------------------------------------------------------------------
INSERT INTO Track(track_id, track_name, supervisor_id) VALUES
(100,'Telco-Cloud Engineering', NULL),
(101,'Embedded & Edge Architectures', NULL),
(102,'Open Source Applications Development', NULL),
(103,'Cloud Platform Development', NULL),
(104,'Enterprise & Web Apps Development (Java)', NULL),
(105,'Mobile Applications Development (Native)', NULL),
(106,'Professional Development & BI-infused CRM', NULL),
(107,'Web & User Interface Development', NULL),
(108,'Telecom Applications Development', NULL),
(109,'Mobile Applications Development (Cross Platform)', NULL),
(110,'Integrated Software Development & Architecture', NULL),
(111,'Data Management', NULL);
GO

---------------------------------------------------------------------
-- 3) Branch_Track mapping (where tracks are offered)
---------------------------------------------------------------------
INSERT INTO Branch_Track(branch_id, track_id) VALUES
-- Smart Village
(1,100),(1,102),(1,103),(1,107),(1,111),
-- Knowledge City
(2,100),(2,103),(2,104),(2,111),
-- Alexandria
(3,101),(3,102),(3,107),
-- Mansoura
(4,102),(4,105),
-- Assiut
(5,101),(5,110),
-- Ismailia
(6,106),(6,102),(6,107);
GO

---------------------------------------------------------------------
-- 4) Courses (10 real, as before)
---------------------------------------------------------------------
INSERT INTO Course(course_id, course_name, hours) VALUES
(3001,'Full-Stack Web Development',140),
(3002,'.NET & C# Advanced',120),
(3003,'Java Enterprise Applications',130),
(3004,'Mobile Native Apps (Android/iOS)',110),
(3005,'Cross-Platform Mobile Development',110),
(3006,'Cloud Platforms & DevOps',100),
(3007,'Data Engineering & Warehousing',130),
(3008,'Telecom Application Design',120),
(3009,'Embedded & Edge Programming',140),
(3010,'Open Source Application Development',120);
GO

---------------------------------------------------------------------
-- 5) Track_Course associations (M:N)
---------------------------------------------------------------------
INSERT INTO Track_Course(track_id, course_id) VALUES
(107,3001),(110,3001),
(106,3002),(110,3002),
(104,3003),(110,3003),
(105,3004),
(109,3005),
(100,3006),(103,3006),
(111,3007),
(108,3008),
(101,3009),
(102,3010);
GO

---------------------------------------------------------------------
-- 6) Topics per course (meaningful topics)
---------------------------------------------------------------------
INSERT INTO Topic(topic_id, topic_name, course_id) VALUES
-- 3001 Full-Stack Web
(5001,'HTML & Accessibility',3001),(5002,'CSS & Layouts',3001),(5003,'Frontend Frameworks (React/Vue)',3001),
(5004,'Backend APIs (Node/Express)',3001),
-- 3002 .NET
(5011,'C# Advanced',3002),(5012,'.NET Core Web API',3002),(5013,'EF Core & Migrations',3002),
-- 3003 Java
(5021,'Spring Boot',3003),(5022,'JPA & Hibernate',3003),(5023,'RESTful Services',3003),
-- 3004 Mobile Native
(5031,'Android Lifecycle & Activities',3004),(5032,'iOS SwiftUI & ViewControllers',3004),
-- 3005 Cross Platform
(5041,'Flutter Widgets & State',3005),(5042,'React Native Bridge & Modules',3005),
-- 3006 Cloud
(5051,'Kubernetes & Containers',3006),(5052,'CI/CD Pipelines & IaC',3006),
-- 3007 Data
(5061,'ETL Design',3007),(5062,'Data Warehousing & Star Schema',3007),(5063,'Big Data Basics',3007),
-- 3008 Telecom
(5071,'SIP & VoIP Fundamentals',3008),(5072,'IMS & Protocols',3008),
-- 3009 Embedded
(5081,'Microcontrollers & Peripherals',3009),(5082,'RTOS basics',3009),
-- 3010 Open Source
(5091,'OSS Licensing (GPL/MIT)',3010),(5092,'Open Source Contribution Workflow',3010);
GO

---------------------------------------------------------------------
-- 7) Instructors (~14) with real names and realistic assignments
---------------------------------------------------------------------
-- Comment: All names are realistic Egyptian/Arabic names. Track_id set to the instructor's main supervision/assignment.
INSERT INTO Instructor(ins_id, ins_fname, ins_lname, gender, age, track_id) VALUES
(9001,'Rami','Abou Nagi','M',45,111),    -- Data Management (supervisor)
(9002,'Mohamed','Throut','M',42,106),    -- Professional Dev & BI (Ismailia supervisor)
(9003,'Heba','Saleh','F',38,100),
(9004,'Omar','Khaled','M',36,104),
(9005,'Nada','Ibrahim','F',34,107),
(9006,'Amr','Youssef','M',41,101),
(9007,'Mohamed','Adel','M',44,108),
(9008,'Sara','Mostafa','F',35,110),
(9009,'Ahmed','Samir','M',39,102),
(9010,'Kareem','Hassan','M',37,102),
(9011,'Rania','Fouad','F',33,103),
(9012,'Youssef','Zaki','M',35,105),
(9013,'Dina','Younes','F',30,110),
(9014,'Walid','Fathy','M',40,NULL); -- Walid unassigned
GO

---------------------------------------------------------------------
-- 8) Assign Track supervisors (update Track.supervisor_id)
---------------------------------------------------------------------
-- Comment: Assign the track supervisors; instructors already have track_id matching their supervised track.
UPDATE Track SET supervisor_id = 9003 WHERE track_id = 100; -- Heba supervises Telco-Cloud
UPDATE Track SET supervisor_id = 9006 WHERE track_id = 101; -- Amr supervises Embedded
UPDATE Track SET supervisor_id = 9010 WHERE track_id = 102; -- Kareem supervises Open Source
UPDATE Track SET supervisor_id = 9011 WHERE track_id = 103; -- Rania supervises Cloud Platform
UPDATE Track SET supervisor_id = 9004 WHERE track_id = 104; -- Omar supervises Java
UPDATE Track SET supervisor_id = 9012 WHERE track_id = 105; -- Youssef supervises Mobile Native
UPDATE Track SET supervisor_id = 9002 WHERE track_id = 106; -- Mohamed Throut supervises Professional Dev & BI (Ismailia)
UPDATE Track SET supervisor_id = 9005 WHERE track_id = 107; -- Nada supervises Web & UI
UPDATE Track SET supervisor_id = 9007 WHERE track_id = 108; -- Mohamed Adel supervises Telecom Apps
-- leave 109 without supervisor for flexibility
UPDATE Track SET supervisor_id = 9013 WHERE track_id = 110; -- Dina supervises Integrated SW
UPDATE Track SET supervisor_id = 9001 WHERE track_id = 111; -- Rami supervises Data Management
GO

---------------------------------------------------------------------
-- 9) Instructor_Course assignments (map instructors to courses)
---------------------------------------------------------------------
INSERT INTO Instructor_Course(ins_id, course_id) VALUES
(9001,3007), -- Rami -> Data Engineering
(9002,3002), -- Mohamed Throut -> .NET & Professional Dev
(9003,3006), -- Heba -> Cloud Platforms
(9004,3003), -- Omar -> Java Enterprise
(9005,3001), -- Nada -> Full-Stack Web
(9006,3009), -- Amr -> Embedded
(9007,3008), -- Mohamed Adel -> Telecom
(9008,3003), -- Sara -> Java
(9009,3010), -- Ahmed Samir -> Open Source
(9010,3010), -- Kareem -> Open Source
(9011,3006), -- Rania -> Cloud Platform
(9012,3004), -- Youssef -> Mobile Native
(9013,3001), -- Dina -> Full-Stack Web
(9014,3005); -- Walid -> Cross-Platform
GO

---------------------------------------------------------------------
-- 10) Students (50 real-sounding Egyptian names)
---------------------------------------------------------------------
-- Comment: explicit inserts for 50 real-style names (IDs 4001..4050)
INSERT INTO Student(student_id, student_fname, student_lname, student_age, student_gender, track_id) VALUES
(4001,'Mohamed','Ali',22,'M',100),
(4002,'Omar','Hassan',23,'M',100),
(4003,'Ahmed','Mahmoud',21,'M',101),
(4004,'Youssef','Mohamed',24,'M',101),
(4005,'Mostafa','Salah',22,'M',102),
(4006,'Mahmoud','Ibrahim',25,'M',102),
(4007,'Karim','Fathy',20,'M',103),
(4008,'Ibrahim','Abdelrahman',26,'M',103),
(4009,'Amr','Hany',27,'M',104),
(4010,'Tamer','Ibrahim',22,'M',104),
(4011,'Sara','Mohamed',21,'F',105),
(4012,'Nada','Saeed',23,'F',105),
(4013,'Dina','Hassan',22,'F',106),
(4014,'Mariam','Fathy',24,'F',106),
(4015,'Rania','Adel',25,'F',107),
(4016,'Nour','Youssef',20,'F',107),
(4017,'Salma','Kamal',22,'F',108),
(4018,'Laila','Mostafa',23,'F',108),
(4019,'Hoda','Samir',24,'F',109),
(4020,'Reem','Gamal',21,'F',109),
(4021,'Hussein','Tarek',22,'M',110),
(4022,'Kareem','Saeed',23,'M',110),
(4023,'Ashraf','Ragab',26,'M',111),
(4024,'Walid','Salah',24,'M',111),
(4025,'Faten','Khaled',22,'F',100),
(4026,'Hala','Mostafa',25,'F',101),
(4027,'Sahar','Ibrahim',23,'F',102),
(4028,'Shady','Nabil',24,'M',103),
(4029,'Mona','Abdel',26,'F',104),
(4030,'Eman','Hani',27,'F',105),
(4031,'Ramy','Younis',22,'M',106),
(4032,'Yara','Mahmoud',21,'F',107),
(4033,'Salma','Nasser',22,'F',108),
(4034,'Mai','Othman',23,'F',109),
(4035,'Ziad','Kamel',24,'M',110),
(4036,'Khaled','Farouk',25,'M',111),
(4037,'Mervat','Sami',28,'F',100),
(4038,'Ehab','Fouad',29,'M',101),
(4039,'Lamia','Ibrahim',30,'F',102),
(4040,'Nermin','Tarek',28,'F',103),
(4041,'Nadia','Kamal',26,'F',104),
(4042,'Saeed','Hassib',27,'M',105),
(4043,'Basma','Sherif',24,'F',106),
(4044,'Ragda','Mahmoud',23,'F',107),
(4045,'Hazem','Salah',25,'M',108),
(4046,'Tarek','Hassan',26,'M',109),
(4047,'Fayrouz','Mahmoud',22,'F',110),
(4048,'Ibtihal','Yousef',23,'F',111),
(4049,'Ibrahim','Khalil',24,'M',100),
(4050,'Sherif','Adly',25,'M',101);
GO

---------------------------------------------------------------------
-- 11) Student_Course enrollments (each student in 2..4 courses, real assignment)
---------------------------------------------------------------------
-- Comment: assign each student to 2-4 courses, but such that many have at least one course relevant to their track
DECLARE @sid INT = 4001;
WHILE @sid <= 4050
BEGIN
    DECLARE @cnt INT = 2 + (ABS(CHECKSUM(NEWID())) % 3); -- 2..4
    DECLARE @k INT = 1;
    WHILE @k <= @cnt
    BEGIN
        -- choose a course with slight bias: students more likely to enroll in courses mapped to their track
        DECLARE @stuTrack INT = (SELECT track_id FROM Student WHERE student_id = @sid);
        DECLARE @c INT;
        IF (ABS(CHECKSUM(NEWID())) % 100) < 60
        BEGIN
            -- pick a course that belongs to the student's track if exists
            SELECT TOP 1 @c = tc.course_id
            FROM Track_Course tc
            WHERE tc.track_id = @stuTrack
            ORDER BY NEWID();
        END
        IF @c IS NULL
            SET @c = 3001 + (ABS(CHECKSUM(NEWID())) % 10); -- fallback course 3001..3010

        IF NOT EXISTS (SELECT 1 FROM Student_Course WHERE student_id = @sid AND course_id = @c)
        BEGIN
            INSERT INTO Student_Course(student_id, course_id, grade)
            VALUES(@sid, @c, 50 + (ABS(CHECKSUM(NEWID())) % 51));
        END

        SET @k = @k + 1;
    END
    SET @sid = @sid + 1;
END;
GO

---------------------------------------------------------------------
-- 12) Build question bank: For EACH course insert 10 MCQ  and 10
--     Questions and choices are domain-appropriate via templates and topic names.
---------------------------------------------------------------------
-------------------------------------------------------------
-- Course 3001: Full-Stack Web Development
-------------------------------------------------------------

-- MCQ
INSERT INTO Question VALUES
(3001,1,'MCQ','Which HTML element is used to define semantic navigation links?'),
(3001,2,'MCQ','Which CSS property is responsible for layout alignment in Flexbox?'),
(3001,3,'MCQ','What does REST stand for in RESTful APIs?'),
(3001,4,'MCQ','Which HTTP method is typically used to update a resource?'),
(3001,5,'MCQ','Which JavaScript keyword declares a block-scoped variable?'),
(3001,6,'MCQ','What is the main purpose of middleware in backend frameworks?'),
(3001,7,'MCQ','Which status code indicates a successful HTTP request?'),
(3001,8,'MCQ','Which database is classified as NoSQL?'),
(3001,9,'MCQ','Which framework is commonly used for frontend SPA development?'),
(3001,10,'MCQ','Which tool is used to bundle frontend assets?');

INSERT INTO Choice VALUES
(3001,1,1,'<nav>',1),(3001,1,2,'<div>',0),(3001,1,3,'<section>',0),(3001,1,4,'<article>',0),
(3001,2,1,'justify-content',1),(3001,2,2,'z-index',0),(3001,2,3,'overflow',0),(3001,2,4,'visibility',0),
(3001,3,1,'Representational State Transfer',1),(3001,3,2,'Remote Server Technology',0),(3001,3,3,'Relational State Table',0),(3001,3,4,'Response System Type',0),
(3001,4,1,'PUT',1),(3001,4,2,'GET',0),(3001,4,3,'DELETE',0),(3001,4,4,'HEAD',0),
(3001,5,1,'let',1),(3001,5,2,'var',0),(3001,5,3,'constantly',0),(3001,5,4,'static',0),
(3001,6,1,'Handle request processing logic',1),(3001,6,2,'Store database records',0),(3001,6,3,'Render HTML pages',0),(3001,6,4,'Compile source code',0),
(3001,7,1,'200',1),(3001,7,2,'404',0),(3001,7,3,'500',0),(3001,7,4,'301',0),
(3001,8,1,'MongoDB',1),(3001,8,2,'MySQL',0),(3001,8,3,'PostgreSQL',0),(3001,8,4,'Oracle',0),
(3001,9,1,'React',1),(3001,9,2,'Laravel',0),(3001,9,3,'Django',0),(3001,9,4,'Spring',0),
(3001,10,1,'Webpack',1),(3001,10,2,'npm',0),(3001,10,3,'Git',0),(3001,10,4,'Docker',0);

-- TF
INSERT INTO Question VALUES
(3001,11,'TF','HTML is a programming language'),
(3001,12,'TF','CSS can control page layout'),
(3001,13,'TF','JavaScript runs only on the server'),
(3001,14,'TF','REST APIs are stateless'),
(3001,15,'TF','Frontend frameworks can consume APIs');

INSERT INTO Choice VALUES
(3001,11,1,'True',0),(3001,11,2,'False',1),
(3001,12,1,'True',1),(3001,12,2,'False',0),
(3001,13,1,'True',0),(3001,13,2,'False',1),
(3001,14,1,'True',1),(3001,14,2,'False',0),
(3001,15,1,'True',1),(3001,15,2,'False',0);


-------------------------------------------------------------
-- Course 3002: .NET & C# Advanced
-------------------------------------------------------------

-- MCQ
INSERT INTO Question VALUES
(3002,1,'MCQ','Which keyword is used to inherit a class in C#?'),
(3002,2,'MCQ','Which .NET component handles HTTP requests?'),
(3002,3,'MCQ','What does CLR stand for?'),
(3002,4,'MCQ','Which collection does not allow duplicate keys?'),
(3002,5,'MCQ','Which keyword prevents inheritance?'),
(3002,6,'MCQ','What is Entity Framework used for?'),
(3002,7,'MCQ','Which LINQ method filters data?'),
(3002,8,'MCQ','Which type handles asynchronous results?'),
(3002,9,'MCQ','Which access modifier is most restrictive?'),
(3002,10,'MCQ','Which file stores project dependencies?');

INSERT INTO Choice VALUES
(3002,1,1,' : ',1),(3002,1,2,'extends',0),(3002,1,3,'inherits',0),(3002,1,4,'implements',0),
(3002,2,1,'ASP.NET Core',1),(3002,2,2,'WinForms',0),(3002,2,3,'WPF',0),(3002,2,4,'Console',0),
(3002,3,1,'Common Language Runtime',1),(3002,3,2,'Core Logic Router',0),(3002,3,3,'Code Level Resource',0),(3002,3,4,'Compiled Layer Runtime',0),
(3002,4,1,'Dictionary',1),(3002,4,2,'List',0),(3002,4,3,'Array',0),(3002,4,4,'Queue',0),
(3002,5,1,'sealed',1),(3002,5,2,'static',0),(3002,5,3,'private',0),(3002,5,4,'readonly',0),
(3002,6,1,'ORM mapping',1),(3002,6,2,'UI rendering',0),(3002,6,3,'Logging',0),(3002,6,4,'Testing',0),
(3002,7,1,'Where()',1),(3002,7,2,'Select()',0),(3002,7,3,'Join()',0),(3002,7,4,'OrderBy()',0),
(3002,8,1,'Task',1),(3002,8,2,'Thread',0),(3002,8,3,'Delegate',0),(3002,8,4,'Event',0),
(3002,9,1,'private',1),(3002,9,2,'protected',0),(3002,9,3,'internal',0),(3002,9,4,'public',0),
(3002,10,1,'csproj',1),(3002,10,2,'appsettings.json',0),(3002,10,3,'Program.cs',0),(3002,10,4,'Startup.cs',0);

-- TF
INSERT INTO Question VALUES
(3002,11,'TF','C# supports multiple inheritance'),
(3002,12,'TF','LINQ can query collections'),
(3002,13,'TF','EF Core supports migrations'),
(3002,14,'TF','ASP.NET Core is cross-platform'),
(3002,15,'TF','Async improves scalability');

INSERT INTO Choice VALUES
(3002,11,1,'True',0),(3002,11,2,'False',1),
(3002,12,1,'True',1),(3002,12,2,'False',0),
(3002,13,1,'True',1),(3002,13,2,'False',0),
(3002,14,1,'True',1),(3002,14,2,'False',0),
(3002,15,1,'True',1),(3002,15,2,'False',0);



-------------------------------------------------------------
-- Course 3003: Java Enterprise Applications
-------------------------------------------------------------

-- MCQ
INSERT INTO Question VALUES
(3003,1,'MCQ','Which Java framework is commonly used to build enterprise applications?'),
(3003,2,'MCQ','Which annotation is used to define a REST controller in Spring Boot?'),
(3003,3,'MCQ','What does JPA stand for?'),
(3003,4,'MCQ','Which file is used to configure a Spring Boot application?'),
(3003,5,'MCQ','Which HTTP method is typically used to create a new resource?'),
(3003,6,'MCQ','Which layer is responsible for business logic in a typical Java application?'),
(3003,7,'MCQ','Which dependency manager is commonly used with Java projects?'),
(3003,8,'MCQ','Which annotation maps a Java class to a database table?'),
(3003,9,'MCQ','Which scope creates a single bean per Spring container?'),
(3003,10,'MCQ','Which tool is commonly used to package Java applications?');

INSERT INTO Choice VALUES
(3003,1,1,'Spring Framework',1),(3003,1,2,'React',0),(3003,1,3,'Angular',0),(3003,1,4,'Flutter',0),
(3003,2,1,'@RestController',1),(3003,2,2,'@Service',0),(3003,2,3,'@Entity',0),(3003,2,4,'@Repository',0),
(3003,3,1,'Java Persistence API',1),(3003,3,2,'Java Process Interface',0),(3003,3,3,'Java Programming Architecture',0),(3003,3,4,'Java Protocol Adapter',0),
(3003,4,1,'application.properties',1),(3003,4,2,'pom.xml',0),(3003,4,3,'web.xml',0),(3003,4,4,'manifest.mf',0),
(3003,5,1,'POST',1),(3003,5,2,'GET',0),(3003,5,3,'PUT',0),(3003,5,4,'DELETE',0),
(3003,6,1,'Service layer',1),(3003,6,2,'Controller layer',0),(3003,6,3,'Repository layer',0),(3003,6,4,'View layer',0),
(3003,7,1,'Maven',1),(3003,7,2,'npm',0),(3003,7,3,'pip',0),(3003,7,4,'composer',0),
(3003,8,1,'@Entity',1),(3003,8,2,'@TableView',0),(3003,8,3,'@Bean',0),(3003,8,4,'@Component',0),
(3003,9,1,'Singleton',1),(3003,9,2,'Prototype',0),(3003,9,3,'Request',0),(3003,9,4,'Session',0),
(3003,10,1,'JAR',1),(3003,10,2,'ZIP',0),(3003,10,3,'EXE',0),(3003,10,4,'DLL',0);

-- TF
INSERT INTO Question VALUES
(3003,11,'TF','Spring Boot simplifies Java application configuration'),
(3003,12,'TF','JPA can work with multiple databases'),
(3003,13,'TF','Hibernate is an implementation of JPA'),
(3003,14,'TF','REST APIs are stateful by default'),
(3003,15,'TF','Maven manages project dependencies');

INSERT INTO Choice VALUES
(3003,11,1,'True',1),(3003,11,2,'False',0),
(3003,12,1,'True',1),(3003,12,2,'False',0),
(3003,13,1,'True',1),(3003,13,2,'False',0),
(3003,14,1,'True',0),(3003,14,2,'False',1),
(3003,15,1,'True',1),(3003,15,2,'False',0);





-------------------------------------------------------------
-- Course 3006: Cloud Platforms & DevOps
-------------------------------------------------------------

-- MCQ
INSERT INTO Question VALUES
(3006,1,'MCQ','Which cloud service model provides virtual machines?'),
(3006,2,'MCQ','Which tool is commonly used for container orchestration?'),
(3006,3,'MCQ','What does CI/CD stand for?'),
(3006,4,'MCQ','Which platform is a public cloud provider?'),
(3006,5,'MCQ','Which file defines Docker container instructions?'),
(3006,6,'MCQ','Which tool is used for infrastructure as code?'),
(3006,7,'MCQ','Which command builds a Docker image?'),
(3006,8,'MCQ','Which Kubernetes object exposes a service externally?'),
(3006,9,'MCQ','Which metric is important for system availability?'),
(3006,10,'MCQ','Which DevOps practice improves deployment speed?');

INSERT INTO Choice VALUES
(3006,1,1,'IaaS',1),(3006,1,2,'SaaS',0),(3006,1,3,'PaaS',0),(3006,1,4,'FaaS',0),
(3006,2,1,'Kubernetes',1),(3006,2,2,'Jenkins',0),(3006,2,3,'Git',0),(3006,2,4,'Maven',0),
(3006,3,1,'Continuous Integration / Continuous Deployment',1),(3006,3,2,'Code Integration Design',0),(3006,3,3,'Cloud Infrastructure Delivery',0),(3006,3,4,'Centralized DevOps Control',0),
(3006,4,1,'AWS',1),(3006,4,2,'Linux',0),(3006,4,3,'Docker',0),(3006,4,4,'GitHub',0),
(3006,5,1,'Dockerfile',1),(3006,5,2,'docker.yml',0),(3006,5,3,'compose.json',0),(3006,5,4,'container.xml',0),
(3006,6,1,'Terraform',1),(3006,6,2,'Photoshop',0),(3006,6,3,'Postman',0),(3006,6,4,'Slack',0),
(3006,7,1,'docker build',1),(3006,7,2,'docker run',0),(3006,7,3,'docker pull',0),(3006,7,4,'docker exec',0),
(3006,8,1,'LoadBalancer',1),(3006,8,2,'Pod',0),(3006,8,3,'ConfigMap',0),(3006,8,4,'Secret',0),
(3006,9,1,'Uptime',1),(3006,9,2,'Code length',0),(3006,9,3,'Disk color',0),(3006,9,4,'File size',0),
(3006,10,1,'Automation',1),(3006,10,2,'Manual testing',0),(3006,10,3,'Code duplication',0),(3006,10,4,'Delayed releases',0);

-- TF
INSERT INTO Question VALUES
(3006,11,'TF','Containers package application code and dependencies'),
(3006,12,'TF','Kubernetes replaces Docker completely'),
(3006,13,'TF','CI/CD reduces human error'),
(3006,14,'TF','Cloud resources are infinitely scalable'),
(3006,15,'TF','DevOps encourages collaboration');

INSERT INTO Choice VALUES
(3006,11,1,'True',1),(3006,11,2,'False',0),
(3006,12,1,'True',0),(3006,12,2,'False',1),
(3006,13,1,'True',1),(3006,13,2,'False',0),
(3006,14,1,'True',0),(3006,14,2,'False',1),
(3006,15,1,'True',1),(3006,15,2,'False',0);



---------------------------------------------------------------------
-- 13) Create 12 exams and attach 20 random questions each (from course bank)
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 14) For each exam: create 10 student attempts and insert their answers (FK-safe)
--     Student answers are selected as either the correct choice_text or a plausible incorrect choice.
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 15) Verification counts (expected: Questions ~ 400, Choices ~ 1400)
---------------------------------------------------------------------
SELECT COUNT(*) AS BranchCount FROM Branch;
SELECT COUNT(*) AS TrackCount FROM Track;
SELECT COUNT(*) AS InstructorCount FROM Instructor;
SELECT COUNT(*) AS CourseCount FROM Course;
SELECT COUNT(*) AS TopicCount FROM Topic;
SELECT COUNT(*) AS StudentCount FROM Student;
SELECT COUNT(*) AS QuestionCount FROM Question;
SELECT COUNT(*) AS ChoiceCount FROM Choice;
SELECT COUNT(*) AS ExamCount FROM Exam;
SELECT COUNT(*) AS ExamQuestionCount FROM Exam_Question;
SELECT COUNT(*) AS StudentExamCount FROM Student_Exam;
SELECT COUNT(*) AS StudentExamAnswerCount FROM Student_Exam_Answer;
GO

-- Sanity checks:
-- 1) answers without an attempt (should return 0 rows)
SELECT sea.*
FROM Student_Exam_Answer sea
LEFT JOIN Student_Exam se ON sea.student_id = se.student_id AND sea.exam_id = se.exam_id
WHERE se.student_id IS NULL;

-- 2) Exams with questions not matching exam course (should return 0 rows)
SELECT eq.*
FROM Exam_Question eq
JOIN Exam e ON e.exam_id = eq.exam_id
WHERE eq.course_id <> e.course_id;

-- 3) Tracks whose supervisor does not belong to same track (should return 0 rows)
SELECT t.track_id, t.track_name, t.supervisor_id, i.track_id AS instructor_track
FROM Track t
LEFT JOIN Instructor i ON i.ins_id = t.supervisor_id
WHERE t.supervisor_id IS NOT NULL AND (i.track_id IS NULL OR i.track_id <> t.track_id);
GO

---------------------------------------------------------------------
-- 16) Create three additional Track instances for same program name in other branches
--     (allows same-named track with different supervisors per branch as requested earlier)
---------------------------------------------------------------------
-- Insert new supervisors first
INSERT INTO Instructor(ins_id, ins_fname, ins_lname, gender, age, track_id) VALUES
(9101,'Mahmoud','ElSayed','M',43,NULL),
(9102,'Salma','Hany','F',37,NULL),
(9103,'Tarek','Abdelrahman','M',45,NULL);
GO

-- Create new Track rows (same track names but branch-specific instances)
INSERT INTO Track(track_id, track_name, supervisor_id) VALUES
(211,'Data Management',NULL),
(212,'Web & User Interface Development',NULL),
(213,'Cloud Platform Development',NULL);
GO

-- assign instructor.track_id then set as supervisor
UPDATE Instructor SET track_id = 211 WHERE ins_id = 9101;
UPDATE Instructor SET track_id = 212 WHERE ins_id = 9102;
UPDATE Instructor SET track_id = 213 WHERE ins_id = 9103;

UPDATE Track SET supervisor_id = 9101 WHERE track_id = 211;
UPDATE Track SET supervisor_id = 9102 WHERE track_id = 212;
UPDATE Track SET supervisor_id = 9103 WHERE track_id = 213;
GO

-- Map these new track instances to branches
INSERT INTO Branch_Track(branch_id, track_id) VALUES (6,211),(3,212),(5,213);
GO

-- Map courses to these new track instances (reuse courses)
INSERT INTO Track_Course(track_id, course_id) VALUES (211,3007),(212,3001),(213,3006);
GO

-- End of script
