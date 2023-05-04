CREATE PROCEDURE Corp.st_ConfirmOfacValidationMatch
	@IdOfacValidationDetail	INT,
	@StatusChangeNote		VARCHAR(max),
	@IdUser					INT,
	@HasError				BIT OUT,
	@Message				VARCHAR(MAX) OUT
AS
BEGIN
	
	BEGIN TRY 
	
		SET @HasError = 0	

		UPDATE Corp.OfacValidationDetail 
		SET GeneralStatus = 'MatchAndConfirmed', 
			IdUserApprove = @IdUser, 
			DateOfApproval = getdate(), 
			StatusChangeNote = @StatusChangeNote
		WHERE IdOfacValidationDetail = @IdOfacValidationDetail
		
		SELECT @Message = 'Ofac Match Confirmed successfully.'
	
	END TRY
	BEGIN CATCH		
		         
		SET @HasError = 1          
		SELECT @Message = ERROR_MESSAGE()         
		
		DECLARE @ErrorMessage NVARCHAR(max)           
		DECLARE @ErrorLine NVARCHAR(max)
		
		SELECT @ErrorMessage = ERROR_MESSAGE()          
		SELECT @ErrorLine = CONVERT(VARCHAR(20), ERROR_LINE())		
		
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_ConfirmOfacValidationMatch]',Getdate(), 'Line: ' + @ErrorLine + ', ' + @ErrorMessage)          
		
	END CATCH		

END	

