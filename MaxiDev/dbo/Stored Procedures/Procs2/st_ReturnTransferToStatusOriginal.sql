/********************************************************************
<Author>Alexis Zavala</Author>
<app>Agente</app>
<Description>Change transfer status to original status</Description>

<ChangeLog>
<log Date="03/12/2018" Author="esalazar"> Creacion  </log>
</ChangeLog>

*********************************************************************/
--Development Status
--56 -> Update Transfer
--70 -> Update In Progress

--QA, 
--74 -> Update Transfer
--73 -> Update In Progress

--Stage, Produccion Status
--71 -> Update Transfer
--70 -> Update In Progress
CREATE PROCEDURE [dbo].[st_ReturnTransferToStatusOriginal]
	@IdUser int,
	@HasError bit output
AS
BEGIN TRY
	DECLARE @IdTransfer int
	DECLARE @TranferNote nvarchar(max)
	DECLARE @IDUpdateInProgress int
	DECLARE @IdTStatus int
	DECLARE @IdTransferDetail int
	DECLARE @TranferDate DATETIME
	DECLARE @DetailTemp TABLE
	( 
	  IdTransferDetail int
	)

	SET @IDUpdateInProgress=70
	SET @HasError=0
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Select top 1 @IdTransfer = [IdTransfer] from [dbo].[TransfersUpdateInProgress] with(nolock) where [IdUser]=@IdUser
	IF(@IdTransfer is not null)
		BEGIN
			-- Insert statements for procedure here
			Select @IdTStatus=[IdStatus] from [dbo].[Transfer] with(nolock) where [IdTransfer]=@IdTransfer

			IF(@IdTStatus=@IDUpdateInProgress)
				BEGIN
					IF EXISTS(SELECT 1 FROM TransferHolds with(nolock) WHERE [IdTransfer]=@IdTransfer AND [IdStatus]=3 AND ([IsReleased]=0 OR [IsReleased] IS NULL))
						BEGIN
							UPDATE [dbo].[Transfer]
							SET 
							[IdStatus] = 41
							,[DateOfLastChange] = GETDATE()
							,[DateStatusChange] = GETDATE()
							WHERE [IdTransfer]= @IdTransfer


						INSERT INTO [dbo].[TransferDetail]
							([IdStatus]
							,[IdTransfer]
							,[DateOfMovement])
							OUTPUT inserted.IdTransferDetail INTO @DetailTemp
								VALUES
									(41
									,@IdTransfer
									,GETDATE())

						SELECT @TranferNote= (Select StatusName from [Status] with(nolock) where [IdStatus]= 41)
						END
					ELSE
					----Update back to Stand By
						BEGIN
							UPDATE [dbo].[Transfer]
							SET 
								[IdStatus] = 20
								,[DateOfLastChange] = GETDATE()
								,[DateStatusChange] = GETDATE()
      
							WHERE [IdTransfer]= @IdTransfer

							INSERT INTO [dbo].[TransferDetail]
								([IdStatus]
								,[IdTransfer]
								,[DateOfMovement])
								OUTPUT inserted.IdTransferDetail INTO @DetailTemp
									VALUES
										(20
										,@IdTransfer
										,GETDATE())
							SELECT @TranferNote= (Select StatusName from [Status] with(nolock) where [IdStatus]= 20)
						END

						SELECT @IdTransferDetail=IdTransferDetail from @DetailTemp

						IF(@IdTransferDetail is not NULL)
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
				delete [dbo].[TransfersUpdateInProgress] where [IdTransfer]=@IdTransfer and [IdUser]=@IdUser
		END

		select @HasError
END TRY
BEGIN CATCH
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ReturnTransferToStatusOriginal',Getdate(),ERROR_MESSAGE())
	set @HasError = 1
END CATCH
