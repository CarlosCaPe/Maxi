CREATE PROCEDURE [dbo].[st_AgentStatusChange]
(
    @IdAgent int,
    @IdStatus int,
    @IdUser int,
    @Note nvarchar(max),
    @CreditAmount money = null
)

AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="23/01/2018" Author="jmolina">Add with(nolock)</log>
<log Date="27/06/2018" Author="snevarez">Add columns insert EmailCellularLog</log>
<log Date="09/10/2018" Author="jresendiz">Se agregó validación para no actualizar campo CloseDate al cambiar al Status Disabled</log>
<log Date="28/12/2021" Author="jcsierra">Se agrega el sp st_SetActiveTrainingCommunication para agregar los comunicados faltantes al agente al habilitar</log>
</ChangeLog>
********************************************************************/
begin try
declare @SystemUser int	

select @SystemUser=convert(int,[dbo].[GetGlobalAttributeByName]('SystemUserID'))

   if isnull(@CreditAmount,0)>0 
   begin
		if(ISNULL((select creditamount from dbo.agent WITH(nolock) where idagent = @IdAgent),0) != @CreditAmount)
			begin
				insert into dbo.creditlimithistory(IdAgent, CreditLimit, DateOfCreation, EnteredByIdUser) values (@IdAgent, @CreditAmount, GETDATE(),@IdUser)								
                update dbo.AgentCreditApproval set IsApproved=0 , DateOfLastChange=getdate() , EnterByIdUser=@SystemUser where idagent=@idAgent and IsApproved is null
                exec dbo.st_SaveAgentMirror @IdAgent 
                update dbo.agent set CreditAmount=@CreditAmount,dateoflastchange=getdate(),enterbyiduser=@IdUser,NoteCreditAmountChange = @Note where idagent=@IdAgent
			end     
   end
   
	DECLARE @LastIdAgentStatus int,@NewIdAgentStatus int
	DECLARE @AgentCode nvarchar(max)
	DECLARE @AgentName nvarchar(max)
	DECLARE @AgentPhone nvarchar(max)
	DECLARE @Balance Money
	DECLARE @Enviroment NVARCHAR(MAX)

	SET @Enviroment = [dbo].[GetGlobalAttributeByName]('Enviroment')
   
   if not exists (select 1 from dbo.agentcurrentbalance with(nolock) where IdAgent=@IdAgent)
   begin
	insert into dbo.agentcurrentbalance values (@IdAgent,0)
   end

   Select @LastIdAgentStatus=IdAgentStatus,@NewIdAgentStatus=@IdStatus,@AgentCode=Agentcode,@AgentName=Agentname,@Balance=balance,@AgentPhone=Agentphone 
   From dbo.Agent a with(nolock)
   join dbo.agentcurrentbalance c with(nolock) on a.idagent=c.idagent
   WHERE a.IdAgent=@IdAgent   

   set @Balance=isnull(@Balance,0)
   set @AgentPhone=isnull(@AgentPhone,'')

   --select @LastIdAgentStatus,@NewIdAgentStatus

    Declare @body nvarchar(max)
	   Declare @Subject nvarchar(max)
	   Declare @DepositDate datetime
	   --Declare @IdAgent int
	   Declare @recipients nvarchar (max)
	   Declare @EmailProfile nvarchar(max)	  
	  
   
   If @LastIdAgentStatus<>@NewIdAgentStatus
   Begin
	   --select 1  
--	   IF ((@LastIdAgentStatus <> 3 AND @NewIdAgentStatus = 3) OR (@LastIdAgentStatus = 3 AND @NewIdAgentStatus <> 3))
--	   BEGIN
--	   		THROW 50001, 'Suspend error', 1
--	   		--RETURN; 
--	   END
	   
	       
       exec dbo.st_SaveAgentMirror @IdAgent 

	   /* JFPACO 20181009
		SE AGREGÓ VALIDACIÓN PARA QUE NO SE CAMBIE LA FECHA DE CIERRE AL CAMBIAR DE WRITEOFF/COLLECTIONS A DISABLED
	   */
	   If @NewIdAgentStatus IN (2,5,6) and @LastIdAgentStatus IN (2,5,6)
	   begin
		   UPDATE dbo.Agent SET SuspendedDatePendingFile = null, IdAgentStatus=@NewIdAgentStatus, 
		   enterbyiduser=@IdUser,DateOfLastChange=getdate() 
		   WHERE IdAgent=@IdAgent --and closedate!='1900-01-01 00:00:00.000'
	   end 
	   else
	   begin 
		/*
			ESTE FRAGMENTO ERA EL ORIGINAL
		*/
			UPDATE dbo.Agent SET SuspendedDatePendingFile = null, IdAgentStatus=@NewIdAgentStatus,closedate=
		    case when @NewIdAgentStatus in (2,5,6) then getdate() else '1900-01-01 00:00:00.000' end, 
		    enterbyiduser=@IdUser,DateOfLastChange=getdate() 
		    WHERE IdAgent=@IdAgent --and closedate!='1900-01-01 00:00:00.000'
	   end  
	       

	   Insert into dbo.AgentStatusHistory (IdUser,IdAgent,IdAgentStatus,DateOfchange,Note) 
	   VALUES (@IdUser,@IdAgent,@NewIdAgentStatus,GETDATE(),@Note)
	   
	  
	   If @NewIdAgentStatus=1
	   Begin
		   --Select @IdAgent=IdAgent from inserted	
		   Select top 1 @DepositDate=DepositDate from dbo.AgentDeposit AS A WITH(nolock) where a.idagent=@IdAgent order by DepositDate desc
		   Select @body='The Agent '+@AgentCode+' has been Enabled. Last Deposit Date on '+isnull(CONVERT(varchar,@DepositDate,1),'No Deposit ever')
                  +'. The Agent balance is $'+convert(varchar,round(@Balance,2),1)+' USD. The Agent phone is '+@AgentPhone+'.'
		   Set @Subject='Agent '+@AgentCode+' '+@AgentName+' has been Enabled'
	   End

       --2	Disabled
       If @NewIdAgentStatus=2
	   Begin
		   --Select @IdAgent=IdAgent from inserted	
		   Select top 1 @DepositDate=DepositDate from dbo.AgentDeposit AS A WITH(nolock)where a.idagent=@IdAgent order by DepositDate desc
		   Select @body='The Agent '+@AgentCode+' has been Disabled, please pick up the equipment. Last Deposit Date on '+isnull(CONVERT(varchar,@DepositDate,1),'No Deposit ever')
                +'. The Agent balance is $'+convert(varchar,round(@Balance,2),1)+' USD. The Agent phone is '+@AgentPhone+'.'
		   Set @Subject='Agent '+@AgentCode+' '+@AgentName+' has been Disabled'
	   End

      --3	Suspended
	  If @NewIdAgentStatus=3
	   Begin
		   --Select @IdAgent=IdAgent from inserted	
		   Select top 1 @DepositDate=DepositDate from dbo.AgentDeposit AS A WITH(nolock) where a.idagent=@IdAgent order by DepositDate desc
		   Select @body='The Agent '+@AgentCode+' has been Suspended. Last Deposit Date on '+isnull(CONVERT(varchar,@DepositDate,1),'No Deposit ever')
                +'. The Agent balance is $'+convert(varchar,round(@Balance,2),1)+' USD. The Agent phone is '+@AgentPhone+'.'
		   Set @Subject='Agent '+@AgentCode+' '+@AgentName+' has been Suspended'
       End	
       
       --4	Hold
	  If @NewIdAgentStatus=4
	   Begin
		   --Select @IdAgent=IdAgent from inserted	
		   Select top 1 @DepositDate=DepositDate from dbo.AgentDeposit AS A WITH(nolock) where a.idagent=@IdAgent order by DepositDate desc
		   Select @body='The Agent '+@AgentCode+' has been put on Hold Status. Last Deposit Date on '+isnull(CONVERT(varchar,@DepositDate,1),'No Deposit ever')
                +'. The Agent balance is $'+convert(varchar,round(@Balance,2),1)+' USD. The Agent phone is '+@AgentPhone+'.'
		   Set @Subject='Agent '+@AgentCode+' '+@AgentName+' has been put on Hold'
       End 

       --5	Collections
       If @NewIdAgentStatus=5
	   Begin
		   --Select @IdAgent=IdAgent from inserted	
		   Select top 1 @DepositDate=DepositDate from dbo.AgentDeposit AS A WITH(nolock) where a.idagent=@IdAgent order by DepositDate desc
		   Select @body='The Agent '+@AgentCode+' has been put on Collections, please pick up the equipment. Last Deposit Date on '+isnull(CONVERT(varchar,@DepositDate,1),'No Deposit ever')
                +'. The Agent balance is $'+convert(varchar,round(@Balance,2),1)+' USD. The Agent phone is '+@AgentPhone+'.'
		   Set @Subject='Agent '+@AgentCode+' '+@AgentName+' has been put on Collections'
       End

         --6	WriteOff 
       If @NewIdAgentStatus=6
	   Begin
		   --Select @IdAgent=IdAgent from inserted	
		   Select top 1 @DepositDate=DepositDate from dbo.AgentDeposit AS A WITH(nolock) where a.idagent=@IdAgent order by DepositDate desc
		   Select @body='The Agent '+@AgentCode+' has been put on Write Off Status, please pick up the equipment. Last Deposit Date on '+isnull(CONVERT(varchar,@DepositDate,1),'No Deposit ever')
                +'. The Agent balance is $'+convert(varchar,round(@Balance,2),1)+' USD. The Agent phone is '+@AgentPhone+'.'
		   Set @Subject='Agent '+@AgentCode+' '+@AgentName+' has been put on Write Off'
       End

       If @NewIdAgentStatus=7
	   Begin
		   --Select @IdAgent=IdAgent from inserted	
		   Select top 1 @DepositDate=DepositDate from dbo.AgentDeposit As A WITH(nolock) where a.idagent=@IdAgent order by DepositDate desc
		   Select @body='The Agent '+@AgentCode+' put on Inactive Status. Last Deposit Date on '+isnull(CONVERT(varchar,@DepositDate,1),'No Deposit ever')
                +'. The Agent balance is $'+convert(varchar,round(@Balance,2),1)+' USD. The Agent phone is '+@AgentPhone+'.'
		   Set @Subject='Agent '+@AgentCode+' '+@AgentName+' has been put on Inactive'
       End	

						SET @recipients = ''
						
						IF @Enviroment = 'Production'
						BEGIN

							SELECT @recipients=C.[Email]
							FROM [dbo].[Agent] A WITH (NOLOCK)
							JOIN [dbo].[Users] B WITH (NOLOCK) ON A.[IdUserSeller] = B.[IdUser]
							JOIN [dbo].[Seller] C WITH (NOLOCK) ON C.[IdUserSeller]=B.[IdUser]
							WHERE A.Idagent=@IdAgent  

							IF @NewIdAgentStatus IN (2,5,6,7)
								SET @recipients = @recipients + ';pendingequipment@maxi-ms.com'
						END
						ELSE
						BEGIN
							SET @recipients='soportemaxi@boz.mx'

							IF @NewIdAgentStatus=6 OR @NewIdAgentStatus=2 OR @NewIdAgentStatus=5
								set @recipients = @recipients + ';mmendoza@maxi-ms.com'
						END
                       
		begin try
	                   If @recipients is not Null and  @recipients<>'' 
						Begin
						    Select @EmailProfile=Value from dbo.GLOBALATTRIBUTES WITH(nolock) where Name='EmailProfiler'    
							Insert into EmailCellularLog (Number,Body,[Subject],[DateOfMessage]) values (@recipients,@body,@subject,GETDATE())
							
							--Fgonzalez 20161117
							DECLARE @ProcID VARCHAR(200)
							SET @ProcID =OBJECT_NAME(@@PROCID)

							EXEC dbo.sp_MailQueue 
							@Source   =  @ProcID,
							@To 	  =  @recipients,      
							@Subject  =  @subject,
							@Body  	  =  @body
							
							
							/*
	                        EXEC msdb.dbo.sp_send_dbmail                            
							 @profile_name=@EmailProfile,                                                       
							 @recipients = @recipients,                                                            
							 @body = @body,                                                             
							 @subject = @subject  
							*/							 
						End	 
		end try
		begin catch
			--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AgentStatusChange revision',Getdate(),'@profile_name='+@EmailProfile+',@recipients='+@recipients+',@body='+@body+'@subject='+@subject)  
			Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AgentStatusChange',Getdate(),ERROR_MESSAGE())  
		end catch

		IF (@IdStatus = 1)
			EXEC st_SetActiveTrainingCommunication @IdAgent, @IdUser				 
   End
End Try                                                                                            
begin CATCH	
	
 	Declare @ErrorMessage nvarchar(max)                                                                                             
 	Select @ErrorMessage=ERROR_MESSAGE()                                             
 	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AgentStatusChange',Getdate(),@ErrorMessage)                                                                                            
End Catch  


--The module 'st_AgentStatusChange' depends on the missing object 'st_SaveAgentMirror'. The module will still be created; however, it cannot run successfully until the object exists.
--The module 'st_AgentStatusChange' depends on the missing object 'st_SaveAgentMirror'. The module will still be created; however, it cannot run successfully until the object exists.
--The module 'st_AgentStatusChange' depends on the missing object 'sp_MailQueue'. The module will still be created; however, it cannot run successfully until the object exists.





