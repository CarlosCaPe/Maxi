
-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-04-16
-- Description:	Get Fee Detail
-- =============================================
create PROCEDURE [dbo].[st_GetFeeDetailFromFee] 
	-- Add the parameters for the stored procedure here
	@IdFee INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
	[IdFeeDetail]
	, [FromAmount]
	, [ToAmount]
	, [Fee]
	FROM [dbo].[FeeDetail] (NOLOCK) 
	WHERE [IdFee] = @IdFee

END

