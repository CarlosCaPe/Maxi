/********************************************************************
<Author>Miguel Hinojo</Author>
<app>Maxi Host Manager Service</app>
<Description>This stored is used by First Midwest Bank in windows service to update check bundles and add note check file </Description>

<ChangeLog>
<log Date="08/15/2016" Author="Mhinojo"> Creación </log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [dbo].[st_UpdateCheckBundlesFirstMidwest]
@BundlesXml XML,
@FileName VARCHAR(255),
@Note VARCHAR(200)
AS
BEGIN TRY

	DECLARE @currentDate DATETIME = GETDATE();
	DECLARE @IdUserSystem INT = [dbo].[GetGlobalAttributeByName]('SystemUserID') 
	DECLARE @IdStatusPaid INT = 30
	DECLARE @DocHandle INT 

	DECLARE @Bundles TABLE(
		[IdCheckBundle] INT
		)

	EXEC sp_xml_preparedocument @DocHandle OUTPUT,@BundlesXml
	INSERT INTO @Bundles ([IdCheckBundle])
		SELECT [IdCheckBundle]
		FROM OPENXML (@DocHandle, '/Bundles/Bundle',2)
		WITH (
				[IdCheckBundle] INT				
		)

	UPDATE [dbo].[CheckBundle] SET [ApplyDate]=@currentDate , [FileName]=@FileName
	WHERE [IdCheckBundle] IN (SELECT [IdCheckBundle] FROM @Bundles)

	UPDATE [dbo].[Checks] SET [IdStatus]=@IdStatusPaid, [DateStatusChange] = @currentDate
		WHERE [IdCheckBundle] IN (SELECT [IdCheckBundle] FROM @Bundles)

	INSERT INTO [dbo].[CheckDetails]
			   ([IdCheck]
			   ,[IdStatus]
			   ,[DateOfMovement]
			   ,[Note]
			   ,[EnterByIdUser])
	SELECT [IdCheck]
		,@IdStatusPaid
		,@currentDate
		,@Note
		,@IdUserSystem
	FROM [Checks] (nolock)
		WHERE [IdCheckBundle] IN (SELECT [IdCheckBundle] FROM @Bundles)

	UPDATE [dbo].[CheckCredit] SET [IdStatus]=@IdStatusPaid
		WHERE [IdCheckBundle] IN (SELECT [IdCheckBundle] FROM @Bundles)

 END TRY                                       
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_UpdateCheckBundlesFirstMidwest', GETDATE(), @ErrorMessage)
END CATCH



