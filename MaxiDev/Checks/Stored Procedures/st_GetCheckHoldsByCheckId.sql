-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-10-21
-- Description:	Return check holds by check id
-- =============================================
CREATE PROCEDURE [Checks].[st_GetCheckHoldsByCheckId]
	-- Add the parameters for the stored procedure here
	@CheckId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT
		CH.[IdCheckHold]
		, CH.[IdCheck]
		, CH.[IsReleased]
		, CH.[DateOfValidation]
		, CH.[DateOfLastChange]
		, CH.[EnterByIdUser]
		, S.[IdStatus]
		, S.[StatusName]
		, U.[UserName]
	FROM [dbo].[CheckHolds] CH WITH (NOLOCK)
	JOIN [dbo].[Status] S WITH (NOLOCK) ON CH.[IdStatus] = S.[IdStatus]
	JOIN [dbo].[Users] U WITH (NOLOCK) ON CH.[EnterByIdUser] = U.[IdUser]
	WHERE CH.IdCheck = @CheckId

END
