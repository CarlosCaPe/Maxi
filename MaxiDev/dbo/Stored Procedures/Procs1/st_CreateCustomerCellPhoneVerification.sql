CREATE PROCEDURE st_CreateCustomerCellPhoneVerification
(
	@PhoneNumber				VARCHAR(20),
	@EnterByIdUser				INT,

	@IdCellPhoneVerification	INT OUT,
	@HasError					BIT	OUT,
	@ErrorMessage				VARCHAR(MAX) OUT
)
AS
BEGIN
	DECLARE @ExpirationDate				DATETIME,
			@VerificationCode			VARCHAR(20)
	EXEC st_CreateCellPhoneVerification @PhoneNumber, @EnterByIdUser, @IdCellPhoneVerification OUT

	SELECT
		@ExpirationDate = c.ExpirationDate,
		@VerificationCode = c.VerificationCode
	FROM CellPhoneVerification c
	WHERE c.IdCellPhoneVerification = @IdCellPhoneVerification

	DECLARE @Message		VARCHAR(500),
			@IdAgent		INT,
			@InterCode		VARCHAR(20),
			@IdMessageType	INT
	
	SET @Message = CONCAT('Your Maxi Code: ', @VerificationCode)
	SET @InterCode = dbo.GetGlobalAttributeByName('InfiniteCountryCode')

	SELECT 
		@IdMessageType = mt.IdMessageType
	FROM Infinite.MessageTypes mt 
	WHERE mt.MessageType = 'ChangePhoneNumber'

	SELECT 
		@IdAgent = au.IdAgent
	FROM AgentUser au
	WHERE au.IdUser = @EnterByIdUser

	EXEC Infinite.st_InsertTextMessage
		@IdMessageType,
		1,
		@PhoneNumber,
		@InterCode,
		@Message,
		@EnterByIdUser,
		@IdAgent,
		0,
		1,
		@HasError OUT,
		@ErrorMessage OUT

	IF @HasError = 1
		SET @IdCellPhoneVerification = 0
END
