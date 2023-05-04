CREATE PROCEDURE [Corp].[st_ChangeStatusFee]
(
    @IdFeeByOtherProducts int,
    @IdOtherProducts int,
    @FeeName  nvarchar(max),
    @EnterByIdUser	int,
    @IdOtherProductCommissionType int = 0,
	@IsEnabled bit,
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
		UPDATE  FeeByOtherProducts  
		SET  FeeName = @FeeName
		  ,DateOfLastChange = GETDATE()
		  ,EnterByIdUser = @EnterByIdUser
		  ,IdOtherProductCommissionType = @IdOtherProductCommissionType 
		  ,IsEnable = ~@IsEnabled
		WHERE IdFeeByOtherProducts =  @IdFeeByOtherProducts
	END TRY


	BEGIN CATCH 
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ChangeStatusFeeMIGRACION',Getdate(),ERROR_MESSAGE())   
	END CATCH
END
