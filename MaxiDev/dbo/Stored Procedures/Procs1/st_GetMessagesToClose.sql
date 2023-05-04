
CREATE PROCEDURE [dbo].[st_GetMessagesToClose]
	@StateCode varchar(30) 
AS
-- ============================================= 
-- Author:		Dario Almeida
-- Create date: 2017-06-14
-- Description:	Return messages for transfer closing

BEGIN

	IF NOT EXISTS (SELECT 1 FROM [Teleprompter].[MessagesToClose] WITH(NOLOCK) WHERE StateCode = @StateCode)
		BEGIN 
			SET @StateCode = 'ALL'
		END 

	SELECT
		MC.StateCode,
		MessageEs, 
		MessageEn
	FROM [Teleprompter].[MessagesToClose] MC WITH(NOLOCK)
	WHERE MC.StateCode = @StateCode
	
END
