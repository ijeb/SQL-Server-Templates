
/* show physical index stats for all indexes in all tables with database name and index name included */

SELECT  DB_NAME(dps.database_id) AS database_name ,
        OBJECT_NAME(dps.object_id) AS table_name ,
        ( SELECT TOP 1
                    name
          FROM      sys.indexes si
          WHERE     si.object_id = dps.object_id
                    AND si.index_id = dps.index_id
        ) AS index_name ,
        *
FROM    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') dps
ORDER BY OBJECT_NAME([object_id]) ,
        index_id ,
        partition_number;