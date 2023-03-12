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

-- 12
CREATE TABLE student_address
(
    id         int,
    city 	   varchar(50),
    street     varchar(50),
	building   int,
	student_id int,
    CONSTRAINT "student_address_pk" PRIMARY KEY (id),
    CONSTRAINT student_address_to_student_rel FOREIGN KEY (student_id)
        REFERENCES student(id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

-- create trigger
CREATE OR REPLACE FUNCTION stop_update_on_student_address()
 	RETURNS TRIGGER
	LANGUAGE plpgsql
AS
$BODY$
BEGIN
	IF NEW.id <> OLD.id
		OR NEW.city <> OLD.city 
		OR NEW.street <> OLD.street
		OR NEW.building <> OLD.building
		OR NEW.student_id <> OLD.student_id 
		THEN RAISE EXCEPTION 'Not allowed to update any fields';
	END IF;
	RETURN NEW;
END;
$BODY$

CREATE TRIGGER avoid_student_address_update
BEFORE UPDATE
ON student_address
FOR EACH ROW
EXECUTE PROCEDURE stop_update_on_student_address();

-- test student addresses
INSERT INTO student_address VALUES(1, 'Lviv', 'Mazepa', 14, 1);
INSERT INTO student_address VALUES(2, 'Lviv', 'Shevchenka', 134, 2);
INSERT INTO student_address VALUES(3, 'Lviv', 'Chornovola', 141, 3);

-- test to update student addresses
UPDATE student_address SET id = '5' where id = 1;
UPDATE student_address SET city = 'Kyiv' where id = 1;
UPDATE student_address SET street = 'Panasa' where id = 1;
UPDATE student_address SET building = 2 where id = 1;
UPDATE student_address SET student_id = 192 where id = 1;