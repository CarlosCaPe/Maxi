CREATE procedure [MaxiMobile].[st_forgotPassword]
(
	--@iduser int,
	--@idagent int,
	@userlogin nvarchar(max),
	--@email nvarchar(max) = null,
	--@cell nvarchar(max) = null,
	@Returncode int output,
	@MsgOutEs nvarchar(max) output,
	@MsgOutEn nvarchar(max) output
)
as
declare
@iduser int,
@idagent int,
@email nvarchar(max) = null,
@cell nvarchar(max) = null

	set  @MsgOutEs= 'Error al cambiar la contraseña'
	set  @MsgOutEn= 'Error in change password'
	set  @Returncode = 1

select @iduser=u.IdUser,@idagent=a.IdAgent from users u join agentuser a on u.iduser=a.IdUser where UserLogin=@userlogin and IdGenericStatus=1

if @idagent is null return

select @email=Email,@cell=Cel from Owner where IdOwner in (select IdOwner from agent where idagent=@idagent)

Declare @NewPass nvarchar(max)
Declare @salt nvarchar(max)
Declare @pass nvarchar(max)
Declare @body nvarchar(max)
	
if @email is null and @cell is null return

select ROW_NUMBER() over (order by name) id,replace(replace(replace(name,' ',''),'E','3'),'A','4') name into #pass from DictionaryNames where len(name)>9 and len(name)<12

SELECT @NewPass=name+convert(varchar,DATEPART(year, getdate())) from #pass where  id =Cast(RAND()*(100-1)+1 as int)

--select @NewPass

	select @salt=[dbo].[fnCreateSalt](30)
	set  @pass=dbo.fnCreatePasswordHash(@NewPass, @salt)
	update Users set UserPassword=@pass,salt=@salt where IdUser=@IdUser
	set  @MsgOutEs= 'Contraseña cambiada correctamente'
	set  @MsgOutEn= 'Password sucessfully change'
	set  @Returncode = 0

	set @body = 'La nueva contraseña para el usuario '+@userlogin+' es: '+@NewPass+' / The new password for the user '+@userlogin+' is: '+@NewPass

if not (isnull(@cell,'')='')
begin

declare @InterCode nvarchar(max) = '1'

if (@cell like '%(449)%') set @InterCode = '52'


DECLARE	@return_value int,
		@HasError bit,
		@Message nvarchar(max)

EXEC	@return_value = [Infinite].[st_InsertTextMessage]
		@MessageType = 9,
		@Priority = 1,
		@CellularNumber = @cell,
		@InterCode = N'52',
		@TextMessage = @body,
		@UserId = 37,
		@AgentId = @idagent,
		@GatewayId = NULL,
		@IsCustomer = 0,
		@HasError = @HasError OUTPUT,
		@Message = @Message OUTPUT
end

if not (isnull(@email,'')='')
begin	
INSERT INTO [dbo].[MailQueue]
           ([Source]
           ,[ReplyTo]
           ,[MsgRecipient]
           ,[MsgCC]
           ,[MsgCCO]
           ,[Subject]
           ,[Body]
           ,[TemplateId]
           ,[CreateDate]
           ,[SendDate]
           ,[MailSent]
           ,[Resend])
     VALUES
           ('maximobile.st_forgotPassword'
           --,'reports@maxitransfers.net'
		   ,'Environment_QA@maxitransfers.net'
           ,@email
           ,null
           ,null
           ,'Solicitid de Cambio de Contraseña/Password Change Request'
           ,@body
           ,null
           ,GETDATE()
           ,DATEADD(MINUTE,1,getdate())
           ,null
           ,null)	
end

drop table #pass
