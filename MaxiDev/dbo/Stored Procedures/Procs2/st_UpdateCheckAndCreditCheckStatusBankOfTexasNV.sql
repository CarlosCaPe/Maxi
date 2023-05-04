/********************************************************************
<Author>Miguel Hinojo</Author>
<app>Maxi Host Manager Service</app>
<Description>	This stored is used in bank of texas windows service for NV state, update check and credit check status </Description>

<ChangeLog>
<log Date="08/09/2016" Author="Mhinojo"> Creación </log>
<log Date="19/12/2019" Author="jmolina"> Add ; </log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [dbo].[st_UpdateCheckAndCreditCheckStatusBankOfTexasNV]
@IdStatus INT,
@ChecksXml XML,
@CheckCreditXml XML,
@fileName VARCHAR(200)
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
	
	UPDATE [dbo].[Checks] SET [IdStatus] = @IdStatus, [DateStatusChange] = @currentDate, CheckFile = @fileName
	WHERE [IdCheck] IN (SELECT [IdCheck] FROM @Checks);

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
	FROM @Checks;

	UPDATE [dbo].[CheckCredit] SET [IdStatus] = @IdStatus
	WHERE [IdCheckCredit] IN (SELECT [IdCheckCredit] FROM @Credits);

 END TRY                                 
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_UpdateCheckAndCreditCheckStatusBankOfTexasNV', GETDATE(),@ErrorMessage);
END CATCH

