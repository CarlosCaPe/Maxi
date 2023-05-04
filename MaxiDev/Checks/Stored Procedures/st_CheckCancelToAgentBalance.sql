CREATE PROCEDURE [Checks].[st_CheckCancelToAgentBalance]
(
    @IdCheck int,
    @EnterByIdUser int,
    @IsReject bit = null
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

begin try   
    declare @Balance money = 0
    declare @Total money
    declare @Amount money
    declare @Fee money
    declare @NFS money
    declare @Name nvarchar(max)
    declare @IdAgent int
    declare @DebitCredit nvarchar(max)= 'Debit'
    declare @TypeOfMovement nvarchar(max)= 'CHRTN'
    declare @IdAgentBalance int
    declare @IdOtherChargesMemo int

set @IsReject=isnull(@IsReject,0)

 select 
    @Amount=Amount,
    @Fee=Fee,
    @Name=name+' '+FirstLastName+' '+replace(SecondLastName,'.',''),
    @IdAgent=IdAgent,
    @NFS=comission
from 
    Checks with(nolock) 
where 
    IdCheck=@IdCheck
  
 set @Total=(@Amount-@Fee)

if (@IdAgent is null)
return

If not Exists (Select 1 from AgentCurrentBalance with(nolock) where IdAgent=@IdAgent) 
begin          
  Insert into AgentCurrentBalance (IdAgent,Balance) values (@IdAgent,@Balance);          
end

Update AgentCurrentBalance set Balance=Balance+@Total,@Balance=Balance+@Total where IdAgent=@IdAgent;   
   
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
    IdTransfer,
    IsMonthly        
)        
Values        
(        
    @IdAgent,        
    @TypeOfMovement,        
    getdate(),        
    abs(@Total),
    @IdCheck,        
    isnull(@Name,''),
    '',
    0,  
    0,
    @DebitCredit,        
    @Balance,        
    @IdCheck,
    null        
);

set @IdAgentBalance = SCOPE_IDENTITY(); 

insert into agentbalancedetail
values
(@IdAgentBalance,@Amount*(-1),@Total*-(1),@Fee*(-1),0, 0);

if (@IsReject=1 and @NFS>0)
begin

    Update AgentCurrentBalance set Balance=Balance+@NFS,@Balance=Balance+@NFS where IdAgent=@IdAgent ;  

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
    'CHNFS',              
    DATEADD (second , 1 , GETDATE()),--GETDATE(),              
    @NFS,              
    @IdCheck,              
    isnull(@Name,''),              
    '',              
    0,
    0,              
    @DebitCredit,              
    @Balance,              
    @IdCheck              
    );              
            
    Select @IdAgentBalance=SCOPE_IDENTITY();   
    select @IdOtherChargesMemo=IdOtherChargesMemo from OtherChargesMemo where memo='4407-03 NSF Fee';

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
    OtherChargesMemoNote,
    IsReverse
    )            
    values            
    (            
    @IdAgent,            
    @IdAgentBalance,            
    @NFS,            
    getdate(),            
    'NFS Check: '+convert(nvarchar,@IdCheck),            
    GETDATE(),            
    @EnterByIdUser,
    @IdOtherChargesMemo,
    '',
    0
    );
	
	
	       
end

/* VERIFICAR CAMBIO PARA FUTURA ENTREGA */

--INSERT INTO [dbo].[AgentDeposit](
--				[IdAgent],
--				[IdAgentBalance],
--				[BankName],
--				[Amount],
--				[DepositDate],
--				[Notes],
--				[DateOfLastChange],
--				[EnterByIdUser],
--				[IdAgentCollectType],
--				[ReferenceNumber])
--			VALUES(        
--				@IdAgent,
--				@IdAgentBalance,
--				'Bank Check ' + CONVERT(NVARCHAR(MAX), @IdCheck),
--				ABS(@Total)*-1,
--				GETDATE(),
--				@Name,
--				GETDATE(),
--				@EnterByIdUser,
--				9, -- Check
--				NULL)

		--Validar CurrentBalance
        exec st_AgentVerifyCreditLimit @IdAgent

		--ajuste maxicollection
		DECLARE @maxicollectiondate DATETIME
		SET @maxicollectiondate = dbo.RemoveTimeFromDatetime(GETDATE() /*+ 5*/)
		declare @TotalForCollection money = @Total * -1
		EXEC [dbo].[st_ApplyDepositMaxicollectionForWeekend] @idagent, @maxicollectiondate, @TotalForCollection;

        --Mandar correo balance negativo

        Declare @recipients nvarchar (max)
        Declare @EmailProfile nvarchar(max)	 
        Declare @body nvarchar(max)
        Declare @Subject nvarchar(max) 
        Declare @AgentCode nvarchar(max)  =' '
        Declare @IdAgentStatus int
        Declare @AgentStatusName nvarchar(max)  =' '
        Declare @AgentName nvarchar(max)  =' '
        
        select @AgentCode=agentcode,@IdAgentStatus=a.IdAgentStatus,@AgentStatusName=upper(agentstatus),@AgentName=agentname from agent a with(nolock)
        join agentstatus s with(nolock) on a.IdAgentStatus=s.IdAgentStatus
        where idagent=@IdAgent

   --     if (round(Isnull(@Balance,0),2)<0)
   --     begin
            
			--DECLARE @Environment NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName]('Enviroment')
			--IF @Environment = 'Production'
			--	SET @recipients = 'cob@maxi-ms.com'
			--ELSE SET @recipients = ''

   --         select @body = 'Agent '+isnull(@AgentCode,'')+', Balance: - $'+convert(varchar,round((-1)*@Balance,2),1)+' - Please review because it''s balance is N E G A T I V E !!!'            
   --         select @subject = 'Agent '+isnull(@AgentCode,'')+', Balance: - $'+convert(varchar,round((-1)*@Balance,2),1)+' - Please review because it''s balance is N E G A T I V E !!!'            
	
   --         Select @EmailProfile=Value from GLOBALATTRIBUTES with(nolock) where Name='EmailProfiler'    
	  --      Insert into EmailCellularLog values (@recipients,@body,@subject,GETDATE())  
	  --      EXEC msdb.dbo.sp_send_dbmail                            
		 --       @profile_name=@EmailProfile,                                                       
		 --       @recipients = @recipients,                                                            
		 --       @body = @body,                                                             
		 --       @subject = @subject         
   --     end	       

end try
begin catch
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_OtherProductToAgentBalance',Getdate(),@ErrorMessage)                                                                                            
end catch

