
ALTER TABLE financial.t_movements ADD COLUMN transfer_uuid UUID NULL;

-- =====================================================
-- UPDATED VIEWS
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
                    'category_icon', scat.category_icon,
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
    ,mv.amount::NUMERIC(12,2)
    ,mv.accounting_date
    ,jsonb_build_object(
        'type_id', tp.type_id,
        'description', tp.description
    ) AS type
    ,jsonb_build_object(
        'category_id', cat.category_id,
        'category_type', cat.category_type,
        'category_icon', cat.category_icon,
        'description', cat.description
    ) AS category
    ,jsonb_build_object(
        'account_id', acc.account_id,
        'description', acc.description
    ) AS account
    ,COALESCE(mt.tags, '[]'::jsonb) AS tags
    ,COALESCE(sm.submovements, '[]'::jsonb) AS submovements,
    mv.transfer_uuid
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
-- UPDATED FUNCTIONS
-- =====================================================

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
    in_submovements JSONB,
    in_transfer_uuid UUID DEFAULT NULL
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
    submovements JSONB,
    transfer_uuid UUID
)
LANGUAGE plpgsql
AS $$
DECLARE 
    v_movement_id BIGINT;
    v_submovement_id BIGINT;
    sub JSONB;
BEGIN
    -- Primero incerta el mivimiento para sacar el movement_id
    INSERT INTO financial.t_movements AS mv (user_id, type_id, category_id, account_id, title, amount, description, accounting_date, transfer_uuid)
    VALUES (in_user_id, in_type_id, in_category_id, in_account_id, in_title, in_amount, in_description, in_accounting_date, in_transfer_uuid)
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
        mv.submovements,
        mv.transfer_uuid
    FROM financial.vw_movements mv
    WHERE mv.movement_id = v_movement_id;
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
    submovements JSONB,
    transfer_uuid UUID
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
        nmv.submovements,
        nmv.transfer_uuid
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
    submovements JSONB,
    transfer_uuid UUID
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
        ,mv.transfer_uuid
    FROM financial.vw_movements mv
    WHERE 
        mv.user_id = in_user_id
        AND mv.accounting_date >= date_trunc('month', in_accounting_date)::date
        AND mv.accounting_date < (date_trunc('month', in_accounting_date) + interval '1 month')::date;
END;
$$;

-- =====================================================
-- CREATED FUNCTIONS
-- =====================================================

DROP FUNCTION IF EXISTS financial.sp_transfer_movement_create;

CREATE OR REPLACE FUNCTION financial.sp_transfer_movement_create(
    in_user_id BIGINT,
    in_account_in_id BIGINT,
    in_account_out_id BIGINT,
    in_title VARCHAR(150),
    in_amount DECIMAL(12,2),
    in_description VARCHAR(500),
    in_accounting_date DATE,
    in_tags JSONB
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
    submovements JSONB,
    transfer_uuid UUID
)
LANGUAGE plpgsql
AS $$
DECLARE 
    v_category_out_id BIGINT;
    v_category_in_id BIGINT;
    v_type_id BIGINT;
    v_transfer_uuid UUID;
BEGIN

    SELECT catout.category_id INTO v_category_out_id
    FROM financial.t_categories AS catout
    WHERE catout.description = 'Salida por transferencia';

    SELECT catin.category_id INTO v_category_in_id
    FROM financial.t_categories AS catin
    WHERE catin.description = 'Ingreso por transferencia';

    SELECT ty.type_id INTO v_type_id
    FROM financial.t_types AS ty
    WHERE ty.description = 'Transferencia';

    v_transfer_uuid := uuidv7();

    RETURN QUERY
    SELECT 
        mvout.movement_id,
        mvout.user_id,
        mvout.title,
        mvout.description,
        mvout.amount,
        mvout.accounting_date,
        mvout.type,
        mvout.category,
        mvout.account,
        mvout.tags,
        mvout.submovements,
        mvout.transfer_uuid
    FROM financial.sp_movements_create(
        in_user_id
        ,v_type_id
        ,v_category_out_id
        ,in_account_out_id
        ,in_title
        ,in_amount
        ,in_description
        ,in_accounting_date
        ,in_tags
        ,'[]'::jsonb
        ,v_transfer_uuid
    ) mvout
    UNION ALL
    SELECT 
        mvin.movement_id,
        mvin.user_id,
        mvin.title,
        mvin.description,
        mvin.amount,
        mvin.accounting_date,
        mvin.type,
        mvin.category,
        mvin.account,
        mvin.tags,
        mvin.submovements,
        mvin.transfer_uuid
    FROM financial.sp_movements_create(
        in_user_id
        ,v_type_id
        ,v_category_in_id
        ,in_account_in_id
        ,in_title
        ,in_amount
        ,in_description
        ,in_accounting_date
        ,in_tags
        ,'[]'::jsonb
        ,v_transfer_uuid
    ) mvin;
END;
$$;

DROP FUNCTION IF EXISTS financial.sp_transfer_movement_delete;

CREATE OR REPLACE FUNCTION financial.sp_transfer_movement_delete(
    in_transfer_uuid UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE financial.t_movements mv
    SET
        active = FALSE
        ,deleted_at = CURRENT_TIMESTAMP
    WHERE 
        mv.transfer_uuid = in_transfer_uuid
        AND mv.active = TRUE;

    RETURN TRUE;

END;
$$;

DROP FUNCTION IF EXISTS financial.sp_transfer_movement_update;

CREATE OR REPLACE FUNCTION financial.sp_transfer_movement_update(
    in_user_id BIGINT,
    in_transfer_uuid UUID,
    in_account_in_id BIGINT,
    in_account_out_id BIGINT,
    in_title VARCHAR(150),
    in_amount DECIMAL(12,2),
    in_description VARCHAR(500),
    in_accounting_date DATE,
    in_tags JSONB
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
    submovements JSONB,
    transfer_uuid UUID
)
LANGUAGE plpgsql
AS $$
DECLARE 
    v_category_out_id BIGINT;
    v_category_in_id BIGINT;
    v_type_id BIGINT;
BEGIN

    PERFORM financial.sp_transfer_movement_delete(in_transfer_uuid);

    SELECT catout.category_id INTO v_category_out_id
    FROM financial.t_categories AS catout
    WHERE catout.description = 'Salida por transferencia';

    SELECT catin.category_id INTO v_category_in_id
    FROM financial.t_categories AS catin
    WHERE catin.description = 'Ingreso por transferencia';

    SELECT ty.type_id INTO v_type_id
    FROM financial.t_types AS ty
    WHERE ty.description = 'Transferencia';

    RETURN QUERY
    SELECT 
        mvout.movement_id,
        mvout.user_id,
        mvout.title,
        mvout.description,
        mvout.amount,
        mvout.accounting_date,
        mvout.type,
        mvout.category,
        mvout.account,
        mvout.tags,
        mvout.submovements,
        mvout.transfer_uuid
    FROM financial.sp_movements_create(
        in_user_id
        ,v_type_id
        ,v_category_out_id
        ,in_account_out_id
        ,in_title
        ,in_amount
        ,in_description
        ,in_accounting_date
        ,in_tags
        ,'[]'::jsonb
        ,in_transfer_uuid
    ) mvout
    UNION ALL
    SELECT 
        mvin.movement_id,
        mvin.user_id,
        mvin.title,
        mvin.description,
        mvin.amount,
        mvin.accounting_date,
        mvin.type,
        mvin.category,
        mvin.account,
        mvin.tags,
        mvin.submovements,
        mvin.transfer_uuid
    FROM financial.sp_movements_create(
        in_user_id
        ,v_type_id
        ,v_category_in_id
        ,in_account_in_id
        ,in_title
        ,in_amount
        ,in_description
        ,in_accounting_date
        ,in_tags
        ,'[]'::jsonb
        ,in_transfer_uuid
    ) mvin;

END;
$$;