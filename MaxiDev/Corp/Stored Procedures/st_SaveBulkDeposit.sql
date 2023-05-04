CREATE PROCEDURE [Corp].[st_SaveBulkDeposit]      
    @deposits XML,                 
    @EnterByIdUser int,     
    @IgnoreWarning bit,     
    @IsSpanishLanguage bit, 
    @HasError bit out,
    @HasWarning bit out,                                
    @Message varchar(max) out            
as         
SET NOCOUNT ON;
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="29/09/2018" Author="jdarellano" Name="#1">Se agregan campos al insert de la tabla EmailCellularLog.</log>
</ChangeLog>
*********************************************************************/

set @HasWarning=0
set @HasError=0
set @Message =''

declare @DepositsTemp table
(
	id int identity(1,1),
	IdAgent int,
	DepositDate datetime,
	BankName varchar(max),
	Notes varchar(max),
	Amount MONEY,
    IdAgentCollectType INT
)
declare @Tempid int 
declare @id int 
declare @IdAgent int
declare @DepositDate datetime
declare @BankName varchar(max)
declare @Notes varchar(max)
declare @Amount money
declare @IdAgentBalance int
declare @Balance MONEY
DECLARE @IdAgentCollectType int

Begin Try 

	Declare @DocHandle int          
	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @deposits           
	   
	insert into @DepositsTemp (IdAgent , DepositDate , BankName , Notes ,  Amount,IdAgentCollectType)    
	SELECT IdAgent ,dbo.RemoveTimeFromDatetime(DepositDate) , BankName , Notes ,  Amount , IdAgentCollectType 
	FROM OPENXML (@DocHandle, 'root/deposit',2)  WITH (IdAgent int, DepositDate datetime, BankName varchar(max), Notes varchar(max),  Amount MONEY, IdAgentCollectType INT)
	EXEC sp_xml_removedocument @DocHandle          
	 
	--Check if exist a recored repeated 
	
	if(@IgnoreWarning=0)  
	Begin     
		declare @numberWarnings int
		set @numberWarnings=0
	
		set @Tempid= 1
		select top 1 @Id= Id, @IdAgent=IdAgent , @DepositDate=DepositDate , @BankName=BankName , @Notes=Notes ,  @Amount=Amount, @IdAgentCollectType=IdAgentCollectType
		from @DepositsTemp where id= @Tempid

		while (@Id is not null)
		Begin     
		      
			if exists(select 1 from AgentDeposit with(nolock) where IdAgent= @IdAgent and DepositDate=@DepositDate and BankName= @BankName
														and Amount= @Amount)
			--or exists(select 1 from @DepositsTemp where IdAgent= @IdAgent and DepositDate=@DepositDate and BankName= @BankName
			--											and Amount= @Amount and id!= @Id)
			Begin
				set @numberWarnings= @numberWarnings+1
				Set @HasWarning=1
				set @Message =	@Message+ case	
												when @Message='' then convert(varchar,@Id) 
												else ',' + convert(varchar,@Id)                                                          			
											end	
			End  
		      
			set @Tempid= @Tempid+1
			set @id= null 
			select top 1 @Id= Id, @IdAgent=IdAgent , @DepositDate=DepositDate , @BankName=BankName , @Notes=Notes ,  @Amount=Amount, @IdAgentCollectType=IdAgentCollectType
			from @DepositsTemp  where id= @Tempid  
		End      
		if(@HasWarning=1)
		Begin
			set @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,58)
					+ case	when @numberWarnings=1 then ' Row : ' else ' Rows: ' end 
					+@Message 
			
			return
		End 
		
	End
	--Insert if not exists record in   AgentCurrentBalance    
	Insert into AgentCurrentBalance (IdAgent,Balance)
	select distinct d.IdAgent,0
	from @DepositsTemp d 
		inner join Agent a with(nolock) on a.IdAgent= d.IdAgent
		where d.IdAgent not in( select IdAgent from AgentCurrentBalance with(nolock))

End Try                                
Begin Catch                                
	 Set @HasError=1                       
	 set @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,59)                                                          
	 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_SaveBulkDeposit]',Getdate(),ERROR_MESSAGE()  )                                
	 return
End Catch

Begin Try 
Begin transaction
	set @Tempid= 1
	select top 1 @Id= Id, @IdAgent=IdAgent , @DepositDate=DepositDate , @BankName=BankName , @Notes=Notes ,  @Amount=Amount, @IdAgentCollectType=IdAgentCollectType
	from @DepositsTemp where id= @Tempid

	while (@Id is not null)
	Begin
		
		/*S52 - Cambio de estado(status) de agencia - 20161214*/
		DECLARE @CollectDate DateTime = GETDATE();

		--select  @Id,  @IdAgent , @DepositDate , @BankName , @Notes ,  @Amount
	
		Update AgentCurrentBalance set Balance=Balance-@Amount, @Balance= Balance-@Amount where IdAgent=@IdAgent   
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
				when @Amount>0 then @Amount
				else @Amount*-1
			end,          
			'',          
			@BankName,          
			'',          
			0,
			0,          
			case
				when @Amount>0 then 'Credit'
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
			@Amount,        
			@DepositDate,        
			@Notes,        
			@CollectDate, --GETDATE(),  /* Fgonzalez: se le pone el collect date que va a validar en activar agentes */      
			@EnterByIdUser,
            ISNULL(@IdAgentCollectType,4)      
		)  		

         --Validar CurrentBalance
        exec [Corp].[st_AgentVerifyCreditLimit] @IdAgent

         --Notificacion de pago
        DECLARE @HasErrorNotification BIT
        DECLARE @MessageErrorNotification NVARCHAR(max)

        exec [Corp].[st_AgentNotificationPaymentThanks_msg]
		    @Idagent,
		    @HasErrorNotification OUTPUT,
		    @MessageErrorNotification OUTPUT


         --ajuste maxicollection
        declare @maxicollectiondate datetime
        set @maxicollectiondate = getdate()
        exec [Corp].[st_ApplyDepositMaxicollectionForWeekend] @idagent,@maxicollectiondate,@Amount  

        --Call history message
        declare @TodayDate datetime
        declare @TotalAmount money
        declare @TotalDeposit money
        declare @HError bit
        declare @HMessage nvarchar(max)
        declare @UserSystem int

        set @UserSystem=convert(int,[dbo].[GetGlobalAttributeByName]('SystemUserID'))

        set @TodayDate = [dbo].[RemoveTimeFromDatetime](getdate())

        select @TotalAmount=sum(amount) from maxicollection with(nolock) where idagent=@idagent and DateOfCollection=@TodayDate group by idagent

        select @TotalDeposit=sum(amount) from agentdeposit  with(nolock) where idagent=@idagent and [dbo].[RemoveTimeFromDatetime](DateOfLastChange)=@TodayDate group by idagent

        if round(@TotalDeposit,2)>=round(@TotalAmount,2)
        begin
        exec [Corp].[st_AddNoteToCallHistory]
            @idagent,
            @UserSystem,
            3,  --closed
            'Closed by System',
            @IsSpanishLanguage,
            @HError,
            @HMessage,
            0
        end

		/*S52 - Cambio de estado(status) de agencia*/
		--DECLARE @CollectDate DateTime = GETDATE();
		EXEC [Corp].[st_AgentStatusException] @CollectDate,@IdAgent,@Amount,@EnterByIdUser;
		/*-----------------------------------------*/

        --mandar correo
        Declare @recipients nvarchar (max)
        Declare @EmailProfile nvarchar(max)	 
        Declare @body nvarchar(max)
        Declare @Subject nvarchar(max) 
        Declare @AgentCode nvarchar(max)  =' '
        Declare @IdAgentStatus int
        Declare @AgentStatusName nvarchar(max)  =' '
        Declare @AgentName nvarchar(max)  =' '


        select @AgentCode=agentcode,@IdAgentStatus=a.IdAgentStatus,@AgentStatusName=upper(agentstatus),@AgentName=agentname from agent a  with(nolock)
        join agentstatus s  with(nolock) on a.IdAgentStatus=s.IdAgentStatus
        where idagent=@IdAgent

        if (@IdAgentStatus=3 or @IdAgentStatus=4 or @IdAgentStatus=7)
        Begin
            select @recipients = 'cob@maxi-ms.com'
            select @body = 'A payment of $ ' + convert(varchar,@Amount) + ' was received for Agent '+ isnull(@AgentCode,'') + ' ' + @AgentName +', the agent status is '+@AgentStatusName
            select @Subject = 'Agent ' + isnull(@AgentCode,'') + ', ' + @AgentStatusName + ', Deposited $ '+convert(varchar,@Amount)
	
            Select @EmailProfile=Value from GLOBALATTRIBUTES  with(nolock) where Name='EmailProfiler'    
	        --Insert into [Maxi_log].[dbo].EmailCellularLog values (@recipients,@body,@subject,GETDATE())  
			Insert into EmailCellularLog (Number, Body, Subject, DateOfMessage, IsSend, IsNegative,AgentCode) values (@recipients,@body,@subject,GETDATE(),0,0,' ') --#1
	        EXEC msdb.dbo.sp_send_dbmail                            
		        @profile_name=@EmailProfile,                                                       
		        @recipients = @recipients,                                                            
		        @body = @body,                                                             
		        @subject = @subject         
        End
        
        --Mandar correo balance negativo
        if (round(Isnull(@Balance,0),2)<0)
        begin
            select @recipients = 'cob@maxi-ms.com'
            --select @body = 'The current balance is $ ' + convert(varchar,@Balance) + ' for the Agent '+ isnull(@AgentCode,'') + ' ' + @AgentName +', the agent status is '+@AgentStatusName
            --select @Subject = 'QA Agent ' + isnull(@AgentCode,'') + ', ' + @AgentStatusName + ', Current Balance $ '+convert(varchar,@Balance)
            select @body = 'Agent '+isnull(@AgentCode,'')+', Balance: - $'+convert(varchar,round((-1)*@Balance,2),1)+' - Please review because it''s balance is N E G A T I V E !!!'            
            select @subject = 'Agent '+isnull(@AgentCode,'')+', Balance: - $'+convert(varchar,round((-1)*@Balance,2),1)+' - Please review because it''s balance is N E G A T I V E !!!'         
	
            Select @EmailProfile=Value from GLOBALATTRIBUTES with(nolock) where Name='EmailProfiler'    
	        --Insert into [Maxi_log].[dbo].EmailCellularLog values (@recipients,@body,@subject,GETDATE())  
			Insert into EmailCellularLog (Number, Body, Subject, DateOfMessage, IsSend, IsNegative,AgentCode) values (@recipients,@body,@subject,GETDATE(),0,1,' ') --#1
	        EXEC msdb.dbo.sp_send_dbmail                            
		        @profile_name=@EmailProfile,                                                       
		        @recipients = @recipients,                                                            
		        @body = @body,                                                             
		        @subject = @subject         
        end	

        set @Tempid= @Tempid+1
		set @id= null 
		select top 1 @Id= Id, @IdAgent=IdAgent , @DepositDate=DepositDate ,  @BankName=BankName, @Notes=Notes ,  @Amount=Amount, @IdAgentCollectType=IdAgentCollectType
		from @DepositsTemp  where id= @Tempid               

	End
	Set @HasError=0                       
	set @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,60) 
	commit
End Try                                
Begin Catch                                
	rollback
	Set @HasError=1                       
	set @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,59)                                                          
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_SaveBulkDeposit]',Getdate(),ERROR_MESSAGE()  )
End Catch





