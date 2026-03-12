DROP TABLE users.t_users;

CREATE TABLE users.t_users (
    user_id BIGINT GENERATED ALWAYS AS IDENTITY,
    first_name VARCHAR(90) NOT NULL,
    last_name VARCHAR(90),
    dni VARCHAR(8) NOT NULL,
    email VARCHAR(150) NOT NULL,
    password VARCHAR(130) NOT NULL,
    image TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT pk_user_id PRIMARY KEY (user_id)
);

CREATE OR REPLACE FUNCTION shared.fn_set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_set_updated_at
BEFORE UPDATE ON users.t_users
FOR EACH ROW
EXECUTE FUNCTION shared.fn_set_updated_at();

drop function if exists users.sp_users_save;

CREATE OR REPLACE FUNCTION users.sp_users_save(
    in_first_name VARCHAR(90),
    in_last_name VARCHAR(90),
    in_dni VARCHAR(8),
    in_email VARCHAR(150),
    in_password VARCHAR(130),
    in_image VARCHAR(255)
)
RETURNS TABLE (
    user_id BIGINT,
    first_name VARCHAR,
    last_name VARCHAR,
    dni VARCHAR,
    email VARCHAR,
    password VARCHAR,
    image TEXT,
    active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO users.t_users (
        first_name, last_name, dni, email, password, image, active
    )
    VALUES (
        in_first_name, in_last_name, in_dni,
        in_email, in_password, in_image, TRUE
    );

    RETURN QUERY
    SELECT 
        u.user_id, u.first_name, u.last_name, u.dni,
        u.email, u.password, u.image, u.active,
        u.created_at, u.updated_at, u.deleted_at
    FROM users.t_users u
    WHERE u.email = in_email;
END;
$$;

DROP FUNCTION IF EXISTS users.sp_users_get_all;

CREATE OR REPLACE FUNCTION users.sp_users_get_all()
RETURNS TABLE (
    user_id BIGINT,
    first_name VARCHAR,
    last_name VARCHAR,
    dni VARCHAR,
    email VARCHAR,
    password VARCHAR,
    image TEXT,
    active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
)
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

DROP FUNCTION IF EXISTS users.sp_users_get_by_id;

CREATE OR REPLACE FUNCTION users.sp_users_get_by_id(in_id BIGINT)
RETURNS TABLE (
    user_id BIGINT,
    first_name VARCHAR,
    last_name VARCHAR,
    dni VARCHAR,
    email VARCHAR,
    password VARCHAR,
    image TEXT,
    active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
)
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

DROP FUNCTION IF EXISTS users.sp_users_get_by_email;

CREATE OR REPLACE FUNCTION users.sp_users_get_by_email(in_email VARCHAR)
RETURNS TABLE (
    user_id BIGINT,
    first_name VARCHAR,
    last_name VARCHAR,
    dni VARCHAR,
    email VARCHAR,
    password VARCHAR,
    image TEXT,
    active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
)
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

DROP FUNCTION IF EXISTS users.sp_users_update;

CREATE OR REPLACE FUNCTION users.sp_users_update(
    in_id BIGINT,
    in_first_name VARCHAR,
    in_last_name VARCHAR,
    in_dni VARCHAR,
    in_image VARCHAR
)
RETURNS TABLE(
    user_id BIGINT
)
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

DROP FUNCTION IF EXISTS users.sp_users_delete;

CREATE OR REPLACE FUNCTION users.sp_users_delete(in_id BIGINT)
RETURNS TABLE (
    user_id BIGINT
)
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

DROP FUNCTION IF EXISTS users.sp_change_password_by_id;

CREATE OR REPLACE FUNCTION users.sp_change_password_by_id(
    in_id BIGINT,
    in_password VARCHAR
)
RETURNS TABLE (
    user_id BIGINT
)
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