CREATE procedure [dbo].[st_ResponseReturnCodeUniteller]
(                                        
    @IdGateway  int,
    @Claimcode  nvarchar(max),
    @ReturnCode nvarchar(max),
    @ReturnCodeType int,
    @XmlValue xml,
    @IsCorrect bit Output
)                                   
AS

/********************************************************************
<Author></Author>
<app>  </app>
<Description></Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="10/12/2018" Author="adominguez">Se agrega "with(nolock)" a las consultas</log>
<log Date="12/12/2018" Author="jmolina">Se agrega "cast a mimsmo tamaño de variable y campo de tabla y se comenta funcionalidad de moneyalert" a las consultas #1</log>
</ChangeLog>
*********************************************************************/

Set nocount on

BEGIN TRY
	Declare @Description nvarchar(max)                                    
	Declare @IdStatusAction int                                    
	Declare @IdTransfer int          
	Declare @ActualIdStatus int                                   
	Declare @str varchar(max)     
	declare @ReturnAllComission int    
	declare @noteUniteller nvarchar(max)

	declare @ReturnCodeCast nvarchar(16)
	declare @ClaimcodeCast nvarchar(50)

	set @ReturnCodeCast = convert(nvarchar(16), @ReturnCode)
	set @ClaimcodeCast = convert(nvarchar(50), @Claimcode)

	set @str=''

	Select @IdStatusAction=A.IdStatusAction,@Description=B.ReturnCodeType+' code '+@ReturnCodeCast+','+[Description]
	--Select @IdStatusAction=A.IdStatusAction,@Description=B.ReturnCodeType+' code '+@ReturnCode+','+[Description]
	from GatewayReturnCode as A with(nolock) 
	inner Join GatewayReturnCodeType as B with(nolock) on (A.IdGatewayReturnCodeType=B.IdGatewayReturnCodeType)
	where A.IdGateway=@IdGateway And A.IdGatewayReturnCodeType=@ReturnCodeType And A.ReturnCode=@ReturnCodeCast
	--where A.IdGateway=@IdGateway And A.IdGatewayReturnCodeType=@ReturnCodeType And A.ReturnCode=@ReturnCode

	Insert into UnitellerResponseLog values (getdate(),@Claimcode,@ReturnCode,@ReturnCodeType,@IdStatusAction,@Description,@XmlValue)

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
	From [Transfer] As t with(nolock)
	left join 
		ReasonForCancel as r with(nolock) on t.IdReasonForCancel=r.IdReasonForCancel
	where ClaimCode=@ClaimcodeCast
	--where ClaimCode=@Claimcode

	--Validar razon de cancelacion
	set @ReturnAllComission=isnull(@ReturnAllComission,0)

	IF @ReturnCode='016'
		BEGIN			
			SELECT	@noteUniteller = ISNULL(T.[xmlString].value('(/TransferUpdate//MESSAGETEXT/node())[1]', 'NVARCHAR(MAX)'),'NULL')
				FROM (SELECT @XmlValue AS [xmlString]) T			
				
				SET @Description = isnull(@Description,'') + isnull(@noteUniteller,'')
				
				Exec st_SimpleAddNoteToTransfer  @IdTransfer,@Description

				Return
		END


	 IF @ReturnCode='006'
	  BEGIN			
				SELECT
					@noteUniteller = ISNULL(T.[xmlString].value('(/TransferUpdate//MESSAGETEXT/node())[1]', 'NVARCHAR(MAX)'),'NULL')
				FROM (SELECT @XmlValue AS [xmlString]) T			
				SET @Description = isnull(@Description,'') + isnull(@noteUniteller,'')

			IF @IdStatusAction=24 AND  @ActualIdStatus=29
			BEGIN
				set @IdStatusAction=29
			END
	  END

	If @IdStatusAction>0
	Begin
		if @IdTransfer is not null and @ActualIdStatus<>@IdStatusAction
		begin
			Update [Transfer] set IdStatus=@IdStatusAction,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer
			Exec st_SaveChangesToTransferLog @IdTransfer,@IdStatusAction,@Description,0
			If @IdStatusAction=31 --- Rejected balance
			Begin
				Exec st_RejectedCreditToAgentBalance @IdTransfer
			End
			If @IdStatusAction=22  -- Cancel Balance
			Begin
				If not exists(Select 1 from TransfersUnclaimed with(nolock) where IdTransfer=@IdTransfer and IdStatus=1)
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
				exec st_SavePayInfoUniteller @IdGateway,@IdTransfer,@Claimcode,@XmlValue
			End
			if (@IdStatusAction in (22,30,31))
			begin
				DECLARE	@HasErrorD bit,	@MessageOutD varchar(max)

				EXEC	[dbo].[st_DismissComplianceNotificationByIdTransfer]
	        		@IdTransfer,
					1,
					@HasErrorD OUTPUT,
					@MessageOutD OUTPUT
			end

			-- Se comenta debido que este servicio dejo de funcionar para MAXI
			--Begin Try 
			--	insert into MoneyAlert.StatusChangePushMessage
			--	values
			--	(@Claimcode,getdate(),null,0)
			--End Try                                                                                            
			--Begin Catch
			-- Declare @ErrorMessage nvarchar(max)                                                                                             
			-- Select @ErrorMessage=ERROR_MESSAGE()                                             
			-- Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCodeUniteller',Getdate(),@ErrorMessage)                                                                                            
			--End Catch  
		End
		ELSE
		BEGIN
			IF @ReturnCode='006'
			BEGIN			
				Exec st_SimpleAddNoteToTransfer  @IdTransfer,@Description
			END
		END

	End
	Else
	Begin
		Select @Description='Return code UNKNOWN:'+@ReturnCode+' '+@str
		Exec st_SimpleAddNoteToTransfer  @IdTransfer,@Description
	End
	Set @IsCorrect=1
	END TRY
BEGIN CATCH
	DECLARE @Parameters varchar(max)
	SET @Parameters = (SELECT * FROM (
				        	SELECT IdGateway = @IdGateway,
				        	Claimcode = @Claimcode,
				        	ReturnCode = @ReturnCode,
				        	ReturnCodeType = @ReturnCodeType,
				        	XmlValue = @XmlValue
				      )AS t
				      FOR XML PATH('CodeUniteller'), ELEMENTS)

    DECLARE @ErrorMessage nvarchar(max)
    Select  @ErrorMessage = ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCodeUniteller: Parameters: ' + CONVERT(varchar(max),@Parameters) + ', ErrorLine: ' + CONVERT(VARCHAR,ERROR_LINE()),Getdate(),@ErrorMessage)
END CATCH