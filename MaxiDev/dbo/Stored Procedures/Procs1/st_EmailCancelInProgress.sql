/********************************************************************
<Author>Not Known</Author>
<app>-</app>
<Description></Description>

<ChangeLog>
<log Date="27/06/2018" Author="azavala">Add columns insert EmailCellularLog</log>
<log Date="19/08/2019" Author="adominguez">Add Validation len of body </log>
</ChangeLog>
********************************************************************/
CREATE Procedure [dbo].[st_EmailCancelInProgress]
@ClaimCode nvarchar(100),
@IdTransfer int, 
@IdGateway int,
@IdAgent int,
@ReasonEn nvarchar(max),
@ReasonEs nvarchar(max)
As
IF(@IdGateway =28 OR @IdGateway =30)
BEGIN

	Declare @body nvarchar(max),
	 @Subject nvarchar(max) ,
	 @recipients nvarchar (max),
	 @EmailProfile nvarchar(max),
	 @AgentCode varchar(10)

	 set @AgentCode  =(select AgentCode from Agent (nolock) where IdAgent=@IdAgent)

	 IF(@IdGateway =28)
BEGIN
 
	 set @Subject = 'Cancellation request for Pontual '+@ClaimCode+' from '+@AgentCode
	 set @Body = 'Agent '+@AgentCode+' request cancellation of '+@ClaimCode+' because '+@ReasonEn+' Please call Pontual'+ '<BR/>' +
				'Agente '+@AgentCode+' solicita la cancelacion de '+@ClaimCode+' porque '+@ReasonEs+' Favor de llamar a Pontual'


END
	 IF(@IdGateway =30)
BEGIN
 
	 set @Subject = 'Cancellation request for Banco Union '+@ClaimCode+' from '+@AgentCode
	 set @Body = 'Agent '+@AgentCode+' request cancellation of '+@ClaimCode+' because '+@ReasonEn+' Please call Banco Union'+ '<BR/>' +
				'Agente '+@AgentCode+' solicita la cancelacion de '+@ClaimCode+' porque '+@ReasonEs+' Favor de llamar a Banco Union'


END

If (len(@body)>2)
	Select @recipients=Value from GLOBALATTRIBUTES (nolock) where Name='EmailRecipientsToCancelStandBy'  
	Select @EmailProfile=Value from GLOBALATTRIBUTES (nolock) where Name='EmailProfiler'  
  
	Insert into EmailCellularLog (Number,Body,[Subject],[DateOfMessage]) values (@recipients,@body,@subject,GETDATE())  
	EXEC msdb.dbo.sp_send_dbmail                            
		@profile_name=@EmailProfile,                                                       
		@recipients = @recipients,                                                            
		@body = @body,                                                             
		@subject = @subject,
		@body_format = 'HTML'

END
