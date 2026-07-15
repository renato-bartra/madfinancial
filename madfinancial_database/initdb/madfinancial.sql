--
-- PostgreSQL database dump
--

\restrict 0uCu7KQeQR6KnWqFh4jdwirrC9MB6fzeop0yEuW8BpPcIQfkPIM4fqvbMoCnOpk

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

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
-- Name: financial; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA financial;


--
-- Name: shared; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA shared;


--
-- Name: users; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA users;


--
-- Name: sp_accounts_create(character varying, bigint); Type: FUNCTION; Schema: financial; Owner: -
--

CREATE FUNCTION financial.sp_accounts_create(in_description character varying, in_user_id bigint) RETURNS TABLE(account_id bigint, description character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE v_account_id BIGINT;
BEGIN
    -- Valida si la categoría ya existe para el usuario
    SELECT acc.account_id INTO v_account_id
    FROM 
        financial.t_accounts acc
        INNER JOIN financial.t_accounts_users usrc ON usrc.account_id = acc.account_id AND usrc.user_id = in_user_id
    WHERE acc.description = in_description;

    IF v_account_id IS NULL THEN
        -- Si no existe, valida si exoste en t_accounts
        SELECT acc.account_id INTO v_account_id
        FROM financial.t_accounts acc
        WHERE acc.description = in_description;

        IF v_account_id IS NULL THEN

            -- Si no existe inserta la nueva accegoría
            INSERT INTO financial.t_accounts (description)
            VALUES (in_description);

            -- consigue el nuevo account_id
            SELECT acc.account_id INTO v_account_id
            FROM financial.t_accounts acc
            WHERE acc.description = in_description;

            -- Asigna la cuenta al usuario
            INSERT INTO financial.t_accounts_users (account_id, user_id)
            VALUES (v_account_id, in_user_id);

        ELSE
            -- Si existe, entonces asigna la cuenta al usuario
            INSERT INTO financial.t_accounts_users (account_id, user_id)
            VALUES (v_account_id, in_user_id);

        END IF;

    ELSE
        -- si el ususario tiene la cuenta entonces bota error
        RAISE EXCEPTION 'El usuario ya tiene asignada la cuenta --> %', in_description;
    END IF;

    RETURN QUERY
    SELECT
        acc.account_id, acc.description
    FROM 
        financial.t_accounts acc
        INNER JOIN financial.t_accounts_users usra ON usra.account_id = acc.account_id AND usra.user_id = in_user_id
    WHERE acc.description = in_description;
END;
$$;


--
-- Name: sp_accounts_get_all(bigint); Type: FUNCTION; Schema: financial; Owner: -
--

CREATE FUNCTION financial.sp_accounts_get_all(in_user_id bigint) RETURNS TABLE(account_id bigint, description character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        acc.account_id, acc.description
    FROM 
        financial.t_accounts acc
        INNER JOIN financial.t_accounts_users usra ON usra.account_id = acc.account_id
    WHERE
        acc.active = TRUE
        AND usra.user_id = in_user_id;
END;
$$;


--
-- Name: sp_categories_create(character varying, boolean, character varying, bigint); Type: FUNCTION; Schema: financial; Owner: -
--

CREATE FUNCTION financial.sp_categories_create(in_description character varying, in_category_type boolean, in_category_icon character varying, in_user_id bigint) RETURNS TABLE(category_id bigint, category_type boolean, category_icon character varying, description character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE v_category_id BIGINT;
BEGIN
    -- Valida si la categoría ya existe para el usuario
    SELECT cat.category_id INTO v_category_id
    FROM 
        financial.t_categories cat
        INNER JOIN financial.t_categories_users usrc ON usrc.category_id = cat.category_id AND usrc.user_id = in_user_id
    WHERE cat.description = in_description;

    IF v_category_id IS NULL THEN
        -- Si no existe, valida si exoste en t_categories
        SELECT cat.category_id INTO v_category_id
        FROM financial.t_categories cat
        WHERE cat.description = in_description;

        IF v_category_id IS NULL THEN

            -- Si no existe inserta la nueva categoría
            INSERT INTO financial.t_categories (description, category_type, category_icon)
            VALUES (in_description, in_category_type, in_category_icon);

            -- consigue el nuevo category_id
            SELECT cat.category_id INTO v_category_id
            FROM financial.t_categories cat
            WHERE cat.description = in_description;

            -- Asigna la categoría al usuario
            INSERT INTO financial.t_categories_users (category_id, user_id)
            VALUES (v_category_id, in_user_id);

        ELSE
            -- Si existe, entonces asigna la categoría al usuario
            INSERT INTO financial.t_categories_users (category_id, user_id)
            VALUES (v_category_id, in_user_id);

        END IF;

    ELSE
        -- si el ususario tiene la cateogía entonces bota error
        RAISE EXCEPTION 'El usuario ya tiene asignada la categoría --> %', in_description;
    END IF;

    RETURN QUERY
    SELECT
        cat.category_id, cat.category_type, cat.category_icon, cat.description
    FROM 
        financial.t_categories cat
        INNER JOIN financial.t_categories_users usrc ON usrc.category_id = cat.category_id AND usrc.user_id = in_user_id
    WHERE cat.description = in_description;
END;
$$;


--
-- Name: sp_categories_get_all(bigint); Type: FUNCTION; Schema: financial; Owner: -
--

CREATE FUNCTION financial.sp_categories_get_all(in_user_id bigint) RETURNS TABLE(category_id bigint, category_type boolean, category_icon character varying, description character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        cat.category_id, cat.category_type, cat.category_icon, cat.description
    FROM 
        financial.t_categories cat
        INNER JOIN financial.t_categories_users usrc ON usrc.category_id = cat.category_id
    WHERE
        cat.active = TRUE
        AND usrc.user_id = in_user_id;
END;
$$;


--
-- Name: sp_get_all_movements_by_user_and_date(bigint, date); Type: FUNCTION; Schema: financial; Owner: -
--

CREATE FUNCTION financial.sp_get_all_movements_by_user_and_date(in_user_id bigint, in_accounting_date date) RETURNS TABLE(movement_id bigint, user_id bigint, title character varying, description character varying, amount numeric, accounting_date date, type jsonb, category jsonb, account jsonb, tags jsonb, submovements jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        mv.movement_id
        ,mv.user_id
        ,mv.title
        ,mv.description
        ,mv.amount
        ,mv.accounting_date
        ,mv.type
        ,mv.category
        ,mv.account
        ,mv.tags
        ,mv.submovements
    FROM financial.vw_movements mv
    WHERE 
        mv.user_id = in_user_id
        AND mv.accounting_date >= date_trunc('month', in_accounting_date)::date
        AND mv.accounting_date < (date_trunc('month', in_accounting_date) + interval '1 month')::date;
END;
$$;


--
-- Name: sp_import_movements(bigint, jsonb); Type: FUNCTION; Schema: financial; Owner: -
--

CREATE FUNCTION financial.sp_import_movements(in_user_id bigint, in_movements jsonb) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO financial.t_movements AS mv (user_id, type_id, category_id, account_id, title, amount, description, accounting_date)
    SELECT
        in_user_id,
        m.type_id,
        m.category_id,
        m.account_id,
        m.title,
        m.amount,
        m.description,
        m.accounting_date
    FROM jsonb_to_recordset(in_movements) AS m(
        type_id BIGINT,
        category_id BIGINT,
        account_id BIGINT,
        title VARCHAR,
        amount NUMERIC,
        description VARCHAR,
        accounting_date DATE
    );

    RETURN TRUE;
END;
$$;


--
-- Name: sp_movements_create(bigint, bigint, bigint, bigint, character varying, numeric, character varying, date, jsonb, jsonb); Type: FUNCTION; Schema: financial; Owner: -
--

CREATE FUNCTION financial.sp_movements_create(in_user_id bigint, in_type_id bigint, in_category_id bigint, in_account_id bigint, in_title character varying, in_amount numeric, in_description character varying, in_accounting_date date, in_tags jsonb, in_submovements jsonb) RETURNS TABLE(movement_id bigint, user_id bigint, title character varying, description character varying, amount numeric, accounting_date date, type jsonb, category jsonb, account jsonb, tags jsonb, submovements jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    v_movement_id BIGINT;
    v_submovement_id BIGINT;
    sub JSONB;
BEGIN
    -- Primero incerta el mivimiento para sacar el movement_id
    INSERT INTO financial.t_movements AS mv (user_id, type_id, category_id, account_id, title, amount, description, accounting_date)
    VALUES (in_user_id, in_type_id, in_category_id, in_account_id, in_title, in_amount, in_description, in_accounting_date)
    RETURNING mv.movement_id INTO v_movement_id;

    -- valida si tiene tags
    IF jsonb_array_length(in_tags) > 0 THEN
        -- Si tiene tags los incerta usando el movement_id que consiguió en el proceso anterior
        INSERT INTO financial.t_movements_tags(movement_id, tag_id)
        SELECT
            v_movement_id
            ,(tg->>'tag_id')::BIGINT
        FROM jsonb_array_elements(in_tags) tg;

    END IF;

    -- Valida si tiene submovements
    IF jsonb_array_length(in_submovements) > 0 THEN
        -- hace un loop para conseguir el submovement_id
        FOR sub IN
            SELECT value
            FROM jsonb_array_elements(in_submovements)
        LOOP
            -- iserta el submovements y consigue el submovement_id
            INSERT INTO financial.t_submovements AS smv
            (
                movement_id,
                subcategory_id,
                title,
                amount,
                description
            )
            VALUES
            (
                v_movement_id,
                (sub->'subcategory'->>'category_id')::BIGINT,
                'Titulo Submovement',
                (sub->>'amount')::DECIMAL(12,2),
                sub->>'description'
            )
            RETURNING smv.submovement_id INTO v_submovement_id;

            IF jsonb_array_length(sub->'tags') > 0 THEN

                -- inserta tags con el submovement_id del proceso anterior
                INSERT INTO financial.t_submovements_tags (submovement_id, tag_id)
                SELECT
                    v_submovement_id,
                    (stg->>'tag_id')::BIGINT
                FROM jsonb_array_elements(sub->'tags') stg;

            END IF;

        END LOOP;

    END IF;

    RETURN QUERY
    SELECT
        mv.movement_id,
        mv.user_id,
        mv.title,
        mv.description,
        mv.amount,
        mv.accounting_date,
        mv.type,
        mv.category,
        mv.account,
        mv.tags,
        mv.submovements
    FROM financial.vw_movements mv
    WHERE mv.movement_id = v_movement_id;
END;
$$;


--
-- Name: sp_movements_delete(bigint); Type: FUNCTION; Schema: financial; Owner: -
--

CREATE FUNCTION financial.sp_movements_delete(in_movement_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
BEGIN
    
    WITH movements AS (
        SELECT
            mv.movement_id
        FROM financial.t_movements mv
        WHERE mv.movement_id = in_movement_id
    )
    UPDATE financial.t_submovements sm
    SET
        active = FALSE
        ,deleted_at = CURRENT_TIMESTAMP
    FROM movements cmv
    WHERE sm.movement_id = cmv.movement_id;

    UPDATE financial.t_movements mv
    SET
        active = FALSE
        ,deleted_at = CURRENT_TIMESTAMP
    WHERE mv.movement_id = in_movement_id;

    RETURN in_movement_id;

END;
$$;


--
-- Name: sp_movements_update(bigint, bigint, bigint, bigint, bigint, character varying, numeric, character varying, date, jsonb, jsonb); Type: FUNCTION; Schema: financial; Owner: -
--

CREATE FUNCTION financial.sp_movements_update(in_movement_id bigint, in_user_id bigint, in_type_id bigint, in_category_id bigint, in_account_id bigint, in_title character varying, in_amount numeric, in_description character varying, in_accounting_date date, in_tags jsonb, in_submovements jsonb) RETURNS TABLE(movement_id bigint, user_id bigint, title character varying, description character varying, amount numeric, accounting_date date, type jsonb, category jsonb, account jsonb, tags jsonb, submovements jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN

    PERFORM financial.sp_movements_delete(in_movement_id);
    
    RETURN QUERY
    SELECT 
        nmv.movement_id,
        nmv.user_id,
        nmv.title,
        nmv.description,
        nmv.amount,
        nmv.accounting_date,
        nmv.type,
        nmv.category,
        nmv.account,
        nmv.tags,
        nmv.submovements
    FROM financial.sp_movements_create(
        in_user_id
        ,in_type_id
        ,in_category_id
        ,in_account_id
        ,in_title
        ,in_amount
        ,in_description
        ,in_accounting_date
        ,in_tags
        ,in_submovements
    ) nmv;

END;
$$;


--
-- Name: sp_tags_create(character varying, bigint); Type: FUNCTION; Schema: financial; Owner: -
--

CREATE FUNCTION financial.sp_tags_create(in_description character varying, in_user_id bigint) RETURNS TABLE(tag_id bigint, description character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE v_tag_id BIGINT;
BEGIN
    -- Valida si la categoría ya existe para el usuario
    SELECT tg.tag_id INTO v_tag_id
    FROM 
        financial.t_tags tg
        INNER JOIN financial.t_tags_users usrt ON usrt.tag_id = tg.tag_id AND usrt.user_id = in_user_id
    WHERE tg.description = in_description;

    IF v_tag_id IS NULL THEN
        -- Si no existe, valida si exoste en t_tags
        SELECT tg.tag_id INTO v_tag_id
        FROM financial.t_tags tg
        WHERE tg.description = in_description;

        IF v_tag_id IS NULL THEN

            -- Si no existe inserta el nuevo tag
            INSERT INTO financial.t_tags (description)
            VALUES (in_description);

            -- consigue el nuevo tag_id
            SELECT tg.tag_id INTO v_tag_id
            FROM financial.t_tags tg
            WHERE tg.description = in_description;

            -- Asigna la categoría al usuario
            INSERT INTO financial.t_tags_users (tag_id, user_id)
            VALUES (v_tag_id, in_user_id);

        ELSE
            -- Si existe, entonces asigna la categoría al usuario
            INSERT INTO financial.t_tags_users (tag_id, user_id)
            VALUES (v_tag_id, in_user_id);

        END IF;

    ELSE
        -- si el ususario tiene la cateogía entonces bota error
        RAISE EXCEPTION 'El usuario ya tiene asignada la etiqueta --> %', in_description;
    END IF;

    RETURN QUERY
    SELECT
        tg.tag_id, tg.description
    FROM 
        financial.t_tags tg
        INNER JOIN financial.t_tags_users usrt ON usrt.tag_id = tg.tag_id AND usrt.user_id = in_user_id
    WHERE tg.description = in_description;
END;
$$;


--
-- Name: sp_tags_get_all(bigint); Type: FUNCTION; Schema: financial; Owner: -
--

CREATE FUNCTION financial.sp_tags_get_all(in_user_id bigint) RETURNS TABLE(tag_id bigint, description character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        tg.tag_id, tg.description
    FROM 
        financial.t_tags tg
        INNER JOIN financial.t_tags_users usrt ON usrt.tag_id = tg.tag_id
    WHERE 
        tg.active = TRUE
        AND usrt.user_id = in_user_id;
END;
$$;


--
-- Name: sp_types_get_all(bigint); Type: FUNCTION; Schema: financial; Owner: -
--

CREATE FUNCTION financial.sp_types_get_all(in_user_id bigint) RETURNS TABLE(type_id bigint, description character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        ty.type_id
        ,ty.description
    FROM 
        financial.t_types as ty
        INNER JOIN financial.t_types_users usrty ON usrty.type_id = ty.type_id
    WHERE
        ty.active = TRUE
        AND usrty.user_id = in_user_id;
END;
$$;


--
-- Name: fn_set_updated_at(); Type: FUNCTION; Schema: shared; Owner: -
--

CREATE FUNCTION shared.fn_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


--
-- Name: sp_change_password_by_id(bigint, character varying); Type: FUNCTION; Schema: users; Owner: -
--

CREATE FUNCTION users.sp_change_password_by_id(in_id bigint, in_password character varying) RETURNS TABLE(user_id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE users.t_users usr
    SET password = in_password
    WHERE usr.user_id = in_id;

    RETURN QUERY
    SELECT
        usr.user_id
    FROM users.t_users usr
    WHERE usr.user_id = in_id;
END;
$$;


--
-- Name: sp_users_delete(bigint); Type: FUNCTION; Schema: users; Owner: -
--

CREATE FUNCTION users.sp_users_delete(in_id bigint) RETURNS TABLE(user_id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE users.t_users usr
    SET active = FALSE,
        deleted_at = CURRENT_TIMESTAMP
    WHERE usr.user_id = in_id;

    RETURN QUERY
    SELECT
        usr.user_id
    FROM users.t_users usr
    WHERE 
        usr.user_id = in_id
        AND usr.active = FALSE;
END;
$$;


--
-- Name: sp_users_get_all(); Type: FUNCTION; Schema: users; Owner: -
--

CREATE FUNCTION users.sp_users_get_all() RETURNS TABLE(user_id bigint, first_name character varying, last_name character varying, dni character varying, email character varying, password character varying, image text, active boolean, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        usr.user_id
        ,usr.first_name
        ,usr.last_name
        ,usr.dni
        ,usr.email
        ,usr.password
        ,usr.image
        ,usr.active
        ,usr.created_at
        ,usr.updated_at
        ,usr.deleted_at
    FROM users.t_users usr
    WHERE usr.active = TRUE;
END;
$$;


--
-- Name: sp_users_get_by_email(character varying); Type: FUNCTION; Schema: users; Owner: -
--

CREATE FUNCTION users.sp_users_get_by_email(in_email character varying) RETURNS TABLE(user_id bigint, first_name character varying, last_name character varying, dni character varying, email character varying, password character varying, image text, active boolean, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        usr.user_id
        ,usr.first_name
        ,usr.last_name
        ,usr.dni
        ,usr.email
        ,usr.password
        ,usr.image
        ,usr.active
        ,usr.created_at
        ,usr.updated_at
        ,usr.deleted_at
    FROM users.t_users usr
    WHERE usr.email = in_email
    AND usr.active = TRUE;
END;
$$;


--
-- Name: sp_users_get_by_id(bigint); Type: FUNCTION; Schema: users; Owner: -
--

CREATE FUNCTION users.sp_users_get_by_id(in_id bigint) RETURNS TABLE(user_id bigint, first_name character varying, last_name character varying, dni character varying, email character varying, password character varying, image text, active boolean, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        usr.user_id
        ,usr.first_name
        ,usr.last_name
        ,usr.dni
        ,usr.email
        ,usr.password
        ,usr.image
        ,usr.active
        ,usr.created_at
        ,usr.updated_at
        ,usr.deleted_at
    FROM users.t_users usr
    WHERE usr.user_id = in_id
    AND usr.active = TRUE;
END;
$$;


--
-- Name: sp_users_save(character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: users; Owner: -
--

CREATE FUNCTION users.sp_users_save(in_first_name character varying, in_last_name character varying, in_dni character varying, in_email character varying, in_password character varying, in_image character varying) RETURNS TABLE(user_id bigint, first_name character varying, last_name character varying, dni character varying, email character varying, password character varying, image text, active boolean, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE v_user_id BIGINT;
BEGIN
    INSERT INTO users.t_users (
        first_name, last_name, dni, email, password, image, active
    )
    VALUES (
        in_first_name, in_last_name, in_dni,
        in_email, in_password, in_image, TRUE
    );

    -- Selecciona id de usuario
    SELECT usr.user_id INTO v_user_id
    FROM users.t_users usr
    WHERE usr.email = in_email;

    -- Inserta sus tipos por defecto
    INSERT INTO financial.t_types_users(type_id, user_id)
    SELECT tp.type_id, v_user_id
    FROM financial.t_types tp
    WHERE tp.description IN ('Ingreso', 'Gasto', 'Transferencia');

    -- inserta sus categorias por defecto
    INSERT INTO financial.t_categories_users(category_id, user_id)
    SELECT cat.category_id, v_user_id
    FROM financial.t_categories cat
    WHERE cat.description IN ('Comida','Restaurante','Supermercado','Vehículo','Salud','Hogar','Facturas','Limpieza','Higiene','Seguro','Taxi',
        'Transporte','Alquiler','Hipoteca','Electricidad','Agua','Internet','Teléfono','Educación','Ropa','Belleza','Mascotas','Entretenimiento',
        'Viajes','Regalos','Suscripciones','Deporte','Tecnología','Impuestos','Inversiones','Ahorro','Devoluciones','Salario','Depositos',
        'Salida por transferencia','Ingreso por transferencia');

    -- Inserta sus cuentas por defecto
    INSERT INTO financial.t_accounts_users(account_id, user_id)
    SELECT acc.account_id, v_user_id
    FROM financial.t_accounts acc
    WHERE acc.description IN ('Sueldo', 'Ahorros');

    RETURN QUERY
    SELECT 
        u.user_id, u.first_name, u.last_name, u.dni,
        u.email, u.password, u.image, u.active,
        u.created_at, u.updated_at, u.deleted_at
    FROM users.t_users u
    WHERE u.user_id = v_user_id;
END;
$$;


--
-- Name: sp_users_update(bigint, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: users; Owner: -
--

CREATE FUNCTION users.sp_users_update(in_id bigint, in_first_name character varying, in_last_name character varying, in_dni character varying, in_image character varying) RETURNS TABLE(user_id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE users.t_users usr
    SET first_name = in_first_name,
        last_name = in_last_name,
        dni = in_dni,
        image = in_image
    WHERE usr.user_id = in_id;

    RETURN QUERY
    SELECT
        usr.user_id
    FROM users.t_users usr
    WHERE usr.user_id = in_id;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: t_accounts; Type: TABLE; Schema: financial; Owner: -
--

CREATE TABLE financial.t_accounts (
    account_id bigint NOT NULL,
    description character varying(100) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);


--
-- Name: t_accounts_account_id_seq; Type: SEQUENCE; Schema: financial; Owner: -
--

ALTER TABLE financial.t_accounts ALTER COLUMN account_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME financial.t_accounts_account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: t_accounts_users; Type: TABLE; Schema: financial; Owner: -
--

CREATE TABLE financial.t_accounts_users (
    account_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: t_categories; Type: TABLE; Schema: financial; Owner: -
--

CREATE TABLE financial.t_categories (
    category_id bigint NOT NULL,
    description character varying(100) NOT NULL,
    category_type boolean DEFAULT true NOT NULL,
    category_icon character varying(500),
    active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);


--
-- Name: t_categories_category_id_seq; Type: SEQUENCE; Schema: financial; Owner: -
--

ALTER TABLE financial.t_categories ALTER COLUMN category_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME financial.t_categories_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: t_categories_users; Type: TABLE; Schema: financial; Owner: -
--

CREATE TABLE financial.t_categories_users (
    category_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: t_movements; Type: TABLE; Schema: financial; Owner: -
--

CREATE TABLE financial.t_movements (
    movement_id bigint NOT NULL,
    user_id bigint NOT NULL,
    type_id bigint NOT NULL,
    category_id bigint NOT NULL,
    account_id bigint NOT NULL,
    title character varying(150) NOT NULL,
    amount numeric(12,2) NOT NULL,
    description character varying(500),
    accounting_date date NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);


--
-- Name: t_movements_movement_id_seq; Type: SEQUENCE; Schema: financial; Owner: -
--

ALTER TABLE financial.t_movements ALTER COLUMN movement_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME financial.t_movements_movement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: t_movements_tags; Type: TABLE; Schema: financial; Owner: -
--

CREATE TABLE financial.t_movements_tags (
    movement_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


--
-- Name: t_submovements; Type: TABLE; Schema: financial; Owner: -
--

CREATE TABLE financial.t_submovements (
    submovement_id bigint NOT NULL,
    movement_id bigint NOT NULL,
    subcategory_id bigint,
    title character varying(150) NOT NULL,
    amount numeric(12,2) NOT NULL,
    description character varying(500),
    active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);


--
-- Name: t_submovements_submovement_id_seq; Type: SEQUENCE; Schema: financial; Owner: -
--

ALTER TABLE financial.t_submovements ALTER COLUMN submovement_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME financial.t_submovements_submovement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: t_submovements_tags; Type: TABLE; Schema: financial; Owner: -
--

CREATE TABLE financial.t_submovements_tags (
    submovement_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


--
-- Name: t_tags; Type: TABLE; Schema: financial; Owner: -
--

CREATE TABLE financial.t_tags (
    tag_id bigint NOT NULL,
    description character varying(100) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);


--
-- Name: t_tags_tag_id_seq; Type: SEQUENCE; Schema: financial; Owner: -
--

ALTER TABLE financial.t_tags ALTER COLUMN tag_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME financial.t_tags_tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: t_tags_users; Type: TABLE; Schema: financial; Owner: -
--

CREATE TABLE financial.t_tags_users (
    tag_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: t_types; Type: TABLE; Schema: financial; Owner: -
--

CREATE TABLE financial.t_types (
    type_id bigint NOT NULL,
    description character varying(100) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);


--
-- Name: t_types_type_id_seq; Type: SEQUENCE; Schema: financial; Owner: -
--

ALTER TABLE financial.t_types ALTER COLUMN type_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME financial.t_types_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: t_types_users; Type: TABLE; Schema: financial; Owner: -
--

CREATE TABLE financial.t_types_users (
    type_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: t_users; Type: TABLE; Schema: users; Owner: -
--

CREATE TABLE users.t_users (
    user_id bigint NOT NULL,
    first_name character varying(90) NOT NULL,
    last_name character varying(90),
    dni character varying(8) NOT NULL,
    email character varying(150) NOT NULL,
    password character varying(130) NOT NULL,
    image text,
    active boolean DEFAULT true NOT NULL,
    last_login timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);


--
-- Name: vw_movements; Type: VIEW; Schema: financial; Owner: -
--

CREATE VIEW financial.vw_movements AS
 WITH movement_tags AS (
         SELECT mt_1.movement_id,
            jsonb_agg(jsonb_build_object('tag_id', tg.tag_id, 'description', tg.description)) AS tags
           FROM (financial.t_movements_tags mt_1
             JOIN financial.t_tags tg ON ((tg.tag_id = mt_1.tag_id)))
          GROUP BY mt_1.movement_id
        ), submovement_tags AS (
         SELECT st.submovement_id,
            jsonb_agg(jsonb_build_object('tag_id', tg.tag_id, 'description', tg.description)) AS tags
           FROM (financial.t_submovements_tags st
             JOIN financial.t_tags tg ON ((tg.tag_id = st.tag_id)))
          GROUP BY st.submovement_id
        ), submovements_json AS (
         SELECT smv.movement_id,
            jsonb_agg(jsonb_build_object('submovement_id', smv.submovement_id, 'description', smv.description, 'amount', smv.amount, 'subcategory', jsonb_build_object('category_id', scat.category_id, 'category_type', scat.category_type, 'category_icon', scat.category_icon, 'description', scat.description), 'tags', COALESCE(st.tags, '[]'::jsonb))) AS submovements
           FROM ((financial.t_submovements smv
             JOIN financial.t_categories scat ON ((scat.category_id = smv.subcategory_id)))
             LEFT JOIN submovement_tags st ON ((st.submovement_id = smv.submovement_id)))
          WHERE (smv.active = true)
          GROUP BY smv.movement_id
        )
 SELECT mv.movement_id,
    mv.user_id,
    mv.title,
    mv.description,
    mv.amount,
    mv.accounting_date,
    jsonb_build_object('type_id', tp.type_id, 'description', tp.description) AS type,
    jsonb_build_object('category_id', cat.category_id, 'category_type', cat.category_type, 'category_icon', cat.category_icon, 'description', cat.description) AS category,
    jsonb_build_object('account_id', acc.account_id, 'description', acc.description) AS account,
    COALESCE(mt.tags, '[]'::jsonb) AS tags,
    COALESCE(sm.submovements, '[]'::jsonb) AS submovements
   FROM ((((((financial.t_movements mv
     JOIN financial.t_types tp ON ((tp.type_id = mv.type_id)))
     JOIN financial.t_categories cat ON ((cat.category_id = mv.category_id)))
     JOIN financial.t_accounts acc ON ((acc.account_id = mv.account_id)))
     JOIN users.t_users usr ON ((usr.user_id = mv.user_id)))
     LEFT JOIN movement_tags mt ON ((mt.movement_id = mv.movement_id)))
     LEFT JOIN submovements_json sm ON ((sm.movement_id = mv.movement_id)))
  WHERE (mv.active = true);


--
-- Name: t_users_user_id_seq; Type: SEQUENCE; Schema: users; Owner: -
--

ALTER TABLE users.t_users ALTER COLUMN user_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME users.t_users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: t_accounts pk_accounts_id; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_accounts
    ADD CONSTRAINT pk_accounts_id PRIMARY KEY (account_id);


--
-- Name: t_accounts_users pk_accounts_users_id; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_accounts_users
    ADD CONSTRAINT pk_accounts_users_id PRIMARY KEY (account_id, user_id);


--
-- Name: t_categories pk_categories_id; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_categories
    ADD CONSTRAINT pk_categories_id PRIMARY KEY (category_id);


--
-- Name: t_categories_users pk_categories_users_id; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_categories_users
    ADD CONSTRAINT pk_categories_users_id PRIMARY KEY (category_id, user_id);


--
-- Name: t_movements pk_movements_id; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_movements
    ADD CONSTRAINT pk_movements_id PRIMARY KEY (movement_id);


--
-- Name: t_movements_tags pk_movements_tags_id; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_movements_tags
    ADD CONSTRAINT pk_movements_tags_id PRIMARY KEY (movement_id, tag_id);


--
-- Name: t_submovements pk_submovements_id; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_submovements
    ADD CONSTRAINT pk_submovements_id PRIMARY KEY (submovement_id);


--
-- Name: t_submovements_tags pk_submovements_tags_id; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_submovements_tags
    ADD CONSTRAINT pk_submovements_tags_id PRIMARY KEY (submovement_id, tag_id);


--
-- Name: t_tags pk_tags_id; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_tags
    ADD CONSTRAINT pk_tags_id PRIMARY KEY (tag_id);


--
-- Name: t_tags_users pk_tags_users_id; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_tags_users
    ADD CONSTRAINT pk_tags_users_id PRIMARY KEY (tag_id, user_id);


--
-- Name: t_types pk_types_id; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_types
    ADD CONSTRAINT pk_types_id PRIMARY KEY (type_id);


--
-- Name: t_types_users pk_types_users_id; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_types_users
    ADD CONSTRAINT pk_types_users_id PRIMARY KEY (type_id, user_id);


--
-- Name: t_accounts uq_accounts_description; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_accounts
    ADD CONSTRAINT uq_accounts_description UNIQUE (description);


--
-- Name: t_categories uq_categories_description; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_categories
    ADD CONSTRAINT uq_categories_description UNIQUE (description);


--
-- Name: t_tags uq_tags_description; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_tags
    ADD CONSTRAINT uq_tags_description UNIQUE (description);


--
-- Name: t_types uq_types_description; Type: CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_types
    ADD CONSTRAINT uq_types_description UNIQUE (description);


--
-- Name: t_users pk_user_id; Type: CONSTRAINT; Schema: users; Owner: -
--

ALTER TABLE ONLY users.t_users
    ADD CONSTRAINT pk_user_id PRIMARY KEY (user_id);


--
-- Name: t_users uq_users_email; Type: CONSTRAINT; Schema: users; Owner: -
--

ALTER TABLE ONLY users.t_users
    ADD CONSTRAINT uq_users_email UNIQUE (email);


--
-- Name: idx_movements_account_id; Type: INDEX; Schema: financial; Owner: -
--

CREATE INDEX idx_movements_account_id ON financial.t_movements USING btree (account_id);


--
-- Name: idx_movements_accounting_date_id; Type: INDEX; Schema: financial; Owner: -
--

CREATE INDEX idx_movements_accounting_date_id ON financial.t_movements USING btree (accounting_date);


--
-- Name: idx_movements_active_id; Type: INDEX; Schema: financial; Owner: -
--

CREATE INDEX idx_movements_active_id ON financial.t_movements USING btree (active);


--
-- Name: idx_movements_category_id; Type: INDEX; Schema: financial; Owner: -
--

CREATE INDEX idx_movements_category_id ON financial.t_movements USING btree (category_id);


--
-- Name: idx_movements_type_id; Type: INDEX; Schema: financial; Owner: -
--

CREATE INDEX idx_movements_type_id ON financial.t_movements USING btree (type_id);


--
-- Name: idx_movements_user_id; Type: INDEX; Schema: financial; Owner: -
--

CREATE INDEX idx_movements_user_id ON financial.t_movements USING btree (user_id);


--
-- Name: idx_movements_user_id_accounting_date; Type: INDEX; Schema: financial; Owner: -
--

CREATE INDEX idx_movements_user_id_accounting_date ON financial.t_movements USING btree (user_id, accounting_date DESC);


--
-- Name: idx_submovements_active; Type: INDEX; Schema: financial; Owner: -
--

CREATE INDEX idx_submovements_active ON financial.t_submovements USING btree (active);


--
-- Name: idx_submovements_movement; Type: INDEX; Schema: financial; Owner: -
--

CREATE INDEX idx_submovements_movement ON financial.t_submovements USING btree (movement_id);


--
-- Name: idx_submovements_subcategory; Type: INDEX; Schema: financial; Owner: -
--

CREATE INDEX idx_submovements_subcategory ON financial.t_submovements USING btree (subcategory_id);


--
-- Name: t_accounts trg_accounts_set_updated_at; Type: TRIGGER; Schema: financial; Owner: -
--

CREATE TRIGGER trg_accounts_set_updated_at BEFORE UPDATE ON financial.t_accounts FOR EACH ROW EXECUTE FUNCTION shared.fn_set_updated_at();


--
-- Name: t_categories trg_categories_set_updated_at; Type: TRIGGER; Schema: financial; Owner: -
--

CREATE TRIGGER trg_categories_set_updated_at BEFORE UPDATE ON financial.t_categories FOR EACH ROW EXECUTE FUNCTION shared.fn_set_updated_at();


--
-- Name: t_movements trg_movements_set_updated_at; Type: TRIGGER; Schema: financial; Owner: -
--

CREATE TRIGGER trg_movements_set_updated_at BEFORE UPDATE ON financial.t_movements FOR EACH ROW EXECUTE FUNCTION shared.fn_set_updated_at();


--
-- Name: t_tags trg_tags_set_updated_at; Type: TRIGGER; Schema: financial; Owner: -
--

CREATE TRIGGER trg_tags_set_updated_at BEFORE UPDATE ON financial.t_tags FOR EACH ROW EXECUTE FUNCTION shared.fn_set_updated_at();


--
-- Name: t_types trg_types_set_updated_at; Type: TRIGGER; Schema: financial; Owner: -
--

CREATE TRIGGER trg_types_set_updated_at BEFORE UPDATE ON financial.t_types FOR EACH ROW EXECUTE FUNCTION shared.fn_set_updated_at();


--
-- Name: t_users trg_set_updated_at; Type: TRIGGER; Schema: users; Owner: -
--

CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON users.t_users FOR EACH ROW EXECUTE FUNCTION shared.fn_set_updated_at();


--
-- Name: t_accounts_users fk_accounts_users_accounts; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_accounts_users
    ADD CONSTRAINT fk_accounts_users_accounts FOREIGN KEY (account_id) REFERENCES financial.t_accounts(account_id);


--
-- Name: t_accounts_users fk_accounts_users_users; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_accounts_users
    ADD CONSTRAINT fk_accounts_users_users FOREIGN KEY (user_id) REFERENCES users.t_users(user_id);


--
-- Name: t_categories_users fk_categories_users_categories; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_categories_users
    ADD CONSTRAINT fk_categories_users_categories FOREIGN KEY (category_id) REFERENCES financial.t_categories(category_id);


--
-- Name: t_categories_users fk_categories_users_users; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_categories_users
    ADD CONSTRAINT fk_categories_users_users FOREIGN KEY (user_id) REFERENCES users.t_users(user_id);


--
-- Name: t_movements fk_movements_accounts; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_movements
    ADD CONSTRAINT fk_movements_accounts FOREIGN KEY (account_id) REFERENCES financial.t_accounts(account_id);


--
-- Name: t_movements fk_movements_categories; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_movements
    ADD CONSTRAINT fk_movements_categories FOREIGN KEY (category_id) REFERENCES financial.t_categories(category_id);


--
-- Name: t_movements_tags fk_movements_tags_movements; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_movements_tags
    ADD CONSTRAINT fk_movements_tags_movements FOREIGN KEY (movement_id) REFERENCES financial.t_movements(movement_id);


--
-- Name: t_movements fk_movements_types; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_movements
    ADD CONSTRAINT fk_movements_types FOREIGN KEY (type_id) REFERENCES financial.t_types(type_id);


--
-- Name: t_movements fk_movements_users; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_movements
    ADD CONSTRAINT fk_movements_users FOREIGN KEY (user_id) REFERENCES users.t_users(user_id);


--
-- Name: t_submovements fk_submovements_categories; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_submovements
    ADD CONSTRAINT fk_submovements_categories FOREIGN KEY (subcategory_id) REFERENCES financial.t_categories(category_id);


--
-- Name: t_submovements fk_submovements_movements; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_submovements
    ADD CONSTRAINT fk_submovements_movements FOREIGN KEY (movement_id) REFERENCES financial.t_movements(movement_id);


--
-- Name: t_submovements_tags fk_submovements_tags_submovements; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_submovements_tags
    ADD CONSTRAINT fk_submovements_tags_submovements FOREIGN KEY (submovement_id) REFERENCES financial.t_submovements(submovement_id);


--
-- Name: t_submovements_tags fk_submovements_tags_tags; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_submovements_tags
    ADD CONSTRAINT fk_submovements_tags_tags FOREIGN KEY (tag_id) REFERENCES financial.t_tags(tag_id);


--
-- Name: t_movements_tags fk_tag_id_tags; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_movements_tags
    ADD CONSTRAINT fk_tag_id_tags FOREIGN KEY (tag_id) REFERENCES financial.t_tags(tag_id);


--
-- Name: t_tags_users fk_tags_users_tags; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_tags_users
    ADD CONSTRAINT fk_tags_users_tags FOREIGN KEY (tag_id) REFERENCES financial.t_tags(tag_id);


--
-- Name: t_tags_users fk_tags_users_users; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_tags_users
    ADD CONSTRAINT fk_tags_users_users FOREIGN KEY (user_id) REFERENCES users.t_users(user_id);


--
-- Name: t_types_users fk_types_users_types; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_types_users
    ADD CONSTRAINT fk_types_users_types FOREIGN KEY (type_id) REFERENCES financial.t_types(type_id);


--
-- Name: t_types_users fk_types_users_users; Type: FK CONSTRAINT; Schema: financial; Owner: -
--

ALTER TABLE ONLY financial.t_types_users
    ADD CONSTRAINT fk_types_users_users FOREIGN KEY (user_id) REFERENCES users.t_users(user_id);


--
-- PostgreSQL database dump complete
--

\unrestrict 0uCu7KQeQR6KnWqFh4jdwirrC9MB6fzeop0yEuW8BpPcIQfkPIM4fqvbMoCnOpk

--
-- PostgreSQL database dump
--

\restrict pWLIj7Qoytzb7sMFDtE6qll0dZHsVTwTiyfuSkvQgg8XgAjWo2NCKi7XPURB2S5

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

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
-- Data for Name: t_accounts; Type: TABLE DATA; Schema: financial; Owner: -
--

INSERT INTO financial.t_accounts (account_id, description, active, created_at, updated_at, deleted_at) OVERRIDING SYSTEM VALUE VALUES (1, 'Sueldo', true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_accounts (account_id, description, active, created_at, updated_at, deleted_at) OVERRIDING SYSTEM VALUE VALUES (2, 'Ahorros', true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);


--
-- Data for Name: t_categories; Type: TABLE DATA; Schema: financial; Owner: -
--

INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (36, 'Salida por transferencia', true, false, '2026-07-11 23:46:13.257601', '2026-07-11 23:46:13.257601', NULL, NULL);
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (37, 'Ingreso por transferencia', false, false, '2026-07-11 23:46:13.257601', '2026-07-11 23:46:13.257601', NULL, NULL);
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (1, 'Comida', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'kitchen_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (2, 'Restaurante', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'restaurant_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (3, 'Supermercado', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'shopping_cart_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (4, 'Vehículo', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'drive_eta_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (5, 'Salud', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'medical_services_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (6, 'Hogar', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'chair_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (7, 'Facturas', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'receipt_long_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (8, 'Limpieza', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'cleaning_services_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (9, 'Higiene', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'soap_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (28, 'Seguro', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'health_and_safety_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (14, 'Taxi', true, true, '2026-03-13 17:01:33.969955', '2026-07-12 00:22:33.467015', NULL, 'local_taxi_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (16, 'Transporte', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'directions_bus_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (13, 'Alquiler', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'home_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (15, 'Hipoteca', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'house_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (17, 'Electricidad', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'bolt_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (10, 'Agua', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'water_drop_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (11, 'Internet', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'wifi_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (12, 'Teléfono', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'phone_iphone_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (18, 'Educación', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'school_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (19, 'Ropa', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'checkroom_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (20, 'Belleza', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'spa_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (21, 'Mascotas', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'pets_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (22, 'Entretenimiento', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'theater_comedy_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (23, 'Viajes', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'flight_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (24, 'Regalos', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'card_giftcard_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (25, 'Suscripciones', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'subscriptions_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (26, 'Deporte', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'sports_soccer_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (27, 'Tecnología', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'devices_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (29, 'Impuestos', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'account_balance_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (30, 'Inversiones', true, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'trending_up_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (31, 'Ahorro', false, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'savings_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (32, 'Devoluciones', false, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'undo_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (33, 'Salario', false, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'payments_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (34, 'Depositos', false, true, '2026-03-13 17:01:33.969955', '2026-07-11 23:59:07.10963', NULL, 'account_balance_wallet_rounded');
INSERT INTO financial.t_categories (category_id, description, category_type, active, created_at, updated_at, deleted_at, category_icon) OVERRIDING SYSTEM VALUE VALUES (35, 'Transferencia', true, false, '2026-03-17 18:49:19.183207', '2026-07-12 00:53:07.905146', '2026-07-12 00:53:07.905146', NULL);


--
-- Data for Name: t_types; Type: TABLE DATA; Schema: financial; Owner: -
--

INSERT INTO financial.t_types (type_id, description, active, created_at, updated_at, deleted_at) OVERRIDING SYSTEM VALUE VALUES (1, 'Ingreso', true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_types (type_id, description, active, created_at, updated_at, deleted_at) OVERRIDING SYSTEM VALUE VALUES (2, 'Gasto', true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);
INSERT INTO financial.t_types (type_id, description, active, created_at, updated_at, deleted_at) OVERRIDING SYSTEM VALUE VALUES (3, 'Transferencia', true, '2026-03-13 17:01:33.969955', '2026-03-13 17:01:33.969955', NULL);


--
-- Name: t_accounts_account_id_seq; Type: SEQUENCE SET; Schema: financial; Owner: -
--

SELECT pg_catalog.setval('financial.t_accounts_account_id_seq', 4, true);


--
-- Name: t_categories_category_id_seq; Type: SEQUENCE SET; Schema: financial; Owner: -
--

SELECT pg_catalog.setval('financial.t_categories_category_id_seq', 37, true);


--
-- Name: t_types_type_id_seq; Type: SEQUENCE SET; Schema: financial; Owner: -
--

SELECT pg_catalog.setval('financial.t_types_type_id_seq', 3, true);


--
-- PostgreSQL database dump complete
--

\unrestrict pWLIj7Qoytzb7sMFDtE6qll0dZHsVTwTiyfuSkvQgg8XgAjWo2NCKi7XPURB2S5

