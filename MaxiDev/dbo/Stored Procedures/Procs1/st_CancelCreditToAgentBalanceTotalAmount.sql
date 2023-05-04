CREATE Procedure [dbo].[st_CancelCreditToAgentBalanceTotalAmount]              
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
 @IdAgent=IdAgent,              
 @DateOfMovement=GETDATE(),              
 @Amount=TotalAmountToCorporate,              
 @Reference=Folio,              
 @Description=CustomerName+' '+CustomerFirstLastName,              
 @Country=C.CountryCode,              
 @Commission=(A.AgentCommission)*-1            
 From [Transfer] A WITH(NOLOCK)
 INNER Join CountryCurrency B WITH(NOLOCK) on (A.IdCountryCurrency=B.IdCountryCurrency)              
 INNER Join Country C WITH(NOLOCK) on (B.IdCountry=C.IdCountry)              
 Where IdTransfer=@IdTransfer              

 select top 1 @Commission= (Commission*-1), @fxfee= (FxFee*-1) from AgentBalance WITH(NOLOCK) where IdTransfer=@IdTransfer order by DateOfMovement desc                 
                     
--Begin Transaction              
--If Exists (Select 1 from AgentCurrentBalance where IdAgent=@IdAgent)               
-- Select top 1 @Balance=Balance from AgentCurrentBalance where IdAgent=@IdAgent              
--Else              
-- Insert into AgentCurrentBalance (IdAgent,Balance) values (@IdAgent,@Balance)              
               
--Set @Balance=@Balance-@Amount              
              
-- Update AgentCurrentBalance set Balance=@Balance where IdAgent=@IdAgent              
--Commit
         
If not Exists (Select 1 from AgentCurrentBalance with(nolock) where IdAgent=@IdAgent) 
begin          
  Insert into AgentCurrentBalance (IdAgent,Balance) values (@IdAgent,@Balance) ;         
end           
          
 Update AgentCurrentBalance set Balance=Balance-@Amount,@Balance=Balance-@Amount where IdAgent=@IdAgent;          
             
              
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
@Commission,    
@fxfee,              
'Credit',              
@Balance,              
@IdTransfer              
);

 --Validar CurrentBalance
exec st_AgentVerifyCreditLimit @IdAgent    


if not exists(select 1 from dbo.TransferNotAllowedResend with(nolock) where IdTransfer=@IdTransfer)
begin
    insert into [dbo].[TransferNotAllowedResend]
        values
    (@IdTransfer,getdate());
end
  
If Exists(Select 1 from StateFee with(nolock) where IdTransfer=@IdTransfer)  
Begin  
 Declare @FeeNote nvarchar(max), @FeeReference nvarchar(max), @SateName nvarchar(max)  
 Declare @StateFeeHasError bit,@StateFeeMessage nvarchar(max), @StateTax money,@SystemUser int  
 Update StateFee set RejectedOrCancelled=1 where IdTransfer=@IdTransfer;  
 Select @StateTax=Tax from StateFee with(nolock) where IdTransfer=@IdTransfer  
 Select top 1 @SateName=StateName  from ZipCode with(nolock) where StateCode=(Select AgentState from Agent with(nolock) Where IdAgent=@IdAgent )  
 --Select @FeeNote='Return '+@SateName+' State Fee, Folio:'+CONVERT(varchar(max),Folio), @FeeReference=CONVERT(varchar(max),Folio) From Transfer where IdTransfer=@IdTransfer                                  
 Select @FeeNote='Folio:'+CONVERT(varchar(max),Folio), @FeeReference=CONVERT(varchar(max),Folio) From [Transfer] with(nolock) where IdTransfer=@IdTransfer                                  
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
    @Message=@StateFeeMessage  output,
    @IdOtherChargesMemo=2, --2	Oklahoma State Fee Return
    @OtherChargesMemoNote=null  ;     
End


