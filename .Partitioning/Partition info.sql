SELECT 
	OBJECT_NAME(SI.object_id) AS PartitionedTable
	, DS.name AS PartitionSchemeName
	, PF.name AS PartitionFunction
	, P.partition_number AS PartitionNumber
	, p.data_compression_desc
	, P.rows AS PartitionRowsApprox
	, FG.name AS FileGroupName
	, CASE WHEN PF.boundary_value_on_right = 0 
      THEN 'LEFT' ELSE 'RIGHT' END AS RangeType
	, PV.value AS BoundaryValue
FROM sys.partitions AS P
JOIN sys.indexes AS SI
	ON P.object_id = SI.object_id AND P.index_id = SI.index_id 
JOIN sys.data_spaces AS DS
	ON DS.data_space_id = SI.data_space_id
JOIN sys.partition_schemes AS PS
	ON PS.data_space_id = SI.data_space_id
JOIN sys.partition_functions AS PF
	ON PF.function_id = PS.function_id
LEFT JOIN sys.partition_range_values AS PV ON PF.function_id = PV.function_id 
          AND P.partition_number = PV.boundary_id  
JOIN sys.destination_data_spaces AS DDS
	ON DDS.partition_scheme_id = SI.data_space_id 
	AND DDS.destination_id = P.partition_number
JOIN sys.filegroups AS FG
	ON DDS.data_space_id = FG.data_space_id
WHERE DS.type = 'PS'
AND OBJECTPROPERTYEX(SI.object_id, 'BaseType') = 'U'
AND SI.type IN(0,1)
ORDER BY 1,4