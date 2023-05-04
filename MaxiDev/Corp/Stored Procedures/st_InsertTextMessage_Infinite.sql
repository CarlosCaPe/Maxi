CREATE PROCEDURE [Corp].[st_InsertTextMessage_Infinite]
	-- Add the parameters for the stored procedure here
	@MessageType INT,
	@Priority INT,
	@CellularNumber NVARCHAR(50), -- Should be in format (449) 100-5794
	@InterCode NVARCHAR(10), -- Only numbers
	@TextMessage NVARCHAR(MAX),
	@UserId INT = NULL,
	@AgentId INT = NULL,
	@GatewayId INT = NULL,
	@IsCustomer BIT = 0,
	@HasError BIT OUTPUT,
	@Message NVARCHAR(MAX) OUTPUT

AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Date DATETIME = GETDATE()
			, @CellularId BIGINT
			, @TextMessageStatusId INT = 1 -- Init

	IF @UserId IS NULL
		SET @UserId = CONVERT(INT,ISNULL([dbo].[GetGlobalAttributeByName]('SystemUserID'),'1'))

	-- The where use [Number] because sometimes we don't know the international code
	SELECT TOP 1 @CellularId = [IdCellularNumber] FROM [Infinite].[CellularNumber] WITH (NOLOCK) WHERE [IsCustomer] = @IsCustomer AND [InterCode] = @InterCode AND [NumberWithFormat] = @CellularNumber

	IF @CellularId IS NULL
	BEGIN
		INSERT INTO [Infinite].[CellularNumber] VALUES (
				0
				, @Date
				, @Date
				, @CellularNumber
				, @IsCustomer
				, @InterCode)
		SET @CellularId = SCOPE_IDENTITY()
	END
	
	-- Message to sent
	INSERT INTO [Infinite].[TextMessageInfinite](
		[IdMessageType]
		, [IdPriority]
		, [IdCellularNumber]
		, [Message]
		, [IdTextMessageStatus]
		, [Attempts]
		, [InserteredDate]
		, [LastDateChange]
		, [EnteredByUserId]
		, [AgentId]
		, [GatewayId])
		VALUES (@MessageType, @Priority, @CellularId, @TextMessage, @TextMessageStatusId, 0, @Date, @Date, @UserId, @AgentId, @GatewayId)

	SET @HasError = 0
	SET @Message = 'Operation was successful'

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_InsertTextMessage', GETDATE(), @ErrorMessage)
	SET @HasError = 1
	SET @Message = 'Error trying insert'
END CATCH

