CREATE OR REPLACE PROCEDURE SILVER.REFRESH_GOLD()
RETURNS STRING
LANGUAGE SQL
AS
DECLARE
    v_validation_result VARCHAR;
    v_clean_result VARCHAR;
    v_final_message VARCHAR;
BEGIN
    CALL SILVER.VALIDATE_DATA() INTO v_validation_result;

    IF (v_validation_result LIKE '%FAILED%') THEN
        INSERT INTO SILVER.AUDIT_LOG
            (PROCEDURE_NAME, STATUS, ROWS_PROCESSED, MESSAGE)
        VALUES (
            'REFRESH_GOLD',
            'ABORTED',
            0,
            'Pipeline aborted due to validation failure: ' || v_validation_result
        );
        RETURN 'Pipeline aborted! ' || v_validation_result;
    END IF;

    CALL SILVER.CLEAN_SILVER_DATA() INTO v_clean_result;

    v_final_message := 
        'Pipeline completed successfully! ' ||
        'Validation: PASSED. ' ||
        'Cleaning: ' || v_clean_result;

    INSERT INTO SILVER.AUDIT_LOG
        (PROCEDURE_NAME, STATUS, ROWS_PROCESSED, MESSAGE)
    VALUES (
        'REFRESH_GOLD',
        'SUCCESS',
        0,
        :v_final_message
    );
    RETURN :v_final_message;
END;

CALL SILVER.REFRESH_GOLD();
