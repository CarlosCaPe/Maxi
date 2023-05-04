-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-02-09
-- Description:	This stored is used in Collect Plan By Commission screen (Corporate / Collection)
-- =============================================
CREATE PROCEDURE [dbo].[st_GetCollectPlanForExcel]
	-- Add the parameters for the stored procedure here
	@Guid VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT
		[AgentCollectionId],
		[AgentCode],
		[AgentName],
		[Percentage],
		[Commission],
		[ExpectedAmount],
		[Amount],
		[Note],
		[AgentClass],
		[Fee],
		[TotalDebt],
		[FixedCommission],
		[SpecialCommission],
		[SpecialCommissionToApply],
		[BonusApplied],
		[BonusDebt]
	FROM [dbo].[CollectPlanForExcel] WITH (NOLOCK)
	WHERE [GuidIdentifier] = @Guid

END
