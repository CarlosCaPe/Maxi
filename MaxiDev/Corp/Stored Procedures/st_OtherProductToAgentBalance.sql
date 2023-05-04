﻿CREATE PROCEDURE [Corp].[st_OtherProductToAgentBalance]        
(        
    @IdTransaction int,
    @IdOtherProduct int,
    @IdAgent int,
    @IsDebit bit,
    @Amount money,
    @Description nvarchar(max),
    @Country nvarchar(max),
    @Commission money,
    @AgentCommission money,
    @CorpCommission money,
    @FxFee money,
    @Fee money,
    @ProviderFee money    
)        
AS        
Set nocount on    
begin try    
Declare @DateOfMovement datetime,        
        @Reference int,
        @Balance money,
        @DebitOrCredit nvarchar (max),
        @TypeOfMovement nvarchar (max),
        @IdAgentBalance int,
        @IsMonthly bit
        
Set @Balance=0    


if (@IsDebit=1)    
begin
    set @DebitOrCredit='Debit'
end
else
begin
    set @DebitOrCredit='Credit'
    set @Amount=@Amount*(-1)
    set @AgentCommission=@AgentCommission*(-1)    
    set @CorpCommission=@CorpCommission*(-1)
    set @Commission=@Commission*(-1)
    set @Fee=@Fee*(-1)
    set @FxFee=@FxFee*(-1)
    set @ProviderFee=@ProviderFee*(-1)

end
        
If not Exists (Select 1 from AgentCurrentBalance with(nolock) where IdAgent=@IdAgent) 
begin          
  Insert into AgentCurrentBalance (IdAgent,Balance) values (@IdAgent,@Balance)          
end

set @DateOfMovement = getdate()
set @Reference=@IdTransaction

set @TypeOfMovement=dbo.fn_GetOtherProductTypeOfMovement(@IdOtherProduct,@IsDebit)

if isnull(@TypeOfMovement,'')=''
begin
    return
end

if isnull(@DebitOrCredit,'')=''
begin
    return
end

select @IsMonthly=case when IDAgentPaymentSchema=1 then 1 else 0 end from agent where idagent=@IdAgent

if @IsDebit=0
begin
    select top 1 @IsMonthly=IsMonthly from agentbalance where idagent=@IdAgent and idtransfer=@IdTransaction and TypeOfMovement=@TypeOfMovement order by idagentbalance desc
    set @IsMonthly=isnull(@IsMonthly,1)
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
    IdTransfer,
    IsMonthly        
)        
Values        
(        
    @IdAgent,        
    @TypeOfMovement,        
    @DateOfMovement,        
    abs(@Amount),
    @Reference,        
    isnull(@Description,''),
    isnull(@Country,''),
    @AgentCommission,  
    @FxFee,
    @DebitOrCredit,        
    @Balance,        
    @IdTransaction,
    @IsMonthly        
)

set @IdAgentBalance = SCOPE_IDENTITY() 

IF @IsMonthly=1
BEGIN
    insert into agentbalancedetail
    values
    (@IdAgentBalance,@Amount,@Amount-@Commission-@Fee,@Fee,@ProviderFee, @CorpCommission)    
END
ELSE
BEGIN
    IF @IdOtherProduct IN  (9,10,11,12,13,14,16)
    BEGIN
         insert into agentbalancedetail
    values
        (@IdAgentBalance,@Amount+@AgentCommission,@Amount+@AgentCommission-@Commission-@Fee,@Fee,@ProviderFee, @CorpCommission)
    END
	ELSE IF @IdOtherProduct = 17
		INSERT INTO [dbo].[AgentBalanceDetail] VALUES (@IdAgentBalance,@Amount,@Amount-@CorpCommission,@Fee,@ProviderFee, @CorpCommission)  
    ELSE
    BEGIN
        insert into agentbalancedetail
        values
        (@IdAgentBalance,@Amount,@Amount-@Commission-@Fee,@Fee,@ProviderFee, @CorpCommission)  
    END
END

--EXEC st_GetAgentCreditApproval @IdAgent

 --Validar CurrentBalance
exec [Corp].[st_AgentVerifyCreditLimit] @IdAgent

end try
begin catch
    Declare @ErrorMessage nvarchar(max)
    Select @ErrorMessage=ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_OtherProductToAgentBalance',Getdate(),@ErrorMessage)
end catch


