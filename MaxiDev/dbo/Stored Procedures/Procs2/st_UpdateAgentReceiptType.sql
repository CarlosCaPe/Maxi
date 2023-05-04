create procedure st_UpdateAgentReceiptType
(
    @IdAgent int,
    @IdPrint int,   
    @HasError bit out
)
as
Begin Try  

	UPDATE Agent SET IdAgentReceiptType = @IdPrint WHERE IdAgent = @IdAgent
	Set @HasError = 0  

End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                   
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Regalii.st_UpdateAgentReceiptType',Getdate(),@ErrorMessage)                                                                                            
End Catch  