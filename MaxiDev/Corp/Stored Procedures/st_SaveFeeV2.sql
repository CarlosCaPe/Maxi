CREATE PROCEDURE [Corp].[st_SaveFeeV2]
(
    @IdFeeByOtherProducts int,
    @IdOtherProducts int,
    @FeeName  nvarchar(max),
    @EnterByIdUser	int,
    @IdOtherProductCommissionType int = 0,
    @IdFeeByOtherProductsOut int out,
    @HasError int out,
    @Message nvarchar(max) out
)
AS
SET NOCOUNT ON;
BEGIN 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET @HasError = 0
	SET @Message = ''
	BEGIN TRY
			IF (@IdFeeByOtherProducts = 0)
				BEGIN
					INSERT INTO FeeByOtherProducts (IdOtherProducts, FeeName, DateOfLastChange, EnterByIdUser, IdOtherProductCommissionType, IsEnable) 
					VALUES (@IdOtherProducts, @FeeName, GETDATE(), @EnterByIdUser, @IdOtherProductCommissionType, 0)
					SET @IdFeeByOtherProductsOut = SCOPE_IDENTITY()
				END
			ELSE
				BEGIN
					UPDATE FeeByOtherProducts 
					SET FeeName	= @FeeName,
						DateOfLastChange = GETDATE(),
						EnterByIdUser = @EnterByIdUser,
						IdOtherProductCommissionType = @IdOtherProductCommissionType
					WHERE IdFeeByOtherProducts = @IdFeeByOtherProducts

					SET @IdFeeByOtherProductsOut = @IdFeeByOtherProducts
				END
	END TRY
	BEGIN CATCH 
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_SaveFeeV2',Getdate(),CONCAT(@Message,' Line: ',ERROR_LINE()))        
	END CATCH
END
