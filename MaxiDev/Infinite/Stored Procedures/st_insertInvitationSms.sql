CREATE PROCEDURE [Infinite].[st_insertInvitationSms]
	-- Add the parameters for the stored procedure here
	@CelullarNumber NVARCHAR(MAX)
	, @EnterByIdUser INT
	, @AgentId INT
	, @InsertSms BIT = 0
	, @IdCustomer INT = NULL
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @InterCode NVARCHAR(MAX)
	, @IdDialingCode INT
	
	
	IF @IdCustomer IS NOT NULL
		BEGIN
			SET @IdDialingCode = (SELECT Customer.IdDialingCodePhoneNumber FROM Customer WHERE Customer.IdCustomer = @IdCustomer)
			SET @InterCode = (select substring(DialingCode,CHARINDEX('+',DialingCode)+1,CHARINDEX(')',DialingCode)- CHARINDEX ('+',DialingCode)-1) from DialingCodePhoneNumber where IdDialingCodePhoneNumber = @IdDialingCode)
		END
	
	
	--[dbo].[GetGlobalAttributeByName]('InfiniteCountryCode')

	IF @InsertSms = 0
	BEGIN
		
		UPDATE [Infinite].[CellularNumber] SET [AllowSentMessages] = 0  WHERE [AllowSentMessages] = 1 AND [IsCustomer] = 1 AND [InterCode] = @InterCode AND [NumberWithFormat] = @CelullarNumber;

	END
	ELSE
	BEGIN

		DECLARE @MessageType INT = 9 -- WelcomeSms

		--IF @CelullarNumber != '' AND NOT EXISTS(SELECT TOP 1 1 FROM [Infinite].[CellularNumber] WITH (NOLOCK) WHERE [AllowSentMessages] = 1 AND [IsCustomer] = 1 AND [InterCode] = @InterCode AND [NumberWithFormat] = @CelullarNumber)
		IF @CelullarNumber != '' AND NOT EXISTS(SELECT 1 FROM [Infinite].[CellularNumber] WITH (NOLOCK) WHERE [AllowSentMessages] = 1 AND [IsCustomer] = 1 AND [InterCode] = @InterCode AND [NumberWithFormat] = @CelullarNumber)--#1
		BEGIN

			DECLARE @TextMessage NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName]('SmsWelcomeMessage')
			, @HasError BIT
			, @ErrorMessage NVARCHAR(MAX)

			EXEC [Infinite].[st_InsertTextMessage]
				@MessageType = @MessageType, 
				@Priority = 3, -- High
				@CellularNumber = @CelullarNumber,
				@InterCode = @InterCode,
				@TextMessage = @TextMessage,
				@UserId = @EnterByIdUser,
				@AgentId = @AgentId,
				@GatewayId = NULL,
				@IsCustomer = 1,
				@IdCustomer = @IdCustomer,
				@HasError = @HasError OUTPUT,
				@Message = @ErrorMessage OUTPUT;

			UPDATE [Infinite].[CellularNumber] SET [AllowSentMessages] = 1  WHERE [AllowSentMessages] = 0 AND [IsCustomer] = 1 AND [InterCode] = @InterCode AND [NumberWithFormat] = @CelullarNumber;

		END

	END
	
END TRY
BEGIN CATCH
	DECLARE @Message NVARCHAR(MAX)
	SELECT @Message=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_insertInvitationSms', GETDATE(), @Message);
END CATCH

