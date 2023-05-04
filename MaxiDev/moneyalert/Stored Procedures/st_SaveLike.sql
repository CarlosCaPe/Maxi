CREATE PROCEDURE [MoneyAlert].[st_SaveLike]
  (  
  @LikeStatus	INT,
  @IdTransfer	INT,
  @IdPersonRole	INT,
  @HasError bit out  
)
AS
SET NOCOUNT ON
BEGIN TRY

  SET @HasError=0

  IF Exists (SELECT 1 FROM MoneyAlert.Likes WHERE IdTransfer=@IdTransfer and IdPersonRole=@IdPersonRole)
  BEGIN
	UPDATE MoneyAlert.Likes SET LikeStatus=@LikeStatus WHERE IdTransfer=@IdTransfer and IdPersonRole=@IdPersonRole
  END
  ELSE
  BEGIN
	INSERT INTO MoneyAlert.Likes (LikeStatus,IdTransfer,IdPersonRole,EnteredDate,DateOfLastChange)
	Values(@LikeStatus,@IdTransfer,@IdPersonRole,Getdate(),Getdate())
  END

         
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH










