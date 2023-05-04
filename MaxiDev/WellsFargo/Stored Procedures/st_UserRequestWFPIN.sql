/********************************************************************
<Author>Not Known</Author>
<app>-</app>
<Description></Description>

<ChangeLog>
<log Date="27/06/2018" Author="azavala">Add columns insert EmailCellularLog</log>
</ChangeLog>
********************************************************************/
CREATE procedure [WellsFargo].[st_UserRequestWFPIN]
(
    @IdCarrier int = null,
    @CelullarNumber nvarchar(1000)= null,
    @Email nvarchar(1000)= null,    
	@IdAgent int=null,
    @EnterByIdUser int,
    @IdLenguage int,
    @HasError bit out,
    @MessageError nvarchar(max) out
)
as
begin try
--declaracion de variables
Declare @Upper INT
Declare @Lower INT
declare @PIN int
declare @EmailProfile nvarchar(max)
declare @body nvarchar(max)
declare @subject nvarchar(max)
declare @UserName nvarchar(max)
declare @Agentcode nvarchar(max)

if @IdLenguage is null 
    set @IdLenguage=2 

if (@IdAgent is null) set @IdAgent=1

SET @Lower = 1000 
SET @Upper = 9999 

SELECT @PIN = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)
select @UserName=UserName from users where IdUser=@EnterByIdUser
select @Agentcode=AgentCode from agent where IdAgent=@IdAgent

    EXEC [WellsFargo].[st_SaveWFPIN]
		@IdCarrier,
		@CelullarNumber,
		@Email,
		@PIN,
		@EnterByIdUser,
		@IdLenguage,
		@HasError OUTPUT,
		@MessageError OUTPUT

    if @HasError=1
    begin
        set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'ERRORSENDWFPIN')
        return
    end

    select @subject = 'Wells Fargo Agent PIN'            
    select @body =  'User '+@UserName+' 
Your Wells Fargo PIN for Agent '+@Agentcode+' is: ' + convert(varchar,@PIN)
    Select @EmailProfile=Value from GLOBALATTRIBUTES where Name='EmailProfiler'    

    if (ltrim(rtrim(isnull(@Email,'')))!='')
    begin            
	        Insert into EmailCellularLog (Number,Body,[Subject],[DateOfMessage]) values (@Email,@body,@subject,GETDATE())  
	        EXEC msdb.dbo.sp_send_dbmail                            
		        @profile_name=@EmailProfile,                                                       
		        @recipients = @Email,                                                            
		        @body = @body,                                                             
		        @subject = @subject
    end

    if (ltrim(rtrim(isnull(@CelullarNumber,'')))!='' and @IdCarrier is not null)
    begin          
         select @Email= Replace (Replace (Replace (Replace(@CelullarNumber,'-',''),' ',''),'(',''),')','')+Email  from carriers where idcarrier=@idcarrier

         Insert into EmailCellularLog (Number,Body,[Subject],[DateOfMessage]) values (@Email,@body,@subject,GETDATE())  
	        EXEC msdb.dbo.sp_send_dbmail                            
		        @profile_name=@EmailProfile,                                                       
		        @recipients = @Email,                                                            
		        @body = @body,                                                             
		        @subject = @subject
    end

set @HasError = 0
set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SENDWFPIN')

End Try
Begin Catch
	Set @HasError=1	
    set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'ERRORSENDWFPIN')
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('WellsFargo.st_AgentRequestWFPIN',Getdate(),@ErrorMessage)
End Catch