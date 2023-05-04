
CREATE PROCEDURE [Checks].[st_CheckTransferProcessorDetail](@IdCheck int, @IdCheckStatus int) AS  

/********************************************************************
<Author>Not Known</Author>
<app>MaxiJobs</app>
<Description></Description>

<ChangeLog>
<log Date="04/12/2018" Author="jmolina">Add with(nolock) and change output of update query #1</log>
<log Date="17/12/2018" Author="jmolina">Add ; in Insert/Update </log>
</ChangeLog>
********************************************************************/ 
	SET NOCOUNT ON;
BEGIN TRY
	DECLARE @HasError BIT
	DECLARE   @Message NVARCHAR(MAX)
	DECLARE @RowAfected int

	IF NOT EXISTS (SELECT TOP 1 IdCheckHold FROM CheckHolds WITH(NOLOCK) WHERE IdCheck = @IdCheck and (IsReleased is null or IsReleased=0)) --Si no existe un Hold sin evaluar o Rejected cambiar Status a 20  
	BEGIN  

		--DECLARE @idsUpdated TABLE ( IdStatus INT )
 
		UPDATE [Checks] SET IdStatus = 20, DateStatusChange=GETDATE()
		--OUTPUT    --#1
		--INSERTED.IdStatus
		--INTO 
		--@idsUpdated 
		WHERE 
		IdCheck=@IdCheck and idstatus=@IdCheckStatus;

		SET @RowAfected = @@ROWCOUNT

		--IF EXISTS (SELECT IdStatus FROM @idsUpdated)
		IF (@RowAfected <> 0)
		BEGIN
			EXEC Checks.[st_SaveChangesToCheckLog] @IdCheck,20,'Stand By',0 -- Log , En Ready to be taken by Gateway
			/*07-Sep-2021*/
			/*UCF*/
			/*TSI_MAXI_013*/
			/*Se comenta la ejecucion del st_CheckApplyToAgentBalance, ya no es necesario afectar el balance al liberar el cheque*/
    		/*EXEC checks.st_CheckApplyToAgentBalance @IdCheck*/

			EXEC dbo.st_DismissComplianceNotificationByIdCheck @IdCheck, 0,  @HasError OUTPUT,  @Message OUTPUT
		END

	END
END TRY
BEGIN CATCH
	DECLARE @MessageError varchar(max)
	SET @MessageError = ERROR_MESSAGE()
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_CheckTransferProcessorDetail', GETDATE(), @MessageError)
END CATCH