CREATE Procedure [dbo].[st_CreateTransferFromPreTransfer]
(
    @IdPreTransfer INT,
    --@IsSpanishLanguage bit,
    @IdLenguage int ,
    @IdCustomer int,
    @IdBeneficiary int,
    @IdPaymentType int,
    @IdCity int,
    @IdBranch int,
    @IdPayer int,
    @IdGateway int,
    @GatewayBranchCode nvarchar(max),
    @IdAgentPaymentSchema int,
    @IdAgent int,
    @IdAgentSchema int,
    @IdCountryCurrency int,
    @AmountInDollars money,
    @Fee money,
    @AgentCommission money,
    @CorporateCommission money,
    @ExRate money,
    @ReferenceExRate money,
    @AmountInMN money,
    @DepositAccountNumber nvarchar(max),
    @EnterByIdUser int,
    @TotalAmountToCorporate money,
    @BeneficiaryName nvarchar(max),
    @BeneficiaryFirstLastName nvarchar(max),
    @BeneficiarySecondLastName nvarchar(max),
    @BeneficiaryAddress nvarchar(max),
    @BeneficiaryCity nvarchar(max),
    @BeneficiaryState nvarchar(max),
    @BeneficiaryCountry nvarchar(max),
    @BeneficiaryZipcode nvarchar(max),
    @BeneficiaryPhoneNumber nvarchar(max),
    @BeneficiaryCelularNumber nvarchar(max),
    @CustomerName nvarchar(max),
    @CustomerIdCustomerIdentificationType int,
    @CustomerFirstLastName nvarchar(max),
    @CustomerSecondLastName nvarchar(max),
    @CustomerAddress nvarchar(max),
    @CustomerCity nvarchar(max),
    @CustomerState nvarchar(max),
    @CustomerZipcode nvarchar(max),
    @CustomerPhoneNumber nvarchar(max),
    @CustomerCelullarNumber nvarchar(max),
    @CustomerSSNumber nvarchar(max),
	@TypeTaxId int,
	@HasTaxId bit,
	@HasDuplicatedTaxId bit,
    @CustomerBornDate datetime,
    @CustomerOccupation nvarchar(max),
    @CustomerIdentificationNumber nvarchar(max),
    @CustomerExpirationIdentification datetime,
    @CustomerPurpose nvarchar(max),
    @CustomerRelationship nvarchar(max),
    @CustomerMoneySource nvarchar(max),
    @CustomerIdCarrier int,
	@CustomerIdOccupation int = 0, /*M00207*/
	@CustomerIdSubcategoryOccupation int = 0,/*M00207*/
	@CustomerSubcategoryOccupationOther nvarchar(max) =null,/*M00207*/
    @XmlRules xml,
    @IdTransferResend int,
    @OWBName nvarchar(max),
    @OWBFirstLastName nvarchar(max),
    @OWBSecondLastName nvarchar(max),
    @OWBAddress nvarchar(max),
    @OWBCity nvarchar(max),
    @OWBState nvarchar(max),
    @OWBZipcode nvarchar(max),
    @OWBPhoneNumber nvarchar(max),
    @OWBCelullarNumber nvarchar(max),
    @OWBSSNumber nvarchar(max),
    @OWBBornDate datetime,
    @OWBOccupation nvarchar(max),
    @OWBIdentificationNumber nvarchar(max),
    @OWBIdCustomerIdentificationType int,
    @OWBExpirationIdentification datetime,
    @OWBPurpose nvarchar(max),
    @OWBRelationship nvarchar(max),
    @OWBMoneySource nvarchar(max),
	@OWBIdOccupation int = 0,/*M00207*/
	@OWBIdSubcategoryOccupation int = 0,/*M00207*/
	@OWBSubcategoryOccupationOther nvarchar(max) =null,/*M00207*/
    @AgentCommissionExtra Money,
    @AgentCommissionOriginal Money,
    @AgentCommissionEditedByCommissionSlider Money,
    @AgentCommissionEditedByExchangeRateSlider Money,
    @StateTax Money,
    @OriginExRate Money,
    @OriginAmountInMN Money,
    @NoteAdditional varchar(max),
    @CustomerIdentificationIdCountry int,
    @CustomerIdentificationIdState int,
    @OWBRuleType int,
    @IdBeneficiaryIdentificationType int,
    @BeneficiaryIdentificationNumber nvarchar(max),
    @HasError bit out,
    @Message varchar(max) out,
    @IdTransferOutput int output,
    @SSNRequired bit = NULL,
    @IsSaveCustomer bit = NULL,
    @SendMoneyAlertInvitation BIT = NULL,
    @IdCustomerCountryOfBirth INT = NULL,
    @IdBeneficiaryCountryOfBirth INT = NULL,
    @BeneficiaryBornDate datetime = NULL,
    @CustomerReceiveSms BIT = 0,
    @ReSendSms BIT = 0,
    @AccountTypeId INT = NULL

    ,@CustomerOccupationDetail nvarchar(max) = NULL /*S44:REQ. MA.025*/
    ,@TransferIdCity int = NULL
    ,@BeneficiaryIdCarrier int = NULL
    ,@BranchCodePontual varchar(10) = NULL -- CR M00259	
	,@IsModify bit = 0
	,@OnlineTransfer	BIT = 0,
    @IdTransferOriginal BIGINT = 0,
	@IdPaymentMethod	INT = 1,
	@Discount			MONEY = 0,
	@OperationFee		MONEY = 0,
	@isValidCustomerPhoneNumber	BIT = 0,
	@IdDialingCodePhoneNumber INT = NULL,
	@ClaimCode					VARCHAR(50) = NULL
) 
as
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/10/30" Author="snevarez"> S44::REQ. MA.025 : Add detail for Other Occupations</log>
<log Date="18/01/2018" Author="azavala">Optimizacion Agente : Se elimino la actualizacion de Customer</log>
<log Date="28/08/2020" Author="jgomez">Optimizacion Agente : se agrega validacion cuando el tipo de cambio este activo por grupos</log>
<log Date="2020/09/03" Author="jgomez" Name="">-- CR M00259	</log>
<log Date="2020/10/04" Author="esalazar" Name="">-- CR M00207	</log>
<log Date="2019/08/13" Author="adominguez"> M00056 : Modificaiones</log>
<log Date="2022/12/07" Author="jcsierra">M1-530: Se agrega el @ClaimCode como parametro </log>
</ChangeLog>
********************************************************************/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
Declare @ActualExRate money
Declare @IdCurrencyUSA int
Declare @IdCurrencyPre int
Declare @OldIdStatus int,
		@IdPrimaryAgent int = 0,
		@IsSwitchSpecExRateGroup bit = 0,
		@MinutesToInvalidatePreTransfer INT;

Declare @CustomerCountry  nvarchar(max)
Set  @CustomerCountry='USA'  

if @IdLenguage is null 
    set @IdLenguage=2

if @IdBeneficiaryCountryOfBirth = 0
    set @IdBeneficiaryCountryOfBirth=null

if @IdCustomerCountryOfBirth = 0
    set @IdCustomerCountryOfBirth=null

if @CustomerOccupationDetail is Null Set @CustomerOccupationDetail='';
if @CustomerSubcategoryOccupationOther IS NULL Set @CustomerSubcategoryOccupationOther='';
if @OWBSubcategoryOccupationOther IS NULL Set @OWBSubcategoryOccupationOther='';  
if @TransferIdCity = 0 Set @TransferIdCity = NULL;
if @BeneficiaryIdCarrier = 0 Set @BeneficiaryIdCarrier = NULL;
SET @MinutesToInvalidatePreTransfer=(SELECT Value from GLOBALATTRIBUTES (nolock) where Name='PreTransferMinutesStillValid' ) 

iF exists (select 1 from pretransfer with(nolock) 
	where idpretransfer=@IdPreTransfer and isvalid=1 AND DATEDIFF(MINUTE, DateOfLastChange,GETDATE())>@MinutesToInvalidatePreTransfer)
begin 
    SET @HasError = 1
        SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'PRETRANSFERNOVALID')
    RETURN
end

    select @IdPrimaryAgent = IdPrimaryAgent from Agent A with(nolock) inner join AgentGroup AG with(nolock) on A.IdAgentGroup = AG.IdAgentGroup where IdAgent = @IdAgent

    select @IsSwitchSpecExRateGroup = IsSwitchSpecExRateGroup from Agent with(nolock) WHERE IsSwitchSpecExRateGroup = 1 AND IdAgent = @IdPrimaryAgent

	if (@IsSwitchSpecExRateGroup = 0) --CR M00256
	BEGIN
		if @OriginExRate!=1 and @IdCountryCurrency!=8
		begin
		    SELECT @ActualExRate = dbo.FunCurrentExRate(@IdCountryCurrency,@IdGateway,@IdPayer,@Idagent,@idcity,@IdPaymentType,@IdAgentSchema,@AmountInDollars)
		
		 INSERT INTO Soporte.InfoLogForStoreProcedure (StoreProcedure, InfoDate, InfoMessage, ExtraData)
		 VALUES ('st_CreateTransferFromPreTransfer', GETDATE(), ISNULL(@Message, ''), 'Actual Ex Rate: ' 
		 +CONVERT(varchar, ISNULL(@ActualExRate,'')) + ', Originala Ex Rate: ' + CONVERT(varchar, ISNULL(@OriginExRate,'')) 
		 + ', IdPre Transfer: ' + CONVERT(varchar, ISNULL(@IdPreTransfer,''))  
		 +' IdCountrycurrency ' + CONVERT(varchar,ISNULL(@IdCountryCurrency,''))+' IdGateway '+ CONVERT(varchar,ISNULL(@IdGateway,''))
		 +' IdPayer '+ CONVERT(varchar,ISNULL(@IdPayer,''))+' IdAgent '+ CONVERT(varchar,ISNULL(@Idagent,''))
		 + ' IdCity '+CONVERT(varchar,@idcity)+ CONVERT(varchar,@IdPaymentType)+' IdAgentSchema '+ CONVERT(varchar,@IdAgentSchema)+' Amount '+ CONVERT(varchar,@AmountInDollars)
		 );

		    --if @ActualExRate<>@OriginExRate and @IdPreTransfer>0 and @IsModify=0
		    --BEGIN
		    --    SET @HasError = 1
		    --    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'PRETRANSFEREXPIRED1')

				

		    --    RETURN
		    --END
		end 
	end --END CR M00256

set @IsSaveCustomer=isnull(@IsSaveCustomer,0)
--generar envio

exec [dbo].[st_CreateTransfer]
    @IdLenguage,
    @IdCustomer, --@IdCustomer
    @IdBeneficiary, --@IdBeneficiary
    @IdPaymentType, --idpaymenttype
    @IdCity, --idcity
    @IdBranch, --idbranch
    @IdPayer, --idpayer
    @IdGateway, --idgateway
    @GatewayBranchCode, --gatewaybranchcode
    @IdAgentPaymentSchema, --idagentpaymentschema
    @IdAgent, --@IdAgent(3188-Aguascalientes)
    @IdAgentSchema, --@IdAgentSchema
    @IdCountryCurrency, --@IdCountryCurrency
    @AmountInDollars, --@AmountInDollars
    @Fee, --@Fee
    @AgentCommission , --@AgentCommission
    @CorporateCommission , --@CorporateCommission
    @ExRate , --@ExRate
    @ReferenceExRate , --@ReferenceExRate
    @AmountInMN, --@AmountInMN
    @DepositAccountNumber, --depositacountnumber
    @EnterByIdUser , --@EnterByIdUser(JoseAgent1)
    @TotalAmountToCorporate,--@TotalAmountToCorporate
    @BeneficiaryName,
    @BeneficiaryFirstLastName,
    @BeneficiarySecondLastName,
    @BeneficiaryAddress , --beneficiaryadreess
    @BeneficiaryCity,
    @BeneficiaryState,
    @BeneficiaryCountry , --beneficiarycountry
    @BeneficiaryZipcode,
    @BeneficiaryPhoneNumber,
    @BeneficiaryCelularNumber, --@BeneficiaryCelularNumber
    @CustomerName,
    @CustomerIdCustomerIdentificationType ,
    @CustomerFirstLastName,
    @CustomerSecondLastName,
    @CustomerAddress,
    @CustomerCity,
    @CustomerState,
    @CustomerZipcode,
    @CustomerPhoneNumber,
    @CustomerCelullarNumber,
    @CustomerSSNumber ,
	@TypeTaxId,
	@HasTaxId,
	@HasDuplicatedTaxId,
    @CustomerBornDate ,
    @CustomerOccupation ,
    @CustomerIdentificationNumber , --@CustomerIdentificationNumber
    @CustomerExpirationIdentification,
    @CustomerPurpose,
    @CustomerRelationship,
    @CustomerMoneySource,
    @CustomerIdCarrier ,
	@CustomerIdOccupation , /*M00207*/
	@CustomerIdSubcategoryOccupation ,/*M00207*/
	@CustomerSubcategoryOccupationOther,/*M00207*/
    @XmlRules , --@XmlRules
    @IdTransferResend , --@IdTransferResend
    @OWBName , --owb
    @OWBFirstLastName ,
    @OWBSecondLastName ,
    @OWBAddress ,
    @OWBCity ,
    @OWBState ,
    @OWBZipcode ,
    @OWBPhoneNumber ,
    @OWBCelullarNumber ,
    @OWBSSNumber ,
    @OWBBornDate ,
    @OWBOccupation ,
    @OWBIdentificationNumber ,
    @OWBIdCustomerIdentificationType ,
    @OWBExpirationIdentification ,
    @OWBPurpose ,
    @OWBRelationship ,
    @OWBMoneySource ,
	@OWBIdOccupation,/*M00207*/
	@OWBIdSubcategoryOccupation,/*M00207*/
	@OWBSubcategoryOccupationOther,/*M00207*/
    @AgentCommissionExtra , --@AgentCommissionExtra
    @AgentCommissionOriginal , --@AgentCommissionOriginal
    @AgentCommissionEditedByCommissionSlider , --@AgentCommissionEditedByCommissionSlider
    @AgentCommissionEditedByExchangeRateSlider , --@AgentCommissionEditedByExchangeRateSlider
    @StateTax,
    @OriginExRate , --@OriginExRate
    @OriginAmountInMN , --@OriginAmountInMN
    @NoteAdditional, --@NoteAdditional
    @CustomerIdentificationIdCountry,
    @CustomerIdentificationIdState,
    @OWBRuleType,
    @IdBeneficiaryIdentificationType,
    @BeneficiaryIdentificationNumber,
    @HasError out,
    @Message out,
    @IdTransferOutput out,
    @SSNRequired,
    @IsSaveCustomer,
    @SendMoneyAlertInvitation,
    @IdCustomerCountryOfBirth,
    @IdBeneficiaryCountryOfBirth,
    @BeneficiaryBornDate,
    @CustomerReceiveSms,
    @ReSendSms,
    @AccountTypeId,
	@IsModify,
	@IdPreTransfer,

    @CustomerOccupationDetail,
    @TransferIdCity,
    @BeneficiaryIdCarrier,
	@BranchCodePontual,		-- CR M00259
    0,
    @OnlineTransfer,
    @IdTransferOriginal,
	@IdPaymentMethod,
	@Discount,
	@OperationFee,
	@isValidCustomerPhoneNumber,
	@IdDialingCodePhoneNumber,
	@ClaimCode
	--Para requerimiento de Modificaciones
	--if @IsModify = 1
	--Begin
	--	Select @OldIdStatus= IdStatus from [Transfer] with(nolock) where IdTransfer = @IdPreTransfer
	--	Insert into TransferModify (OldIdTransfer,NewIdTransfer,CreatedBy,CreateDate,OldIdStatus,IsCancel) values(@IdPreTransfer, @IdTransferOutput, @EnterByIdUser, GETDATE(),@OldIdStatus, 0)
	--end


    --eliminar preenvio
    IF @HasError=0 and @IdPreTransfer>0
    BEGIN
        --DELETE FROM dbo.PreTransfer WHERE IdPreTransfer=@IdPreTransfer    
        update dbo.PreTransfer set [status]=1, IdTransfer=@IdTransferOutput WHERE IdPreTransfer=@IdPreTransfer;  
    END
