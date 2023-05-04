CREATE Procedure [dbo].[st_SaveDeb]            
    @IsSpanishLanguage bit,            
    @IdAgent int,            
    @Amount Money,    
    @IsDebit bit,          
    @ChargeDate datetime,            
    @Notes nvarchar(max),    
    @Reference nvarchar(max),            
    @EnterByIdUser int,            
    @HasError bit out,                                  
    @Message varchar(max) out ,
    @IdOtherChargesMemo int =null,
    @OtherChargesMemoNote  nvarchar(max) =null              
as            
Begin Try            
            
Declare @Balance Money            
Declare @PositiveAmount Money            
Declare @TypeOfCharge nvarchar(10)            
Declare @IdAgentBalance int 
Declare @AmountCurrentBalance money

Set  @Balance=0            
If @IsDebit=1
	Set @AmountCurrentBalance=@Amount
Else
	Set @AmountCurrentBalance=@Amount*-1
--------------------- Modify Agent current balance -------------------------------               

If not Exists (Select 1 from AgentCurrentBalance  with(nolock) where IdAgent=@IdAgent)
begin                
 Insert into AgentCurrentBalance (IdAgent,Balance) values (@IdAgent,0)  
end 
    Update AgentCurrentBalance set Balance=Balance+@AmountCurrentBalance ,@Balance=Balance+@AmountCurrentBalance  where IdAgent=@IdAgent
	--Select @Balance=Balance from AgentCurrentBalance where IdAgent=@IdAgent      
    
          
          
--------------------- Debit or Credit ----------------------------------------------              
if @IsDebit=0            
 Begin            
  Set @TypeOfCharge='Credit'            
     Set @PositiveAmount=@Amount            
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
'DEBT',             
GETDATE(),              
@PositiveAmount,              
@Reference,              
@Notes,              
'',              
0,
0,              
@TypeOfCharge,              
@Balance,              
0              
)              
            
Select @IdAgentBalance=SCOPE_IDENTITY()            
-------------------------------- Insert in to Other Charges ---------------------------            
            
Insert into AgentOtherCharge            
(            
IdAgent,            
IdAgentBalance,            
Amount,            
ChargeDate,            
Notes,            
DateOfLastChange,            
EnterByIdUser,
IdOtherChargesMemo,
OtherChargesMemoNote              
)            
values            
(            
@IdAgent,            
@IdAgentBalance,            
@Amount,            
@ChargeDate,            
'',            --cambio miguel
GETDATE(),            
@EnterByIdUser  ,
@IdOtherChargesMemo,
@OtherChargesMemoNote          
)  

 --Validar CurrentBalance
        exec st_AgentVerifyCreditLimit @IdAgent          
               
            
 Set @HasError=0                                  
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,16)                                  
                                  
End Try                                  
Begin Catch  


                                 
 Set @HasError=1                         
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,17)                                   
 Declare @ErrorMessage nvarchar(max)                                   
 set @ErrorMessage = 'Agent: ' +ISNULL (CAST(@IdAgent as varchar) ,'Is null')+' Amount: ' + ISNULL(CAST( @Amount as varchar),'Is null') + ' Reference: ' + ISNULL(@Reference,'Is null ') + 'Is debit: ' + ISNULL(Cast(@IsDebit as varchar), 'Is null ') + 'Charge Date: ' + ISNULL(Cast(@ChargeDate as varchar), 'Is null ') +'Notes: '+ ISNULL(@Notes,'is null ') + 'User: '+ ISNULL(CAST(@EnterByIdUser as varchar) ,'Is null' )  + ERROR_MESSAGE()                                  
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveDeb',Getdate(),@ErrorMessage)                                  
End Catch


