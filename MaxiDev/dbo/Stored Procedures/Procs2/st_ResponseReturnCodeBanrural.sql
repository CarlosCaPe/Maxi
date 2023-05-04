CREATE procedure [dbo].[st_ResponseReturnCodeBanrural]
(
    @IdGateway  int,
    @Claimcode  nvarchar(max),
    @ReturnCode nvarchar(max),
    @ReturnCodeType int,
    @XmlValue xml,
    @IsCorrect bit Output
)
AS
Set nocount on

/********************************************************************
<Author>Unknow</Author>
<app>-</app>
<Description></Description>

<ChangeLog>
<log Date="09/04/2018" Author="jmmolina">Se agrego validación para remesas canceladas y con respuesta con estatus 'disponible' desde gateway #1</log>
</ChangeLog>
*********************************************************************/

BEGIN TRY

	Declare @Description nvarchar(max)
	Declare @IdStatusAction int
	Declare @IdTransfer int   
	Declare @ActualIdStatus Int 
	declare @ReturnAllComission int
	Declare @str varchar(max)

	Set @str=''

	--INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage, ExtraData) VALUES('st_ResponseReturnCodeBanrural', GETDATE(), 'Validando respuesta Banrural, parametros: @IdGateway = ' + CONVERT(varchar(50), @IdGateway) + ', @Claimcode = ' + @Claimcode + ', @ReturnCode = ' + @ReturnCode + ', @ReturnCodeType = ' + CONVERT(VARCHAR(50), @ReturnCodeType), CONVERT(VARCHAR(max), @XmlValue))

	Select @IdStatusAction=A.IdStatusAction,@Description=B.ReturnCodeType+' code '+@ReturnCode+','+[Description]
	from GatewayReturnCode AS A WITH(NOLOCK)  
	inner Join GatewayReturnCodeType AS B WITH(NOLOCK)  on (A.IdGatewayReturnCodeType=B.IdGatewayReturnCodeType)
	where A.IdGateway=@IdGateway And A.IdGatewayReturnCodeType=@ReturnCodeType And A.ReturnCode=@ReturnCode

	Insert into BanruralResponseLog values (getdate(),@Claimcode,@ReturnCode,@ReturnCodeType,@IdStatusAction,@Description,@XmlValue)

	If @ReturnCodeType=3
	Begin
		Declare @DocHandle int
		EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XmlValue
		SELECT Name+'='+Value as variable  into #temp FROM OPENXML (@DocHandle, 'root/Variable',2)  WITH (Name varchar(max),Value varchar(max))
		EXEC sp_xml_removedocument @DocHandle

		SELECT @str = COALESCE(@str + ';', '') + variable FROM #temp
		Set @Description=@Description+' '+@str
	End

	Select 
		@IdTransfer=IdTransfer,
		@ActualIdStatus=IdStatus,
		@ReturnAllComission=ReturnAllComission 
	From [Transfer] AS t WITH(NOLOCK)
	left join ReasonForCancel AS r WITH(NOLOCK) on t.IdReasonForCancel=r.IdReasonForCancel
	where ClaimCode=@Claimcode

	--Validar razon de cancelacion
	set @ReturnAllComission=isnull(@ReturnAllComission,0)

	If @IdStatusAction > 0
	Begin

		if @IdTransfer is not null and @ActualIdStatus<>@IdStatusAction
		Begin
			IF NOT (@ActualIdStatus = 25 AND @ReturnCode = 'Disponible') --#1
			BEGIN

				Update [Transfer] set IdStatus=@IdStatusAction,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer

				Exec st_SaveChangesToTransferLog @IdTransfer,@IdStatusAction,@Description,0
				If @IdStatusAction=31 --- Rejected balance
				Begin
					Exec st_RejectedCreditToAgentBalance @IdTransfer
				End
				If @IdStatusAction=22  -- Cancel Balance
				Begin

					If not exists(Select 1 from TransfersUnclaimed WITH(NOLOCK) where IdTransfer=@IdTransfer and IdStatus=1)
					begin
						if (@ReturnAllComission=0)--validar si se regresa completa la comision
							Exec st_CancelCreditToAgentBalance @IdTransfer 
						else
							EXEC st_CancelCreditToAgentBalanceTotalAmount  @IdTransfer
					end
					Else
					Begin

						Declare @UnclaimedStatus int 
						set @UnclaimedStatus=27
						Update TransfersUnclaimed set IdStatus=2 where IdTransfer=@IdTransfer
						Update [Transfer] set IdStatus=@UnclaimedStatus,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer
						Exec st_SaveChangesToTransferLog @IdTransfer,@UnclaimedStatus,@Description,0
					End                
				End

				If @IdStatusAction=30  -- Paid
				Begin
					exec dbo.st_SavePayInfoBanrural @IdGateway,@IdTransfer,@Claimcode,@XmlValue
				End
				if (@IdStatusAction in (22,30,31))
				begin
					DECLARE @HasErrorD bit, @MessageOutD varchar(max)

					EXEC [dbo].[st_DismissComplianceNotificationByIdTransfer]
						@IdTransfer,
						1,
						@HasErrorD OUTPUT,
						@MessageOutD OUTPUT
				end  
				--Begin Try 
				insert into MoneyAlert.StatusChangePushMessage
				values (@Claimcode,getdate(),null,0)
				/*End Try
				Begin Catch
				 Declare @ErrorMessage nvarchar(max)
				 Select @ErrorMessage=ERROR_MESSAGE()
				 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCodeBanrural',Getdate(),@ErrorMessage
				End Catch*/
			END
			--ELSE --#1
				--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Info: st_ResponseReturnCodeBanrural @IdTransfer = ' + CONVERT(VARCHAR, @IdTransfer) + ', @ReturnCode = ' + @ReturnCode + ', @ActualIdStatus = ' + CONVERT(VARCHAR, @ActualIdStatus),Getdate(),'Validando Cancelaciones Banrural')
		End 
	End
	Else
	Begin
		Select @Description='Return code UNKNOWN:'+@ReturnCode+' '+@str
		Exec st_SimpleAddNoteToTransfer  @IdTransfer,@Description
	End
	Set @IsCorrect=1
END TRY
BEGIN CATCH
	Declare @ErrorMessage nvarchar(max)
	declare @ErrorLine varchar(500)
	Select @ErrorMessage=ERROR_MESSAGE()
	select @ErrorLine = CONVERT(varchar(500), ERROR_LINE())
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCodeBanrural, @str: ' + @str, Getdate(),@ErrorMessage + '; Error: ' + @ErrorLine)
	INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage, ExtraData) VALUES('st_ResponseReturnCodeBanrural', GETDATE(), 'Validando respuesta Banrural, parametros: @IdGateway = ' + CONVERT(varchar(50), @IdGateway) + ', @Claimcode = ' + @Claimcode + ', @ReturnCode = ' + @ReturnCode + ', @ReturnCodeType = ' + CONVERT(VARCHAR(50), @ReturnCodeType), CONVERT(VARCHAR(max), @XmlValue))
END CATCH