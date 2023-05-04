CREATE procedure [dbo].[st_ResponseReturnCodeBankaya]
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
	declare @noteBankaya nvarchar(max)

	declare @ReturnCodeCast nvarchar(16)
	declare @ClaimcodeCast nvarchar(50)

	set @ReturnCodeCast = convert(nvarchar(16), @ReturnCode)
	set @ClaimcodeCast = convert(nvarchar(50), @Claimcode)

	set @str=''

	Select @IdStatusAction=A.IdStatusAction,@Description=B.ReturnCodeType+' code '+@ReturnCodeCast+', '+[Description]
	from GatewayReturnCode as A with(nolock) 
	inner Join GatewayReturnCodeType as B with(nolock) on (A.IdGatewayReturnCodeType=B.IdGatewayReturnCodeType)
	where A.IdGateway=@IdGateway And A.IdGatewayReturnCodeType=@ReturnCodeType And A.ReturnCode=@ReturnCodeCast


	Insert into BankayaResponseLog values (getdate(),@Claimcode,@ReturnCode,@ReturnCodeType,@IdStatusAction,@Description,@XmlValue)

	IF @ReturnCode='400' or @ReturnCode='404' or @ReturnCode='409' or @ReturnCode='500'
		BEGIN			
			SELECT	@noteBankaya =  ISNULL(T.[xmlString].value('(/ResponseTransfer/ERRORMESSAGE/node())[1]', 'NVARCHAR(MAX)'),'NULL') + '. Origin:' + 
									ISNULL(T.[xmlString].value('(/ResponseTransfer/ORIGIN/node())[1]', 'NVARCHAR(MAX)'),'NULL')
									FROM (SELECT @XmlValue AS [xmlString]) T				
				
				SET @Description = isnull(@Description,'') + isnull(@noteBankaya,'')
				
				--Exec st_SimpleAddNoteToTransfer  @IdTransfer,@Description

				--Return
		END
	IF @ReturnCode='403'
		Begin
			SELECT	@noteBankaya =  ISNULL(T.[xmlString].value('(/ResponseKyc/ERRORMESSAGE/node())[1]', 'NVARCHAR(MAX)'),'NULL') + '. Origin:' + 
									ISNULL(T.[xmlString].value('(/ResponseKyc/ORIGIN/node())[1]', 'NVARCHAR(MAX)'),'NULL')
									FROM (SELECT @XmlValue AS [xmlString]) T				
				
				SET @Description = isnull(@Description,'') + isnull(@noteBankaya,'')
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
			if (@IdStatusAction in (22,30,31))
			begin
				DECLARE	@HasErrorD bit,	@MessageOutD varchar(max)

				EXEC	[dbo].[st_DismissComplianceNotificationByIdTransfer]
	        		@IdTransfer,
					1,
					@HasErrorD OUTPUT,
					@MessageOutD OUTPUT
			end
		End
		ELSE
		BEGIN
					
				Exec st_SimpleAddNoteToTransfer  @IdTransfer,@Description
			
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
				      FOR XML PATH('CodeBankaya'), ELEMENTS)

    DECLARE @ErrorMessage nvarchar(max)
    Select  @ErrorMessage = ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ResponseReturnCodeBankaya: Parameters: ' + CONVERT(varchar(max),@Parameters) + ', ErrorLine: ' + CONVERT(VARCHAR,ERROR_LINE()),Getdate(),@ErrorMessage)
END CATCH