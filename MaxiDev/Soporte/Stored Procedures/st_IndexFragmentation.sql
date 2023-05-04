CREATE PROCEDURE [Soporte].[st_IndexFragmentation]
@Percent float
AS
/********************************************************************
<Author>jmmolina</Author>
<app>MaxiSupport</app>
<createdate>2018-01-08</createdate>
<Description>Proceso de notificaciones de porcentaje de fragmentación en indices</Description>

<ChangeLog>
</ChangeLog>
********************************************************************/   
BEGIN
		DECLARE @IndexRebuild TABLE(IdIndexRebuild int identity(1, 1), TableName varchar(500), IndexName varchar(900), FragmentationPercent float)
		DECLARE @IdLoop int
		DECLARE @Query nvarchar(max), @Query2 nvarchar(max), @Query3 nvarchar(max), @Body nvarchar(max), @Index varchar(1500)

		INSERT INTO @IndexRebuild
		SELECT '[' + ch.Name + '].[' + OBJECT_NAME(ind.OBJECT_ID) + ']', 
				ind.name AS IndexName, indexstats.avg_fragmentation_in_percent 
			FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) As indexstats 
			INNER JOIN sys.indexes AS ind WITH(NOLOCK)  ON ind.object_id = indexstats.object_id AND ind.index_id = indexstats.index_id	
			LEFT OUTER JOIN sys.tables AS t WITH(NOLOCK) ON t.object_id = ind.object_id
			LEFT OUTER JOIN sys.Schemas AS ch WITH(NOLOCK) ON ch.Schema_id = t.Schema_id
			WHERE 1 = 1
			AND indexstats.avg_fragmentation_in_percent >= @Percent 
			AND indexstats.index_type_desc LIKE 'NONCLUSTERED%'
		 --ORDER BY indexstats.avg_fragmentation_in_percent DESC
		 --SELECT * FROM @IndexRebuild
		
		--SET @IdLoop = 1
		
		SET @Body = '<table><tbody><tr><th>Table Name</th><th>Index Name</th><th>Fragmentation</th><th>Query</th><thead><tbody>'
		
		/*WHILE EXISTS(SELECT 1 FROM @IndexRebuild WHERE 1 = 1 AND IdIndexRebuild = @IdLoop)
		BEGIN
			SET @Index = (SELECT N'ALTER INDEX [' + IndexName + N'] ON ' + TableName + N' REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)' 
			                FROM @IndexRebuild 
						   WHERE 1 = 1 
						     AND IdIndexRebuild = @IdLoop)
			--EXEC (@Index)
			--PRINT @Index
			SET @IdLoop += 1
		END*/
		
		SET @Body += (CAST((SELECT TableName AS 'td', '', IndexName AS 'td', '', CONVERT(VARCHAR, FragmentationPercent) AS 'td', '', CASE WHEN FragmentationPercent < 30 THEN 'ALTER INDEX [' + IndexName + '] ON ' + TableName + ' REORGANIZE ' ELSE 'ALTER INDEX [' + IndexName + '] ON ' + TableName + ' REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)' END
		                      FROM @IndexRebuild 
							 WHERE 1 = 1 
							 ORDER BY FragmentationPercent DESC FOR XML PATH('tr'), ELEMENTS) AS VARCHAR(max)))

		SET @Body += '</tbody></table>'

		--SELECT  @Body

		EXEC msdb.dbo.sp_send_dbmail @profile_name='Maxi notification email',
		@recipients='jmolina@boz.mx',
		@subject='Index fragmentation more thant 10 percent',
		@body=@Body,
		@body_format = 'HTML'
END