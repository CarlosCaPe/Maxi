CREATE PROCEDURE [Infinite].[st_InsertTextMessage]
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
	@IdCustomer INT = NULL,
	@IsDelayed BIT = 0,
	@IdTransfer INT = NULL,	
	@HasError BIT OUTPUT,
	@Message NVARCHAR(MAX) OUTPUT

AS

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="24/01/2018" Author="jmolina">Add ChangeLog</log>
<log Date="17/12/2018" Author="jmolina">Se agrego el ; por cada insert y/o update</log>
<log Date="07/09/2021" Author="cagarcia">Se agrega parametro IdCustomer</log>
</ChangeLog>
********************************************************************/

BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Date DATETIME = GETDATE()
			, @CellularId BIGINT
			, @TextMessageStatusId INT = 1 -- Init
			, @DelayedDateTime DATETIME
			, @DelayMinutes INT
			, @IdDialingCode INT

	IF @UserId IS NULL
		SET @UserId = CONVERT(INT,ISNULL([dbo].[GetGlobalAttributeByName]('SystemUserID'),'1'))
		
	SET @DelayMinutes = CONVERT(INT,ISNULL([dbo].[GetGlobalAttributeByName]('SmsDelayTime'),'30'))

	IF @IdTransfer IS NOT NULL
	BEGIN
		SET @IdDialingCode = (SELECT Transfer.IdDialingCodePhoneNumber FROM Transfer WHERE Transfer.IdTransfer = @IdTransfer)
		SET @InterCode = (select substring(DialingCode,CHARINDEX('+',DialingCode)+1,CHARINDEX(')',DialingCode)- CHARINDEX ('+',DialingCode)-1) from DialingCodePhoneNumber where IdDialingCodePhoneNumber = @IdDialingCode)
	END
	ELSE
	BEGIN
		IF @IdCustomer IS NOT NULL
		BEGIN
			SET @IdDialingCode = (SELECT Customer.IdDialingCodePhoneNumber FROM Customer WHERE Customer.IdCustomer = @IdCustomer)
			SET @InterCode = (select substring(DialingCode,CHARINDEX('+',DialingCode)+1,CHARINDEX(')',DialingCode)- CHARINDEX ('+',DialingCode)-1) from DialingCodePhoneNumber where IdDialingCodePhoneNumber = @IdDialingCode)
		END
	END

	--Add @InterCode from table Transfer by dialing code
	--SET @InterCode = (SELECT Transfer.IdDialingCodePhoneNumber FROM Transfer WHERE Transfer.IdTransfer = @IdTransfer)
		
	
	DECLARE @Source NVARCHAR(MAX)
	SET @Source = [dbo].[fn_GetNumeric] (LTRIM(ISNULL(@CellularNumber,'')))		
	
	DECLARE @SourceWithFormat NVARCHAR(MAX) = SUBSTRING(@Source, LEN(@Source)-9, LEN(@Source)+1)
	SET @SourceWithFormat = [dbo].[fnFormatPhoneNumber](@SourceWithFormat)
   	
   	IF @IsDelayed = 1 AND @MessageType = 11
   	BEGIN
   		SET @DelayedDateTime = dateadd(mi, @DelayMinutes, @Date)
   	END
	

	-- The where use [Number] because sometimes we don't know the international code
	SELECT TOP 1 @CellularId = [IdCellularNumber] 
	FROM [Infinite].[CellularNumber] WITH (NOLOCK) 
	WHERE [IsCustomer] = @IsCustomer 
		AND [InterCode] = @InterCode 
		AND [NumberWithFormat] IN (@Source, @SourceWithFormat)

	IF @CellularId IS NULL
	BEGIN
		INSERT INTO [Infinite].[CellularNumber] VALUES (
				0
				, @Date
				, @Date
				, @CellularNumber
				, @IsCustomer
				, @InterCode
				, @IdCustomer);
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
		, [GatewayId]
		, [IsDelayed]
		, [DelayedDateTime]
		, [IdTransfer])
		VALUES (@MessageType, @Priority, @CellularId, @TextMessage, @TextMessageStatusId, 0, @Date, @Date, @UserId, @AgentId, @GatewayId, @IsDelayed, @DelayedDateTime, @IdTransfer);

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



