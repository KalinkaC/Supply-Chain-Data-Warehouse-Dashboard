CREATE OR REPLACE PROCEDURE SILVER.VALIDATE_DATA()
RETURNS STRING
LANGUAGE SQL
AS
DECLARE
    v_null_order_id INT DEFAULT 0;
    v_null_customer_id INT DEFAULT 0;
    v_null_purchase INT DEFAULT 0;
    v_invalid_dates INT DEFAULT 0;
    v_negative_values INT DEFAULT 0;
    v_status VARCHAR DEFAULT 'PASSED';
    v_message VARCHAR DEFAULT '';
BEGIN
    SELECT COUNT(*) INTO :v_null_order_id
    FROM SILVER.ORDERS
    WHERE ORDER_ID IS NULL;

    SELECT COUNT(*) INTO :v_null_customer_id
    FROM SILVER.ORDERS
    WHERE CUSTOMER_ID IS NULL;

    SELECT COUNT(*) INTO :v_null_purchase
    FROM SILVER.ORDERS
    WHERE ORDER_PURCHASE IS NULL;

    SELECT COUNT(*) INTO :v_invalid_dates
    FROM SILVER.ORDERS
    WHERE ORDER_DELIVERED < ORDER_PURCHASE;

    SELECT COUNT(*) INTO :v_negative_values
    FROM SILVER.ORDERS
    WHERE TOTAL_ORDER_VALUE < 0
       OR PRICE < 0
       OR SHIPPING_CHARGES < 0;

    IF (:v_null_order_id > 0
        OR :v_null_customer_id > 0
        OR :v_null_purchase > 0
        OR :v_invalid_dates > 0
        OR :v_negative_values > 0) THEN

        v_status := 'FAILED';
        v_message :=
            'Validation failed! Issues found: ' ||
            'NULL ORDER_ID: ' || :v_null_order_id || ', ' ||
            'NULL CUSTOMER_ID: ' || :v_null_customer_id || ', ' ||
            'NULL ORDER_PURCHASE: ' || :v_null_purchase || ', ' ||
            'Invalid dates: ' || :v_invalid_dates || ', ' ||
            'Negative values: ' || :v_negative_values;
    ELSE
        v_status := 'PASSED';
        v_message := 'All validation checks passed successfully.';
    END IF;

    INSERT INTO SILVER.AUDIT_LOG
        (PROCEDURE_NAME, STATUS, ROWS_PROCESSED, MESSAGE)
    SELECT
        'VALIDATE_DATA',
        :v_status,
        COUNT(*),
        :v_message
    FROM SILVER.ORDERS;

    RETURN :v_message;
END;

CALL SILVER.VALIDATE_DATA();