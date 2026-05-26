CREATE ROLE IF NOT EXISTS ANALYST_ROLE COMMENT = 'Role for data analysts - read access to GOLD schema only';
CREATE ROLE IF NOT EXISTS ENGINEER_ROLE COMMENT = 'Role for data engineers - full access to all schemas';
CREATE ROLE IF NOT EXISTS VIEWER_ROLE COMMENT = 'Role for business users - read-only access to GOLD schema';

SHOW ROLES;