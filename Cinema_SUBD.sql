--
-- PostgreSQL database dump
--

-- Dumped from database version 16.0
-- Dumped by pg_dump version 16.0

-- Started on 2024-02-02 16:06:01

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 25000)
-- Name: main_data; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA main_data;


ALTER SCHEMA main_data OWNER TO postgres;

--
-- TOC entry 2 (class 3079 OID 16384)
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- TOC entry 4864 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


--
-- TOC entry 243 (class 1255 OID 25001)
-- Name: insert_film(character varying, integer, integer, date, time with time zone); Type: PROCEDURE; Schema: main_data; Owner: postgres
--

CREATE PROCEDURE main_data.insert_film(IN g character varying, IN c integer, IN hall_ integer, IN date_ date, IN time_ time with time zone)
    LANGUAGE sql
    AS $$
insert into main_data.film values ((SELECT MAX(id) FROM main_data.film) + 1, g, c);
insert into main_data.session 
values ((SELECT MAX(id) FROM main_data.film), 
hall_, 
date_,  
(SELECT session.price FROM main_data.session WHERE id_hall = hall_ LIMIT 1), 
time_, 
(SELECT MAX(id) FROM main_data.session) + 1);
$$;


ALTER PROCEDURE main_data.insert_film(IN g character varying, IN c integer, IN hall_ integer, IN date_ date, IN time_ time with time zone) OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 25002)
-- Name: insert_trigger_function(); Type: FUNCTION; Schema: main_data; Owner: postgres
--

CREATE FUNCTION main_data.insert_trigger_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
BEGIN
	IF NEW.price >1000 then 
	raise exception 'Прайс слишком большой!';
	end if;
	IF NEW.data <= CURRENT_DATE then 
	raise exception 'Этот день уже прошел !';
	end if;
	IF NEW.time <= CURRENT_TIME then 
	raise exception 'Этот сеанс уже прошел !';
	end if;
	RETURN NEW;
END;
$$;


ALTER FUNCTION main_data.insert_trigger_function() OWNER TO postgres;

--
-- TOC entry 4865 (class 0 OID 0)
-- Dependencies: 244
-- Name: FUNCTION insert_trigger_function(); Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON FUNCTION main_data.insert_trigger_function() IS 'Триггер на вставку билета ограничения по дате и времяни, нельзя вставить билет если сеанс прошел или дата находится в прошлом, а также нельзя вставлять стоимость билета больше 1000  ';


--
-- TOC entry 245 (class 1255 OID 25003)
-- Name: insert_trigger_function_tick(); Type: FUNCTION; Schema: main_data; Owner: postgres
--

CREATE FUNCTION main_data.insert_trigger_function_tick() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
DECLARE COUNTER integer;
id_h integer;
cap integer;
BEGIN
	SELECT COUNT(id_session) INTO COUNTER FROM main_data.ticket
	WHERE NEW.id_session = ticket.id_session;
	SELECT id_hall into id_h FROM  main_data.session 
	WHERE new.id_session = session.id;
	SELECT capacity into cap FROM  main_data.hall 
	WHERE id_h = hall.id;
	IF COUNTER >= cap then
	raise exception 'Билеты закончились!';
	end if;
	RETURN NEW;
END;
$$;


ALTER FUNCTION main_data.insert_trigger_function_tick() OWNER TO postgres;

--
-- TOC entry 4866 (class 0 OID 0)
-- Dependencies: 245
-- Name: FUNCTION insert_trigger_function_tick(); Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON FUNCTION main_data.insert_trigger_function_tick() IS 'Тригер на вставку билетов, если билеты на данный сеанс уже закончились, то новый билет уже нельзя вставить';


--
-- TOC entry 246 (class 1255 OID 25004)
-- Name: procedura_bat_man(); Type: PROCEDURE; Schema: main_data; Owner: postgres
--

CREATE PROCEDURE main_data.procedura_bat_man()
    LANGUAGE sql
    AS $$
DELETE FROM main_data.film WHERE id = 12;
insert into main_data.film values (12, 'Bat', 1);
UPDATE main_data.film
	SET id=12, name_film='Bat', id_cat=1;
$$;


ALTER PROCEDURE main_data.procedura_bat_man() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 25005)
-- Name: categories; Type: TABLE; Schema: main_data; Owner: postgres
--

CREATE TABLE main_data.categories (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE main_data.categories OWNER TO postgres;

--
-- TOC entry 4867 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE categories; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON TABLE main_data.categories IS 'Таблица жанров ';


--
-- TOC entry 4868 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN categories.id; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.categories.id IS 'Уникальный номер жанра';


--
-- TOC entry 4869 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN categories.name; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.categories.name IS 'Наименование жанра';


--
-- TOC entry 218 (class 1259 OID 25008)
-- Name: film; Type: TABLE; Schema: main_data; Owner: postgres
--

CREATE TABLE main_data.film (
    id integer NOT NULL,
    name_film character varying(50) NOT NULL,
    id_cat integer NOT NULL
);


ALTER TABLE main_data.film OWNER TO postgres;

--
-- TOC entry 4870 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE film; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON TABLE main_data.film IS 'Таблица фильмов, которые будут показаны';


--
-- TOC entry 4871 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN film.id; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.film.id IS 'Уникальный номер фильма';


--
-- TOC entry 4872 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN film.name_film; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.film.name_film IS 'Наименование фильма';


--
-- TOC entry 4873 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN film.id_cat; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.film.id_cat IS 'Номер жанра фильма';


--
-- TOC entry 219 (class 1259 OID 25011)
-- Name: CategoriesWichFilms; Type: VIEW; Schema: main_data; Owner: postgres
--

CREATE VIEW main_data."CategoriesWichFilms" AS
 SELECT id,
    name
   FROM main_data.categories
  WHERE (NOT (id IN ( SELECT film.id_cat
           FROM main_data.film)));


ALTER VIEW main_data."CategoriesWichFilms" OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 25015)
-- Name: categories_id_seq; Type: SEQUENCE; Schema: main_data; Owner: postgres
--

CREATE SEQUENCE main_data.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE main_data.categories_id_seq OWNER TO postgres;

--
-- TOC entry 4874 (class 0 OID 0)
-- Dependencies: 220
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: main_data; Owner: postgres
--

ALTER SEQUENCE main_data.categories_id_seq OWNED BY main_data.categories.id;


--
-- TOC entry 221 (class 1259 OID 25016)
-- Name: session; Type: TABLE; Schema: main_data; Owner: postgres
--

CREATE TABLE main_data.session (
    id_film integer NOT NULL,
    id_hall integer NOT NULL,
    data date NOT NULL,
    price smallint NOT NULL,
    "time" time with time zone NOT NULL,
    id integer NOT NULL
);


ALTER TABLE main_data.session OWNER TO postgres;

--
-- TOC entry 4875 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE session; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON TABLE main_data.session IS 'Таблица для сеансов, которые будут показаны в кинотеатре';


--
-- TOC entry 4876 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN session.id_film; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.session.id_film IS 'Номер фильма, который будет показан на данном сеансе';


--
-- TOC entry 4877 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN session.id_hall; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.session.id_hall IS 'Номер зала, в котором будет показ фильма';


--
-- TOC entry 4878 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN session.data; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.session.data IS 'Дата проведения сеанса';


--
-- TOC entry 4879 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN session.price; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.session.price IS 'Стоимость билета на сеанс ';


--
-- TOC entry 4880 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN session."time"; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.session."time" IS 'Время начала фильма';


--
-- TOC entry 4881 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN session.id; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.session.id IS 'Уникальный номер сеанса';


--
-- TOC entry 222 (class 1259 OID 25019)
-- Name: compound; Type: VIEW; Schema: main_data; Owner: postgres
--

CREATE VIEW main_data.compound AS
 SELECT fi.name_film,
    count(*) AS "Количество сеансов"
   FROM main_data.session se,
    main_data.film fi
  WHERE (se.id_film = fi.id)
  GROUP BY fi.name_film;


ALTER VIEW main_data.compound OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 25023)
-- Name: film_id_seq; Type: SEQUENCE; Schema: main_data; Owner: postgres
--

CREATE SEQUENCE main_data.film_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE main_data.film_id_seq OWNER TO postgres;

--
-- TOC entry 4882 (class 0 OID 0)
-- Dependencies: 223
-- Name: film_id_seq; Type: SEQUENCE OWNED BY; Schema: main_data; Owner: postgres
--

ALTER SEQUENCE main_data.film_id_seq OWNED BY main_data.film.id;


--
-- TOC entry 224 (class 1259 OID 25024)
-- Name: grouping; Type: VIEW; Schema: main_data; Owner: postgres
--

CREATE VIEW main_data."grouping" AS
 SELECT price,
    count(price) AS count
   FROM main_data.session
  GROUP BY price;


ALTER VIEW main_data."grouping" OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 25028)
-- Name: hall; Type: TABLE; Schema: main_data; Owner: postgres
--

CREATE TABLE main_data.hall (
    id integer NOT NULL,
    name_hall character varying(20) NOT NULL,
    capacity smallint NOT NULL
);


ALTER TABLE main_data.hall OWNER TO postgres;

--
-- TOC entry 4883 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE hall; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON TABLE main_data.hall IS 'Таблица залов';


--
-- TOC entry 4884 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN hall.id; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.hall.id IS 'Уникальный номер зала ';


--
-- TOC entry 4885 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN hall.name_hall; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.hall.name_hall IS 'Наименование зала';


--
-- TOC entry 4886 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN hall.capacity; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.hall.capacity IS 'Вместимость зала';


--
-- TOC entry 226 (class 1259 OID 25031)
-- Name: hall_id_seq; Type: SEQUENCE; Schema: main_data; Owner: postgres
--

CREATE SEQUENCE main_data.hall_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE main_data.hall_id_seq OWNER TO postgres;

--
-- TOC entry 4887 (class 0 OID 0)
-- Dependencies: 226
-- Name: hall_id_seq; Type: SEQUENCE OWNED BY; Schema: main_data; Owner: postgres
--

ALTER SEQUENCE main_data.hall_id_seq OWNED BY main_data.hall.id;


--
-- TOC entry 227 (class 1259 OID 25032)
-- Name: izmenaemoe; Type: VIEW; Schema: main_data; Owner: postgres
--

CREATE VIEW main_data.izmenaemoe AS
 SELECT id,
    name_film,
    id_cat
   FROM main_data.film
  WHERE (id_cat = 1)
  WITH LOCAL CHECK OPTION;


ALTER VIEW main_data.izmenaemoe OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 25036)
-- Name: session_id_seq; Type: SEQUENCE; Schema: main_data; Owner: postgres
--

CREATE SEQUENCE main_data.session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE main_data.session_id_seq OWNER TO postgres;

--
-- TOC entry 4888 (class 0 OID 0)
-- Dependencies: 228
-- Name: session_id_seq; Type: SEQUENCE OWNED BY; Schema: main_data; Owner: postgres
--

ALTER SEQUENCE main_data.session_id_seq OWNED BY main_data.session.id;


--
-- TOC entry 229 (class 1259 OID 25037)
-- Name: ticket; Type: TABLE; Schema: main_data; Owner: postgres
--

CREATE TABLE main_data.ticket (
    id integer NOT NULL,
    place smallint NOT NULL,
    id_session integer NOT NULL
);


ALTER TABLE main_data.ticket OWNER TO postgres;

--
-- TOC entry 4889 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE ticket; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON TABLE main_data.ticket IS 'Таблица для билетов';


--
-- TOC entry 4890 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN ticket.id; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.ticket.id IS 'Уникальный номер билета';


--
-- TOC entry 4891 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN ticket.place; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.ticket.place IS 'Номер места в зале';


--
-- TOC entry 4892 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN ticket.id_session; Type: COMMENT; Schema: main_data; Owner: postgres
--

COMMENT ON COLUMN main_data.ticket.id_session IS 'Номер сианса на который выдан билет';


--
-- TOC entry 230 (class 1259 OID 25040)
-- Name: ticket_id_seq; Type: SEQUENCE; Schema: main_data; Owner: postgres
--

CREATE SEQUENCE main_data.ticket_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE main_data.ticket_id_seq OWNER TO postgres;

--
-- TOC entry 4893 (class 0 OID 0)
-- Dependencies: 230
-- Name: ticket_id_seq; Type: SEQUENCE OWNED BY; Schema: main_data; Owner: postgres
--

ALTER SEQUENCE main_data.ticket_id_seq OWNED BY main_data.ticket.id;


--
-- TOC entry 231 (class 1259 OID 25041)
-- Name: allowed; Type: VIEW; Schema: public; Owner: Admin
--

CREATE VIEW public.allowed AS
 SELECT id_film,
    id_hall,
    data
   FROM main_data.session;


ALTER VIEW public.allowed OWNER TO "Admin";

--
-- TOC entry 4680 (class 2604 OID 25045)
-- Name: categories id; Type: DEFAULT; Schema: main_data; Owner: postgres
--

ALTER TABLE ONLY main_data.categories ALTER COLUMN id SET DEFAULT nextval('main_data.categories_id_seq'::regclass);


--
-- TOC entry 4681 (class 2604 OID 25046)
-- Name: film id; Type: DEFAULT; Schema: main_data; Owner: postgres
--

ALTER TABLE ONLY main_data.film ALTER COLUMN id SET DEFAULT nextval('main_data.film_id_seq'::regclass);


--
-- TOC entry 4683 (class 2604 OID 25047)
-- Name: hall id; Type: DEFAULT; Schema: main_data; Owner: postgres
--

ALTER TABLE ONLY main_data.hall ALTER COLUMN id SET DEFAULT nextval('main_data.hall_id_seq'::regclass);


--
-- TOC entry 4682 (class 2604 OID 25048)
-- Name: session id; Type: DEFAULT; Schema: main_data; Owner: postgres
--

ALTER TABLE ONLY main_data.session ALTER COLUMN id SET DEFAULT nextval('main_data.session_id_seq'::regclass);


--
-- TOC entry 4684 (class 2604 OID 25049)
-- Name: ticket id; Type: DEFAULT; Schema: main_data; Owner: postgres
--

ALTER TABLE ONLY main_data.ticket ALTER COLUMN id SET DEFAULT nextval('main_data.ticket_id_seq'::regclass);


--
-- TOC entry 4849 (class 0 OID 25005)
-- Dependencies: 217
-- Data for Name: categories; Type: TABLE DATA; Schema: main_data; Owner: postgres
--

INSERT INTO main_data.categories VALUES (1, 'comedy');
INSERT INTO main_data.categories VALUES (2, 'action movie');
INSERT INTO main_data.categories VALUES (3, 'detective');
INSERT INTO main_data.categories VALUES (4, 'cartoon');
INSERT INTO main_data.categories VALUES (5, 'fantastic');
INSERT INTO main_data.categories VALUES (6, 'Horror');
INSERT INTO main_data.categories VALUES (7, 'scientific films');
INSERT INTO main_data.categories VALUES (8, 'BatMan');


--
-- TOC entry 4850 (class 0 OID 25008)
-- Dependencies: 218
-- Data for Name: film; Type: TABLE DATA; Schema: main_data; Owner: postgres
--

INSERT INTO main_data.film VALUES (1, 'John Wick', 2);
INSERT INTO main_data.film VALUES (2, 'Hangover', 1);
INSERT INTO main_data.film VALUES (3, 'Murder on the Orient Express', 3);
INSERT INTO main_data.film VALUES (4, 'Avengers', 5);
INSERT INTO main_data.film VALUES (5, 'Shrek', 4);
INSERT INTO main_data.film VALUES (6, 'Freelance bodyguard', 1);
INSERT INTO main_data.film VALUES (7, 'Angry Birds', 4);
INSERT INTO main_data.film VALUES (8, 'Shazam', 5);
INSERT INTO main_data.film VALUES (9, 'Gran Turismo', 5);
INSERT INTO main_data.film VALUES (10, 'Inconvenient Planet', 7);
INSERT INTO main_data.film VALUES (13, 'Night shift', 1);
INSERT INTO main_data.film VALUES (12, 'BatMan', 5);
INSERT INTO main_data.film VALUES (14, 'All or nothing', 1);


--
-- TOC entry 4854 (class 0 OID 25028)
-- Dependencies: 225
-- Data for Name: hall; Type: TABLE DATA; Schema: main_data; Owner: postgres
--

INSERT INTO main_data.hall VALUES (2, 'VIP', 50);
INSERT INTO main_data.hall VALUES (3, 'IMAX', 100);
INSERT INTO main_data.hall VALUES (4, 'Comfort', 100);
INSERT INTO main_data.hall VALUES (5, 'Dolby Atmos', 150);
INSERT INTO main_data.hall VALUES (6, 'Very smoll', 2);
INSERT INTO main_data.hall VALUES (1, 'Children room', 50);


--
-- TOC entry 4852 (class 0 OID 25016)
-- Dependencies: 221
-- Data for Name: session; Type: TABLE DATA; Schema: main_data; Owner: postgres
--

INSERT INTO main_data.session VALUES (1, 2, '2023-05-08', 700, '18:30:00+05', 1);
INSERT INTO main_data.session VALUES (2, 4, '2023-05-08', 300, '15:00:00+05', 2);
INSERT INTO main_data.session VALUES (3, 3, '2023-05-08', 450, '19:50:00+05', 3);
INSERT INTO main_data.session VALUES (4, 5, '2023-05-08', 700, '22:00:00+05', 4);
INSERT INTO main_data.session VALUES (5, 1, '2023-05-08', 300, '11:00:00+05', 5);
INSERT INTO main_data.session VALUES (1, 2, '2023-05-08', 700, '15:00:00+05', 6);
INSERT INTO main_data.session VALUES (2, 4, '2023-05-08', 300, '13:00:00+05', 8);
INSERT INTO main_data.session VALUES (2, 4, '2023-05-08', 300, '19:00:00+05', 9);
INSERT INTO main_data.session VALUES (3, 2, '2023-05-08', 700, '11:00:00+05', 10);
INSERT INTO main_data.session VALUES (3, 5, '2023-05-08', 300, '20:00:00+05', 11);
INSERT INTO main_data.session VALUES (4, 3, '2023-05-08', 450, '14:00:00+05', 12);
INSERT INTO main_data.session VALUES (4, 4, '2023-05-08', 300, '17:00:00+05', 13);
INSERT INTO main_data.session VALUES (5, 1, '2023-05-08', 300, '09:00:00+05', 14);
INSERT INTO main_data.session VALUES (5, 1, '2023-05-08', 300, '13:00:00+05', 15);
INSERT INTO main_data.session VALUES (6, 4, '2023-05-08', 700, '11:00:00+05', 16);
INSERT INTO main_data.session VALUES (6, 2, '2023-05-08', 700, '13:00:00+05', 17);
INSERT INTO main_data.session VALUES (6, 5, '2023-05-08', 700, '18:00:00+05', 18);
INSERT INTO main_data.session VALUES (7, 1, '2023-05-08', 300, '15:00:00+05', 19);
INSERT INTO main_data.session VALUES (7, 1, '2023-05-08', 300, '17:00:00+05', 20);
INSERT INTO main_data.session VALUES (7, 1, '2023-05-08', 300, '19:00:00+05', 21);
INSERT INTO main_data.session VALUES (8, 3, '2023-05-08', 450, '22:00:00+05', 22);
INSERT INTO main_data.session VALUES (8, 4, '2023-05-08', 700, '21:00:00+05', 23);
INSERT INTO main_data.session VALUES (8, 5, '2023-05-08', 700, '16:00:00+05', 24);
INSERT INTO main_data.session VALUES (9, 2, '2023-05-08', 700, '20:30:00+05', 25);
INSERT INTO main_data.session VALUES (9, 3, '2023-05-08', 450, '18:00:00+05', 26);
INSERT INTO main_data.session VALUES (9, 5, '2023-05-08', 700, '14:00:00+05', 27);
INSERT INTO main_data.session VALUES (14, 3, '2023-12-09', 450, '20:00:00+05', 28);
INSERT INTO main_data.session VALUES (1, 6, '2023-05-08', 700, '16:00:00+05', 7);


--
-- TOC entry 4857 (class 0 OID 25037)
-- Dependencies: 229
-- Data for Name: ticket; Type: TABLE DATA; Schema: main_data; Owner: postgres
--

INSERT INTO main_data.ticket VALUES (1, 1, 1);
INSERT INTO main_data.ticket VALUES (2, 5, 1);
INSERT INTO main_data.ticket VALUES (3, 7, 1);
INSERT INTO main_data.ticket VALUES (4, 10, 1);
INSERT INTO main_data.ticket VALUES (5, 3, 1);
INSERT INTO main_data.ticket VALUES (6, 2, 2);
INSERT INTO main_data.ticket VALUES (7, 10, 2);
INSERT INTO main_data.ticket VALUES (8, 11, 2);
INSERT INTO main_data.ticket VALUES (9, 3, 2);
INSERT INTO main_data.ticket VALUES (10, 9, 2);
INSERT INTO main_data.ticket VALUES (11, 8, 3);
INSERT INTO main_data.ticket VALUES (12, 7, 3);
INSERT INTO main_data.ticket VALUES (13, 5, 3);
INSERT INTO main_data.ticket VALUES (14, 22, 3);
INSERT INTO main_data.ticket VALUES (15, 12, 3);
INSERT INTO main_data.ticket VALUES (16, 14, 4);
INSERT INTO main_data.ticket VALUES (17, 7, 4);
INSERT INTO main_data.ticket VALUES (18, 2, 4);
INSERT INTO main_data.ticket VALUES (19, 3, 4);
INSERT INTO main_data.ticket VALUES (20, 10, 4);
INSERT INTO main_data.ticket VALUES (21, 5, 5);
INSERT INTO main_data.ticket VALUES (22, 11, 5);
INSERT INTO main_data.ticket VALUES (23, 12, 5);
INSERT INTO main_data.ticket VALUES (24, 3, 5);
INSERT INTO main_data.ticket VALUES (25, 7, 5);
INSERT INTO main_data.ticket VALUES (26, 17, 6);
INSERT INTO main_data.ticket VALUES (27, 13, 6);
INSERT INTO main_data.ticket VALUES (28, 12, 6);
INSERT INTO main_data.ticket VALUES (29, 11, 6);
INSERT INTO main_data.ticket VALUES (30, 3, 6);
INSERT INTO main_data.ticket VALUES (33, 7, 7);
INSERT INTO main_data.ticket VALUES (34, 10, 7);
INSERT INTO main_data.ticket VALUES (35, 15, 7);
INSERT INTO main_data.ticket VALUES (36, 21, 8);
INSERT INTO main_data.ticket VALUES (37, 16, 8);
INSERT INTO main_data.ticket VALUES (38, 2, 8);
INSERT INTO main_data.ticket VALUES (39, 3, 8);
INSERT INTO main_data.ticket VALUES (40, 4, 8);
INSERT INTO main_data.ticket VALUES (41, 10, 9);
INSERT INTO main_data.ticket VALUES (42, 11, 9);
INSERT INTO main_data.ticket VALUES (43, 12, 9);
INSERT INTO main_data.ticket VALUES (44, 7, 9);
INSERT INTO main_data.ticket VALUES (45, 8, 9);
INSERT INTO main_data.ticket VALUES (31, 4, 7);
INSERT INTO main_data.ticket VALUES (32, 6, 7);
INSERT INTO main_data.ticket VALUES (46, 5, 8);


--
-- TOC entry 4894 (class 0 OID 0)
-- Dependencies: 220
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: main_data; Owner: postgres
--

SELECT pg_catalog.setval('main_data.categories_id_seq', 1, false);


--
-- TOC entry 4895 (class 0 OID 0)
-- Dependencies: 223
-- Name: film_id_seq; Type: SEQUENCE SET; Schema: main_data; Owner: postgres
--

SELECT pg_catalog.setval('main_data.film_id_seq', 1, false);


--
-- TOC entry 4896 (class 0 OID 0)
-- Dependencies: 226
-- Name: hall_id_seq; Type: SEQUENCE SET; Schema: main_data; Owner: postgres
--

SELECT pg_catalog.setval('main_data.hall_id_seq', 1, false);


--
-- TOC entry 4897 (class 0 OID 0)
-- Dependencies: 228
-- Name: session_id_seq; Type: SEQUENCE SET; Schema: main_data; Owner: postgres
--

SELECT pg_catalog.setval('main_data.session_id_seq', 1, false);


--
-- TOC entry 4898 (class 0 OID 0)
-- Dependencies: 230
-- Name: ticket_id_seq; Type: SEQUENCE SET; Schema: main_data; Owner: postgres
--

SELECT pg_catalog.setval('main_data.ticket_id_seq', 25, true);


--
-- TOC entry 4686 (class 2606 OID 25051)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: main_data; Owner: postgres
--

ALTER TABLE ONLY main_data.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- TOC entry 4688 (class 2606 OID 25053)
-- Name: film film_pkey; Type: CONSTRAINT; Schema: main_data; Owner: postgres
--

ALTER TABLE ONLY main_data.film
    ADD CONSTRAINT film_pkey PRIMARY KEY (id);


--
-- TOC entry 4692 (class 2606 OID 25055)
-- Name: hall hall_pkey; Type: CONSTRAINT; Schema: main_data; Owner: postgres
--

ALTER TABLE ONLY main_data.hall
    ADD CONSTRAINT hall_pkey PRIMARY KEY (id);


--
-- TOC entry 4690 (class 2606 OID 25057)
-- Name: session session_pkey; Type: CONSTRAINT; Schema: main_data; Owner: postgres
--

ALTER TABLE ONLY main_data.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id);


--
-- TOC entry 4694 (class 2606 OID 25059)
-- Name: ticket ticket_pkey; Type: CONSTRAINT; Schema: main_data; Owner: postgres
--

ALTER TABLE ONLY main_data.ticket
    ADD CONSTRAINT ticket_pkey PRIMARY KEY (id);


--
-- TOC entry 4699 (class 2620 OID 25060)
-- Name: session insert_trigger; Type: TRIGGER; Schema: main_data; Owner: postgres
--

CREATE TRIGGER insert_trigger AFTER INSERT ON main_data.session FOR EACH ROW EXECUTE FUNCTION main_data.insert_trigger_function();


--
-- TOC entry 4700 (class 2620 OID 25061)
-- Name: ticket insert_trigger_tic; Type: TRIGGER; Schema: main_data; Owner: postgres
--

CREATE TRIGGER insert_trigger_tic AFTER INSERT ON main_data.ticket FOR EACH ROW EXECUTE FUNCTION main_data.insert_trigger_function_tick();


--
-- TOC entry 4695 (class 2606 OID 25062)
-- Name: film film_id_cat_fkey; Type: FK CONSTRAINT; Schema: main_data; Owner: postgres
--

ALTER TABLE ONLY main_data.film
    ADD CONSTRAINT film_id_cat_fkey FOREIGN KEY (id_cat) REFERENCES main_data.categories(id) NOT VALID;


--
-- TOC entry 4696 (class 2606 OID 25067)
-- Name: session session_id_film_fkey; Type: FK CONSTRAINT; Schema: main_data; Owner: postgres
--

ALTER TABLE ONLY main_data.session
    ADD CONSTRAINT session_id_film_fkey FOREIGN KEY (id_film) REFERENCES main_data.film(id) NOT VALID;


--
-- TOC entry 4697 (class 2606 OID 25072)
-- Name: session session_id_hall_fkey; Type: FK CONSTRAINT; Schema: main_data; Owner: postgres
--

ALTER TABLE ONLY main_data.session
    ADD CONSTRAINT session_id_hall_fkey FOREIGN KEY (id_hall) REFERENCES main_data.hall(id) NOT VALID;


--
-- TOC entry 4698 (class 2606 OID 25077)
-- Name: ticket ticket_id_session_fkey; Type: FK CONSTRAINT; Schema: main_data; Owner: postgres
--

ALTER TABLE ONLY main_data.ticket
    ADD CONSTRAINT ticket_id_session_fkey FOREIGN KEY (id_session) REFERENCES main_data.session(id) NOT VALID;


-- Completed on 2024-02-02 16:06:02

--
-- PostgreSQL database dump complete
--

