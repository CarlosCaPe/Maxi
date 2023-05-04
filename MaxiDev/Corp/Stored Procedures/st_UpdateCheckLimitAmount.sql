CREATE PROCEDURE [Corp].[st_UpdateCheckLimitAmount]
	@Amount 	VARCHAR(10),
	@IsReset	BIT,
	@IdUser		INT,
	@HasError	BIT OUT,
	@Message	VARCHAR(MAX) OUT
	
AS
BEGIN

	BEGIN TRY	
		DECLARE @CheckLimitAmountPerCustomerOld VARCHAR(MAX), @MaxAmountForCheckOld VARCHAR(MAX),
				@CheckLimitAmountPerCustomerNew VARCHAR(MAX), @MaxAmountForCheckNew VARCHAR(MAX)
		
		
		SELECT @CheckLimitAmountPerCustomerOld = Value
		FROM dbo.GlobalAttributes
		WHERE Name = 'CheckLimitAmountPerCustomer'
		
		SELECT @MaxAmountForCheckOld = Value
		FROM dbo.GlobalAttributes
		WHERE Name = 'MaxAmountForcheck'
	
		SET @HasError = 0
		
	
		IF (@IsReset = 1)
		BEGIN
		
			UPDATE GlobalAttributes SET  [Value]='9999' 
			WHERE [name] = 'CheckLimitAmountPerCustomer'
			
			UPDATE GlobalAttributes SET [Value]='9999' 
			WHERE [name] = 'MaxAmountForcheck' 
			
			
			
		END
		ELSE
		BEGIN		
		
			UPDATE GlobalAttributes SET [Value]=@Amount
			WHERE [name] = 'CheckLimitAmountPerCustomer'
			
			UPDATE GlobalAttributes SET [Value]=@Amount 
			WHERE [name] = 'MaxAmountForcheck'
		
		END	
		
		--Log	
		SELECT @CheckLimitAmountPerCustomerNew = Value
		FROM dbo.GlobalAttributes
		WHERE Name = 'CheckLimitAmountPerCustomer'
		
		SELECT @MaxAmountForCheckNew = Value
		FROM dbo.GlobalAttributes
		WHERE Name = 'MaxAmountForcheck'
		
		
		IF (@CheckLimitAmountPerCustomerOld <> @CheckLimitAmountPerCustomerNew)
		BEGIN		
			INSERT INTO dbo.GeneralUpdateTablesLog (TableName, RowName, OldValue, NewValue, IdUser, IdRow, IdTextRow, DateOfCreation, Description)
			VALUES ('[dbo].[GlobalAttributes]', 'Value', @CheckLimitAmountPerCustomerOld, @CheckLimitAmountPerCustomerNew, @IdUser, 0, 'CheckLimitAmountPerCustomer', getdate(), 'Support Module - Check Limit Change')		
		END
		
		IF (@MaxAmountForCheckOld <> @MaxAmountForCheckNew)
		BEGIN		
			INSERT INTO dbo.GeneralUpdateTablesLog (TableName, RowName, OldValue, NewValue, IdUser, IdRow, IdTextRow, DateOfCreation, Description)
			VALUES ('[dbo].[GlobalAttributes]', 'Value', @MaxAmountForCheckOld, @MaxAmountForCheckNew, @IdUser, 0, 'MaxAmountForcheck', getdate(), 'Support Module - Check Limit Change')	
		END 
		
		
		SELECT @Message = 'Check limit amount saved succesfully.'
	
	END TRY
	BEGIN CATCH		
		         
		SET @HasError = 1          
		SELECT @Message = ERROR_MESSAGE()         
		
		DECLARE @ErrorMessage NVARCHAR(max)           
		DECLARE @ErrorLine NVARCHAR(max)
		
		SELECT @ErrorMessage = ERROR_MESSAGE()          
		SELECT @ErrorLine = CONVERT(VARCHAR(20), ERROR_LINE())		
		
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_UpdateCheckLimitAmount]',Getdate(), 'Line: ' + @ErrorLine + ', ' + @ErrorMessage)          
		
	END CATCH
	
	
	

END
