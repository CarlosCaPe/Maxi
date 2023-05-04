create procedure [WellsFargo].st_EnableDisableAgentWFPIN
(    
    @EnterByIdUser int,
    @IdLenguage int,
    @IdGenericStatus int,
	@IdAgent int=null,
    @HasError bit out,
    @MessageError nvarchar(max) out
)
as
begin try

if (@IdAgent is null) set @IdAgent=1

declare @CellularNumberOLD nvarchar(max)
declare @EmailOLD nvarchar(max)
declare @Email nvarchar(max)
declare @IdCarrierOLD int
declare @IdUserOLD int
declare @EmailProfile nvarchar(max)
declare @body nvarchar(max)
declare @subject nvarchar(max)
declare @UserName nvarchar(max)
declare @Agentcode nvarchar(max)

select @IdUserOLD=enterbyiduser,@CellularNumberOLD=[CelullarNumber],@EmailOLD=[Email],@IdCarrierOLD=[IdCarrier] from [WellsFargo].wfpin where enterbyiduser=@EnterByIdUser

select @UserName=UserName from users where IdUser=@EnterByIdUser
select @Agentcode=AgentCode from agent where IdAgent=@IdAgent

update [WellsFargo].wfpin  set idgenericstatus=@IdGenericStatus,enterbyiduser=@EnterByIdUser,dateoflastchange=getdate() where enterbyiduser=@EnterByIdUser

if (isnull(@IdUserOLD ,0)!=0)
begin
    
    if @IdGenericStatus=2
    begin
        select @subject = 'Wells Fargo Agent PIN has been disabled'
        select @body = 'User '+@UserName+' 
Your Wells Fargo PIN for Agent '+@Agentcode+' has been disabled'
    end
    else
    begin
        select @subject = 'Wells Fargo Agent PIN has been enable'
        select @body = 'User '+@UserName+' 
Your Wells Fargo PIN for Agent '+@Agentcode+' has been enable'
    end
    
    Select @EmailProfile=Value from GLOBALATTRIBUTES where Name='EmailProfiler'   
    
    if (ltrim(rtrim(isnull(@EmailOLD,'')))!='')
    begin            
	        Insert into EmailCellularLog values (@EmailOLD,@body,@subject,GETDATE())  
	        EXEC msdb.dbo.sp_send_dbmail                            
		        @profile_name=@EmailProfile,                                                       
		        @recipients = @EmailOLD,                                                            
		        @body = @body,                                                             
		        @subject = @subject
    end

    if (ltrim(rtrim(isnull(@CellularNumberOLD,'')))!='' and @IdCarrierOLD is not null)
    begin          
         select @Email= Replace (Replace (Replace (Replace(@CellularNumberOLD,'-',''),' ',''),'(',''),')','')+Email  from carriers where idcarrier=@IdCarrierOLD

         Insert into EmailCellularLog values (@Email,@body,@subject,GETDATE())  
	        EXEC msdb.dbo.sp_send_dbmail                            
		        @profile_name=@EmailProfile,                                                       
		        @recipients = @Email,                                                            
		        @body = @body,                                                             
		        @subject = @subject
    end
end

set @HasError = 0
set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SAVEWFPIN')

End Try
Begin Catch
	Set @HasError=1	
    set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'ERRORSAVEWFPIN')
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('WellsFargo.st_EnableDisableAgentWFPIN',Getdate(),@ErrorMessage)
End Catch