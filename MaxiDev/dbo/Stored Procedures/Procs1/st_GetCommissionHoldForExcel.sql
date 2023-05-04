-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-02-09
-- Description:	This stored is used in Commission Hold screen (Corporate / Collection)
-- =============================================
CREATE PROCEDURE [dbo].[st_GetCommissionHoldForExcel]
	-- Add the parameters for the stored procedure here
	@Guid VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT
		[AgentId],
		[AgentCode],
		[AgentName],
		[AgentClass],
		[TotalCommission],
		[SpecialCommission],
		[RetainCommission],
		[MonthlyCommission],
		[Debt],
		[Amount],
		[Notes],
		[BonusApplied],
		[BonusDebt]
	FROM [dbo].[CommissionHoldForExcel] WITH (NOLOCK)
	WHERE [GuidIdentifier] = @Guid


END
