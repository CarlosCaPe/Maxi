CREATE PROCEDURE [dbo].[st_DeletePreTransfer]
AS 
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add ;</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY
	DELETE FROM dbo.PreTransfer WHERE DateOfPreTransfer<dbo.RemoveTimeFromDatetime(GETDATE());
END TRY
BEGIN CATCH
	DECLARE @Message varchar(max)
	SET @Message = ERROR_MESSAGE()
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES ('st_DeletePreTransfer', GETDATE(), @Message)
END CATCH