CREATE SCHEMA IF NOT EXISTS users;

DROP TABLE IF EXISTS users.t_users;
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

CREATE SCHEMA IF NOT EXISTS financial;

-- =====================================================
-- TYPES
-- =====================================================
DROP TABLE IF EXISTS financial.t_types;
CREATE TABLE financial.t_types (
    type_id BIGINT GENERATED ALWAYS AS IDENTITY,
    description VARCHAR(100) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT pk_types_id PRIMARY KEY (type_id),
    CONSTRAINT uq_types_description UNIQUE (description)
);

DROP TABLE IF EXISTS financial.t_types_users;
CREATE TABLE financial.t_types_users(
    type_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    CONSTRAINT pk_types_users_id PRIMARY KEY (type_id, user_id),
    CONSTRAINT fk_types_users_types FOREIGN KEY (type_id) REFERENCES financial.t_types(type_id),
    CONSTRAINT fk_types_users_users FOREIGN KEY (user_id) REFERENCES users.t_users(user_id)
);

-- =====================================================
-- CATEGORIES
-- =====================================================
DROP TABLE IF EXISTS financial.t_categories;
CREATE TABLE financial.t_categories (
    category_id BIGINT GENERATED ALWAYS AS IDENTITY,
    description VARCHAR(100) NOT NULL,
    category_type BOOLEAN NOT NULL DEFAULT TRUE,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT pk_categories_id PRIMARY KEY (category_id),
    CONSTRAINT uq_categories_description UNIQUE (description)
);

DROP TABLE IF EXISTS financial.t_categories_users;
CREATE TABLE financial.t_categories_users(
    category_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    CONSTRAINT pk_categories_users_id PRIMARY KEY (category_id, user_id),
    CONSTRAINT fk_categories_users_categories FOREIGN KEY (category_id) REFERENCES financial.t_categories(category_id),
    CONSTRAINT fk_categories_users_users FOREIGN KEY (user_id) REFERENCES users.t_users(user_id)
);

-- =====================================================
-- TAGS
-- =====================================================
DROP TABLE IF EXISTS financial.t_tags;
CREATE TABLE financial.t_tags (
    tag_id BIGINT GENERATED ALWAYS AS IDENTITY,
    description VARCHAR(100) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT pk_tags_id PRIMARY KEY (tag_id),
    CONSTRAINT uq_tags_description UNIQUE (description)
);

DROP TABLE IF EXISTS financial.t_tags_users;
CREATE TABLE financial.t_tags_users(
    tag_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    CONSTRAINT pk_tags_users_id PRIMARY KEY (tag_id, user_id),
    CONSTRAINT fk_tags_users_tags FOREIGN KEY (tag_id) REFERENCES financial.t_tags(tag_id),
    CONSTRAINT fk_tags_users_users FOREIGN KEY (user_id) REFERENCES users.t_users(user_id)
);

-- =====================================================
-- ACCOUNTS
-- =====================================================
DROP TABLE IF EXISTS financial.t_accounts;
CREATE TABLE financial.t_accounts (
    account_id BIGINT GENERATED ALWAYS AS IDENTITY,
    description VARCHAR(100) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT pk_accounts_id PRIMARY KEY (account_id),
    CONSTRAINT uq_accounts_description UNIQUE (description)
);

DROP TABLE IF EXISTS financial.t_accounts_users;
CREATE TABLE financial.t_accounts_users(
    account_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    CONSTRAINT pk_accounts_users_id PRIMARY KEY (account_id, user_id),
    CONSTRAINT fk_accounts_users_accounts FOREIGN KEY (account_id) REFERENCES financial.t_accounts(account_id),
    CONSTRAINT fk_accounts_users_users FOREIGN KEY (user_id) REFERENCES users.t_users(user_id)
);

-- =====================================================
-- MOVEMENTS
-- =====================================================
DROP TABLE IF EXISTS financial.t_movements;
CREATE TABLE financial.t_movements (
    movement_id BIGINT GENERATED ALWAYS AS IDENTITY,
    user_id BIGINT NOT NULL,
    type_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    account_id BIGINT NOT NULL,
    title VARCHAR(150) NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    description VARCHAR(500),
    accounting_date DATE NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT pk_movements_id PRIMARY KEY (movement_id),
    CONSTRAINT fk_movements_users FOREIGN KEY (user_id) REFERENCES users.t_users(user_id),
    CONSTRAINT fk_movements_types FOREIGN KEY (type_id) REFERENCES financial.t_types(type_id),
    CONSTRAINT fk_movements_categories FOREIGN KEY (category_id) REFERENCES financial.t_categories(category_id),
    CONSTRAINT fk_movements_accounts FOREIGN KEY (account_id) REFERENCES financial.t_accounts(account_id)
);

CREATE INDEX idx_movements_user_id ON financial.t_movements (user_id);
CREATE INDEX idx_movements_accounting_date_id ON financial.t_movements (accounting_date);
CREATE INDEX idx_movements_user_id_accounting_date ON financial.t_movements (user_id, accounting_date DESC);
CREATE INDEX idx_movements_category_id ON financial.t_movements (category_id);
CREATE INDEX idx_movements_account_id ON financial.t_movements (account_id);
CREATE INDEX idx_movements_type_id ON financial.t_movements (type_id);
CREATE INDEX idx_movements_active_id ON financial.t_movements (active);

-- =====================================================
-- SUBMOVEMENTS
-- =====================================================
DROP TABLE IF EXISTS financial.t_submovements;
CREATE TABLE financial.t_submovements (
    submovement_id BIGINT GENERATED ALWAYS AS IDENTITY,
    movement_id BIGINT NOT NULL,
    subcategory_id BIGINT,
    title VARCHAR(150) NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    description VARCHAR(500),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT pk_submovements_id PRIMARY KEY (submovement_id),
    CONSTRAINT fk_submovements_movements FOREIGN KEY (movement_id) REFERENCES financial.t_movements(movement_id),
    CONSTRAINT fk_submovements_categories FOREIGN KEY (subcategory_id) REFERENCES financial.t_categories(category_id)
);

CREATE INDEX idx_submovements_movement ON financial.t_submovements (movement_id);
CREATE INDEX idx_submovements_subcategory ON financial.t_submovements (subcategory_id);
CREATE INDEX idx_submovements_active ON financial.t_submovements (active);

-- =====================================================
-- MOVEMENTS-TAGS
-- =====================================================
DROP TABLE IF EXISTS financial.t_movements_tags;
CREATE TABLE financial.t_movements_tags (
    movement_id BIGINT NOT NULL,
    tag_id BIGINT NOT NULL,
    CONSTRAINT pk_movements_tags_id PRIMARY KEY (movement_id, tag_id),
    CONSTRAINT fk_movements_tags_movements FOREIGN KEY (movement_id) REFERENCES financial.t_movements(movement_id),
    CONSTRAINT fk_tag_id_tags FOREIGN KEY (tag_id) REFERENCES financial.t_tags(tag_id)
);

-- =====================================================
-- SUBMOVEMENTS-TAGS
-- =====================================================
DROP TABLE financial.t_submovements_tags;
CREATE TABLE financial.t_submovements_tags (
    submovement_id BIGINT NOT NULL,
    tag_id BIGINT NOT NULL,
    CONSTRAINT pk_submovements_tags_id PRIMARY KEY (submovement_id, tag_id),
    CONSTRAINT fk_submovements_tags_submovements FOREIGN KEY (submovement_id) REFERENCES financial.t_submovements(submovement_id),
    CONSTRAINT fk_submovements_tags_tags FOREIGN KEY (tag_id) REFERENCES financial.t_tags(tag_id)
);

-- =====================================================
-- FUNCTIONS
-- =====================================================
DROP FUNCTION IF EXISTS shared.fn_set_updated_at;
CREATE OR REPLACE FUNCTION shared.fn_set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- =====================================================
-- TRIGGERS
-- =====================================================

CREATE TRIGGER trg_set_updated_at
BEFORE UPDATE ON users.t_users
FOR EACH ROW
EXECUTE FUNCTION shared.fn_set_updated_at();

CREATE TRIGGER trg_types_set_updated_at
BEFORE UPDATE ON financial.t_types
FOR EACH ROW
EXECUTE FUNCTION shared.fn_set_updated_at();

CREATE TRIGGER trg_categories_set_updated_at
BEFORE UPDATE ON financial.t_categories
FOR EACH ROW
EXECUTE FUNCTION shared.fn_set_updated_at();

CREATE TRIGGER trg_tags_set_updated_at
BEFORE UPDATE ON financial.t_tags
FOR EACH ROW
EXECUTE FUNCTION shared.fn_set_updated_at();

CREATE TRIGGER trg_accounts_set_updated_at
BEFORE UPDATE ON financial.t_accounts
FOR EACH ROW
EXECUTE FUNCTION shared.fn_set_updated_at();

CREATE TRIGGER trg_movements_set_updated_at
BEFORE UPDATE ON financial.t_movements
FOR EACH ROW
EXECUTE FUNCTION shared.fn_set_updated_at();

CREATE TRIGGER trg_sub_movements_set_updated_at
BEFORE UPDATE ON financial.t_submovements
FOR EACH ROW
EXECUTE FUNCTION shared.fn_set_updated_at();

-- =====================================================
-- FIRSTS INSETS
-- =====================================================
INSERT INTO financial.t_types(description)
VALUES ('Ingreso'),('Gasto'),('Transferencia');

INSERT INTO financial.t_categories(description, category_type)
VALUES ('Comida', TRUE),
('Restaurante', TRUE),
('Supermercado', TRUE),
('Gasolina', TRUE),
('Taxi', TRUE),
('Transporte', TRUE),
('Alquiler', TRUE),
('Hipoteca', TRUE),
('Electricidad', TRUE),
('Agua', TRUE),
('Internet', TRUE),
('Teléfono', TRUE),
('Limpieza', TRUE),
('Salud', TRUE),
('Higiene', TRUE),
('Facturas', TRUE),
('Seguro', TRUE),
('Educación', TRUE),
('Ropa', TRUE),
('Belleza', TRUE),
('Mascotas', TRUE),
('Entretenimiento', TRUE),
('Viajes', TRUE),
('Regalos', TRUE),
('Suscripciones', TRUE),
('Deporte', TRUE),
('Tecnología', TRUE),
('Hogar', TRUE),
('Impuestos', TRUE),
('Inversiones', TRUE),
('Ahorro', FALSE),
('Devoluciones', FALSE),
('Salario', FALSE),
('Depositos', FALSE);

INSERT INTO financial.t_accounts(description)
VALUES ('Sueldo'), ('Ahorros');

-- =====================================================
-- VIEWS
-- =====================================================
DROP VIEW IF EXISTS financial.vw_movements;
CREATE VIEW financial.vw_movements
AS
WITH movement_tags AS (
    SELECT
        mt.movement_id,
        jsonb_agg(
            jsonb_build_object(
                'tag_id', tg.tag_id,
                'description', tg.description
            )
        ) AS tags
    FROM 
        financial.t_movements_tags mt
        INNER JOIN financial.t_tags tg ON tg.tag_id = mt.tag_id
    GROUP BY mt.movement_id
)
,submovement_tags AS (
    SELECT
        st.submovement_id,
        jsonb_agg(
            jsonb_build_object(
                'tag_id', tg.tag_id,
                'description', tg.description
            )
        ) AS tags
    FROM 
        financial.t_submovements_tags st
        INNER JOIN financial.t_tags tg ON tg.tag_id = st.tag_id
    GROUP BY st.submovement_id
),
submovements_json AS (
    SELECT
        smv.movement_id,
        jsonb_agg(
            jsonb_build_object(
                'submovement_id', smv.submovement_id,
                'description', smv.description,
                'amount', smv.amount,
                'subcategory',
                jsonb_build_object(
                    'category_id', scat.category_id,
                    'category_type', scat.category_type,
                    'description', scat.description
                ),
                'tags', COALESCE(st.tags, '[]'::jsonb)
            )
        ) AS submovements
    FROM 
        financial.t_submovements smv
        INNER JOIN financial.t_categories scat ON scat.category_id = smv.subcategory_id
        LEFT JOIN submovement_tags st ON st.submovement_id = smv.submovement_id
    WHERE smv.active = TRUE
    GROUP BY smv.movement_id
)
SELECT
    mv.movement_id
    ,mv.user_id
    ,mv.title
    ,mv.description
    ,mv.amount
    ,mv.accounting_date
    ,jsonb_build_object(
        'type_id', tp.type_id,
        'description', tp.description
    ) AS type
    ,jsonb_build_object(
        'category_id', cat.category_id,
        'category_type', cat.category_type,
        'description', cat.description
    ) AS category
    ,jsonb_build_object(
        'account_id', acc.account_id,
        'description', acc.description
    ) AS account
    ,COALESCE(mt.tags, '[]'::jsonb) AS tags
    ,COALESCE(sm.submovements, '[]'::jsonb) AS submovements
FROM 
    financial.t_movements mv
    INNER JOIN financial.t_types tp ON tp.type_id = mv.type_id
    INNER JOIN financial.t_categories cat ON cat.category_id = mv.category_id
    INNER JOIN financial.t_accounts acc ON acc.account_id = mv.account_id
    INNER JOIN users.t_users usr ON usr.user_id = mv.user_id
    LEFT JOIN movement_tags mt ON mt.movement_id = mv.movement_id
    LEFT JOIN submovements_json sm ON sm.movement_id = mv.movement_id
WHERE mv.active = TRUE;


-- =====================================================
-- PROCEDURES
-- =====================================================
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
    WHERE cat.description IN ('Comida','Restaurante','Supermercado','Gasolina','Taxi','Transporte','Alquiler','Hipoteca','Electricidad','Agua','Internet',
        'Teléfono','Limpieza','Salud','Higiene','Facturas','Seguro','Educación','Ropa','Belleza','Mascotas','Entretenimiento','Viajes','Regalos','Suscripciones','Deporte',
        'Tecnología','Hogar','Impuestos','Inversiones','Ahorro', 'Devoluciones', 'Salario', 'Depositos');

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

DROP FUNCTION IF EXISTS financial.sp_tags_get_all;

CREATE OR REPLACE FUNCTION financial.sp_tags_get_all(
    in_user_id BIGINT
)
RETURNS TABLE (
    tag_id BIGINT,
    description VARCHAR(100)
)
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

DROP FUNCTION IF EXISTS financial.sp_tags_create;

CREATE OR REPLACE FUNCTION financial.sp_tags_create(
    in_description VARCHAR(100),
    in_user_id BIGINT
)
RETURNS TABLE (
    tag_id BIGINT,
    description VARCHAR(100)
)
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

DROP FUNCTION IF EXISTS financial.sp_categories_get_all;

CREATE OR REPLACE FUNCTION financial.sp_categories_get_all(
    in_user_id BIGINT
)
RETURNS TABLE (
    category_id BIGINT,
    category_type BOOLEAN,
    description VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        cat.category_id, cat.category_type, cat.description
    FROM 
        financial.t_categories cat
        INNER JOIN financial.t_categories_users usrc ON usrc.category_id = cat.category_id
    WHERE
        cat.active = TRUE
        AND usrc.user_id = in_user_id;
END;
$$;

DROP FUNCTION IF EXISTS financial.sp_categories_create;

CREATE OR REPLACE FUNCTION financial.sp_categories_create(
    in_description VARCHAR(100),
    in_category_type BOOLEAN,
    in_user_id BIGINT
)
RETURNS TABLE (
    category_id BIGINT,
    category_type BOOLEAN,
    description VARCHAR(100)
)
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
            INSERT INTO financial.t_categories (description, category_type)
            VALUES (in_description, in_category_type);

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
        cat.category_id, cat.category_type, cat.description
    FROM 
        financial.t_categories cat
        INNER JOIN financial.t_categories_users usrc ON usrc.category_id = cat.category_id AND usrc.user_id = in_user_id
    WHERE cat.description = in_description;
END;
$$;

DROP FUNCTION IF EXISTS financial.sp_accounts_get_all;

CREATE OR REPLACE FUNCTION financial.sp_accounts_get_all(
    in_user_id BIGINT
)
RETURNS TABLE (
    account_id BIGINT,
    description VARCHAR(100)
)
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

DROP FUNCTION IF EXISTS financial.sp_accounts_create;

CREATE OR REPLACE FUNCTION financial.sp_accounts_create(
    in_description VARCHAR(100),
    in_user_id BIGINT
)
RETURNS TABLE (
    account_id BIGINT,
    description VARCHAR(100)
)
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


DROP FUNCTION IF EXISTS financial.sp_movements_create;

CREATE OR REPLACE FUNCTION financial.sp_movements_create(
    in_user_id BIGINT,
    in_type_id BIGINT,
    in_category_id BIGINT,
    in_account_id BIGINT,
    in_title VARCHAR(150),
    in_amount DECIMAL(12,2),
    in_description VARCHAR(500),
    in_accounting_date DATE,
    in_tags JSONB,
    in_submovements JSONB
)
RETURNS TABLE (
    movement_id BIGINT,
    user_id BIGINT,
    title VARCHAR,
    description VARCHAR,
    amount NUMERIC,
    accounting_date DATE,
    type JSONB,
    category JSONB,
    account JSONB,
    tags JSONB,
    submovements JSONB
)
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

DROP FUNCTION IF EXISTS financial.sp_get_all_movements_by_user_and_date;

CREATE OR REPLACE FUNCTION financial.sp_get_all_movements_by_user_and_date(
    in_user_id BIGINT
    ,in_accounting_date DATE
)
RETURNS TABLE (
    movement_id BIGINT,
    user_id BIGINT,
    title VARCHAR,
    description VARCHAR,
    amount NUMERIC,
    accounting_date DATE,
    type JSONB,
    category JSONB,
    account JSONB,
    tags JSONB,
    submovements JSONB
)
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
        AND mv.accounting_date = in_accounting_date;
END;
$$;

DROP FUNCTION IF EXISTS financial.sp_movements_delete;

CREATE OR REPLACE FUNCTION financial.sp_movements_delete(
    in_movement_id BIGINT
)
RETURNS BIGINT
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

DROP FUNCTION IF EXISTS financial.sp_movements_update;

CREATE OR REPLACE FUNCTION financial.sp_movements_update(
    in_movement_id BIGINT,
    in_user_id BIGINT,
    in_type_id BIGINT,
    in_category_id BIGINT,
    in_account_id BIGINT,
    in_title VARCHAR(150),
    in_amount DECIMAL(12,2),
    in_description VARCHAR(500),
    in_accounting_date DATE,
    in_tags JSONB,
    in_submovements JSONB
)
RETURNS TABLE (
    movement_id BIGINT,
    user_id BIGINT,
    title VARCHAR,
    description VARCHAR,
    amount NUMERIC,
    accounting_date DATE,
    type JSONB,
    category JSONB,
    account JSONB,
    tags JSONB,
    submovements JSONB
)
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