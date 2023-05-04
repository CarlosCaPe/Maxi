CREATE PROCEDURE [dbo].[st_MoveAgentCustomer]
(
    @IdAgentOrigin int,
    @IdAgentDestiny int,
    @EnterByIdUser int,
    @IsSpanishLenguage bit,
    @HasError bit out,                  
    @MessageOut varchar(max) out  
)
as
Begin Try      
 
 if not exists (select top 1 1 from customer c where IdAgentCreatedBy=@IdAgentOrigin)
 begin
    Set @HasError = 1                                       
    Select @MessageOut = [dbo].[GetMessageFromLenguajeResorces] (@IsSpanishLenguage,80)
 end
	DECLARE @CustomersTemp AS TABLE (idElasticCustomer VARCHAR(MAX))
	INSERT INTO @CustomersTemp 
	SELECT idElasticCustomer FROM Customer WHERE IdAgentCreatedBy = @IdAgentOrigin

     update Customer set 
	       IdAgentCreatedBy = @IdAgentDestiny
     where IdAgentCreatedBy = @IdAgentOrigin

     
    Insert into AgentCustomerMovement (IdAgentOrigin,IdAgentDestiny,EnterByIdUser,DateOfMovement) 
	values (@IdAgentOrigin,@IdAgentDestiny,@EnterByIdUser,GETDATE()) 

	SELECT idElasticCustomer FROM @CustomersTemp WHERE LTRIM(RTRIM(idElasticCustomer)) <> 'Descartado'
     
     Set @HasError = 0
     Set @MessageOut = [dbo].[GetMessageFromLenguajeResorces] (@IsSpanishLenguage,91)

End Try                                                
Begin Catch                                                
 Set @HasError = 1                                       
 Select @MessageOut = [dbo].[GetMessageFromLenguajeResorces] (@IsSpanishLenguage,80)
 Declare @ErrorMessage nvarchar(max)                                                 
 Select @ErrorMessage=ERROR_MESSAGE()                                                
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_MoveAgentCustomer',Getdate(),@ErrorMessage)                                                
End Catch 
