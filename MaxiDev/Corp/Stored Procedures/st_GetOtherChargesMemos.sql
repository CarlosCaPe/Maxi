CREATE PROCEDURE [Corp].[st_GetOtherChargesMemos]
	@isDebit BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdOtherChargesMemo], [Memo], [DateOfLastChange], [EnterByIdUser], [IsValidReverse], [IdQuickbook], [ForCredit], [ForDebit], [ReverseNote]
	FROM [MAXI].[dbo].[OtherChargesMemo] WITH(NOLOCK)
	WHERE ForDebit = @isDebit

END 



