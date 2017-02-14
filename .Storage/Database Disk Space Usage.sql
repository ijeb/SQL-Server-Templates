DECLARE @DBInfo TABLE
    (
      ServerName VARCHAR(100) ,
      DatabaseName VARCHAR(100) ,
      FileSizeMB INT ,
      LogicalFileName SYSNAME ,
      PhysicalFileName NVARCHAR(520) ,
      Status SYSNAME ,
      Updateability SYSNAME ,
      RecoveryMode SYSNAME ,
      FreeSpaceMB INT ,
      FreeSpacePct VARCHAR(7) ,
      FreeSpacePages INT ,
	  IsPercentGrowth BIT ,
	  GrowthMB INT ,
      MaxSizeMB INT ,
      PollDate DATETIME
    )  

DECLARE @command VARCHAR(5000)  

SELECT  @command = 'Use [' + '?' + '] SELECT @@servername as ServerName,  
' + '''' + '?' + ''''
        + ' AS DatabaseName, CAST(database_files.size/128.0 AS int) AS FileSize,  
database_files.name AS LogicalFileName, database_files.name AS PhysicalFileName,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Status'')) AS Status,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Updateability'')) AS Updateability,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Recovery'')) AS RecoveryMode,  
CAST(database_files.size/128.0 - CAST(FILEPROPERTY(database_files.name, ' + ''''
        + 'SpaceUsed' + '''' + ' ) AS int)/128.0 AS int) AS FreeSpaceMB,  
CAST(100 * (CAST (((database_files.size/128.0 -CAST(FILEPROPERTY(database_files.name,  
' + '''' + 'SpaceUsed' + '''' + ' ) AS int)/128.0)/(database_files.size/128.0))  
AS decimal(4,2))) AS varchar(8)) + ' + '''' + '%' + ''''
        + ' AS FreeSpacePct,
database_files.is_percent_growth AS IsPercentGrowth,
CAST(database_files.growth/128.0 AS int) AS GrowthMB,  
CAST(database_files.max_size/128.0 AS int) AS MaxSizeMB,		  
GETDATE() as PollDate FROM sys.database_files'  

INSERT  INTO @DBInfo
        ( ServerName ,
          DatabaseName ,
          FileSizeMB ,
          LogicalFileName ,
          PhysicalFileName ,
          [Status] ,
          Updateability ,
          RecoveryMode ,
          FreeSpaceMB ,
          FreeSpacePct ,
		  IsPercentGrowth ,
		  GrowthMB ,
		  MaxSizeMB ,
          PollDate
        )
        EXEC sp_MSForEachDB @command  

SELECT  ServerName ,
        DatabaseName ,
        FileSizeMB ,
        FreeSpaceMB ,
        ( CAST(FileSizeMB AS NUMERIC(19, 2))
          - CAST(FreeSpaceMB AS NUMERIC(19, 2)) ) AS ApproxSpaceUsedMB ,
        FreeSpacePct ,
		IsPercentGrowth ,
		GrowthMB ,
		MaxSizeMB ,
        LogicalFileName ,
        PhysicalFileName ,
        [Status] ,
        Updateability ,
        RecoveryMode ,
        PollDate
FROM    @DBInfo
ORDER BY ServerName ,
        DatabaseName