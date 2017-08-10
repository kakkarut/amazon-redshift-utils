--DROP VIEW admin.v_generate_objects_grants;
/**********************************************************************************************
Purpose: View to get the grants for an object.  This will give the grant statement for any object be it view or a table

History:
2017-08-11 anuragk Created
**********************************************************************************************/

CREATE OR REPLACE VIEW admin.v_generate_objects_grants
AS
  SELECT
    tab1.schema_name,
    tab1.object_name,
    replace(tab1.grantsql, 'TO ;', 'TO public;') AS grantsql
  FROM
    (WITH object_list(schema_name, object_name, permission_info)
    AS (
        SELECT
          N.nspname,
          C.relname,
          array_to_string(relacl, ',')
        FROM pg_class AS C
          INNER JOIN pg_namespace AS N
            ON C.relnamespace = N.oid
        WHERE C.relkind IN ('v', 'r')
              AND N.nspname NOT IN ('pg_catalog', 'pg_toast', 'information_schema')
              AND C.relacl [1] IS NOT NULL
    ),
        object_permissions(schema_name, object_name, permission_string)
      AS (
        SELECT
          schema_name,
          object_name,
          SPLIT_PART(permission_info, ',', 1)
        FROM object_list
        UNION ALL
        SELECT
          schema_name,
          object_name,
          SPLIT_PART(permission_info, ',', 2)
        FROM object_list
        UNION ALL
        SELECT
          schema_name,
          object_name,
          SPLIT_PART(permission_info, ',', 3)
        FROM object_list
        UNION ALL
        SELECT
          schema_name,
          object_name,
          SPLIT_PART(permission_info, ',', 4)
        FROM object_list
        UNION ALL
        SELECT
          schema_name,
          object_name,
          SPLIT_PART(permission_info, ',', 5)
        FROM object_list
        UNION ALL
        SELECT
          schema_name,
          object_name,
          SPLIT_PART(permission_info, ',', 6)
        FROM object_list
        UNION ALL
        SELECT
          schema_name,
          object_name,
          SPLIT_PART(permission_info, ',', 7)
        FROM object_list
        UNION ALL
        SELECT
          schema_name,
          object_name,
          SPLIT_PART(permission_info, ',', 8)
        FROM object_list
        UNION ALL
        SELECT
          schema_name,
          object_name,
          SPLIT_PART(permission_info, ',', 9)
        FROM object_list
        UNION ALL
        SELECT
          schema_name,
          object_name,
          SPLIT_PART(permission_info, ',', 10)
        FROM object_list
      ),
        permission_parts(schema_name, object_name, security_principal, permission_pattern)
      AS (
          SELECT
            schema_name,
            object_name,
            LEFT(permission_string, CHARINDEX('=', permission_string) - 1),
            SPLIT_PART(SPLIT_PART(permission_string, '=', 2), '/', 1)
          FROM object_permissions
          WHERE permission_string > ''
      )
    SELECT
      schema_name,
      object_name,
      'GRANT ' ||
      SUBSTRING(
          CASE WHEN charindex('r', permission_pattern) > 0
            THEN ',SELECT '
          ELSE '' END
          || CASE WHEN charindex('w', permission_pattern) > 0
            THEN ',UPDATE '
             ELSE '' END
          || CASE WHEN charindex('a', permission_pattern) > 0
            THEN ',INSERT '
             ELSE '' END
          || CASE WHEN charindex('d', permission_pattern) > 0
            THEN ',DELETE '
             ELSE '' END
          || CASE WHEN charindex('R', permission_pattern) > 0
            THEN ',RULE '
             ELSE '' END
          || CASE WHEN charindex('x', permission_pattern) > 0
            THEN ',REFERENCES '
             ELSE '' END
          || CASE WHEN charindex('t', permission_pattern) > 0
            THEN ',TRIGGER '
             ELSE '' END
          || CASE WHEN charindex('X', permission_pattern) > 0
            THEN ',EXECUTE '
             ELSE '' END
          || CASE WHEN charindex('U', permission_pattern) > 0
            THEN ',USAGE '
             ELSE '' END
          || CASE WHEN charindex('C', permission_pattern) > 0
            THEN ',CREATE '
             ELSE '' END
          || CASE WHEN charindex('T', permission_pattern) > 0
            THEN ',TEMPORARY '
             ELSE '' END
          , 2, 10000
      )
      || ' ON ' || schema_name || '.' || object_name
      || ' TO ' || security_principal
      || ';' AS grantsql
    FROM permission_parts) tab1;

