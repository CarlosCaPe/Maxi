
CREATE Procedure [dbo].[st_DebitToAgentBalanceForSB]        
(        
    @IdTransfer int,
    @IdAgent Int,
    @Amount Money,        
    @Reference int,  
    @CustomerName nvarchar(max),        
    @CustomerFirstLastName nvarchar(max),            
    @Country nvarchar(max)  ,
    @AgentCommissionExtra money,
    @AgentCommissionOriginal money,
    @ModifierCommissionSlider money,
    @ModifierExchangeRateSlider money
)
AS        
Set nocount on 
       
Declare         
    @DateOfMovement datetime,        
    @Description nvarchar(max),        
    @Commission money,        
    @FxFee money,      
    @Balance money
        
Set @Balance=0        
        
Select          
 @DateOfMovement=DATEADD (SECOND , 1 , GETDATE() ),          
 @Description=@CustomerName+' '+@CustomerFirstLastName,         
 @Commission=@AgentCommissionExtra+@AgentCommissionOriginal,    
 @FxFee=@ModifierCommissionSlider+@ModifierExchangeRateSlider  
 
If not Exists (Select 1 from AgentCurrentBalance with(nolock) where IdAgent=@IdAgent) 
begin          
  Insert into AgentCurrentBalance (IdAgent,Balance) values (@IdAgent,@Balance)          
end           
          
 Update AgentCurrentBalance set Balance=Balance+@Amount,@Balance=Balance+@Amount where IdAgent=@IdAgent        
        
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
'TRAN',        
@DateOfMovement,        
@Amount,        
@Reference,        
@Description,        
@Country,        
@Commission,  
@FxFee,         
'Debit',        
@Balance,        
@IdTransfer        
)

--EXEC st_GetAgentCreditApproval @IdAgent

 --Validar CurrentBalance
exec st_AgentVerifyCreditLimit @IdAgent


