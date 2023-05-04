CREATE PROCEDURE [dbo].[st_GetBillPaymentBtsFee] 
	@idProduct INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdFeeByOtherProducts], [IdOtherProducts], [FeeName], [DateOfLastChange], [EnterByIdUser]  
	FROM [dbo].[FeeByOtherProducts] WITH(NOLOCK)
    WHERE [IdOtherProducts] = @idProduct

END 




