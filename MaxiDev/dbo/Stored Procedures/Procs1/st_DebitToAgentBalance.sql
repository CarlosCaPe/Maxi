CREATE Procedure [dbo].[st_DebitToAgentBalance]        
(        
@IdTransfer int        
)        
AS        
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Declare @IdAgent Int,        
@DateOfMovement datetime,        
@Amount Money,        
@Reference int,        
@Description nvarchar(max),        
@Country nvarchar(max),        
@Commission money,        
@Balance money,  
@FxFee money        
        
Set @Balance=0        
        
Select         
 @IdAgent=IdAgent,        
 @DateOfMovement=GETDATE(),        
 @Amount=TotalAmountToCorporate,        
 @Reference=Folio,        
 @Description=CustomerName+' '+CustomerFirstLastName,        
 @Country=C.CountryCode,        
 @Commission=A.AgentCommissionExtra+A.AgentCommissionOriginal,    
 @FxFee=ModifierCommissionSlider+ModifierExchangeRateSlider  
 From [Transfer] A with(nolock)
 Join CountryCurrency B with(nolock) on (A.IdCountryCurrency=B.IdCountryCurrency)        
 Join Country C with(nolock) on (B.IdCountry=C.IdCountry)        
 Where IdTransfer=@IdTransfer        
         
--Begin Transaction        
--If Exists (Select 1 from AgentCurrentBalance where IdAgent=@IdAgent)         
-- Select @Balance=Balance from AgentCurrentBalance where IdAgent=@IdAgent        
--Else        
-- Insert into AgentCurrentBalance (IdAgent,Balance) values (@IdAgent,@Balance)        
         
--Set @Balance=@Balance+@Amount        
        
-- Update AgentCurrentBalance set Balance=@Balance where IdAgent=@IdAgent        
--Commit   

If not Exists (Select 1 from AgentCurrentBalance with(nolock) where IdAgent=@IdAgent) 
begin          
  Insert into AgentCurrentBalance (IdAgent,Balance) values (@IdAgent,@Balance);          
end           
          
 Update AgentCurrentBalance set Balance=Balance+@Amount,@Balance=Balance+@Amount where IdAgent=@IdAgent ;       
        
Insert into AgentBalance         
(        
IdAgent,        
TypeOfMovement,        
DateOfMovement,        
Amount,        
Reference,        
[Description],        
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
);

--EXEC st_GetAgentCreditApproval @IdAgent

 --Validar CurrentBalance
exec st_AgentVerifyCreditLimit @IdAgent;


