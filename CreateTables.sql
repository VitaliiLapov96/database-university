BEGIN;


CREATE TABLE IF NOT EXISTS public.student
(
    id serial NOT NULL,
    name text NOT NULL,
    surname text NOT NULL,
    date_of_birth date NOT NULL,
    phone_number text,
    primary_skill text,
    created_datetime timestamp without time zone NOT NULL,
    updated_datetime timestamp without time zone NOT NULL,
    PRIMARY KEY (id)
);

CREATE INDEX idx_student_surname ON student(surname);

CREATE TABLE IF NOT EXISTS public.subject
(
    id serial NOT NULL,
    name text NOT NULL,
    tutor text NOT NULL,
    student_id integer NOT NULL,
    PRIMARY KEY (id)
);

CREATE INDEX idx_subject_name ON subject(name);

CREATE TABLE IF NOT EXISTS public.exam_result
(
    id serial NOT NULL,
    mark integer NOT NULL,
    student_id integer NOT NULL,
    subject_id integer NOT NULL,
    PRIMARY KEY (id)
);

CREATE INDEX idx_exam_result_mark ON exam_result(mark);

ALTER TABLE IF EXISTS public.subject
    ADD CONSTRAINT student_id FOREIGN KEY (student_id)
    REFERENCES public.student (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.exam_result
    ADD CONSTRAINT student_id FOREIGN KEY (student_id)
    REFERENCES public.student (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.exam_result
    ADD CONSTRAINT subject_id FOREIGN KEY (subject_id)
    REFERENCES public.subject (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

END;