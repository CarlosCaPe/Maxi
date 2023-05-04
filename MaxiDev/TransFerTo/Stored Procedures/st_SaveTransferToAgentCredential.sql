 create procedure TransferTo.st_SaveTransferToAgentCredential
 (
    @IdAgentCredential int,
    @IdAgent int,
    @Active int, --1 activo, 2 inactivo
    @Username nvarchar(max),
    @UserPassword nvarchar(max),
    @EnterByIdUser int,
    @IdLenguage int,
    @HasError bit out,  
    @ResultMessage nvarchar(max) out,
    @IdAgentCredentialOut int out
 )
 as
 begin try

 if @IdLenguage is null 
    set @IdLenguage=2 
    
    
if (@IdAgentCredential=0) and exists(select top 1 1 from [TransFerTo].[AgentCredential] where idagent=@IdAgent)
begin
  set @HasError =1    
  SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'CREDENTIALSAVEERROR2')
  return
end

 if (@IdAgentCredential=0)
 begin
    insert into [TransFerTo].[AgentCredential] 
    values
    (@idagent,@username,@userpassword,@enterbyiduser,getdate(),getdate(),@Active)

    set @IdAgentCredentialOut=SCOPE_IDENTITY()

 end
 else
 begin
    update [TransFerTo].[AgentCredential]  set
        username=@username,
        userpassword=@userpassword,
        enterbyiduser=@enterbyiduser,
        DateOfLastChange=getdate(),
        idgenericstatus=@Active
    where IdAgentCredential=@IdAgentCredential

    set @IdAgentCredentialOut=@IdAgentCredential;

 end

  set @HasError =0    
  SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'CREDENTIALSAVE')

end try

begin catch

  Declare @ErrorMessage nvarchar(max)           
  Select @ErrorMessage=ERROR_MESSAGE()          
  Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransferTo.st_SaveTransferToAgentCredential',Getdate(),@ErrorMessage)   
  set @HasError =1    
  SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'CREDENTIALSAVEERROR')

end catch

