CREATE procedure [dbo].[st_ResponseReturnCodeAppriza]
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
<log Date="12/12/2018" Author="jmolina">Se agrega "cast a mimsmo tamaño de variable y campo de tabla a las consultas y se comenta funcionalidad de moneyalert" #1</log>
</ChangeLog>
*********************************************************************/

Set nocount on                                  
Declare @Description nvarchar(max)                                    
Declare @IdStatusAction int                                    
Declare @IdTransfer int          
Declare @ActualIdStatus int                                   
Declare @str varchar(max)     
declare @ReturnAllComission int

BEGIN TRY
	declare @ReturnCodeCast nvarchar(16)
	declare @ClaimcodeCast nvarchar(50)
	
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCodeAppriza',Getdate(),'Inicio')
	
	--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCodeAppriza',Getdate(),'Description: ' + @Description + ', ReturnCodeType: ' + @ReturnCodeType + ', ReturnCode: ' + @ReturnCode + ', ClaimCode: ' + @Claimcode)

	set @ReturnCodeCast = convert(nvarchar(16), @ReturnCode)
	set @ClaimcodeCast = convert(nvarchar(50), @Claimcode)

	set @str=''

	Select @IdStatusAction=A.IdStatusAction,@Description=B.ReturnCodeType+' code '+@ReturnCodeCast+','+[Description]
	--Select @IdStatusAction=A.IdStatusAction,@Description=B.ReturnCodeType+' code '+@ReturnCode+','+Description
	from GatewayReturnCode A with(nolock) 
	inner Join GatewayReturnCodeType B with(nolock) on (A.IdGatewayReturnCodeType=B.IdGatewayReturnCodeType)
	where A.IdGateway=@IdGateway And A.IdGatewayReturnCodeType=@ReturnCodeType And A.ReturnCode=@ReturnCodeCast
	--where A.IdGateway=@IdGateway And A.IdGatewayReturnCodeType=@ReturnCodeType And A.ReturnCode=@ReturnCode
	
	/*Appriza SubCodes Notifications*/
	DECLARE @DocHandleComp INT
	DECLARE @strAprizzaSubCodes NVARCHAR(max)
	
	EXEC sp_xml_preparedocument @DocHandleComp OUTPUT, @XmlValue
	
	SELECT [Rule] AS 'RuleName', Value AS 'Entity'
	INTO #tmpApprizaSubCodes 
	FROM OPENXML (@DocHandleComp, 'root/Compliance',2)  WITH ([Rule] varchar(max),Value varchar(max))
	
	EXEC sp_xml_removedocument @DocHandleComp
	
	SELECT A.RuleName, A.Entity, D.Description AS 'Document'
	INTO #tmpApprizaSubCodesReqDocs
	FROM #tmpApprizaSubCodes A
	INNER JOIN ApprizaReturnSubCode R ON R.ReturnSubCode = A.RuleName
	INNER JOIN ApprizaReturnSubCodeDocuments D ON D.IdDocument = R.IdDocument
	
	SELECT '(' + RuleName +'-'+ Entity +') Appriza requires from ' +
			CASE WHEN Entity = 'SEN' THEN 'Sender ' ELSE 'Beneficiary ' END +
			CASE WHEN RuleName IN ('DNY','OFA','PDL') THEN 'one ' ELSE 'each ' END  + 'of the following: ' + 
			STUFF((SELECT ', ' + CAST(Document AS VARCHAR(max)) [text()]
	         FROM #tmpApprizaSubCodesReqDocs 
	         WHERE RuleName = t.RuleName AND Entity = t.Entity
	         FOR XML PATH(''), TYPE)
	        .value('.','NVARCHAR(MAX)'),1,2,' ') List
	INTO #tmpFinalApprizaReqCodes     
	FROM #tmpApprizaSubCodesReqDocs t
	GROUP BY RuleName, Entity
	
	
	SELECT @strAprizzaSubCodes = A.ApprizaDocs
	FROM 
	(
		SELECT DISTINCT STUFF((SELECT '; ' + CAST(List AS VARCHAR(max)) [text()]
					         FROM #tmpFinalApprizaReqCodes 
					         FOR XML PATH(''), TYPE)
					        .value('.','NVARCHAR(MAX)'),1,2,' ') ApprizaDocs  
		FROM #tmpFinalApprizaReqCodes t
	) A
	
	SET @Description = @Description + ' ' + isnull(@strAprizzaSubCodes, '')

	Insert into ApprizaResponseLog values (getdate(),@Claimcode,@ReturnCode,@ReturnCodeType,@IdStatusAction,@Description,@XmlValue)

	--if (@Claimcode!='700700265890' and @ReturnCodeType in (2,3))-->prueba Appriza Notificación Cancelación
	--begin
	If @ReturnCodeType in (1,3)
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
	From [Transfer] t with(nolock)
	left join 
		ReasonForCancel r with(nolock) on t.IdReasonForCancel=r.IdReasonForCancel
	where ClaimCode=@ClaimcodeCast
	--where ClaimCode=@Claimcode

	--Validar razon de cancelacion
	set @ReturnAllComission=isnull(@ReturnAllComission,0)

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
				exec st_SavePayInfoAppriza @IdGateway,@IdTransfer,@Claimcode,@XmlValue
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

			--Begin Try 
			--	insert into MoneyAlert.StatusChangePushMessage
			--	values
			--	(@Claimcode,getdate(),null,0)
			--End Try                                                                                            
			--Begin Catch
			-- Declare @ErrorMessage nvarchar(max)                                                                                             
			-- Select @ErrorMessage=ERROR_MESSAGE()                             
			-- Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCode',Getdate(),@ErrorMessage)                                                                                            
			--End Catch  

		End
	End
	Else
	Begin
		Select @Description='Return code UNKNOWN:'+@ReturnCode+' '+@str
		Exec st_SimpleAddNoteToTransfer  @IdTransfer,@Description
	End
	Set @IsCorrect=1

	--end-->
END TRY
BEGIN CATCH
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCodeAppriza',Getdate(),@ErrorMessage)
END CATCH
