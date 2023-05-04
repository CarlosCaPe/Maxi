CREATE PROCEDURE st_AddContactEmail
(
	@IdContactEntity		INT,
	@IdReference			INT,
	@Email					VARCHAR(200),
	@EnterByIdUser			INT,
	@IsPrincipal			BIT = 0,
	@Active					BIT = 1
)
AS
BEGIN
	DECLARE @MSG_ERROR NVARCHAR(500)
	
	IF NOT EXISTS(SELECT 1 FROM ContactEntity ce WHERE ce.IdContactEntity = @IdContactEntity)
	BEGIN
		SET @MSG_ERROR = CONCAT('The contact entity (', @IdContactEntity, ') not exists')
		RAISERROR(@MSG_ERROR, 16, 1);
	END

	IF @IsPrincipal = 1
		UPDATE ContactEmail SET
			IsPrincipal = 0
		WHERE IdContactEntity = @IdContactEntity AND IdReference = @IdReference

	DECLARE @PrevId INT

	SELECT
		@PrevId = ce.IdContactEmail
	FROM ContactEmail ce 
	WHERE ce.IdContactEntity = @IdContactEntity 
		AND ce.IdReference = @IdReference 
		AND ce.Email = @Email

	IF (ISNULL(@PrevId, 0) = 0)
	BEGIN
		INSERT INTO ContactEmail(
			IdContactEntity, 
			IdReference, 
			Email, 
			IsPrincipal, 
			EnterByIdUser, 
			CreateDate,
			ChangeByUser,
			DateOfLastChange,
			Active
		)
		VALUES(
			@IdContactEntity, 
			@IdReference, 
			@Email, 
			@IsPrincipal, 
			@EnterByIdUser, 
			GETDATE(),
			@EnterByIdUser,
			GETDATE(),
			1
		)
	END
	ELSE
	BEGIN
		UPDATE ContactEmail SET
			IsPrincipal = @IsPrincipal,
			ChangeByUser = @EnterByIdUser,
			DateOfLastChange = GETDATE(),
			Active = @Active
		WHERE IdContactEmail = @PrevId
	END
END
