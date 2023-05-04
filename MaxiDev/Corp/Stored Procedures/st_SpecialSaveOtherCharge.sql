CREATE Procedure [Corp].[st_SpecialSaveOtherCharge]               
@IsSpanishLanguage bit,              
@IdAgent int,              
@Amount Money,  
@Commission Money,              
@ChargeDate datetime,              
@Notes nvarchar(max),      
@Reference nvarchar(max),              
@EnterByIdUser int,
@Country nvarchar(max),              
@HasError bit out,                                    
@Message varchar(max) out                
as              
Begin Try              
              
Declare @Balance Money              
Declare @PositiveAmount Money              
Declare @TypeOfCharge nvarchar(10)              
Declare @IdAgentBalance int              
Set  @Balance=0              
--------------------- Modify Agent current balance -------------------------------                 
               
If not Exists (Select 1 from AgentCurrentBalance with(nolock) where IdAgent=@IdAgent)                 
begin              
 Insert into AgentCurrentBalance (IdAgent,Balance) values (@IdAgent,@Balance)                
end                              
               
 Update AgentCurrentBalance set Balance=Balance+@Amount,@Balance=Balance+@Amount  where IdAgent=@IdAgent                
              
                
--------------------- Debit or Credit ----------------------------------------------                
if @Amount<0              
 Begin              
  Set @TypeOfCharge='Credit'              
     Set @PositiveAmount=@Amount*-1              
    End              
    Else              
    Begin              
        Set @TypeOfCharge='Debit'              
        Set @PositiveAmount=@Amount              
    End              
  ---------------------- Insert into Agent balance ------------------------------------              
                
Insert into AgentBalance                 
(                
IdAgent,                
TypeOfMovement,                
DateOfMovement,                
Amount,                
Reference,                
Description,                
Country,                
Commission,
FxFee,                
DebitOrCredit,                
Balance,                
IdTransfer                
)                
Values                
(                
@IdAgent,                
'CGO',                
GETDATE(),                
@PositiveAmount,                
@Reference,                
@Notes,                
@Country,                
@Commission,
0,                
@TypeOfCharge,                
@Balance,                
0                
)                
              
Select @IdAgentBalance=SCOPE_IDENTITY() 

 --Validar CurrentBalance
exec [Corp].[st_AgentVerifyCreditLimit] @IdAgent             

              
 Set @HasError=0                                    
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,16)                                    
                                    
End Try                                    
Begin Catch                                    
 Set @HasError=1                           
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,17)                                     
 Declare @ErrorMessage nvarchar(max)                                     
 Select @ErrorMessage=ERROR_MESSAGE()                                    
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_SpecialSaveOtherCharge]  ',Getdate(),@ErrorMessage)                                    
End Catch
