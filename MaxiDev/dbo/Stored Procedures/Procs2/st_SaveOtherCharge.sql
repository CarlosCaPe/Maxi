CREATE Procedure [dbo].[st_SaveOtherCharge]
--@IsSpanishLanguage bit,            
    @IdLenguage INT,
    @IdAgent INT,            
    @Amount MONEY,    
    @IsDebit BIT,          
    @ChargeDate DATETIME,            
    @Notes NVARCHAR(MAX),    
    @Reference NVARCHAR(MAX),            
    @EnterByIdUser INT,            
    @HasError BIT OUT,                                  
    @Message NVARCHAR(MAX) out,
    @IdOtherChargesMemo INT =NULL,
    @OtherChargesMemoNote  NVARCHAR(MAX) =NULL,
	@ComesFromStoredReverse BIT = 0,
	@IsReverse BIT = 0
as            
Begin Try 

set @IdOtherChargesMemo=isnull(@IdOtherChargesMemo,15)           
            
Declare @Balance Money            
Declare @PositiveAmount Money            
Declare @TypeOfCharge nvarchar(10)            
Declare @IdAgentBalance int 
Declare @AmountCurrentBalance money

if @IdLenguage is null 
    set @IdLenguage=2

Set  @Balance=0            
If @IsDebit=1
	Set @AmountCurrentBalance=@Amount
Else
	Set @AmountCurrentBalance=@Amount*-1

--------------------- Modify Agent current balance -------------------------------               

If not Exists (Select 1 from AgentCurrentBalance WITH(NOLOCK) where IdAgent=@IdAgent)
begin                
 Insert into AgentCurrentBalance (IdAgent,Balance) values (@IdAgent,0)  
end 
    Update AgentCurrentBalance set Balance=Balance+@AmountCurrentBalance ,@Balance=Balance+@AmountCurrentBalance  where IdAgent=@IdAgent
	--Select @Balance=Balance from AgentCurrentBalance where IdAgent=@IdAgent      
    
--------------------- Debit or Credit ----------------------------------------------              
if @IsDebit=0            
Begin            
	Set @TypeOfCharge='Credit'            
	Set @PositiveAmount=@Amount            
End            
Else            
Begin            
	Set @TypeOfCharge='Debit'            
	Set @PositiveAmount=@Amount            
End            
  ---------------------- Insert into Agent balance ------------------------------------            

  declare @description nvarchar(max)
  declare @memo nvarchar(max)

  IF @ComesFromStoredReverse = 0
  BEGIN

		--IF (@Notes = 'Check Scanner Fee') /*2016-Sep-13*/
		--BEGIN
		--	SET @description = @Notes;
		--END
		--ELSE
		--BEGIN
			select @memo=memo from [OtherChargesMemo] (NOLOCK) where IdOtherChargesMemo=@IdOtherChargesMemo

			set @description = @memo
			--set @description = case when @IdOtherChargesMemo=15 then isnull(@OtherChargesMemoNote,'') else @memo end
			--			+ case when @Notes ='' then '' else ' - ' +@Notes end
		--END
  END
  ELSE IF @IsReverse = 1
	  SELECT @description = ISNULL([ReverseNote],'') FROM [dbo].[OtherChargesMemo] (NOLOCK) WHERE [IdOtherChargesMemo] = @IdOtherChargesMemo
  ELSE
	SELECT @description = ISNULL([Memo],'') FROM [dbo].[OtherChargesMemo] (NOLOCK) WHERE [IdOtherChargesMemo] = @IdOtherChargesMemo
              
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
'CGO',              
 DATEADD (second , 1 , GETDATE()),--GETDATE(),              
@PositiveAmount,              
@Reference,              
@description,              
'',              
0,
0,              
@TypeOfCharge,              
@Balance,              
0              
)              
            
Select @IdAgentBalance=SCOPE_IDENTITY()            
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
@Amount,            
@ChargeDate,            
@Notes,            
GETDATE(),            
@EnterByIdUser,
@IdOtherChargesMemo,
@OtherChargesMemoNote,
@IsReverse
)     

 --Validar CurrentBalance
        exec st_AgentVerifyCreditLimit @IdAgent

        --Mandar correo balance negativo

        Declare @recipients nvarchar (max)
        Declare @EmailProfile nvarchar(max)	 
        Declare @body nvarchar(max)
        Declare @Subject nvarchar(max) 
        Declare @AgentCode nvarchar(max)  =' '
        Declare @IdAgentStatus int
        Declare @AgentStatusName nvarchar(max)  =' '
        Declare @AgentName nvarchar(max)  =' '
        
        select @AgentCode=agentcode,@IdAgentStatus=a.IdAgentStatus,@AgentStatusName=upper(agentstatus),@AgentName=agentname 
		from agent a WITH(NOLOCK)
			join agentstatus s WITH(NOLOCK) on a.IdAgentStatus=s.IdAgentStatus
        where idagent=@IdAgent

        --if (round(Isnull(@Balance,0),2)<0)
        --begin
        --    select @recipients = 'cob@maxi-ms.com'
        --    --select @recipients = ''
        --    select @body = 'Agent '+isnull(@AgentCode,'')+', Balance: - $'+convert(varchar,round((-1)*@Balance,2),1)+' - Please review because it''s balance is N E G A T I V E !!!'            
        --    select @subject = 'Agent '+isnull(@AgentCode,'')+', Balance: - $'+convert(varchar,round((-1)*@Balance,2),1)+' - Please review because it''s balance is N E G A T I V E !!!'            
	
        --    Select @EmailProfile=Value from GLOBALATTRIBUTES WITH(NOLOCK) where Name='EmailProfiler'    
	       -- Insert into EmailCellularLog values (@recipients,@body,@subject,GETDATE())  
	       -- EXEC msdb.dbo.sp_send_dbmail                            
		      --  @profile_name=@EmailProfile,                                                       
		      --  @recipients = @recipients,                                                            
		      --  @body = @body,                                                             
		      --  @subject = @subject         
        --end	       
               
            
 Set @HasError=0                                  
 --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,16)                                  
 SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE16')
                                  
End Try                                  
Begin Catch  


                                 
 Set @HasError=1                         
 --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,17)                                   
 SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE17')
 Declare @ErrorMessage nvarchar(max)                                   
 set @ErrorMessage = 'Agent: ' +ISNULL (CAST(@IdAgent as varchar) ,'Is null')+' Amount: ' + ISNULL(CAST( @Amount as varchar),'Is null') + ' Reference: ' + ISNULL(@Reference,'Is null ') + 'Is debit: ' + ISNULL(Cast(@IsDebit as varchar), 'Is null ') + 'Charge Date: ' + ISNULL(Cast(@ChargeDate as varchar), 'Is null ') +'Notes: '+ ISNULL(@Notes,'is null ') + 'User: '+ ISNULL(CAST(@EnterByIdUser as varchar) ,'Is null' )  + ERROR_MESSAGE()                                  
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveOtherCharge',Getdate(),@ErrorMessage)                                  
End Catch
