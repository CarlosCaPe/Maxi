/********************************************************************
<Author> azavala </Author>
<app>Agent</app>
<Description>regresa el estatus de las transacciones a stand by cuando se cierra la aplicacion y no se concluyo la modificacion de transferencia</Description>

<ChangeLog>
<log Date="05/09/2018" Author="azavala">Creacion</log>
<log Date="06/09/2018" Author="azavala">ELIMINACION DE LOGS</log>
<log Date="13/09/2018" Author="esalazar">INCLUCION DE VOLVER A STATUS VERIFY HOLD</log>
<log Date="05/12/2018" Author="azavala">Eliminacion de registro en tabla temporal [TransfersUpdateInProgress]</log>
</ChangeLog>
*********************************************************************/
CREATE PROCEDURE [dbo].[st_ReturnTransferToStandBy]
	@IdUser int,
	@HasError bit out
AS
BEGIN TRY
	DECLARE @IdTransfer int
	DECLARE @IdTransferDetails int
	SET NOCOUNT ON;
	SET @IdTransfer = (SELECT TOP 1 T.IdTransfer 
					FROM TransferDetail TD WITH(NOLOCK) 
					join Transfer T WITH(NOLOCK) on T.IdTransfer=TD.IdTransfer
					join TransferNote TN WITH(NOLOCK) on TD.IdTransferDetail=TN.IdTransferDetail
					WHERE T.IdStatus=70 and TN.IdUser=@IdUser ORDER BY DateOfTransfer DESC)
    
	IF(@IdTransfer is not NULL)
	BEGIN
		DECLARE @DateOfChange DATETIME
		SET @DateOfChange = getDate()

		----UPDATE back to Transfer Hold
		IF EXISTS(SELECT 1 FROM TransferHolds WHERE IdTransfer=@IdTransfer AND IdStatus=3 AND (IsReleased=0 OR IsReleased IS NULL))
		BEGIN
			UPDATE Transfer SET IdStatus=41, DateOfLastChange=@DateOfChange WHERE IdTransfer=@IdTransfer
			--INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('st_ReturnTransferToStandBy',GETDATE(),'UPDATE Completed - Transfer')
			Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement) VALUES (41,@IdTransfer,@DateOfChange)
			SELECT @IdTransferDetails=SCOPE_IDENTITY();
			--INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('st_ReturnTransferToStandBy',GETDATE(),'Insert Completed - TransferDetail')
			--INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('st_ReturnTransferToStandBy',GETDATE(),'Get Last IdTransferDetail: ' + convert(varchar(max), @IdTransferDetails))
			IF(@IdTransferDetails is not NULL)
			BEGIN
				Insert into TransferNote (IdTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate) VALUES (@IdTransferDetails,1,@IdUser,(SELECT StatusName FROM Status WHERE IdStatus=41),@DateOfChange)
				--INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('st_ReturnTransferToStandBy',GETDATE(),'Insert Completed - TransferNote')
				SET @HasError=0
			END
			else
			BEGIN
				SET @HasError=1
			END
		END
		ELSE
		----UPDATE back to Stand By
		BEGIN
			DECLARE @OldIdStatus INT

			SELECT
				@OldIdStatus = u.OriginalIdStatus
			FROM TransfersUpdateInProgress u
			WHERE u.IdTransfer = @IdTransfer
			ORDER BY u.DateOfModified DESC

			UPDATE Transfer SET 
				IdStatus=@OldIdStatus, 
				DateOfLastChange=@DateOfChange 
			WHERE IdTransfer=@IdTransfer

			INSERT INTO TransferDetail (IdStatus,IdTransfer,DateOfMovement) 
			VALUES (@OldIdStatus, @IdTransfer, @DateOfChange)

			SELECT @IdTransferDetails=SCOPE_IDENTITY();
			
			IF(@IdTransferDetails IS NOT NULL)
			BEGIN
				INSERT INTO TransferNote (IdTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate) 
				VALUES (@IdTransferDetails, 1, @IdUser, (SELECT StatusName FROM Status WHERE IdStatus = @OldIdStatus), @DateOfChange)
				SET @HasError=0
			END
			else
			BEGIN
				SET @HasError=1
			END
		END
		
		DELETE [dbo].[TransfersUpdateInProgress] WHERE IdTransfer=@IdTransfer and IdUser=@IdUser
	END
	ELSE
	BEGIN
		SET @HasError=0
	END
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('st_ReturnTransferToStandBy',GETDATE(),ERROR_MESSAGE())
END CATCH
