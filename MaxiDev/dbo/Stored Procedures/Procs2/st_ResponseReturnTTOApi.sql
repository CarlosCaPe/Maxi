CREATE procedure [dbo].[st_ResponseReturnTTOApi]                                        
(                                        
    @IdGateway  int,
    @Claimcode  nvarchar(max),
    @ReturnCode nvarchar(max),
    @ReturnCodeType int,
    @XmlValue xml,
    @IsCorrect bit Output
)
/********************************************************************
<Author></Author>
<app></app>
<Description></Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="05/10/2018" Author="snevarez">Categorization of error codes for second attempts & Add Serial(TTApiSerial)</log>
</ChangeLog>
*********************************************************************/
AS                                  
Set nocount on                                  
Declare @Description nvarchar(max)                                    
Declare @IdStatusAction int                                    
Declare @IdTransfer int          
Declare @ActualIdStatus int                                   
Declare @str varchar(max)     
declare @ReturnAllComission int    

/*----05/10/2018-Begin----*/
IF(@ReturnCode in ('E02','E03') And @ReturnCodeType = 1)
BEGIN
    DECLARE @ReturnCodeError VARCHAR(25);
    DECLARE @ReturnMsgError VARCHAR(MAX);
    DECLARE @IsError BIT;
    EXEC [dbo].[st_ReturnErrorCodeTTAPI] @XmlValue, @ReturnCodeError OUTPUT, @ReturnMsgError OUTPUT, @IsError OUTPUT;

    IF(@IsError = 1)
    BEGIN
	   SET @ReturnCode = @ReturnCodeError;
    END
END
/*----05/10/2018-End----*/

set @str='';

Select 
    @IdStatusAction = A.IdStatusAction
    ,@Description = B.ReturnCodeType + ' code ' + @ReturnCode + ',' + Description
From GatewayReturnCode AS A WITH(NOLOCK)
    Join GatewayReturnCodeType AS B  WITH(NOLOCK) on (A.IdGatewayReturnCodeType = B.IdGatewayReturnCodeType)
Where A.IdGateway = @IdGateway 
    And A.IdGatewayReturnCodeType = @ReturnCodeType
    And A.ReturnCode = @ReturnCode

/*----05/10/2018-Begin----*/
DECLARE @ClaimcodeTmp nvarchar(max) = @Claimcode;
SET @Claimcode = (Select Top 1 item From [dbo].[fnSplit](@Claimcode,'_'));
IF(@Claimcode = @ClaimcodeTmp)
BEGIN    
    Insert into [MAXILOG].[dbo].[TTOApiResponseLog] values (getdate(),@Claimcode,@ReturnCode,@ReturnCodeType,@IdStatusAction,@Description,@XmlValue)
END
ELSE
BEGIN
    Insert into [MAXILOG].[dbo].[TTOApiResponseLog] values (getdate(),@Claimcode,@ReturnCode,@ReturnCodeType,@IdStatusAction,(@Description+ '; New tracking ' + @ClaimcodeTmp),@XmlValue)
END
/*----05/10/2018-End----*/
--Insert into [MAXILOG].[dbo].[TTOApiResponseLog] values (getdate(),@Claimcode,@ReturnCode,@ReturnCodeType,@IdStatusAction,@Description,@XmlValue)


If @ReturnCodeType=3 or @ReturnCodeType=1
Begin
 Set @str = COALESCE(@str + ';', '') + @XmlValue.value('(/Message/node())[1]', 'nvarchar(max)')
 Set @Description = @Description + ' ' + @str
End


Select 
    @IdTransfer=IdTransfer,
    @ActualIdStatus=IdStatus,
    @ReturnAllComission=ReturnAllComission 
From Transfer AS t WITH(NOLOCK)
    left join ReasonForCancel AS r WITH(NOLOCK) on t.IdReasonForCancel=r.IdReasonForCancel
where ClaimCode = @Claimcode

--Validar razon de cancelacion
set @ReturnAllComission=isnull(@ReturnAllComission,0)

If @IdStatusAction>0
Begin
    If @IdTransfer is not null and @ActualIdStatus<>@IdStatusAction
    Begin

	   /*----05/10/2018-Begin----*/
	   --24	Returned
	   IF(@IdStatusAction=24)
	   BEGIN
		  IF EXISTS(SELECT 1 FROM [dbo].[TTApiSerial] WITH(NOLOCK) WHERE [IdTransfer] = @IdTransfer)
		  BEGIN
			 DECLARE @Serial INT = 0;
			 SET @Serial = (SELECT TOP 1 [Serial] FROM [dbo].[TTApiSerial] WITH(NOLOCK) WHERE [IdTransfer] = @IdTransfer) + 1;
			 UPDATE [dbo].[TTApiSerial] SET [Serial] = @Serial WHERE [IdTransfer] = @IdTransfer;
		  END
		  ELSE
		  BEGIN
			 INSERT INTO [dbo].[TTApiSerial] ([IdTransfer],[Serial]) VALUES (@IdTransfer, 1);
		  END

		  DECLARE @ClaimCodeNew VARCHAR(100);
		  SET @ClaimCodeNew = (Select ClaimCode + '_' + CONVERT(nvarchar(max),s.serial) 
							 FROM transfer AS t WITH(NOLOCK)
								Inner join [dbo].[TTApiSerial] AS s WITH(NOLOCK) on t.IdTransfer=s.IdTransfer
							 WHERE T.IdTransfer = @IdTransfer);

		  SET @Description = @Description + '; New tracking ' + @ClaimCodeNew;
	   END
	   /*----05/10/2018-End----*/

	   Update Transfer set IdStatus=@IdStatusAction,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer
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
			 Declare @UnclaimedStatus int;
			 set @UnclaimedStatus = 27;
			 Update TransfersUnclaimed set IdStatus=2 where IdTransfer=@IdTransfer;
			 Update Transfer set IdStatus=@UnclaimedStatus,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer;
			 Exec st_SaveChangesToTransferLog @IdTransfer,@UnclaimedStatus,@Description,0
		  End
	   End
	   --If @IdStatusAction=30  -- Paid
		  --Begin
	   --    exec st_SavePayInfoTNW @IdGateway,@IdTransfer,@Claimcode,@XmlValue
	   --End
	   If (@IdStatusAction in (22,30,31))
	   begin
		  DECLARE	@HasErrorD bit, @MessageOutD varchar(max);

		  EXEC	[dbo].[st_DismissComplianceNotificationByIdTransfer]
			 @IdTransfer,
				1,
				@HasErrorD OUTPUT,
				@MessageOutD OUTPUT
	   end
    End
End
Else
Begin
	Select @Description='Return code UNKNOWN:' + @ReturnCode + ' '  +@str;
	Exec st_SimpleAddNoteToTransfer  @IdTransfer,@Description
End
Set @IsCorrect=1