
CREATE PROCEDURE [dbo].[sp_spaceused2]
AS
SET NOCOUNT ON
DECLARE @allocation_table table
(
      dbname sysname,
      reservedpages bigint,
      usedpages bigint,
      pages bigint
)
INSERT INTO @allocation_table
EXEC sp_MSforeachdb N'IF EXISTS
(
     SELECT 1 FROM SYS.DATABASES WHERE name = ''?'' AND  NAME NOT IN(''master'',''msdb'',''model'',''tempdb'') and STATE=0
    --customize to monitor specific databases
     --SELECT 1 FROM SYS.DATABASES WHERE name = ''?'' AND  NAME IN(''EMPLOYEE'') and STATE=0 
)
BEGIN
     SELECT
        ''?'',
            SUM(a.total_pages) as reservedpages,
            SUM(a.used_pages) as usedpages,
            SUM(
                CASE
                    -- XML-Index and FT-Index internal tables are not considered "data", but is part of "index_size"
                    When it.internal_type IN (202,204,211,212,213,214,215,216) Then 0
                    When a.type <> 1 Then a.used_pages
                    When p.index_id < 2 Then a.data_pages
                    Else 0
                END
            ) as pages
        from ?.sys.partitions p join ?.sys.allocation_units a on p.partition_id = a.container_id
        left join ?.sys.internal_tables it on p.object_id = it.object_id
END';
SELECT
		@@SERVERNAME instancename,
        -- from first result set of 'exec sp_spacedused'
        db_name(sf.database_id) as [database_name]
        ,convert(dec (15,2), (convert (dec (15,2),sf.dbsize) + convert (dec (15,2),sf.logsize)) * 8192 / 1048576) as [database_size_mb]
        ,convert(dec (15,2), (case when sf.dbsize >= pages.reservedpages then
            (convert (dec (15,2),sf.dbsize) - convert (dec (15,2),pages.reservedpages))
            * 8192 / 1048576 else 0 end)) as [unallocated space_mb]
        -- from second result set of 'exec sp_spacedused'
        ,convert(dec(15,0), (pages.reservedpages * 8192 / 1048576.)) as [reserved_mb]
        ,convert(dec(15,0), (pages.pages * 8192 / 1048576.)) as data_mb
        ,convert(dec(15,0), ((pages.usedpages - pages.pages) * 8192 / 1048576.)) as index_size_mb
        ,convert(dec(15,0), ((pages.reservedpages - pages.usedpages) * 8192 / 1048576.)) as unused_mb
        -- additional columns data and Log Size
        ,convert(dec(15,2), (convert (dec (15,2),sf.dbsize)) * 8192 / 1048576)  as dbsize_mb
        ,convert(dec(15,2), (convert (dec (15,2),sf.logsize)) * 8192 / 1048576)  as logsize_mb
    FROM (
        select
            database_id,
            sum(convert(bigint,case when type = 0 then size else 0 end)) as dbsize,
            sum(convert(bigint,case when type <> 0 then size else 0 end)) as logsize
        from sys.master_files
        group by database_id
    ) sf,
    (
    SELECT
            dbname,
            reservedpages,
            usedpages,
            pages
            FROM @ALLOCATION_TABLE
     ) pages
  WHERE DB_NAME(sf.database_id)=pages.dbname
