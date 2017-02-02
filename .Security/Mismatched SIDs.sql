USE <Database_Name, sysname, Database_Name>

SELECT dp.type_desc, dp.SID, dp.name AS user_name
FROM sys.database_principals AS dp
LEFT JOIN sys.server_principals AS sp
    ON dp.SID = sp.SID
WHERE sp.SID IS NULL
    AND authentication_type_desc = 'INSTANCE';

--ALTER USER ... WITH Login = ...