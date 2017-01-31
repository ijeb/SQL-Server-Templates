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
      PollDate DATETIME
    )  

DECLARE @command VARCHAR(5000)  

SELECT  @command = 'Use [' + '?' + '] SELECT @@servername as ServerName,  
' + '''' + '?' + ''''
        + ' AS DatabaseName, CAST(sysfiles.size/128.0 AS int) AS FileSize,  
sysfiles.name AS LogicalFileName, sysfiles.filename AS PhysicalFileName,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Status'')) AS Status,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Updateability'')) AS Updateability,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Recovery'')) AS RecoveryMode,  
CAST(sysfiles.size/128.0 - CAST(FILEPROPERTY(sysfiles.name, ' + ''''
        + 'SpaceUsed' + '''' + ' ) AS int)/128.0 AS int) AS FreeSpaceMB,  
CAST(100 * (CAST (((sysfiles.size/128.0 -CAST(FILEPROPERTY(sysfiles.name,  
' + '''' + 'SpaceUsed' + '''' + ' ) AS int)/128.0)/(sysfiles.size/128.0))  
AS decimal(4,2))) AS varchar(8)) + ' + '''' + '%' + ''''
        + ' AS FreeSpacePct,  
GETDATE() as PollDate FROM dbo.sysfiles'  

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
        LogicalFileName ,
        PhysicalFileName ,
        [Status] ,
        Updateability ,
        RecoveryMode ,
        PollDate
FROM    @DBInfo
ORDER BY ServerName ,
        DatabaseName
