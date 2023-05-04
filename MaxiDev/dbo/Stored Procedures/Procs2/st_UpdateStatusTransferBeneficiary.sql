/********************************************************************
<Author>Eneas Salazar</Author>
<app>Agente</app>
<Description>Change transfer status on modify beneficiary request </Description>

<ChangeLog>
<log Date="13/08/2018" Author="esalazar"> Creacion  </log>
<log Date="03/12/2018" Author="azavala">Insercion en tabla propia de transferencias en "Update in Progress"</log>
<log Date="03/12/2020" Author="adominguez">Agregar funcionalidad de "Update in Progress" a status despues de 30 min</log>
</ChangeLog>

*********************************************************************/
--Development Status
--56 -> Update Transfer
--70 -> Update In Progress

--QA, Stage, Produccion Status
--74 -> Update Transfer
--73 -> Update In Progress

--Stage, Produccion Status
--71 -> Update Transfer
--70 -> Update In Progress						  						  
CREATE PROCEDURE [dbo].[st_UpdateStatusTransferBeneficiary]
	@IdTransfer int,
	@IdUser int,
	@UpdateType bit,---0 = change to stand by Or Verify Hold/1 = change to update in progress
	@HasError bit out,
	@ExpiredModify bit out

AS

DECLARE @IDUpdateInProgress int
DECLARE @TranferNote nvarchar(max)
DECLARE @IdTransferDetail int
DECLARE @IdTStatus int
DECLARE @TranferDate DATETIME
DECLARE @DetailTemp TABLE
( 
  IdTransferDetail int
)
BEGIN

 SET @IDUpdateInProgress=70
 SET @HasError=0
 SET @ExpiredModify=0
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Select @IdTStatus=[IdStatus], @TranferDate= DateOfTransfer from [dbo].[Transfer] with(nolock) WHERE IdTransfer= @IdTransfer
	
	--IF( (DATEDIFF(minute, @TranferDate, GETDATE()))<=30 )
	--	BEGIN
			SET @ExpiredModify=1
	--	END

	IF @IdTStatus IS NULL
		BEGIN
			SET @HasError=1
		END

IF((@HasError=0 AND @ExpiredModify=1) OR (@HasError=0 AND (@IdTStatus=@IDUpdateInProgress)OR (@IdTStatus=41)) )/*from find transfer OR Cancel Edit */
	BEGIN
		BEGIN TRY
			
				
			IF( (@IdTStatus=20 AND @UpdateType=0) OR (@IdTStatus=@IDUpdateInProgress AND @UpdateType=1) OR (@IdTStatus=41 AND @UpdateType=0))
				BEGIN
						
						SET @HasError=1
				END

			IF(@IdTStatus=@IDUpdateInProgress AND @UpdateType=0)
				BEGIN
					
					----Update back to Transfer Hold
					IF EXISTS(SELECT 1 FROM TransferHolds with(nolock) WHERE IdTransfer=@IdTransfer AND IdStatus=3 AND (IsReleased=0 OR IsReleased IS NULL))
						BEGIN
							UPDATE [dbo].[Transfer]
						SET 
							[IdStatus] = 41
							,[DateOfLastChange] = GETDATE()
							,[DateStatusChange] = GETDATE()
      
						WHERE IdTransfer= @IdTransfer


						INSERT INTO [dbo].[TransferDetail]
						   ([IdStatus]
						   ,[IdTransfer]
						   ,[DateOfMovement])
						   --OUTPUT inserted.IdTransferDetail INTO @DetailTemp
							 VALUES
								   (41
								   ,@IdTransfer
								   ,GETDATE())

						SET @IdTransferDetail = SCOPE_IDENTITY()

						SELECT @TranferNote= (Select StatusName from [Status] with(nolock) where IdStatus= 41)
						END
					ELSE
					----Update back to Original Status
						BEGIN
						declare @OriginalIdStatus int
						Select @OriginalIdStatus = OriginalIdStatus from [dbo].[TransfersUpdateInProgress] where IdTransfer=@IdTransfer and IdUser=@IdUser
							UPDATE [dbo].[Transfer]
							SET 
								[IdStatus] = @OriginalIdStatus
								,[DateOfLastChange] = GETDATE()
								,[DateStatusChange] = GETDATE()
      
							WHERE IdTransfer= @IdTransfer

							INSERT INTO [dbo].[TransferDetail]
							   ([IdStatus]
							   ,[IdTransfer]
							   ,[DateOfMovement])
							  -- OUTPUT inserted.IdTransferDetail INTO @DetailTemp
								 VALUES
									   (@OriginalIdStatus
									   ,@IdTransfer
									   ,GETDATE())
							SET @IdTransferDetail = SCOPE_IDENTITY()
							SELECT @TranferNote= (Select StatusName from [Status] with(nolock) where IdStatus= @OriginalIdStatus)
						END
						
					delete [dbo].[TransfersUpdateInProgress] where IdTransfer=@IdTransfer and IdUser=@IdUser
					--SELECT @IdTransferDetail=IdTransferDetail from @DetailTemp

					
					
					IF(@IdTransferDetail > 0)
							BEGIN
								INSERT INTO [dbo].[TransferNote]
										   ([IdTransferDetail]
										   ,[IdTransferNoteType]
										   ,[IdUser]
										   ,[Note]
										   ,[EnterDate])
									 VALUES
										   (@IdTransferDetail
										   ,1
										   ,@IdUser
										   ,@TranferNote
										   ,GETDATE())										
							END
						ELSE
							BEGIN
							
								SET @HasError = 1 
							END

					END
 
			 IF((((select count(*) from Status with(nolock) where IdStatus = @IdTStatus and CanChangeRequest = 1) > 0) OR ( @IdTStatus=20)OR (@IdTStatus=41)) AND @UpdateType=1)
				BEGIN
					INSERT INTO [dbo].[TransfersUpdateInProgress] (IdTransfer, IdUser, DateOfModified,OriginalIdStatus) values (@IdTransfer, @IdUser, GETDATE(),@IdTStatus)

						UPDATE [dbo].[Transfer]
						SET 
							 [IdStatus] = @IDUpdateInProgress
							,[DateOfLastChange] = GETDATE()
							,[DateStatusChange] = GETDATE()
					WHERE IdTransfer= @IdTransfer


					INSERT INTO [dbo].[TransferDetail]
						   ([IdStatus]
						   ,[IdTransfer]
						   ,[DateOfMovement])
						   --OUTPUT inserted.IdTransferDetail INTO @DetailTemp
							 VALUES
								   (@IDUpdateInProgress
								   ,@IdTransfer
								   ,GETDATE())

					SET @IdTransferDetail = SCOPE_IDENTITY()

					--SELECT @IdTransferDetail=IdTransferDetail from @DetailTemp

					SELECT @TranferNote= (Select StatusName from [Status] with(nolock) where IdStatus= @IDUpdateInProgress)
					
					IF(@IdTransferDetail > 0)
							BEGIN
								INSERT INTO [dbo].[TransferNote]
										   ([IdTransferDetail]
										   ,[IdTransferNoteType]
										   ,[IdUser]
										   ,[Note]
										   ,[EnterDate])
									 VALUES
										   (@IdTransferDetail
										   ,1
										   ,@IdUser
										   ,@TranferNote
										   ,GETDATE())										
							END
						ELSE
							BEGIN
							
								SET @HasError = 1 
							END


					

			END
					 		
				
		END TRY
		BEGIN CATCH
		Declare @ErrorMessage nvarchar(max) 
		SET @HasError = 1                                                                            
		Select  @ErrorMessage=ERROR_MESSAGE()                                             
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_UpdateStatusTransferBeneficiary]',Getdate(),@ErrorMessage)
		END CATCH
	END
	ELSE
		BEGIN
			SET @HasError = 1 
		END
END
