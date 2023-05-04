CREATE PROCEDURE  [Corp].[st_DiscardSimilarDeposit] 
	@IdScannerProcessFiles int,
	@idUser int,
	@HasError bit output,
	@Message varchar(50) output
	
	as
BEGIN
SET @HasError=0

	SET NOCOUNT ON;
	IF EXISTS( SELECT TOP 1
	[IdScannerProcessFiles]
      ,[IdAgent]
      ,[IdUploadFile]
      ,[BankName]
      ,[Amount]
      ,[DepositDate]
  FROM [dbo].[ScannerProcessFile] WITH (nolock)
  WHERE [IdScannerProcessFiles]= @IdScannerProcessFiles)
  BEGIN 
	  BEGIN TRY
			  UPDATE [dbo].[ScannerProcessFile]
		   SET 
			  [EnterByIdUser] = @idUser
			  ,[DateofLastChange] = GETDATE()
			  ,[IsProcessed] = 1
		 WHERE [IdScannerProcessFiles]= @IdScannerProcessFiles
		 SET @Message='Operation was performed successfully'
	  END TRY
	  BEGIN CATCH
		  Declare @ErrorMessage nvarchar(max)
		  SET @HasError = 1                                                                                       
		  Select  @ErrorMessage=ERROR_MESSAGE() 
		  SET @Message = 'Error while updating'                                            
		  Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_DiscardSimilarDeposit] ',Getdate(),@ErrorMessage)
	  END CATCH
  END
  ELSE
  BEGIN
  SET @Message='File doesnt exist, please refresh your screen'
  END
  
END
