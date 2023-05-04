CREATE PROCEDURE [Corp].[st_SaveNoteCheckDetails]
@IdCheck int,
@Note Varchar (MAX),
@EnterByIdUser int,
@isNote bit = 1,
@HasError bit out,
@Message nvarchar(max) out
as
BEGIN TRY

	DECLARE @IdStatus INT
	DECLARE @idCheckDetail INT = NULL
	SET @IdStatus = (SELECT IdStatus FROM [dbo].[Checks] WHERE IdCheck = @IdCheck) 

	IF (@isNote = 1)
	BEGIN
		--VERSION ANTERIOR
		INSERT INTO [dbo].[CheckDetails]  (IdCheck,IdStatus, DateOfMovement,Note,EnterByIdUser ) VALUES (@IdCheck, @IdStatus, GETDATE(),@Note,@EnterByIdUser);
	END
	ELSE
	BEGIN
		--VERSION NUEVA PARA NOTIFICACIONES ::  20160915

		SELECT TOP 1 @idCheckDetail = cd.idCheckDetail
		FROM dbo.checks c WITH(NOLOCK)
		INNER JOIN dbo.CheckDetails cd WITH(NOLOCK) ON cd.idCheck = c.idCheck AND cd.IdStatus = c.IdStatus
		WHERE c.IdCheck = @IdCheck
		ORDER BY cd.IdCheckDetail

		IF @idCheckDetail IS NULL
		BEGIN 
			SELECT TOP 1  @idCheckDetail = cd.idCheckDetail
			FROM CheckDetails cd WITH(NOLOCK)
			WHERE idCheck = @IdCheck
			ORDER BY IdCheckDetail DESC
		END

		INSERT CheckNote (idCheckDetail, idCheckNoteType, idUser, Note, EnterDate)
		VALUES (@idCheckDetail, 3, @EnterByIdUser, @Note, GETDATE());
	END

    Select @Message=dbo.GetMessageFromLenguajeResorces(0,30)
	Set @HasError=0
	
End Try
Begin Catch
	Set @HasError=1
	Select @Message = dbo.GetMessageFromLenguajeResorces (0,33)
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_SaveNoteCheckDetails',Getdate(),@ErrorMessage);
End Catch
