CREATE procedure [dbo].[st_GetOFACForCheckCustomer]
(    
    @CustomerName nvarchar(max),
    @CustomerFirstLastName nvarchar(max),
    @CustomerSecondLastName nvarchar(max) = '',  
	@ResultOfac int = 0 output,
	@HasError bit = 0 output,
	@ErrorMessage nvarchar(max) = '' output 
)
as
declare     
            @CustomerPercentMatch float=0
begin try
	
	SELECT @CustomerPercentMatch = [dbo].[fun_OfacnamePercentLetterPairsWithPercent] (
		 @CustomerName
		,@CustomerFirstLastName
		,@CustomerSecondLastName
		,100
	)

	SET @ResultOfac = 0

	IF (@CustomerPercentMatch = 100)
		SET @ResultOfac = 1

	SET @HasError = 0
	SET @ErrorMessage = ''
end try                                                                                    
Begin Catch                                                                                            
    SET @HasError = 1
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetOFACForCheckCustomer',Getdate(),@ErrorMessage)                                                                                            
End Catch