WITH Q AS(
SELECT @@servername servername
	,DB_NAME() database_name
	,dp.NAME AS username
	,[db_containment] = (SELECT containment_desc FROM sys.databases WHERE database_id = DB_ID())
	,[user_containment] =	CASE WHEN (SELECT containment FROM sys.databases WHERE database_id = DB_ID()) = 1 
									THEN CASE WHEN ue.major_id IS NULL THEN 'Contained' ELSE 'Not Contained' END
								 ELSE 'N/A'
							END
	,sp.NAME AS login
	,sp.type_desc login_type
	,dp.authentication_type_desc
	,server_roles = (SELECT STUFF(
						(SELECT ',' + spsub.name
						FROM sys.server_role_members rm
						JOIN sys.server_principals spsub ON spsub.principal_id = rm.role_principal_id
						WHERE rm.member_principal_id = sp.principal_id
						ORDER BY spsub.name
						FOR XML PATH('')
						),1,1,''))
	,[server_permissions] = (SELECT STUFF(
								(SELECT ',' + 
								CASE WHEN class = 100 --p.type IN ('COSQ','VWDB','VWAD','ALAG')
									THEN p.state_desc + ' ' + p.permission_name ELSE
									class_desc + '|' + RTRIM(p.[permission_name]) + '|'  + state + '|' +
									CASE 
										WHEN p.class_desc = 'SERVER' THEN ''
										WHEN p.class_desc = 'SERVER_PRINCIPAL' THEN ''
										WHEN p.class_desc = 'ENDPOINT' THEN (SELECT [name] FROM sys.endpoints WHERE [endpoint_id] = p.major_id)
									END
								END
								FROM sys.server_permissions p
								WHERE p.grantee_principal_id = sp.principal_id
								FOR XML PATH('')
								),1,1,''))						
	,database_roles = (SELECT STUFF(
						(SELECT ',' + dpsub.name
						FROM sys.database_role_members rm
						JOIN sys.database_principals dpsub ON dpsub.principal_id = rm.role_principal_id
						WHERE rm.member_principal_id = dp.principal_id
						ORDER BY dpsub.name
						FOR XML PATH('')
						),1,1,''))
	,[database_permissions] = (SELECT STUFF(
							(SELECT ',' + 
								p.state_desc + ' ' + p.permission_name + ' ' +
								--class_desc + '|' + RTRIM(p.[permission_name]) + '|'  + state + '|' +
								CASE 
									WHEN p.class_desc = 'DATABASE' THEN 'DATABASE'
									WHEN p.class_desc = 'OBJECT_OR_COLUMN' AND p.minor_id = 0 THEN o.type_desc + ' ' + SCHEMA_NAME(o.[schema_id]) + '.' +OBJECT_NAME(p.major_id)
									WHEN p.class_desc = 'OBJECT_OR_COLUMN' AND p.minor_id != 0 THEN SCHEMA_NAME(o.[schema_id]) + '.' + OBJECT_NAME(p.major_id) + '(' + c.[name] + ')'
									WHEN p.class_desc = 'SCHEMA' THEN SCHEMA_NAME(p.major_id)
									WHEN p.class_desc = 'DATABASE_PRINCIPAL' THEN (SELECT [name] FROM sys.database_principals WHERE [principal_id] = p.major_id)
									WHEN p.class_desc = 'ASSEMBLY' THEN (SELECT [clr_name] COLLATE DATABASE_DEFAULT FROM sys.assemblies WHERE [assembly_id] = p.major_id)
									WHEN p.class_desc = 'TYPE' THEN TYPE_NAME(p.major_id)
									WHEN p.class_desc = 'XML_SCHEMA_COLLECTION' THEN (SELECT [name] FROM sys.xml_schema_collections WHERE [xml_collection_id] = p.major_id)
									WHEN p.class_desc = 'MESSAGE_TYPE' THEN (SELECT [name] FROM sys.service_message_types WHERE [message_type_id] = p.major_id)
									WHEN p.class_desc = 'SERVICE_CONTRACT' THEN (SELECT [name] FROM sys.service_contracts WHERE [service_contract_id] = p.major_id)
									WHEN p.class_desc = 'SERVICE' THEN (SELECT [name] FROM sys.services WHERE [service_id] = p.major_id)
									WHEN p.class_desc = 'REMOTE_SERVICE_BINDING' THEN (SELECT [name] FROM sys.remote_service_bindings WHERE [remote_service_binding_id] = p.major_id)
									WHEN p.class_desc = 'ROUTE' THEN (SELECT [name] FROM sys.routes WHERE [route_id] = p.major_id)
									WHEN p.class_desc = 'FULLTEXT_CATALOG' THEN (SELECT [name] FROM sys.fulltext_catalogs WHERE [fulltext_catalog_id] = p.major_id)
									WHEN p.class_desc = 'SYMMETRIC_KEY' THEN (SELECT [name] FROM sys.symmetric_keys WHERE [symmetric_key_id] = p.major_id)
									WHEN p.class_desc = 'CERTIFICATE' THEN (SELECT [name] FROM sys.certificates WHERE [certificate_id] = p.major_id)
									WHEN p.class_desc = 'ASYMMETRIC_KEY' THEN (SELECT [name] FROM sys.asymmetric_keys WHERE [asymmetric_key_id] = p.major_id)
									ELSE OBJECT_NAME(p.[major_id])
								END
							--END
							FROM sys.database_permissions p
							LEFT OUTER JOIN sys.objects o ON p.major_id = o.[object_id]
							LEFT OUTER JOIN	sys.columns c ON p.major_id = c.[object_id] AND p.minor_id = c.[column_id]
							WHERE p.grantee_principal_id = dp.principal_id
							FOR XML PATH('')
							),1,1,''))
FROM sys.database_principals dp
LEFT OUTER JOIN sys.dm_db_uncontained_entities ue ON ue.major_id = dp.principal_id AND ue.class = 4
LEFT OUTER JOIN sys.server_principals sp ON sp.sid = dp.sid
LEFT OUTER JOIN sys.dm_exec_sessions s ON s.security_id = dp.sid --s.login_name = sp.NAME AND s.is_user_process = 1
LEFT OUTER JOIN sys.dm_exec_connections c ON c.session_id = s.session_id
LEFT OUTER JOIN sys.sysprocesses p ON p.spid = s.session_id
LEFT OUTER JOIN sys.availability_group_listener_ip_addresses i ON i.ip_address = c.local_net_address
LEFT OUTER JOIN sys.availability_group_listeners l ON l.listener_id = i.listener_id
LEFT OUTER JOIN sys.resource_governor_workload_groups w ON w.group_id = s.group_id
WHERE dp.type NOT IN ('A','R') -- Application role / Database role
)
SELECT servername, database_name, [db_containment], username, [user_containment], login, login_type, authentication_type_desc,server_roles, [server_permissions], database_roles, [database_permissions]
FROM Q
WHERE username not in ('dbo','NT AUTHORITY\SYSTEM','INFORMATION_SCHEMA','guest','sys')
AND username not like '##%##'
GROUP BY servername, database_name, [db_containment], username, [user_containment], login, login_type, authentication_type_desc, server_roles, [server_permissions], database_roles, [database_permissions]
ORDER BY 3