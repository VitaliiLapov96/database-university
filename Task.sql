-- 4
--- a
SELECT * FROM student WHERE name = 'Bob';

--- b
SELECT * FROM student WHERE surname LIKE 'Car%';

--- c
SELECT * FROM student WHERE phone_number LIKE '063%';

--- d
SELECT exam_result.mark FROM student 
INNER JOIN exam_result ON student.id = exam_result.student_id 
WHERE student.surname = 'Jenkins';

-- 5
CREATE OR REPLACE FUNCTION update_datetime_column()   
	RETURNS TRIGGER
	LANGUAGE plpgsql
AS
$$
BEGIN
    NEW.updated_datetime = now();
    RETURN NEW;   
END;
$$;

CREATE TRIGGER student_update_datetime 
BEFORE UPDATE ON student 
FOR EACH ROW EXECUTE PROCEDURE update_datetime_column();

-- 6
ALTER TABLE student
ADD CONSTRAINT name_validation 
CHECK (name ~ '^[^@#$]*$');

-- 7
pg_dump -F c -h localhost -p 5432 -U postgres -d university > /Library/PostgreSQL/15/bin/Database/backup/university_backup.sql

-- 8
CREATE OR REPLACE FUNCTION student_average_mark(first_name text, last_name text)
	RETURNS numeric(3,1)
	LANGUAGE plpgsql
AS
$$
DECLARE
  	average_mark numeric(3,1);
BEGIN
	SELECT AVG(exam_result.mark)
	INTO average_mark
	FROM exam_result
	INNER JOIN student ON exam_result.student_id = student.id
	WHERE student.name = first_name AND student.surname = last_name;
   
  	RETURN average_mark;
END;
$$;

-- 9
CREATE OR REPLACE FUNCTION subject_average_mark(subject_name text)
	RETURNS numeric(3,1)
	LANGUAGE plpgsql
AS
$$
DECLARE
  	average_mark numeric(3,1);
BEGIN
	SELECT AVG(exam_result.mark)
	INTO average_mark
	FROM exam_result
	INNER JOIN subject ON exam_result.subject_id = subject.id
	WHERE subject.name = subject_name;
   
  	RETURN average_mark;
END;
$$;

-- 10
CREATE OR REPLACE FUNCTION red_zone(first_name text, last_name text)
	RETURNS bool
	LANGUAGE plpgsql
AS
$$
DECLARE
	red_zone int;
BEGIN
	SELECT count(*)
	INTO red_zone
	FROM exam_result
	INNER JOIN student ON exam_result.student_id = student.id
	WHERE student.name = first_name 
		AND student.surname = last_name
		AND exam_result.mark <= 3;
   	
  	RETURN red_zone <= 3;
END;
$$;