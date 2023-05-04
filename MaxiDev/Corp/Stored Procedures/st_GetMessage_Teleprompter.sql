CREATE PROCEDURE [Corp].[st_GetMessage_Teleprompter] 
	@StateCode VARCHAR(12)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		SELECT 
			[IdMessage]
			,[StateCode]
			,[MessageEn]
			,[MessageEs]
		FROM [Teleprompter].[MessagesToClose] WITH(NOLOCK)
		WHERE [StateCode] = @StateCode;

END
