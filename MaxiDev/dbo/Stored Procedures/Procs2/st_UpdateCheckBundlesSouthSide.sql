-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-01-05
-- Description:	This stored is used in wells fargo windows service, update check bundles
-- =============================================
CREATE PROCEDURE [dbo].[st_UpdateCheckBundlesSouthSide]
@BundlesXml XML,
@FileName VARCHAR(255)
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
		,''
		,@IdUserSystem
	FROM [Checks] (nolock)
		WHERE [IdCheckBundle] IN (SELECT [IdCheckBundle] FROM @Bundles)

	UPDATE [dbo].[CheckCredit] SET [IdStatus]=@IdStatusPaid
		WHERE [IdCheckBundle] IN (SELECT [IdCheckBundle] FROM @Bundles)

 END TRY                                       
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_UpdateCheckBundles', GETDATE(), @ErrorMessage)
END CATCH



