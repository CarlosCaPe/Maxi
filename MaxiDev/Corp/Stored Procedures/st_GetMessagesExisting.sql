CREATE PROCEDURE [Corp].[st_GetMessagesExisting]
(
	@IdAgent INT,
	@ComplianceProductMessage VARCHAR(MAX),
	@Update INT OUTPUT,
	@HasError BIT OUTPUT,
	@MessageOut NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IsSpanishLanguage BIT = 0;
	DECLARE @IsEnable INT = 0;
	SET @HasError = 0;

	BEGIN TRY

		/*GenericStatus*/
		/*1	Enabled*/
		/*2	Disabled*/
		SET @IsEnable = ISNULL((SELECT TOP 1 IdGenericStatus FROM GenericStatus WHERE GenericStatus = 'Disabled'),0);

		SET @Update = 0;

		DECLARE @USERS TABLE
		(
			IdUser INT
		);

		INSERT INTO @USERS
			SELECT DISTINCT A.IdUser 
				FROM [dbo].[AgentUser] AS A with(nolock) 
						INNER JOIN Users AS US with(nolock)  ON A.IdUser = US.IdUser							
							WHERE A.IdAgent = @IdAgent
								AND US.IdGenericStatus <> @IsEnable;

		IF EXISTS(
			 SELECT TOP 1 1 FROM msg.Messages AS M
				Inner Join msg.MessageSubcribers AS MS ON M.IdMessage = ms.IdMessage
				INNER JOIN @USERS AS U ON MS.IdUser = U.IdUser 
			 WHERE 		
				((CHARINDEX(@ComplianceProductMessage, RawMessage) > 0)		
				AND IdMessageProvider = 5))
		BEGIN

			DECLARE @Messages TABLE ( IdMessage INT );

			INSERT INTO @Messages
				SELECT DISTINCT M.IdMessage 
					FROM msg.Messages AS M
						Inner Join msg.MessageSubcribers AS MS ON M.IdMessage = ms.IdMessage
							INNER JOIN @USERS AS U ON MS.IdUser = U.IdUser 
					WHERE  ((CHARINDEX(@ComplianceProductMessage, RawMessage) > 0)		
						AND IdMessageProvider = 5);

			UPDATE M
				SET DateOfLastChange = GETDATE()
					FROM @Messages AS Msg
						INNER JOIN msg.Messages AS M ON Msg.IdMessage = M.IdMessage;

			UPDATE msg.MessageSubcribers
				SET 
					IdMessageStatus = 5,
					--MessageIsRead = 1,
					DateOfLastChange = GETDATE()
				FROM  msg.MessageSubcribers AS MS
						INNER JOIN @Messages AS Msg ON Msg.IdMessage = MS.IdMessage;

			SET @Update  = @@ROWCOUNT;
		END
		ELSE
		BEGIN
			SET @Update = 0;
		END

	return @Update;

	END TRY 
	BEGIN CATCH
		 Set @HasError=1;
		 Select @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33);
		 Declare @ErrorMessage nvarchar(max);
		 Select @ErrorMessage=ERROR_MESSAGE();
		 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetMessagesExisted',Getdate(),@ErrorMessage);
	END CATCH

END

