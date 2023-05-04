
CREATE PROCEDURE [dbo].[st_ApplyReconcilePayments]
(
    @DataXml XML,
    @IdAgent INT,
	@IdUser INT,
    --@ApplyDate datetime,
	@Force bit,
    @IsSpanishLanguage bit,
	@HasSimilarDeposits bit out,
    @HasError bit out,
    @Message varchar(max) out   
)

AS

DECLARE @DocHandle INT 
DECLARE @TotalDepositsToInsert INT
DECLARE @SearchDays INT
DECLARE @BeginDate DATETIME
--DECLARE @DefaultBankName NVARCHAR(max)

Create Table #DepositsToInsert
(
	Id int identity(1,1),
	Amount Money,
	DepositDate DateTime,
    Note nvarchar(max),
    BankName NVarChar(max)
)

Create Table #SimilarDeposits
(
	DepositDate DateTime,
	ApplyDate DateTime,
	Note NVarChar(max),    
	[User] NVarChar(max),
	AgentCollectType NVarChar(max),
    Amount money
)

--Inicializacion de variables
SET @HasError = 0
SET @HasSimilarDeposits = 0
SET @Message='Reconcile payment was applied successfully'

Begin try

--SELECT @DefaultBankName=BankName FROM dbo.AgentBankDeposit WHERE IdAgentBankDeposit=CONVERT(INT,dbo.GetGlobalAttributeByName('DefaultBankEncodeDeposit'))
SELECT @SearchDays = CONVERT(INT,dbo.GetGlobalAttributeByName('DaysforSearchDeposit'))


EXEC sp_xml_preparedocument @DocHandle OUTPUT,@DataXml   

INSERT INTO #DepositsToInsert (Amount, DepositDate,Note,BankName)
SELECT Amount,  dbo.RemoveTimeFromDatetime(DepositDate), Note , BankName
FROM OPENXML (@DocHandle, '/ReconcilePayments/ReconcilePayment',2)
With (
		Amount Money,
		DepositDate DateTime,
        Note nvarchar(max),
        BankName nvarchar(max)
	)

EXEC sp_xml_removedocument @DocHandle 

If(@Force<>1)
Begin
	Select @TotalDepositsToInsert = count(Id) from #DepositsToInsert

	DECLARE @TempAmount Money
	DECLARE @TempDepositDate DateTime
	DECLARE @i INT
    DECLARE @IdAgentBalance INT
    DECLARE @Balance money
    Declare @note nvarchar(max)
    Declare @BankName nvarchar(max)
	SET @i= 1

	While (@i<= @TotalDepositsToInsert)
	Begin
		Select	@TempAmount = Amount,
				@TempDepositDate = DepositDate,
                @BankName = BankName
		From #DepositsToInsert
		Where Id= @i				 

        set @BeginDate=@TempDepositDate-@SearchDays

        if (isnull(@BankName,'')='')
        begin
            select @BankName = BankName from agentbankdeposit where IdAgentBankDeposit in(
            select IdAgentBankDeposit from agent where idagent=@IdAgent)
        end

		Insert Into #SimilarDeposits
		SELECT DepositDate,d.DateOfLastChange ApplyDate,Notes Note,u.UserLogin [User],c.NAME AgentCollectType, Amount
		FROM dbo.AgentDeposit d
		JOIN AgentCollectType c ON d.IdAgentCollectType =c.IdAgentCollectType
		JOIN dbo.Users u ON d.EnterByIdUser=u.IdUser
		WHERE 
			IdAgent=@IdAgent AND
			Amount=@TempAmount AND
			BankName like '%'+@BankName+'%' AND 
			dbo.RemoveTimeFromDatetime(DepositDate)>=@BeginDate AND dbo.RemoveTimeFromDatetime(DepositDate)<=@TempDepositDate

		Set @i = @i+1
	End
End


--Regresar si existen depositos similares
If exists(Select top 1 1 from #SimilarDeposits)
Begin
	set @HasSimilarDeposits = 1
	set @HasError = 0
	set @Message = 'There are similar deposits'

	Select DepositDate,Amount, ApplyDate, Note, [User], AgentCollectType
	From #SimilarDeposits

	Return
End

--Insert if not exists record in   AgentCurrentBalance    
Insert into AgentCurrentBalance (IdAgent,Balance)
select @IdAgent,0 where @IdAgent not in( select IdAgent from AgentCurrentBalance  with(nolock))

end try

BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @Message = 'Error in Reconcile Deposits'
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ApplyReconcilePayments',Getdate(),@ErrorMessage)    
END CATCH


--Aplicar depositos
Begin Try 
Begin transaction	
	

	while exists (select top 1 1 from #DepositsToInsert)
	Begin
		

        select top 1 @i= Id, @TempAmount=Amount,@TempDepositDate=DepositDate,@Note=note,  @BankName = BankName
	    from #DepositsToInsert 

        if (isnull(@BankName,'')='')
        begin
            select @BankName = BankName from agentbankdeposit where IdAgentBankDeposit in(
            select IdAgentBankDeposit from agent where idagent=@IdAgent)
        end
		
	
		Update AgentCurrentBalance set Balance=Balance-@TempAmount, @Balance= Balance-@TempAmount where IdAgent=@IdAgent   

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
			'DEP',          
			GETDATE(),          
			case
				when @TempAmount>0 then @TempAmount
				else @TempAmount*-1
			end,          
			'',          
			@BankName,          
			'',          
			0,
			0,          
			case
				when @TempAmount>0 then 'Credit'
				else 'Debit' 
			end,          
			@Balance,          
			0          
		) 		

		set @IdAgentBalance = SCOPE_IDENTITY()			      
		
        Insert into AgentDeposit        
		(        
			IdAgent,        
			IdAgentBalance,        
			BankName,        
			Amount,        
			DepositDate,        
			Notes,        
			DateOfLastChange,        
			EnterByIdUser,
            IdAgentCollectType        
		)        
		values        
		(        
			@IdAgent,        
			@IdAgentBalance,        
			@BankName,        
			@TempAmount,        
			@TempDepositDate,        
			@Note,--'Apply by Reconcile Payments',
			GETDATE(),        
			@IdUser,
            4 -- No Codified Deposit   
		)  

        --Validar CurrentBalance
        exec st_AgentVerifyCreditLimit @IdAgent
		
         --Notificacion de pago
        DECLARE @HasErrorNotification BIT
        DECLARE @MessageErrorNotification NVARCHAR(max)

        exec [msg].[st_AgentNotificationPaymentThanks]
		    @Idagent,
		    @HasErrorNotification OUTPUT,
		    @MessageErrorNotification OUTPUT

        delete from #DepositsToInsert  where id=@i

        --ajuste maxicollection
        declare @maxicollectiondate datetime
        set @maxicollectiondate = getdate()
        exec st_ApplyDepositMaxicollectionForWeekend @idagent,@maxicollectiondate,@TempAmount

		--Call history message
		declare @TodayDate datetime
		declare @TotalAmount money
		declare @TotalDeposit money
		declare @HError bit
		declare @HMessage nvarchar(max)
		declare @UserSystem int

		set @UserSystem=convert(int,[dbo].[GetGlobalAttributeByName]('SystemUserID'))

		set @TodayDate = [dbo].[RemoveTimeFromDatetime](getdate())

		select @TotalAmount=sum(amount) from maxicollection where idagent=@idagent and DateOfCollection=@TodayDate group by idagent

		select @TotalDeposit=sum(amount) from agentdeposit where idagent=@idagent and [dbo].[RemoveTimeFromDatetime](DateOfLastChange)=@TodayDate group by idagent

		if round(@TotalDeposit,2)>=round(@TotalAmount,2)
		begin
			exec [st_AddNoteToCallHistory]
				@idagent,
				@UserSystem,
				3,  --closed
				'Closed by System',
				@IsSpanishLanguage,
				@HError,
				@HMessage,
				0
		end

        --mandar correo
        Declare @recipients nvarchar (max)
        Declare @EmailProfile nvarchar(max)	 
        Declare @body nvarchar(max)
        Declare @Subject nvarchar(max) 
        Declare @AgentCode nvarchar(max)  =' '
        Declare @IdAgentStatus int
        Declare @AgentStatusName nvarchar(max)  =' '
        Declare @AgentName nvarchar(max)  =' '


        select @AgentCode=agentcode,@IdAgentStatus=a.IdAgentStatus,@AgentStatusName=upper(agentstatus),@AgentName=agentname from agent a
        join agentstatus s on a.IdAgentStatus=s.IdAgentStatus
        where idagent=@IdAgent

        if (@IdAgentStatus=3 or @IdAgentStatus=4 or @IdAgentStatus=7)
        Begin
            select @recipients = 'cob@maxi-ms.com'
           
            select @body = 'A payment of $ ' + convert(varchar,@TempAmount) + ' was received for Agent '+ isnull(@AgentCode,'') + ' ' + @AgentName +', the agent status is '+@AgentStatusName
            select @Subject = 'Agent ' + isnull(@AgentCode,'') + ', ' + @AgentStatusName + ', Deposited $ '+convert(varchar,@TempAmount)
	
            Select @EmailProfile=Value from GLOBALATTRIBUTES where Name='EmailProfiler'    
	        Insert into EmailCellularLog values (@recipients,@body,@subject,GETDATE())  
	        EXEC msdb.dbo.sp_send_dbmail                            
		        @profile_name=@EmailProfile,                                                       
		        @recipients = @recipients,                                                            
		        @body = @body,                                                             
		        @subject = @subject         
        End	

        --Mandar correo balance negativo
        if (round(@Balance,2)<0)
        begin
            select @recipients = 'cob@maxi-ms.com; mmendoza@maxi-ms.com'
         
            select @body = 'The current balance is $ ' + convert(varchar,@Balance) + ' for the Agent '+ isnull(@AgentCode,'') + ' ' + @AgentName +', the agent status is '+@AgentStatusName
            select @Subject = 'Agent ' + isnull(@AgentCode,'') + ', ' + @AgentStatusName + ', Current Balance $ '+convert(varchar,@Balance)
	
            Select @EmailProfile=Value from GLOBALATTRIBUTES where Name='EmailProfiler'    
	        Insert into EmailCellularLog values (@recipients,@body,@subject,GETDATE())  
	        EXEC msdb.dbo.sp_send_dbmail                            
		        @profile_name=@EmailProfile,                                                       
		        @recipients = @recipients,                                                            
		        @body = @body,                                                             
		        @subject = @subject         
        end

	End
	--Set @HasError=0                       
	--set @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,60) 
	commit
End Try                                
Begin Catch                                
 rollback
 Set @HasError=1                                                                                   
 Select @Message = 'Error in Reconcile Deposits' 
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ApplyReconcilePayments',Getdate(),@ErrorMessage)    
End Catch


