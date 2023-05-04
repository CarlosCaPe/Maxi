-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-01-05
-- Description:	This stored is used in wells fargo windows service, update check and credit check status
-- =============================================
CREATE PROCEDURE [dbo].[st_UpdateCheckAndCreditCheckStatus]
@IdStatus INT,
@ChecksXml XML,
@CheckCreditXml XML
AS
BEGIN TRY

	DECLARE @currentDate DATETIME = GETDATE();
	DECLARE @IdUserSystem INT = [dbo].[GetGlobalAttributeByName]('SystemUserID') 
	DECLARE  @DocHandle INT

	DECLARE @Checks TABLE(
	[IdCheck] INT
	)

	DECLARE @Credits TABLE(
	[IdCheckCredit] INT
	)

	EXEC sp_xml_preparedocument @DocHandle OUTPUT,@ChecksXml
	INSERT INTO @Checks ([IdCheck])
		SELECT [IdCheck]
		FROM OPENXML (@DocHandle, '/Checks/Check',2)
		WITH (
				[IdCheck] INT
		)
	EXEC sp_xml_removedocument @DocHandle 

	EXEC sp_xml_preparedocument @DocHandle OUTPUT,@CheckCreditXml
	INSERT INTO @Credits (IdCheckCredit)
	SELECT IdCheckCredit 
	FROM OPENXML (@DocHandle, '/Credits/Credit',2)
	WITH (
			[IdCheckCredit] INT
	)
	EXEC sp_xml_removedocument @DocHandle

	--select * from @Checks
	--select * from @Credits
	
	UPDATE [dbo].[Checks] SET [IdStatus] = @IdStatus, [DateStatusChange] = @currentDate
	WHERE [IdCheck] IN (SELECT [IdCheck] FROM @Checks)

	INSERT INTO [dbo].[CheckDetails]
			   ([IdCheck]
			   ,[IdStatus]
			   ,[DateOfMovement]
			   ,[Note]
			   ,[EnterByIdUser])
	SELECT [IdCheck]
		,@IdStatus
		,@currentDate
		,''
		,@IdUserSystem
	FROM @Checks

	UPDATE [dbo].[CheckCredit] SET [IdStatus] = @IdStatus
	WHERE [IdCheckCredit] IN (SELECT [IdCheckCredit] FROM @Credits)

 END TRY                                 
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_UpdateCheckAndCreditCheckStatus', GETDATE(),@ErrorMessage)
END CATCH

