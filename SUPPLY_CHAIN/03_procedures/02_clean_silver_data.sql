CREATE OR REPLACE PROCEDURE SILVER.CLEAN_SILVER_DATA()
RETURNS STRING
LANGUAGE SQL
AS
DECLARE
    v_deleted_orders NUMBER DEFAULT 0;
    v_deleted_customers NUMBER DEFAULT 0;
    v_deleted_products NUMBER DEFAULT 0;
    v_result_message STRING;
BEGIN

    DELETE FROM SILVER.ORDERS
    WHERE ORDER_ID IS NULL
       OR CUSTOMER_ID IS NULL
       OR ORDER_PURCHASE IS NULL;

    DELETE FROM SILVER.ORDERS o
    USING (
        SELECT ORDER_ID,
               ROW_NUMBER() OVER (
                   PARTITION BY ORDER_ID
                   ORDER BY ORDER_PURCHASE ASC
               ) AS rn
        FROM SILVER.ORDERS
    ) d
    WHERE o.ORDER_ID = d.ORDER_ID
      AND d.rn > 1;

    v_deleted_orders := SQLROWCOUNT;

    DELETE FROM SILVER.CUSTOMERS
    WHERE CUSTOMER_ID IS NULL;

    DELETE FROM SILVER.CUSTOMERS c
    USING (
        SELECT CUSTOMER_ID,
               ROW_NUMBER() OVER (
                   PARTITION BY CUSTOMER_ID
                   ORDER BY CUSTOMER_ID
               ) AS rn
        FROM SILVER.CUSTOMERS
    ) d
    WHERE c.CUSTOMER_ID = d.CUSTOMER_ID
      AND d.rn > 1;

    v_deleted_customers := SQLROWCOUNT;

    DELETE FROM SILVER.PRODUCTS
    WHERE PRODUCT_ID IS NULL;

    DELETE FROM SILVER.PRODUCTS p
    USING (
        SELECT PRODUCT_ID,
               ROW_NUMBER() OVER (
                   PARTITION BY PRODUCT_ID
                   ORDER BY PRODUCT_ID
               ) AS rn
        FROM SILVER.PRODUCTS
    ) d
    WHERE p.PRODUCT_ID = d.PRODUCT_ID
      AND d.rn > 1;

    v_deleted_products := SQLROWCOUNT;

    v_result_message :=
        'Cleaning completed! Removed: ' ||
        :v_deleted_orders || ' duplicate orders, ' ||
        :v_deleted_customers || ' duplicate customers, ' ||
        :v_deleted_products || ' duplicate products.';

    INSERT INTO SILVER.AUDIT_LOG
        (PROCEDURE_NAME, STATUS, ROWS_PROCESSED, MESSAGE)
    VALUES (
        'CLEAN_SILVER_DATA',
        'SUCCESS',
        :v_deleted_orders + :v_deleted_customers + :v_deleted_products,
        :v_result_message
    );

    RETURN :v_result_message;

END;

CALL SILVER.CLEAN_SILVER_DATA();
