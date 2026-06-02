--
-- PostgreSQL database dump
--

\restrict 0U7s9Zc33DhmpPaTxFmtdYfUd1uvXpFSX1JH8uxB0JpeIHycLAOCdxEZkcTzlEC

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: t_accounts; Type: TABLE DATA; Schema: financial; Owner: renato
--

INSERT INTO financial.t_accounts OVERRIDING SYSTEM VALUE VALUES (1, 'Sueldo', true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_accounts OVERRIDING SYSTEM VALUE VALUES (2, 'Ahorros', true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);


--
-- Data for Name: t_categories; Type: TABLE DATA; Schema: financial; Owner: renato
--

INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (1, 'Comida', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (2, 'Restaurante', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (3, 'Supermercado', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (4, 'Gasolina', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (5, 'Taxi', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (6, 'Transporte', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (7, 'Alquiler', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (8, 'Hipoteca', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (9, 'Electricidad', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (10, 'Agua', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (11, 'Internet', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (12, 'Teléfono', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (13, 'Limpieza', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (14, 'Salud', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (15, 'Higiene', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (16, 'Facturas', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (17, 'Seguro', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (18, 'Educación', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (19, 'Ropa', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (20, 'Belleza', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (21, 'Mascotas', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (22, 'Entretenimiento', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (23, 'Viajes', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (24, 'Regalos', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (25, 'Suscripciones', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (26, 'Deporte', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (27, 'Tecnología', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (28, 'Hogar', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (29, 'Impuestos', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (30, 'Inversiones', true, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (31, 'Ahorro', false, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:09:11.884982', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (32, 'Devoluciones', false, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:09:11.884982', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (33, 'Salario', false, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:09:11.884982', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (34, 'Depositos', false, true, '2026-03-13 17:01:33.969955', '2026-03-13 17:09:11.884982', NULL);
INSERT INTO financial.t_categories OVERRIDING SYSTEM VALUE VALUES (35, 'Transferencia', true, true, '2026-03-17 18:49:19.183207', '2026-03-17 18:49:19.183207', NULL);


--
-- Data for Name: t_types; Type: TABLE DATA; Schema: financial; Owner: renato
--

INSERT INTO financial.t_types OVERRIDING SYSTEM VALUE VALUES (1, 'Ingreso', true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_types OVERRIDING SYSTEM VALUE VALUES (2, 'Gasto', true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_types OVERRIDING SYSTEM VALUE VALUES (3, 'Transferencia', true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);


--
-- Name: t_accounts_account_id_seq; Type: SEQUENCE SET; Schema: financial; Owner: renato
--

SELECT pg_catalog.setval('financial.t_accounts_account_id_seq', 4, true);


--
-- Name: t_categories_category_id_seq; Type: SEQUENCE SET; Schema: financial; Owner: renato
--

SELECT pg_catalog.setval('financial.t_categories_category_id_seq', 35, true);


--
-- Name: t_types_type_id_seq; Type: SEQUENCE SET; Schema: financial; Owner: renato
--

SELECT pg_catalog.setval('financial.t_types_type_id_seq', 3, true);


--
-- PostgreSQL database dump complete
--

\unrestrict 0U7s9Zc33DhmpPaTxFmtdYfUd1uvXpFSX1JH8uxB0JpeIHycLAOCdxEZkcTzlEC

