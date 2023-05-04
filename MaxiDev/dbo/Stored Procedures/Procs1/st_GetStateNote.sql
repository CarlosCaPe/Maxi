CREATE PROCEDURE [dbo].[st_GetStateNote] 
	@IdState INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdStateNote], [IdState], [ComplaintNoticeEnglish], [ComplaintNoticeSpanish], [AffiliationNoticeEnglish], [AffiliationNoticeSpanish], [ComplaintNoticePortugues], [AffiliationNoticePortugues]
	FROM [dbo].[StateNote] WITH(NOLOCK)
	WHERE [IdState] = @IdState
END


