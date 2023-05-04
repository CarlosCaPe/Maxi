--ejecutar en qa
CREATE PROCEDURE [dbo].[st_AgentStatusChange2] 
(
    @IdAgent int,
    @IdStatus int,
    @IdUser int,
    @Note nvarchar(max),
    @CreditAmount money = null
)
AS 
   if isnull(@CreditAmount,0)>0 
   begin        
        update agent set CreditAmount=@CreditAmount where idagent=@IdAgent
   end
   
   Declare @LastIdAgentStatus int,@NewIdAgentStatus int
   declare @AgentCode nvarchar(max)
   declare @AgentName nvarchar(max)
   declare @AgentPhone nvarchar(max)
   Declare @Balance Money      
   
   if not exists (select top 1 1 from agentcurrentbalance with(nolock) where IdAgent=@IdAgent)
   begin
	insert into agentcurrentbalance values (@IdAgent,0)
   end

   Select @LastIdAgentStatus=IdAgentStatus,@NewIdAgentStatus=@IdStatus,@AgentCode=Agentcode,@AgentName=Agentname,@Balance=balance,@AgentPhone=Agentphone 
   From dbo.Agent a  with(nolock)
   join agentcurrentbalance c with(nolock) on a.idagent=c.idagent
   WHERE a.IdAgent=@IdAgent   

   set @Balance=isnull(@Balance,0)
   set @AgentPhone=isnull(@AgentPhone,'')

   select @LastIdAgentStatus,@NewIdAgentStatus
   
   If @LastIdAgentStatus<>@NewIdAgentStatus
   Begin
	   
	   

       Insert into AgentStatusHistory (IdUser,IdAgent,IdAgentStatus,DateOfchange,Note) 
	   VALUES (@IdUser,@IdAgent,@NewIdAgentStatus,GETDATE(),@Note)

       UPDATE dbo.Agent SET IdAgentStatus=@NewIdAgentStatus WHERE IdAgent=@IdAgent
	   
	   Declare @body nvarchar(max)
	   Declare @Subject nvarchar(max)
	   Declare @DepositDate datetime
	   --Declare @IdAgent int
	   Declare @recipients nvarchar (max)
	   Declare @EmailProfile nvarchar(max)	  
	  
	   If @NewIdAgentStatus=1
	   Begin
		   --Select @IdAgent=IdAgent from inserted	
		   Select top 1 @DepositDate=DepositDate from AgentDeposit A where a.idagent=@IdAgent order by DepositDate desc
		   Select @body='The Agent '+@AgentCode+' has been Enabled. Last Deposit Date on '+isnull(CONVERT(varchar,@DepositDate,1),'No Deposit ever')
                  +'. The Agent balance is $'+convert(varchar,round(@Balance,2),1)+' USD. The Agent phone is '+@AgentPhone+'.'
		   Set @Subject='Agent '+@AgentCode+' '+@AgentName+' has been Enabled'
	   End

       --2	Disabled
       If @NewIdAgentStatus=2
	   Begin
		   --Select @IdAgent=IdAgent from inserted	
		   Select top 1 @DepositDate=DepositDate from AgentDeposit A where a.idagent=@IdAgent order by DepositDate desc
		   Select @body='The Agent '+@AgentCode+' has been Disabled, please pick up the equipment. Last Deposit Date on '+isnull(CONVERT(varchar,@DepositDate,1),'No Deposit ever')
                +'. The Agent balance is $'+convert(varchar,round(@Balance,2),1)+' USD. The Agent phone is '+@AgentPhone+'.'
		   Set @Subject='Agent '+@AgentCode+' '+@AgentName+' has been Disabled'
	   End

      --3	Suspended
	  If @NewIdAgentStatus=3
	   Begin
		   --Select @IdAgent=IdAgent from inserted	
		   Select top 1 @DepositDate=DepositDate from AgentDeposit A where a.idagent=@IdAgent order by DepositDate desc
		   Select @body='The Agent '+@AgentCode+' has been Suspended. Last Deposit Date on '+isnull(CONVERT(varchar,@DepositDate,1),'No Deposit ever')
                +'. The Agent balance is $'+convert(varchar,round(@Balance,2),1)+' USD. The Agent phone is '+@AgentPhone+'.'
		   Set @Subject='Agent '+@AgentCode+' '+@AgentName+' has been Suspended'
       End	
       
       --4	Hold
	  If @NewIdAgentStatus=4
	   Begin
		   --Select @IdAgent=IdAgent from inserted	
		   Select top 1 @DepositDate=DepositDate from AgentDeposit A where a.idagent=@IdAgent order by DepositDate desc
		   Select @body='The Agent '+@AgentCode+' has been put on Hold Status. Last Deposit Date on '+isnull(CONVERT(varchar,@DepositDate,1),'No Deposit ever')
                +'. The Agent balance is $'+convert(varchar,round(@Balance,2),1)+' USD. The Agent phone is '+@AgentPhone+'.'
		   Set @Subject='Agent '+@AgentCode+' '+@AgentName+' has been put on Hold'
       End 

       --5	Collections
       If @NewIdAgentStatus=5
	   Begin
		   --Select @IdAgent=IdAgent from inserted	
		   Select top 1 @DepositDate=DepositDate from AgentDeposit A where a.idagent=@IdAgent order by DepositDate desc
		   Select @body='The Agent '+@AgentCode+' has been put on Collections, please pick up the equipment. Last Deposit Date on '+isnull(CONVERT(varchar,@DepositDate,1),'No Deposit ever')
                +'. The Agent balance is $'+convert(varchar,round(@Balance,2),1)+' USD. The Agent phone is '+@AgentPhone+'.'
		   Set @Subject='Agent '+@AgentCode+' '+@AgentName+' has been put on Collections'
       End

         --6	WriteOff 
       If @NewIdAgentStatus=6
	   Begin
		   --Select @IdAgent=IdAgent from inserted	
		   Select top 1 @DepositDate=DepositDate from AgentDeposit A where a.idagent=@IdAgent order by DepositDate desc
		   Select @body='The Agent '+@AgentCode+' has been put on Write Off Status, please pick up the equipment. Last Deposit Date on '+isnull(CONVERT(varchar,@DepositDate,1),'No Deposit ever')
                +'. The Agent balance is $'+convert(varchar,round(@Balance,2),1)+' USD. The Agent phone is '+@AgentPhone+'.'
		   Set @Subject='Agent '+@AgentCode+' '+@AgentName+' has been put on Write Off'
       End

						Set @recipients=''      
						Select @recipients=C.Email from Agent A  with(nolock) Join Users B with(nolock) on (A.IdUserSeller=B.IdUser)  Join Seller C on (C.IdUserSeller=B.IdUser)   where A.Idagent=@IdAgent  

                       --Solo pruebas boz
                       --set @recipients='soportemaxi@boz.mx'

					    If @NewIdAgentStatus=6 or @NewIdAgentStatus=2 or @NewIdAgentStatus=5
						begin
							set @recipients=@recipients+';mmendoza@maxi-ms.com'
						end
		
	                   If @recipients is not Null and  @recipients<>'' 
						Begin
						    Select @EmailProfile=Value from GLOBALATTRIBUTES where Name='EmailProfiler'    
							Insert into EmailCellularLog values (@recipients,@body,@subject,GETDATE())  
							
							--FGONZALEZ 20161117
							DECLARE @ProcID VARCHAR(200)
							SET @ProcID =OBJECT_NAME(@@PROCID)

							EXEC sp_MailQueue 
							@Source   =  @ProcID,
							@To 	  =  @recipients,      
							@Subject  =  @subject,
							@Body  	  =  @body
							
	                        /*EXEC msdb.dbo.sp_send_dbmail                            
							 @profile_name=@EmailProfile,                                                       
							 @recipients = @recipients,                                                            
							 @body = @body,                                                             
							 @subject = @subject         
							*/
						End	 
							 
   End



