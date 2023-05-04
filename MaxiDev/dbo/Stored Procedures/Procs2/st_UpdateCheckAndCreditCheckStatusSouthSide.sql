-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-01-05
-- Description:	This stored is used in wells fargo windows service, update check and credit check status
-- =============================================
/********************************************************************
<Author>Not Known</Author>
<app>-</app>
<Description></Description>

<ChangeLog>
<log Date="27/06/2018" Author="azavala">Add columns insert EmailCellularLog</log>
</ChangeLog>
********************************************************************/
CREATE PROCEDURE [dbo].[st_UpdateCheckAndCreditCheckStatusSouthSide]
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


	declare @Amount money, @count int, @emailsList varchar(1000), @Subject varchar(1000), @Body varchar(max),  @EmailProfile NVARCHAR(MAX)

	set @Subject='MAXI Transfers - Check21'
	set @emailsList = [dbo].[GetGlobalAttributeByName]('SOUTHSIDE_UploadFileEmailNotification') 
	
	select @Amount = sum(Amount), @count=count(1)
	from [dbo].[Checks] (nolock)
	WHERE [IdCheck] IN (SELECT [IdCheck] FROM @Checks)

	set @Body = 'Maxi transfers have generated the check 21 file. '+CHAR(13)+CHAR(10)+
			'Total amount $' +CONVERT(varchar,Round( @Amount,2))+CHAR(13)+CHAR(10)+
			'Total items ' +CONVERT(varchar,Round( @count,2))

	set @EmailProfile=dbo.GetGlobalAttributeByName('EmailProfiler')

	EXEC msdb.dbo.sp_send_dbmail
	 @profile_name=@EmailProfile,
	 @recipients = @emailsList,
	 @body = @Body,
	 @subject = @Subject

	INSERT INTO [dbo].[EmailCellularLog] (Number,Body,[Subject],[DateOfMessage]) VALUES (@emailsList,@Body,@Subject,GETDATE())

 END TRY                                 
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
	DECLARE @ErrorLine NVARCHAR(MAX) = CONVERT(VARCHAR(20), ERROR_LINE())
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_UpdateCheckAndCreditCheckStatusSouthSide', GETDATE(), 'Line: ' + @ErrorLine + ', ' + @ErrorMessage)
END CATCH

