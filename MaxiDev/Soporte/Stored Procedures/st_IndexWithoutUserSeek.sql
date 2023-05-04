CREATE PROCEDURE [Soporte].[st_IndexWithoutUserSeek]
AS
/********************************************************************
<Author>jmmolina</Author>
<app>MaxiSupport</app>
<createdate>2018-01-08</createdate>
<Description>Proceso de notificaciones de uso de indices</Description>

<ChangeLog>
</ChangeLog>
********************************************************************/   
BEGIN
	DECLARE @TableHTML Nvarchar(max)
	DECLARE @QueryTableHTML Nvarchar(max)
	SET @TableHTML = '<table><thead><tr><th>SchemaName</th><th>ObjectName</th><th>IndexName</th><th>ObjectType</th><th>IndexType</th><th>TotalUserSeeks</th><th>TotalUserScans</th><th>TotalUserLookups</th><th>TotalUserUpdates</th><th>LastUserSeek</th><th>LastUserScan</th><th>LastUserLookup</th><th>LastUserUpdate</th><th>LeafLevelInsertCount</th><th>LeafLevelUpdateCount</th><th>LeafLevelDeleteCount</th></tr></thead><tbody>';
	
	IF OBJECT_ID('tempdb..#cte_rowCount') IS NOT NULL DROP TABLE #cte_rowCount
	IF OBJECT_ID('tempdb..#cte_IndexCount') IS NOT NULL DROP TABLE #cte_IndexCount
	IF OBJECT_ID('tempdb..#cte_rowCount') IS NOT NULL DROP TABLE #cte_rowCount

	--WITH cte_rowCount AS (
							SELECT 
								  OBJECT_SCHEMA_NAME(p.object_id) AS [Schema], 
								  OBJECT_NAME(p.object_id) AS [Table],
								  SUM(p.rows) AS [Row Count] INTO #cte_rowCount
							FROM sys.partitions p WITH(NOLOCK)
							INNER JOIN sys.indexes i WITH(NOLOCK) ON p.object_id = i.object_id
													 AND p.index_id = i.index_id
							WHERE OBJECT_SCHEMA_NAME(p.object_id) != 'sys'
							  --AND OBJECT_NAME(p.object_id) AS [Table] = ''
								--AND OBJECT_SCHEMA_NAME(p.object_id) =  'Production'
	
								AND OBJECT_NAME(p.object_id) not like '%LOG%'
								AND OBJECT_NAME(p.object_id) not like '%TEMP%'
								AND OBJECT_NAME(p.object_id) not like '%TMP%'  	
	
							GROUP BY OBJECT_SCHEMA_NAME(p.object_id) , 
									 OBJECT_NAME(p.object_id)
	
							HAVING SUM(p.rows) >  2000
						--) 
			
	  --,	cte_IndexCount AS (
	
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
						--),
	   --TopTable AS (
					SELECT #cte_rowCount.[Schema], #cte_rowCount.[Table] INTO #TopTable
					  FROM #cte_rowCount WITH(NOLOCK)
					 INNER JOIN #cte_IndexCount WITH(NOLOCK) ON #cte_rowCount.[Schema] = #cte_IndexCount.[Schema] AND #cte_rowCount.[Table] = #cte_IndexCount.[Table]
		           --)
	
	SELECT @QueryTableHTML =  CAST((
	SELECT 
	        SCHEMA_NAME([sObj].[schema_id]) AS 'td', ''
	      , [sObj].[name] AS  'td', ''
	      , ISNULL([sIdx].[name], 'N/A') AS 'td', ''
		  , CASE
				  WHEN [sObj].[type] = 'U' THEN 'Table'
				  WHEN [sObj].[type] = 'V' THEN 'View'
			END AS 'td', ''
	      , CASE
				 WHEN [sIdx].[type] = 0 THEN 'Heap'
				 WHEN [sIdx].[type] = 1 THEN 'Clustered'
				 WHEN [sIdx].[type] = 2 THEN 'Nonclustered'
				 WHEN [sIdx].[type] = 3 THEN 'XML'
				 WHEN [sIdx].[type] = 4 THEN 'Spatial'
				 WHEN [sIdx].[type] = 5 THEN 'Reserved for future use'
				 WHEN [sIdx].[type] = 6 THEN 'Nonclustered columnstore index'
			END AS 'td', ''
		  , [sdmvIUS].[user_seeks] AS 'td', ''
		  , [sdmvIUS].[user_scans] AS 'td', ''
	      , [sdmvIUS].[user_lookups] AS 'td', ''
	      , [sdmvIUS].[user_updates] AS 'td', ''
		  -----------------------------------------------------
	      , [sdmvIUS].[last_user_seek] AS 'td', ''
	      , [sdmvIUS].[last_user_scan] AS 'td', ''
		  , [sdmvIUS].[last_user_lookup] AS 'td', ''
	      , [sdmvIUS].[last_user_update] AS 'td', ''
		  -----------------------------------------------------
	      , [sdmfIOPS].[leaf_insert_count] AS 'td', ''
	      , [sdmfIOPS].[leaf_update_count] AS 'td', ''
	      , [sdmfIOPS].[leaf_delete_count] AS 'td'
	
	 FROM [sys].[indexes] AS [sIdx]
	INNER JOIN [sys].[objects] AS [sObj] ON [sIdx].[object_id] = [sObj].[object_id]
	INNER JOIN #TopTable AS TT WITH(NOLOCK) ON TT.[Table] = [sObj].[name] AND TT.[Schema] = SCHEMA_NAME([sObj].[schema_id])
	 LEFT JOIN [sys].[dm_db_index_usage_stats] AS [sdmvIUS] ON [sIdx].[object_id] = [sdmvIUS].[object_id] AND [sIdx].[index_id] = [sdmvIUS].[index_id] AND [sdmvIUS].[database_id] = DB_ID()
	 LEFT JOIN [sys].[dm_db_index_operational_stats] (DB_ID(),NULL,NULL,NULL) AS [sdmfIOPS] ON [sIdx].[object_id] = [sdmfIOPS].[object_id] AND [sIdx].[index_id] = [sdmfIOPS].[index_id]
	WHERE [sObj].[type] IN ('U','V')   
	  AND [sObj].[is_ms_shipped] = 0x0   
	  AND [sIdx].[is_disabled] = 0x0
	  AND [sdmvIUS].[user_seeks] < 10
	  --AND  SCHEMA_NAME([sObj].[schema_id]) = 'Production'
	--  AND [sObj].[name] = 'Customer'
	ORDER BY 2, [sdmvIUS].[user_updates] DESC, [sdmvIUS].[user_seeks] DESC
	FOR XML PATH('tr'), ELEMENTS)
	 AS NVARCHAR(MAX))
	
		SET @TableHTML += @QueryTableHTML + '</tbody></table>'
	
		EXEC msdb.dbo.sp_send_dbmail @profile_name='Maxi notification email',
		@recipients='jmolina@boz.mx',
		@subject='Index without user seek',
		@body=@TableHTML,
		@body_format = 'HTML'
END