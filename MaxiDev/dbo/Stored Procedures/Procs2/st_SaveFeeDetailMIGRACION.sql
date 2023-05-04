CREATE PROCEDURE [dbo].[st_SaveFeeDetailMIGRACION]
(
    @IdFeeDetailByOtherProductsr INT,
    @IdFeeByOtherProducts int,
    @FromAmount	money,
    @ToAmount	money,
    @Fee money,
    @IsFeePercentage bit,
    @EnterByIdUser	int,    
    @IdFeeDetailByOtherProductsrOut int out,
    @HasError int out,
    @Message nvarchar(max) out
)
AS
SET NOCOUNT ON;
BEGIN
	SET @HasError = 0
	SET @Message = ''
	BEGIN TRY
		IF (@IdFeeDetailByOtherProductsr=0)
		BEGIN
			INSERT INTO FeedetailByOtherProducts (IdFeeByOtherProducts, FromAmount, ToAmount, Fee, DateOfLastChange, EnterByIdUser, IsFeePercentage) 
			VALUES (@IdFeeByOtherProducts, @FromAmount, @ToAmount, @Fee, GETDATE(), @EnterByIdUser, @IsFeePercentage)
			SET @IdFeeDetailByOtherProductsrOut = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			UPDATE FeedetailByOtherProducts 
			SET IdFeeByOtherProducts = @IdFeeByOtherProducts,
				FromAmount = @FromAmount,
				ToAmount = @ToAmount,
				Fee = @Fee,
				DateOfLastChange = GETDATE(),
				EnterByIdUser = @EnterByIdUser,
				IsFeePercentage = @IsFeePercentage
			WHERE IdFeeDetailByOtherProductsr = @IdFeeDetailByOtherProductsr

			SET @IdFeeDetailByOtherProductsrOut = @IdFeeDetailByOtherProductsr
		END
	END TRY
	BEGIN CATCH 
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
	END CATCH
END
