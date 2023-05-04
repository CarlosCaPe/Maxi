CREATE PROCEDURE Soporte.st_ResultIndexAvgEstimatedImpact
AS
BEGIN
	SELECT 
			OBJECT_SCHEMA_NAME(p.object_id) AS [Schema], 
			OBJECT_NAME(p.object_id) AS [Table],
			SUM(p.rows) AS [Row Count] INTO #cte_rowCount
	FROM sys.partitions p WITH(NOLOCK)
	INNER JOIN sys.indexes i WITH(NOLOCK) ON p.object_id = i.object_id
								AND p.index_id = i.index_id
	WHERE OBJECT_SCHEMA_NAME(p.object_id) != 'sys'
		AND OBJECT_NAME(p.object_id) not like '%LOG%'
		AND OBJECT_NAME(p.object_id) not like '%TEMP%'
		AND OBJECT_NAME(p.object_id) not like '%TMP%'  	
	GROUP BY OBJECT_SCHEMA_NAME(p.object_id) , 
				OBJECT_NAME(p.object_id)
	HAVING SUM(p.rows) >  2000
	
	SELECT OBJECT_SCHEMA_NAME(p.object_id) AS [Schema], 
			OBJECT_NAME(p.object_id) AS [Table],
			COUNT(1) nIndex INTO #cte_IndexCount
			--i.name AS IndexName,
			--i.index_id AS IndexID,
			--8 * SUM(a.used_pages) AS 'Indexsize(KB)'
		FROM sys.indexes AS i WITH(NOLOCK)
	INNER JOIN sys.partitions AS p WITH(NOLOCK) ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id
	INNER JOIN sys.allocation_units AS a WITH(NOLOCK) ON a.container_id = p.partition_id
	WHERE 1 = 1 --OBJECT_SCHEMA_NAME(p.object_id) =  'Production'
	
		AND OBJECT_NAME(p.object_id) not like '%LOG%'
		AND OBJECT_NAME(p.object_id) not like '%TEMP%'
		AND OBJECT_NAME(p.object_id) not like '%TMP%'  	
	
	GROUP BY OBJECT_SCHEMA_NAME(p.object_id) , 
				OBJECT_NAME(p.object_id) 

	SELECT #cte_rowCount.[Schema], #cte_rowCount.[Table] INTO #TopTable
		FROM #cte_rowCount WITH(NOLOCK)
		INNER JOIN #cte_IndexCount WITH(NOLOCK) ON #cte_rowCount.[Schema] = #cte_IndexCount.[Schema] AND #cte_rowCount.[Table] = #cte_IndexCount.[Table]
	
	SELECT 
			dm_mid.database_id AS 'td', '',--AS DatabaseID,
			CONVERT(DECIMAL(24, 4), dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans)) AS 'td', '', --AS Avg_Estimated_Impact,
			CONVERT(VARCHAR(25), dm_migs.last_user_seek, 120) AS 'td', '', --AS Last_User_Seek,
			dm_mid.[statement] AS 'td', '', --AS [PathTable],
			OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) AS 'td', '', --AS [TableName],
			'CREATE INDEX [IX_' + OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) + '_'
			+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns,''),', ','_'),'[',''),']','') 
			+ CASE
			WHEN dm_mid.equality_columns IS NOT NULL
			AND dm_mid.inequality_columns IS NOT NULL THEN '_'
			ELSE ''
			END
			+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns,''),', ','_'),'[',''),']','')
			+ ']'
			+ ' ON ' + dm_mid.statement
			+ ' (' + ISNULL (dm_mid.equality_columns,'')
			+ CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns 
			IS NOT NULL THEN ',' ELSE
			'' END
			+ ISNULL (dm_mid.inequality_columns, '')
			+ ')'
			+ ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '') AS 'td' --AS Create_Statement
		FROM sys.dm_db_missing_index_groups dm_mig WITH(NOLOCK)
		INNER JOIN sys.dm_db_missing_index_group_stats dm_migs WITH(NOLOCK) ON dm_migs.group_handle = dm_mig.index_group_handle
		INNER JOIN sys.dm_db_missing_index_details dm_mid WITH(NOLOCK) ON dm_mig.index_handle = dm_mid.index_handle
		INNER JOIN #TopTable AS TT WITH(NOLOCK) ON TT.[Table] = OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id)
		WHERE dm_mid.database_ID = DB_ID()
		AND CONVERT(DECIMAL(24, 4), dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans)) > 400
	--AND OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) = 'Customer'
		ORDER BY CONVERT(DECIMAL(24, 4), dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans)) DESC
END