﻿CREATE Procedure [dbo].[st_CancelCreditToAgentBalance]                    
(                    
@IdTransfer int                    
)                    
AS                    
Set nocount on                    
Declare @IdAgent Int,                    
@DateOfMovement datetime,                    
@Amount Money,                    
@Reference int,                    
@Description nvarchar(max),                    
@Country nvarchar(max),                    
@Commission money,
@Commission2 money,                     
@Balance money,
@fxfee money            
                    
Set @Balance=0                    

/********************************************************************
<Author> ???</Author>
<app>Corporate </app>
<Description> ??? </Description>

<ChangeLog>
<log Date="21/11/2018" Author="esalazar - smacias"> Cambio en los campos de commission y fxFee ahora se toman de agent balance</log>
</ChangeLog>

*********************************************************************/
                    
Select                     
 @IdAgent=A.IdAgent,                    
 @DateOfMovement=GETDATE(),
 /**************/              
 @Amount=case
			when Ag.CancelReturnCommission=1 then TotalAmountToCorporate
			else case when A.TotalAmountToCorporate=AmountInDollars+Fee Then A.AmountInDollars Else  A.TotalAmountToCorporate-A.CorporateCommission End
		end,
 /**************/                    
 --@Amount = case when A.TotalAmountToCorporate=AmountInDollars+Fee Then A.AmountInDollars Else  A.TotalAmountToCorporate-A.CorporateCommission End ,                    
 @Reference=A.Folio,                    
 @Description=CustomerName+' '+CustomerFirstLastName,                    
 @Country=C.CountryCode,   
 /**************/
 @Commission= case
				when Ag.CancelReturnCommission=1 then (A.AgentCommission)*-1 
				else case when A.TotalAmountToCorporate=AmountInDollars+Fee Then (A.AgentCommission)*-1 Else    0 End  -- Just to see if it is Retain or Monthly     
			  end
 /**************/                 
 --@Commission= case when A.TotalAmountToCorporate=AmountInDollars+Fee Then (A.AgentCommission)*-1 Else    0 End  -- Just to see if it is Retain or Monthly            
 From [Transfer] A with(nolock) 
 /**************/
 inner join Agent Ag with(nolock) on Ag.IdAgent =A.IdAgent             
 /**************/                  
 Join CountryCurrency B with(nolock) on (A.IdCountryCurrency=B.IdCountryCurrency)                    
 Join Country C with(nolock) on (B.IdCountry=C.IdCountry)                    
 Where IdTransfer=@IdTransfer 

 

 select top 1 @Commission2= (Commission*-1), @fxfee= (FxFee*-1) from AgentBalance with(nolock) where IdTransfer=@IdTransfer order by DateOfMovement desc                 
                     
                    
--If Exists (Select 1 from AgentCurrentBalance where IdAgent=@IdAgent)                     
-- Select top 1 @Balance=Balance from AgentCurrentBalance where IdAgent=@IdAgent                    
--Else                    
-- Insert into AgentCurrentBalance (IdAgent,Balance) values (@IdAgent,@Balance)                    
                     
--Set @Balance=@Balance-@Amount                    
--Begin Transaction                    
-- Update AgentCurrentBalance set Balance=@Balance where IdAgent=@IdAgent                    
--Commit  

If not Exists (Select 1 from AgentCurrentBalance with(nolock) where IdAgent=@IdAgent) 
begin          
  Insert into AgentCurrentBalance (IdAgent,Balance) values (@IdAgent,@Balance)          
end           
          
 Update AgentCurrentBalance set Balance=Balance-@Amount,@Balance=Balance-@Amount where IdAgent=@IdAgent                   
                    
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
'CANC',                    
@DateOfMovement,                    
@Amount,                    
@Reference,                    
@Description,                    
@Country,                    
@Commission2,          
@fxfee,                    
'Credit',                    
@Balance,                    
@IdTransfer                    
) ;  

--Validar CurrentBalance
exec st_AgentVerifyCreditLimit @IdAgent ;      

/***********************/
if(exists(select 1 from agent with(nolock) where idAgent=@IdAgent and CancelReturnCommission=1))
Begin     
	if not exists(select 1 from  [TransferNotAllowedResend] with(nolock) where idTransfer=@IdTransfer)
	Begin
		INSERT INTO [dbo].[TransferNotAllowedResend]
			   ([IdTransfer]
			   ,[DateOfLastChange])
		 VALUES
			   (@IdTransfer
			   ,getDate());
	End
End  
Else
	Begin
	
	delete [TransferNotAllowedResend] where idTransfer =@IdTransfer;
	
	End
    /***********************/
        
        
If Exists(Select 1 from StateFee with(nolock) where IdTransfer=@IdTransfer)        
Begin        
 Declare @FeeNote nvarchar(max), @FeeReference nvarchar(max), @SateName nvarchar(max)        
 Declare @StateFeeHasError bit,@StateFeeMessage nvarchar(max), @StateTax money,@SystemUser int        
         
 Update StateFee set RejectedOrCancelled=1 where IdTransfer=@IdTransfer ;       
 Select @StateTax=Tax from StateFee with(nolock) where IdTransfer=@IdTransfer        
 Select top 1 @SateName=StateName  from ZipCode with(nolock) where StateCode=(Select AgentState from Agent with(nolock) Where IdAgent=@IdAgent )        
 --Select @FeeNote='Return '+@SateName+' State Fee, Folio:'+CONVERT(varchar(max),Folio), @FeeReference=CONVERT(varchar(max),Folio) From Transfer where IdTransfer=@IdTransfer                                        
 Select @FeeNote=+'Folio:'+CONVERT(varchar(max),Folio), @FeeReference=CONVERT(varchar(max),Folio) From [Transfer] with(nolock) where IdTransfer=@IdTransfer                                        
 Select @SystemUser=dbo.GetGlobalAttributeByName('SystemUserID')        
 Exec st_SaveOtherCharge 
        1,
        @IdAgent,
        @StateTax,
        0,
        @DateOfMovement,
        @FeeNote,
        @FeeReference,
        @SystemUser,
        @HasError=@StateFeeHasError Output,
        @Message=@StateFeeMessage Output,
        @IdOtherChargesMemo=2, --2	Oklahoma State Fee Return
        @OtherChargesMemoNote=null;       
End


