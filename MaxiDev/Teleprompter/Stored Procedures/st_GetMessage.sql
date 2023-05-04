-- =============================================
-- Author:		Nevarez, Sergio
-- Create date: 2017-Jun-12
-- Description:	This stored gets Messages
-- =============================================
CREATE PROCEDURE [Teleprompter].[st_GetMessage] 
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
