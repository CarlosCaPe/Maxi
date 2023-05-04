CREATE PROCEDURE [dbo].[st_GetComissionDetail] 
	@idCommission int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdCommissionDetailByProvider], [IdCommissionByOtherProducts], [FromAmount], [ToAmount], [AgentCommissionInPercentage], [CorporateCommissionInPercentage],
		[DateOfLastChange], [EnterByIdUser], [ExtraAmount], [BillerSpecific]
	FROM [dbo].[CommissionDetailByOtherProducts] WITH(NOLOCK)
	WHERE [IdCommissionByOtherProducts] = @idCommission


END

