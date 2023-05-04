CREATE PROCEDURE [dbo].[st_DeleteDetailsCommissionsMIGRACION]
(
    @IdCommissionByOtherProducts INT,
	@HasError INT OUT,
    @Message NVARCHAR(MAX)OUT
)
AS
SET NOCOUNT ON;
BEGIN TRY
	SET @HasError = 0
	SET @Message = ''
	DELETE FROM CommissiondetailByOtherProducts
	WHERE IdCommissionByOtherProducts = @IdCommissionByOtherProducts
END TRY
BEGIN CATCH 
	SET @HasError = 1
	SET @Message = ERROR_MESSAGE()
END CATCH

