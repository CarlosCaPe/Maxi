/********************************************************************
<Author>jresendiz</Author>
<app>Corporate </app>
<Description></Description>

<ChangeLog>
<log Date="10/12/2018" Author="jresendiz"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [dbo].[st_DeleteFeeBillPayment] 
	@IdFeeByOtherProducts INT,
	@HasError BIT OUT,
	@Message NVARCHAR(MAX) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @HasError = 0
	SET @Message = ''
	BEGIN TRY
		DELETE FROM [dbo].[FeeDetailByOtherProducts] WHERE IdFeeByOtherProducts = @IdFeeByOtherProducts
		--DELETE FROM [dbo].[FeeByOtherProducts] WHERE IdFeeByOtherProducts = @IdFeeByOtherProducts
	END TRY
	BEGIN CATCH
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
	END CATCH
END
