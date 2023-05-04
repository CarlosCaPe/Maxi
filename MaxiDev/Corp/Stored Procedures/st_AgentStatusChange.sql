CREATE PROCEDURE [Corp].[st_AgentStatusChange]
(
    @IdAgent 				int,
    @IdStatus 				int,
    @IdUser 				int,
    @Note 					nvarchar(max),
    @CreditAmount 			money = NULL,
    @IsSuspCompliance		BIT = 0,
	@IsSuspAMLTraining		BIT = 0,
	@IsSuspAccReceivable	BIT = 0,
	@IsSuspFraudMonitor		BIT = 0,
	@IsSuspAgentAdmin		BIT = 0,
	@IsSuspCFPBTraining		BIT = 0,
	@IsSuspPhoneSalesFraud	BIT = 0
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
<log Date="11/01/2021" Author="cagarcia">Se agrega validacion para no actualizar campo CloseDate al cambiar entre Status Collection, Write Off y Disabled</log>
<log Date="28/12/2021" Author="jcsierra">Se agrega el sp st_SetActiveTrainingCommunication para agregar los comunicados faltantes al agente al habilitar</log>
<log Date="17/04/2023" Author="jfresendiz">BM-1670 Se agrega suspensión por entrenamiento CFPB</log>
<log Date="17/04/2023" Author="jfresendiz">BM-1724 Se agrega suspensión por fraude en ventas telefónicas</log>
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
                exec [Corp].[st_SaveAgentMirror] @IdAgent 
                update dbo.agent set CreditAmount=@CreditAmount,dateoflastchange=getdate(),enterbyiduser=@IdUser,NoteCreditAmountChange = @Note where idagent=@IdAgent
			end     
   end
   
	DECLARE @LastIdAgentStatus INT,@NewIdAgentStatus INT
	DECLARE @AgentCode nvarchar(max)
	DECLARE @AgentName nvarchar(max)
	DECLARE @AgentPhone nvarchar(max)
	DECLARE @Balance Money
	DECLARE @Enviroment NVARCHAR(MAX)
	
	DECLARE @MailSuspMsg NVARCHAR(MAX)
	DECLARE @IsSuspended BIT = 0
	DECLARE @IsReleased BIT = 0
	DECLARE @StillReleasedBy NVARCHAR(max)
	

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
	  
   
   If @LastIdAgentStatus <> @NewIdAgentStatus OR (@NewIdAgentStatus = 3 AND @LastIdAgentStatus = 3)
   Begin
	   --select 1      
       exec [Corp].[st_SaveAgentMirror] @IdAgent 

	   /* CAGARCIA 20210111
		SE AGREGÓ VALIDACIÓN PARA QUE NO SE CAMBIE LA FECHA DE CIERRE AL CAMBIAR ENTRE LOS STATUS: COLLECTIONS, WRITE OFF Y DISABLED
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
	   
	   
	   /*CAGARCIA 2021-05-11*/
	   --Insertar subestatus suspended
	   IF @NewIdAgentStatus = 3 OR (@LastIdAgentStatus = 3 AND @IsSuspCompliance = 0 AND @IsSuspAMLTraining = 0 AND @IsSuspAccReceivable = 0 AND 
	   								@IsSuspFraudMonitor = 0 AND @IsSuspAgentAdmin = 0 AND @IsSuspCFPBTraining = 0 AND @IsSuspPhoneSalesFraud = 0)
	   BEGIN 
	   		  
	   		DECLARE @SuspComplianceCurrent BIT, @SuspAMLTrainingCurrent BIT, @SuspAccRecCurrent BIT, @SuspFraudMonitorCurrent BIT, @SuspAgentAdminCurrent BIT, @SuspCFPBTrainingCurrent BIT, @SuspPhoneSalesFraudCurrent BIT
	   		
	   		SELECT @SuspComplianceCurrent = isnull(Suspended, 0) FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 1
			SELECT @SuspAMLTrainingCurrent = isnull(Suspended, 0) FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 2
			SELECT @SuspAccRecCurrent = isnull(Suspended, 0) FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 3
			SELECT @SuspFraudMonitorCurrent = isnull(Suspended, 0) FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 4
			SELECT @SuspAgentAdminCurrent = isnull(Suspended, 0) FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 5  
			SELECT @SuspCFPBTrainingCurrent = isnull(Suspended, 0) FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 6
			SELECT @SuspPhoneSalesFraudCurrent = isnull(Suspended, 0) FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 7
			
			SET @SuspComplianceCurrent = isnull(@SuspComplianceCurrent, 0)
			SET @SuspAMLTrainingCurrent = isnull(@SuspAMLTrainingCurrent, 0)
			SET @SuspAccRecCurrent = isnull(@SuspAccRecCurrent, 0)
			SET @SuspFraudMonitorCurrent = isnull(@SuspFraudMonitorCurrent, 0)
			SET @SuspAgentAdminCurrent = isnull(@SuspAgentAdminCurrent, 0)
			SET @SuspCFPBTrainingCurrent = isnull(@SuspCFPBTrainingCurrent, 0)
			SET @SuspPhoneSalesFraudCurrent = isnull(@SuspPhoneSalesFraudCurrent, 0)
			
			IF (@SuspComplianceCurrent = 1 AND @IsSuspCompliance = 0)
			BEGIN
				SET @IsReleased = 1
				SET @Note = 'Released by Compliance - ' + @Note
				SET @MailSuspMsg = ' Released by Compliance'
			END
			IF (@SuspComplianceCurrent = 0 AND @IsSuspCompliance = 1)
			BEGIN
				SET @IsSuspended = 1
				SET @Note = 'Suspended by Compliance - ' + @Note
				SET @MailSuspMsg = ' Suspended by Compliance'
			END
			
			
			IF (@SuspAMLTrainingCurrent = 1 AND @IsSuspAMLTraining = 0)
			BEGIN
				SET @IsReleased = 1
				SET @Note = 'Released by AML Training - ' + @Note
				SET @MailSuspMsg = ' Released by AML Training'
			END
			IF (@SuspAMLTrainingCurrent = 0 AND @IsSuspAMLTraining = 1)
			BEGIN
				SET @IsSuspended = 1
				SET @Note = 'Suspended by AML Training - ' + @Note
				SET @MailSuspMsg = ' Suspended by AML Training'
			END
			
			
			IF (@SuspAccRecCurrent = 1 AND @IsSuspAccReceivable = 0)
			BEGIN
				SET @IsReleased = 1
				SET @Note = 'Released by Accounts Receivable - ' + @Note
				SET @MailSuspMsg = ' Released by Accounts Receivable'
			END
			IF (@SuspAccRecCurrent = 0 AND @IsSuspAccReceivable = 1)
			BEGIN
				SET @IsSuspended = 1
				SET @Note = 'Suspended by Accounts Receivable - ' + @Note
				SET @MailSuspMsg = ' Suspended by Accounts Receivable'
			END
			
			
			IF (@SuspFraudMonitorCurrent = 1 AND @IsSuspFraudMonitor = 0)
			BEGIN
				SET @IsReleased = 1
				SET @Note = 'Released by Fraud Monitor - ' + @Note
				SET @MailSuspMsg = ' Released by Fraud Monitor'
			END
			IF (@SuspFraudMonitorCurrent = 0 AND @IsSuspFraudMonitor = 1)
			BEGIN
				SET @IsSuspended = 1
				SET @Note = 'Suspended by Fraud Monitor - ' + @Note
				SET @MailSuspMsg = ' Suspended by Fraud Monitor'
			END
			
			
			IF (@SuspAgentAdminCurrent = 1 AND @IsSuspAgentAdmin = 0)
			BEGIN
				SET @IsReleased = 1
				SET @Note = 'Released by Agent Administration - ' + @Note
				SET @MailSuspMsg = ' Released by Agent Administration'
			END
			IF (@SuspAgentAdminCurrent = 0 AND @IsSuspAgentAdmin = 1)
			BEGIN
				SET @IsSuspended = 1
				SET @Note = 'Suspended by Agent Administration - ' + @Note
				SET @MailSuspMsg = ' Suspended by Fraud Monitor'
			END

			IF (@SuspCFPBTrainingCurrent = 1 AND @IsSuspCFPBTraining = 0)
			BEGIN
				SET @IsReleased = 1
				SET @Note = 'Released by CFPB Training - ' + @Note
				SET @MailSuspMsg = ' Released by CFPB Training'
			END
			IF (@SuspCFPBTrainingCurrent = 0 AND @IsSuspCFPBTraining = 1)
			BEGIN
				SET @IsSuspended = 1
				SET @Note = 'Suspended by CFPB Training - ' + @Note
				SET @MailSuspMsg = ' Suspended by Fraud Monitor'
			END
	   		
			IF (@SuspPhoneSalesFraudCurrent = 1 AND @IsSuspPhoneSalesFraud = 0)
			BEGIN
				SET @IsReleased = 1
				SET @Note = 'Released by Telephone Sales Fraud - ' + @Note
				SET @MailSuspMsg = ' Released by Telephone Sales Fraud'
			END
			IF (@SuspPhoneSalesFraudCurrent = 0 AND @IsSuspPhoneSalesFraud = 1)
			BEGIN
				SET @IsSuspended = 1
				SET @Note = 'Suspended by Telephone Sales Fraud - ' + @Note
				SET @MailSuspMsg = ' Suspended by Fraud Monitor'
			END
	   		
	   		EXEC [Corp].[st_InsertUpdateAgentSuspendedSubStatus] @IdAgent, @IdUser, @IsSuspCompliance, @IsSuspAMLTraining, @IsSuspAccReceivable, @IsSuspFraudMonitor, @IsSuspAgentAdmin, @IsSuspCFPBTraining, @IsSuspPhoneSalesFraud   		
	   		
	   END    

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
	   BEGIN
	   		
	   		IF (@IsReleased = 1)
			BEGIN
				Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_AgentStatusChange',Getdate(),'Is Released')
	   		
		   		SELECT D.MaxiDepartment
		   		INTO #tmpStillSuspendedBy
		   		FROM Corp.AgentSuspendedSubStatus S WITH(NOLOCK) INNER JOIN
		   			Corp.MaxiDepartment D WITH(NOLOCK) ON D.IdMaxiDepartment = S.IdMaxiDepartment
		   		WHERE IdAgent = @IdAgent AND Suspended = 1	   		
		   		
		   		
		   		SELECT @StillReleasedBy = A.Departments
		   		FROM (	   		
			   		SELECT DISTINCT STUFF((SELECT DISTINCT ', ' + MaxiDepartment 
											FROM #tmpStillSuspendedBy 
											FOR XML PATH('')
					                     ), 1, 2, ''
					                   ) AS Departments                   
					FROM #tmpStillSuspendedBy t
					) A
					
				SET @StillReleasedBy = isnull(@StillReleasedBy, '')
				
				IF EXISTS(SELECT 1 FROM #tmpStillSuspendedBy)
				BEGIN
					SET @StillReleasedBy = 'The Agent status is still SUSPENDED by ' + @StillReleasedBy
				END		
			
				
			END
			ELSE
			BEGIN
				SET @StillReleasedBy = ''
			END
	   		
	   
		   --Select @IdAgent=IdAgent from inserted	
		   Select top 1 @DepositDate=DepositDate from dbo.AgentDeposit AS A WITH(nolock) where a.idagent=@IdAgent order by DepositDate DESC
		   IF ((@IsReleased = 1 OR @IsSuspended = 1) AND @MailSuspMsg IS NOT NULL)
		   BEGIN
		   
		   		SELECT @body='The Agent '+@AgentCode+' has been' + @MailSuspMsg + '. Last Deposit Date on '+isnull(CONVERT(varchar,@DepositDate,1),'No Deposit ever')
	                +'. The Agent balance is $'+convert(varchar,round(@Balance,2),1)+' USD. The Agent phone is '+@AgentPhone+'. ' + @StillReleasedBy
			   	SET @Subject='Agent '+@AgentCode+' '+@AgentName+' has been' + @MailSuspMsg
		   
		   END
		   ELSE
		   BEGIN
		   
				Select @body='The Agent '+@AgentCode+' has been Suspended. Last Deposit Date on '+isnull(CONVERT(varchar,@DepositDate,1),'No Deposit ever')
				    +'. The Agent balance is $'+convert(varchar,round(@Balance,2),1)+' USD. The Agent phone is '+@AgentPhone+'.'
				Set @Subject='Agent '+@AgentCode+' '+@AgentName+' has been Suspended'
		   
		   END
		   
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
							SET @recipients='soportemaxi@boz.mx;cagarcia@maxillc.com;jmagallanes@maxillc.com'

							IF @NewIdAgentStatus=6 OR @NewIdAgentStatus=2 OR @NewIdAgentStatus=5
								set @recipients = @recipients + ';mmendoza@maxi-ms.com'
						END
                       
		begin try
	                   If @recipients is not Null and  @recipients<>'' 
						Begin
						    Select @EmailProfile=Value from dbo.GLOBALATTRIBUTES WITH(nolock) where Name='EmailProfiler'    
							Insert into [MAXI].[dbo].EmailCellularLog (Number,Body,[Subject],[DateOfMessage]) values (@recipients,@body,@subject,GETDATE())
							
							--Fgonzalez 20161117
							DECLARE @ProcID VARCHAR(200)
							SET @ProcID =OBJECT_NAME(@@PROCID)

							EXEC [Corp].[sp_MailQueue] 
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
			Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_AgentStatusChange',Getdate(),ERROR_MESSAGE())  
		end catch
			
		IF (@IdStatus = 1)
			EXEC st_SetActiveTrainingCommunication @IdAgent, @IdUser
   End
End Try                                                                                            
begin catch
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_AgentStatusChange',Getdate(),@ErrorMessage)                                                                                            
End Catch  

--The module 'st_AgentStatusChange' depends on the missing object 'st_SaveAgentMirror'. The module will still be created; however, it cannot run successfully until the object exists.
--The module 'st_AgentStatusChange' depends on the missing object 'st_SaveAgentMirror'. The module will still be created; however, it cannot run successfully until the object exists.
--The module 'st_AgentStatusChange' depends on the missing object 'sp_MailQueue'. The module will still be created; however, it cannot run successfully until the object exists.
