CREATE PROCEDURE [Soporte].[st_RebuildFullTextCatalog]
AS
/********************************************************************
<Author>jmmolina</Author>
<app>MaxiSupport</app>
<createdate>2018-01-08</createdate>
<Description>Proceso de notificaciones de ultima actualización de los indices Full Text</Description>

<ChangeLog>
</ChangeLog>
********************************************************************/   
BEGIN
		DECLARE @FT TABLE (FTName varchar(150), PopulationDate datetime, IsProcess bit)
		DECLARE @DatePopulateFT Datetime
		DECLARE @FTName varchar(150), @Query nvarchar(Max), @Body varchar(max) = ''
		
		INSERT INTO @FT
		SELECT name, DATEADD(ss, FULLTEXTCATALOGPROPERTY(name,'PopulateCompletionAge'), '1/1/1990') AS LastPopulated, IsProcess = 0
		  FROM sys.fulltext_catalogs AS cat
		 WHERE 1 = 1
		
		WHILE EXISTS(SELECT 1 FROM @FT WHERE 1 = 1 AND IsProcess = 0)
		BEGIN
		
			SELECT @FTName = FTName, @DatePopulateFT = PopulationDate
			  FROM @FT
			 WHERE 1 = 1
			   AND IsProcess = 0
		
			IF (@FTName = 'CustomerInfo') AND ((DATEDIFF(HH, @DatePopulateFT, GETDATE())) > 12 AND (CAST(@DatePopulateFT AS DATE) != CAST('1/1/1990' AS DATE)))
			BEGIN
				SET @Body += '<tr><td>' + @FTName + '</td><td>' + CONVERT(VARCHAR, @DatePopulateFT, 120) + '</td></tr>'
				SET @Query = 'ALTER FULLTEXT CATALOG ' + @FTName + ' REBUILD'
				PRINT @Query
				--EXEC SP_executeSQL @Query
			END
			ELSE IF (@FTName IN ('LocationCatalog', 'OFAC')) AND ((DATEDIFF(HH, @DatePopulateFT, GETDATE())) > 6 /*26*/ AND (CAST(@DatePopulateFT AS DATE) != CAST('1/1/1990' AS DATE)))
			BEGIN
				SET @Body += '<tr><td>' + @FTName + '</td><td>' + CONVERT(VARCHAR, @DatePopulateFT, 120) + '</td></tr>'
				SET @Query = 'ALTER FULLTEXT CATALOG ' + @FTName + ' REBUILD'
				PRINT @Query
				--EXEC SP_executeSQL @Query
			END
		
			UPDATE @FT SET IsProcess = 1 WHERE 1 = 1 AND FTName = @FTName
		END
		
		IF (@Body != '' AND @Body IS NOT NULL)
		BEGIN
			SET @DatePopulateFT = GETDATE()
			WHILE EXISTS(
						SELECT 1
						  FROM (
								SELECT
								       name,
								       DATEADD(ss, FULLTEXTCATALOGPROPERTY(name,'PopulateCompletionAge'), '1/1/1990') AS LastPopulated
								       ,(SELECT CASE FULLTEXTCATALOGPROPERTY(name,'PopulateStatus')
								           WHEN 0 THEN 'Idle'
								           WHEN 1 THEN 'Full Population In Progress'
								           WHEN 2 THEN 'Paused'
								           WHEN 3 THEN 'Throttled'
								           WHEN 4 THEN 'Recovering'
								           WHEN 5 THEN 'Shutdown'
								           WHEN 6 THEN 'Incremental Population In Progress'
								           WHEN 7 THEN 'Building Index'
								           WHEN 8 THEN 'Disk Full.  Paused'
								           WHEN 9 THEN 'Change Tracking' END) AS PopulateStatus
								  FROM sys.fulltext_catalogs AS cat
						       ) As t 
						  WHERE 1 = 1 
						    AND PopulateStatus != 'Idle')
			BEGIN 
			--PRINT 'Existe actualizacion'
				SET @Query = ''
			END
		
			SET @Body = '<table><thead><tr><td>Full Text Name</td><td>Last Populated</td></tr></thead><tfoot><tr><td>Rebuild Catalog Time</td><td>'+ CONVERT(VARCHAR(20), CONVERT(DECIMAL(10, 4), (CONVERT(DECIMAL(10, 6), CONVERT(VARCHAR(10), DATEDIFF(SECOND, @DatePopulateFT, GETDATE()))) / CONVERT(DECIMAL(10, 6), 60)))) + ' Minutes' + '</td></tr></tfoot><tbody>' + @Body + '</tbody></table>'
		
			EXEC msdb.dbo.sp_send_dbmail @profile_name='Maxi notification email',
			@recipients='jmolina@boz.mx',
			@subject='Rebuild FullText Catalog',
			@body=@Body,
			@body_format = 'HTML'
		END
END