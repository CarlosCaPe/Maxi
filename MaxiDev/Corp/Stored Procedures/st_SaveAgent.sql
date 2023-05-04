CREATE PROCEDURE [Corp].[st_SaveAgent](
	@idAgent int,
    @idAgentCommunication int,
    @cancelReturnCommission bit,
    @showLogo bit  = NULL,
    @excludeReportExRates bit,
    @excludeReportSignatureHold bit,
    @guarantorBornCountry varchar(MAX),
    @showAgentProfitWhenSendingTransfer bit,
    --@county varchar(MAX),
    @idAgentCollectType int,
    @exrateBottom money,
    @exrateTop money,
    @commissionBottom money,
    @commissionTop money,
    @switchExrate bit,
    @switchCommission bit,
    @doneOnSaturdayPayOn int,
    @doneOnFridayPayOn int ,
    @doneOnThursdayPayOn int,
    @doneOnWednesdayPayOn int,
    @doneOnTuesdayPayOn int,
    @doneOnMondayPayOn int,
    @doneOnSundayPayOn int,
    @businessPermissionExpiration datetime = NULL,
    @businessPermissionNumber varchar(MAX),
    @closeDate datetime,
    @openDate datetime,
    @notes varchar(MAX),
    @amountRequiredToAskId money,
    @creditAmount money,
    @taxId varchar(MAX),
    @guarantorBornDate datetime = NULL,
    @guarantorIdExpirationDate datetime = NULL,
    @guarantorIdNumber varchar(MAX),
    @guarantorIdType varchar(MAX),
    @guarantorSsn varchar(MAX),
    @guarantorEmail varchar(MAX),
    @guarantorCel varchar(MAX),
    @guarantorPhone varchar(MAX),
    @guarantorZipcode varchar(MAX),
    @guarantorState varchar(MAX),
    @guarantorCity varchar(MAX),
    @guarantorAddress varchar(MAX),
    @guarantorSecondLastName varchar(MAX),
    @guarantorLastName varchar(MAX),
    @guarantorName varchar(MAX),
    @agentBusinessType varchar(MAX),
    @agentTimeInBusiness varchar(MAX),
    @agentContact varchar(MAX),
    @agentEmail varchar(MAX),
    @agentPhone varchar(MAX),
    @agentFax varchar(MAX),
    @agentZipcode varchar(MAX),
    @agentState varchar(MAX),
    @agentCity varchar(MAX),
    @agentAddress varchar(MAX),
    @agentCode varchar(MAX),
	@AgentStateCode varchar(MAX),
    @agentName varchar(MAX),
    @idOwner int,
    @idAgentBankDeposit int = NULL,
    @idAgentReceiptType int = NULL,
    @idAgentPaymentSchema int ,
    @idUserOpeningSalesRep int = NULL,
    @idUserSeller int,
    @idAgentType int,
    --@folio int,
    @idAgentClass int,
    @accountNumber varchar(MAX),
    @routingNumber varchar(MAX),
    @retainMoneyCommission bit,
	@DoingBusinessAs nvarchar(MAX) = NULL,
	@phoneNumbers XML,
	@idAgentStatus int,
	@enteredByIdUser int,
	@IsSpanishLanguage bit,
    @IdAgentCommissionPay int = null,
    @SubAccount nvarchar(max) = null,
    @UsePIN bit = null,
    @UsePayNow bit = null,
    @idcounty int = null,
    @idcountyguarantor int = null,
	@idTimeZone int = null,
	@Hours XML,
	@accountNumberCommission varchar(MAX),
    @routingNumberCommission varchar(MAX),
	@BlockPhoneTransactions BIT,
	@MoneyAlertInvitation BIT,
	@CheckEditMicr BIT,
	@NeedsWFSubaccount BIT,
	@RequestWFSubaccount BIT,
	@IsSwitchSpecExRateGroup  Bit = 0, --M00256
	@AgentBusinessWebsite			NVARCHAR(150) = NULL,
	@AgentFinCENReg				BIT = NULL,
	@AgentFinCENRegExpiration		DATE = NULL,
	@AgentCheckCasher				BIT = NULL,
	@AgentCheckLicense				BIT = NULL,
	@AgentCheckLicenseNumber		VARCHAR(50) = NULL,
	@MailCheckTo					VARCHAR(20) = NULL,
	@ComplianceOfficerDateOfBirth	DATE = NULL,
	@ComplianceOfficerPlaceofBirth	VARCHAR(250) = NULL,
	@ComplianceOfficerName			VARCHAR(250) = NULL,
	@AgentCollectTypeRelAgentXml	XML = NULL,
	@IdAgentBusinessType			INT = NULL,
	@IdTaxIDType					INT = NULL,
	@HasError bit out,
	@MessageOut varchar(max) out,
	@IdAgentOut int out,
	@agentCodeOut varchar(max) OUT
	
	
)            
AS         
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="13/02/2017" Author="mdelgado">Add delete AgentLocation when updated Agent</log>
<log Date="15/03/2017" Author="mdelgado">Add Log of Change to Phone Fax email and Additional Phones</log>
<log Date="04/07/2017" Author="mdelgado">S27 :: Add Log/Fields for Changes to Needs/Request Wells Fargo</log>
<log Date="24/08/2017" Author="dalmeida">S36 :: Add column state code to agent</log>
<log Date="17/10/2018" Author="azavala">FIX :: Modified IF to Disabled Exception for Agent with Bank ACH and CollectType ACH or ACH with Scanner</log>
<log Date="26/10/2018" Author="jdarellano" Name="#1">Ticket 1486.- Se quita regla de eliminación de excepciones para agencias que no cumplan con ACH</log>
<log Date="17/08/2020" Author="jgomez" Name="#1">M00256 - PERMITIR MODIFICACIONES DEL TIPO DE CAMBIO EN AGENTE</log>
<log Date="07/09/2022" Author="cagarcia">MP1236_PaymentMethods se agrega relacion con los CollectTypes</log>
<log Date="08/09/2022" Author="cagarcia">MP1064/SD1-2024 - Add duplicate SSN validation</log>
<log Date="07/10/2022" Author="cagarcia">SD1-2288 Se agrega campo IdAgentBusinessType</log>
<log Date="17/10/2022" Author="cagarcia">SD1-2289 Se agrega campo IdTaxIdType</log>
<log Date="03/02/2023" Author="maprado">BM-668 Se setea @cancelReturnCommission a 1</log>
<log Date="2023/02/20" Author="jdarellano">Se setea variable @IdTaxIDType a 1 cuando se recibe 0 ó nulo (Ticket 7323).</log>
<log Date="22/02/2023" Author="cagarcia">BM-860: Se quita validacion de SSN de Owner duplicado </log>
</ChangeLog>

********************************************************************/
   
Begin Try

declare @SystemUser int
declare @agentClass nvarchar(5)

set @closeDate = case when @idAgentStatus in (2,5,6) then getdate() else '1900-01-01 00:00:00.000' END

IF ISNULL(@IdTaxIDType,0) = 0
BEGIN
	SET @IdTaxIDType = 1;
END;

--------------------------- validating IdAgentPaymentSchema
--if (@IdAgentPaymentSchema=2) --retain?
--begin
--	set @IdAgentCommissionPay =null
--end
---------------------

	-- Types of history
	DECLARE @agentPhoneType			  nvarchar(25) = 'AgentPhone'
	DECLARE @agentFaxType			  nvarchar(25) = 'AgentFax'
	DECLARE @agentEmailType			  nvarchar(25) = 'AgentEmail'
	DECLARE @agentAdditionalPhoneType nvarchar(25) = 'AgentAdditionalPhone'
	DECLARE @agentClassType			  nvarchar(25) = 'AgentClass'
	
	DECLARE @NeedsWFSubaccountType    nvarchar(MAX) = 'NeedsWFSubaccount'
	DECLARE @RequestWFSubaccountType  nvarchar(MAX) = 'RequestWFSubaccount'
	
	--BM-668 BEGIN
	SET @cancelReturnCommission = 1
	--BM-668 END
	
	/*Validacion SSN de Owner duplicada*/
--	IF(EXISTS(SELECT TOP 1 1
--	          FROM Owner WITH(nolock)
--	          WHERE SSN = @taxId AND IdOwner != @idOwner))
--	BEGIN
--	    SET @HasError = 1
--	    SET @MessageOut = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage, 84)
--	    RETURN;
--	END

	Set @HasError=0
	set @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,81)

	DECLARE	@return_value int,
		        @IsValid bit
				
	set @agentCodeOut = @agentCode
	set @IsValid=1

    select @SystemUser=convert(int,[dbo].[GetGlobalAttributeByName]('SystemUserID'))


	set @agentClass = (Select Description from dbo.AgentClass with(nolock) where IdAgentClass = @idAgentClass)

	if(exists (select top  1 1 from dbo.agent with(nolock) where AgentCode = @agentCode and IdAgent != @idAgent))
		begin 
		
		Set @IsValid=0
		if(@idAgent = 0)
			begin

				EXEC	@return_value = [Corp].[st_GetNewAgentCode]
						@StateCode = @agentState,
						@EnterByIdUser = @enteredByIdUser,
						@agentCode = @AgentCode OUTPUT,
						@IsValid = @IsValid OUTPUT

					set @agentCodeOut = @agentCode

						if(@IsValid = 0)
							begin

								Set @HasError=1
								set @MessageOut  = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,83)
								set @IdAgentOut = 0

							end
			end
		else
			begin
				Set @HasError=1
				set @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,83)
				set @IdAgentOut = 0
			end
		
		end
	if(@IsValid = 1)
		begin
			if(@idAgent > 0)
				begin
					if(exists (select top  1 1 from dbo.agent with(nolock) where IdAgent = @idAgent))
						begin

							--validacion para insertar el historial de credit limit 
							if(ISNULL((select creditamount from dbo.agent with(nolock) where idagent = @idAgent),0) != @creditAmount)
								begin
									insert into dbo.creditlimithistory(IdAgent, creditlimit, DateOfCreation, EnteredByIdUser) values (@idAgent, @creditAmount, GETDATE(),@enteredByIdUser)								
                                    update dbo.AgentCreditApproval set IsApproved=0 , DateOfLastChange=getdate() , EnterByIdUser=@SystemUser where idagent=@idAgent and IsApproved is null
								end

                            exec [Corp].[st_SaveAgentMirror] @IdAgent

							update dbo.Agent set 
							  IdAgentCommunication = @idAgentCommunication
							  ,CancelReturnCommission = @cancelReturnCommission
							  ,ShowLogo = @showLogo
							  ,ExcludeReportExRates = @excludeReportExRates
							  ,ExcludeReportSignatureHold = @excludeReportSignatureHold
							  ,GuarantorBornCountry = @guarantorBornCountry
							  ,ShowAgentProfitWhenSendingTransfer = @showAgentProfitWhenSendingTransfer
							  --,county = @county
                              ,idcounty=@idcounty
                              ,idcountyguarantor=@idcountyguarantor
							  ,IdAgentCollectType = @idAgentCollectType
							  ,ExrateBottom = @exrateBottom
							  ,ExrateTop = @exrateTop
							  ,CommissionBottom = @commissionBottom
							  ,CommissionTop = @commissionTop
							  ,SwitchExrate = @switchExrate
							  ,SwitchCommission = @switchCommission
							  ,DoneOnSaturdayPayOn = @doneOnSaturdayPayOn
							  ,DoneOnFridayPayOn = @doneOnFridayPayOn
							  ,DoneOnThursdayPayOn = @doneOnThursdayPayOn
							  ,DoneOnWednesdayPayOn = @doneOnWednesdayPayOn
							  ,DoneOnTuesdayPayOn = @doneOnTuesdayPayOn
							  ,DoneOnMondayPayOn = @doneOnMondayPayOn
							  ,DoneOnSundayPayOn = @doneOnSundayPayOn
							  ,BusinessPermissionExpiration = @businessPermissionExpiration
							  ,BusinessPermissionNumber = @businessPermissionNumber
							  --,CloseDate = @closeDate
							  ,OpenDate = @openDate
							  ,Notes = @notes
							  ,AmountRequiredToAskId = @amountRequiredToAskId
							  ,CreditAmount = @creditAmount 
							  ,TaxID = @taxId
							  ,GuarantorBornDate = @guarantorBornDate
							  ,GuarantorIdExpirationDate = @guarantorIdExpirationDate
							  ,GuarantorIdNumber = @guarantorIdNumber
							  ,GuarantorIdType = @guarantorIdType
							  ,GuarantorSSN = @guarantorSsn
							  ,GuarantorEmail = @guarantorEmail
							  ,GuarantorCel = @guarantorCel
							  ,GuarantorPhone = @guarantorPhone
							  ,GuarantorZipcode = @guarantorZipcode
							  ,GuarantorState = @guarantorState
							  ,GuarantorCity = @guarantorCity
							  ,GuarantorAddress = @guarantorAddress
							  ,GuarantorSecondLastName = @guarantorSecondLastName
							  ,GuarantorLastName = @guarantorLastName
							  ,GuarantorName = @guarantorName
							  ,AgentBusinessType = @agentBusinessType 
							  ,AgentTimeInBusiness= @agentTimeInBusiness
							  ,AgentContact = @agentContact
							  ,AgentEmail = @agentEmail
							  ,AgentPhone = @agentPhone
							  ,AgentFax = @agentFax
							  ,AgentZipcode = @agentZipcode
							  ,AgentState = @agentState
							  ,AgentCity = @agentCity
							  ,AgentAddress = @agentAddress
							  ,AgentCode = @agentCode
							  ,StateCode = @AgentStateCode
							  ,AgentName = @agentName
							  ,IdOwner = @idOwner
							  ,IdAgentBankDeposit = @idAgentBankDeposit
							  ,IdAgentReceiptType = @idAgentReceiptType
							  ,IdAgentPaymentSchema = @idAgentPaymentSchema
							  ,IdUserOpeningSalesRep = @idUserOpeningSalesRep
							  ,IdUserSeller = @idUserSeller
							  ,IdAgentType = @idAgentType
							  --,Folio = @folio
							  ,IdAgentClass = @idAgentClass
							  ,AccountNumber = @accountNumber
							  ,RoutingNumber = @routingNumber
							  ,RetainMoneyCommission = @retainMoneyCommission
							  ,EnterByIdUser = @enteredByIdUser
							  ,DateOfLastChange = GETDATE()
							  ,IdAgentStatus = @idAgentStatus
							  ,DoingBusinessAs = @DoingBusinessAs
                              ,IdAgentCommissionPay = @IdAgentCommissionPay
                              ,SubAccount =@SubAccount
							  ,AccountNumberCommission = @accountNumberCommission
							  ,RoutingNumberCommission = @routingNumberCommission
                              ,UsePIN = isnull(@UsePIN,0)
                              ,UsePayNow = isnull(@UsePayNow,0)
							  ,BlockPhoneTransactions = @BlockPhoneTransactions
							  ,MoneyAlertInvitation = @MoneyAlertInvitation
							  ,CheckEditMicr = @CheckEditMicr
							  ,IdTimeZone = @idTimeZone
							  ,NeedsWFSubaccount = @NeedsWFSubaccount
							  ,NeedsWFSubaccountIduser = CASE WHEN NeedsWFSubaccount <> @NeedsWFSubaccount THEN @enteredByIdUser ELSE NeedsWFSubaccountIduser END
							  ,NeedsWFSubaccountDate = CASE WHEN NeedsWFSubaccount <> @NeedsWFSubaccount THEN GETDATE() ELSE NeedsWFSubaccountDate END
							  ,RequestWFSubaccount = @RequestWFSubaccount
							  ,IsSwitchSpecExRateGroup  = @IsSwitchSpecExRateGroup --M00256
							  ,ExpirationDateExRateGroup = GETDATE() --M00256
							  ,RequestWFSubaccountIdUser = CASE WHEN RequestWFSubaccount <> @RequestWFSubaccount THEN @enteredByIdUser ELSE RequestWFSubaccountIdUser END
							  ,RequestWFSubaccountDate = CASE WHEN RequestWFSubaccount <> @RequestWFSubaccount THEN GETDATE() ELSE RequestWFSubaccountDate END
							  ,AgentBusinessWebsite = isnull(@AgentBusinessWebsite, AgentBusinessWebsite)
							  ,AgentFinCENReg = @AgentFinCENReg
							  ,AgentFinCENRegExpiration = @AgentFinCENRegExpiration
							  ,AgentCheckCasher = @AgentCheckCasher
							  ,AgentCheckLicense = @AgentCheckLicense
							  ,AgentCheckLicenseNumber = isnull(@AgentCheckLicenseNumber, AgentCheckLicenseNumber)
							  ,MailCheckTo = @MailCheckTo
							  ,ComplianceOfficerDateOfBirth = @ComplianceOfficerDateOfBirth
							  ,ComplianceOfficerPlaceOfBirth = isnull(@ComplianceOfficerPlaceofBirth, ComplianceOfficerPlaceOfBirth)
							  ,ComplianceOfficerName = isnull(@ComplianceOfficerName, ComplianceOfficerName)
							  ,IdAgentBusinessType = @IdAgentBusinessType
							  ,IdTaxIDType = @IdTaxIDType
							where IdAgent = @idAgent;
							
							

							EXEC [Corp].[st_saveAgentChangeHistory] @idAgent, @agentPhone, @agentPhoneType, @enteredByIdUser, 0;
							EXEC [Corp].[st_saveAgentChangeHistory] @idAgent, @agentFax, @agentFaxType, @enteredByIdUser, 0;
							EXEC [Corp].[st_saveAgentChangeHistory] @idAgent, @agentEmail, @agentEmailType, @enteredByIdUser, 0;
							EXEC [Corp].[st_saveAgentChangeHistory] @idAgent, @agentClass, @agentClassType, @enteredByIdUser, 0;
							-- History of Wells Fargo Needs & Request

							EXEC [Corp].[st_saveAgentChangeHistory] @idAgent, @NeedsWFSubaccount,@NeedsWFSubaccountType, @enteredByIdUser, 0;							
							EXEC [Corp].[st_saveAgentChangeHistory] @idAgent, @RequestWFSubaccount, @RequestWFSubaccountType , @enteredByIdUser, 0;
							
							
							delete from dbo.AgentLocation where idAgent = @idAgent;
						end
					else
						begin
							Set @HasError=1
							set @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,85)
						end
					set @IdAgentOut = @idAgent
				end
			else
				begin
				
					insert into dbo.Agent( 
						 IdAgentCommunication
						,CancelReturnCommission
						,ShowLogo
						,ExcludeReportExRates
						,ExcludeReportSignatureHold
						,GuarantorBornCountry
						,ShowAgentProfitWhenSendingTransfer
						--,county
                        ,idcounty
                        ,idcountyguarantor
						,IdAgentCollectType
						,ExrateBottom
						,ExrateTop
						,CommissionBottom
						,CommissionTop
						,SwitchExrate
						,SwitchCommission
						,DoneOnSaturdayPayOn
						,DoneOnFridayPayOn
						,DoneOnThursdayPayOn
						,DoneOnWednesdayPayOn
						,DoneOnTuesdayPayOn
						,DoneOnMondayPayOn
						,DoneOnSundayPayOn
						,BusinessPermissionExpiration
						,BusinessPermissionNumber
						,CloseDate
						,OpenDate
						,Notes
						,AmountRequiredToAskId
						,CreditAmount
						,TaxID
						,GuarantorBornDate
						,GuarantorIdExpirationDate
						,GuarantorIdNumber
						,GuarantorIdType
						,GuarantorSSN
						,GuarantorEmail
						,GuarantorCel
						,GuarantorPhone
						,GuarantorZipcode
						,GuarantorState
						,GuarantorCity
						,GuarantorAddress
						,GuarantorSecondLastName
						,GuarantorLastName
						,GuarantorName
						,AgentBusinessType
						,AgentTimeInBusiness
						,AgentContact
						,AgentEmail
						,AgentPhone
						,AgentFax
						,AgentZipcode
						,AgentState
						,AgentCity
						,AgentAddress
						,AgentCode
						,AgentName
						,IdOwner
						,IdAgentBankDeposit
						,IdAgentReceiptType
						,IdAgentPaymentSchema
						,IdUserOpeningSalesRep
						,IdUserSeller
						,IdAgentType
						,CreationDate
						--,Folio
						,IdAgentClass
						,AccountNumber
						,RoutingNumber
						,RetainMoneyCommission
						,EnterByIdUser
						,DateOfLastChange
						,IdAgentStatus
						,DoingBusinessAs
                        ,IdAgentCommissionPay
                        ,SubAccount
						,AccountNumberCommission
					    ,RoutingNumberCommission
                        ,UsePIN
                        ,UsePayNow
						,BlockPhoneTransactions
						,MoneyAlertInvitation
						,CheckEditMicr
						,IdTimeZone
						,NeedsWFSubaccount
						,NeedsWFSubaccountDate
						,NeedsWFSubaccountIduser
						,RequestWFSubaccount
						,IsSwitchSpecExRateGroup --M00256
						,ExpirationDateExRateGroup --M00256
						,RequestWFSubaccountDate
						,RequestWFSubaccountIdUser
						,IdAgentBusinessType
						,IdTaxIDType
					) values (
						@idAgentCommunication ,
						@cancelReturnCommission ,
						@showLogo,
						@excludeReportExRates ,
						@excludeReportSignatureHold ,
						@guarantorBornCountry ,
						@showAgentProfitWhenSendingTransfer ,
						--@county ,
                        @idcounty,
                        @idcountyguarantor,
						@idAgentCollectType ,
						@exrateBottom ,
						@exrateTop ,
						@commissionBottom ,
						@commissionTop ,
						@switchExrate ,
						@switchCommission ,
						@doneOnSaturdayPayOn ,
						@doneOnFridayPayOn  ,
						@doneOnThursdayPayOn ,
						@doneOnWednesdayPayOn ,
						@doneOnTuesdayPayOn ,
						@doneOnMondayPayOn ,
						@doneOnSundayPayOn ,
						@businessPermissionExpiration ,
						@businessPermissionNumber ,
						@closeDate,
						@openDate,
						@notes ,
						@amountRequiredToAskId ,
						@creditAmount ,
						@taxId ,
						@guarantorBornDate ,
						@guarantorIdExpirationDate ,
						@guarantorIdNumber ,
						@guarantorIdType ,
						@guarantorSsn ,
						@guarantorEmail ,
						@guarantorCel ,
						@guarantorPhone ,
						@guarantorZipcode ,
						@guarantorState ,
						@guarantorCity ,
						@guarantorAddress ,
						@guarantorSecondLastName ,
						@guarantorLastName ,
						@guarantorName ,
						@agentBusinessType ,
						@agentTimeInBusiness ,
						@agentContact ,
						@agentEmail ,
						@agentPhone ,
						@agentFax ,
						@agentZipcode ,
						@agentState ,
						@agentCity ,
						@agentAddress ,
						@agentCode ,
						@agentName ,
						@idOwner ,
						@idAgentBankDeposit  ,
						@idAgentReceiptType  ,
						@idAgentPaymentSchema  ,
						@idUserOpeningSalesRep  ,
						@idUserSeller ,
						@idAgentType ,
						GETDATE(),
						--@folio ,
						@idAgentClass ,
						@accountNumber ,
						@routingNumber ,
						@retainMoneyCommission ,
						@enteredByIdUser,
						GETDATE(),
						@idAgentStatus,
						@DoingBusinessAs,
                        @IdAgentCommissionPay,
                        @SubAccount,
					    @accountNumberCommission,
						@routingNumberCommission,
                        isnull(@UsePIN,0),
                        isnull(@UsePayNow,0),
						@BlockPhoneTransactions,
						@MoneyAlertInvitation,
						@CheckEditMicr,
						@idTimeZone,
						@NeedsWFSubaccount,
						GETDATE(),
						@enteredByIdUser,
						@RequestWFSubaccount,
						@IsSwitchSpecExRateGroup, --M00256
						GETDATE(), --M00256
						GETDATE(),
						@enteredByIdUser,
						@IdAgentBusinessType,
						@IdTaxIDType
                        )

					set @IdAgentOut = SCOPE_IDENTITY()
					
					Insert into dbo.AgentStatusHistory (IdUser,IdAgent,IdAgentStatus,DateOfchange,Note) 
					VALUES (@enteredByIdUser,@IdAgentOut,@idAgentStatus,GETDATE(),'Initial Status')

					insert into dbo.creditlimithistory(IdAgent, creditlimit, DateOfCreation, EnteredByIdUser) values (@IdAgentOut, @creditAmount, GetDAte(),@enteredByIdUser)

                    DECLARE	
		                    @HasError2 bit,
		                    @MessageError2 nvarchar(max)

                    EXEC	[dbo].[st_SetAgentDefaultSchemas]
		                    @IdAgent = @IdAgentOut,
		                    @EnterByIdUser = @enteredByIdUser,
		                    @IdLenguage = 1,
		                    @HasError = @HasError2 OUTPUT,
		                    @MessageError = @MessageError2 OUTPUT

					EXEC [Corp].[st_saveAgentChangeHistory] @IdAgentOut, @agentPhone, @agentPhoneType, @enteredByIdUser, 0;
					EXEC [Corp].[st_saveAgentChangeHistory] @IdAgentOut, @agentFax,	@agentFaxType,	@enteredByIdUser, 0;
					EXEC [Corp].[st_saveAgentChangeHistory] @IdAgentOut, @agentEmail, @agentEmailType, @enteredByIdUser, 0;
					EXEC [Corp].[st_saveAgentChangeHistory] @idAgent,	@agentClass, @agentClassType, @enteredByIdUser, 0;
					
					EXEC [Corp].[st_saveAgentChangeHistory] @idAgent, @NeedsWFSubaccount,@NeedsWFSubaccountType, @enteredByIdUser, 0;
					EXEC [Corp].[st_saveAgentChangeHistory] @idAgent, @RequestWFSubaccount, @RequestWFSubaccountType , @enteredByIdUser, 0;
					
			end

			/************************************************************************************      ACH Exception     ******************************************************************************/
			DECLARE @IdAgentCollectTypeACH INT = (SELECT TOP 1 idAgentCollectType FROM dbo.AgentCollectType WITH (NOLOCK) WHERE LTRIM(RTRIM([Name])) = 'ACH')
			DECLARE @IdAgentCollectTypeACHScan INT = (SELECT TOP 1 idAgentCollectType FROM dbo.AgentCollectType WITH (NOLOCK) WHERE LTRIM(RTRIM([Name])) = 'ACH with Scanner')
			DECLARE @IdAgentBankDepositACH INT = (SELECT TOP 1 IdAgentBankDeposit FROM dbo.AgentBankDeposit WITH (NOLOCK) WHERE BankName like 'ACH%')
			DECLARE @IsAgentException BIT = (SELECT dbo.fn_GetIsAgentException(@IdAgentOut))
			IF (@IsAgentException = 0) AND (@IdAgentCollectTypeACH = @idAgentCollectType OR @IdAgentCollectTypeACHScan = @idAgentCollectType) AND (@idAgentBankDeposit = @IdAgentBankDepositACH)
			BEGIN
				EXEC [Corp].[st_AddNoteAgentException] 1, @IdAgentOut, 1, @SystemUser, 'Mark as exception by system; ACH', @HasError, @MessageOut
			END
			/*ELSE
			IF ((@IsAgentException = 1) AND (@idAgentCollectType not in (@IdAgentCollectTypeACH,@IdAgentCollectTypeACHScan) OR @idAgentBankDeposit <> @IdAgentBankDepositACH))
			BEGIN
				EXEC [dbo].[st_AddNoteAgentException] 1, @IdAgentOut, 0, @SystemUser, 'Mark as exception disabled by system; ACH', @HasError, @MessageOut
			END*/--#1
			/******************************************************************************************************************************************************************************************/

			Declare @Id int, @Comment varchar(MAX), @PhoneNumber varchar(MAX)
			Declare @DocHandle INT 

			delete from dbo.AgentPhoneNumber where IdAgent = @IdAgentOut
    
			create table #phoneNumbers
			(
				Id int,
				Comment varchar(MAX),
				PhoneNumber varchar(MAX)
			)

			EXEC sp_xml_preparedocument @DocHandle OUTPUT,@phoneNumbers
	
			insert into #phoneNumbers
			SELECT Id,Comment, PhoneNumber From OPENXML (@DocHandle, '/Phone/Detail',2)
			WITH (
				Id int,
				Comment varchar(MAX),
				PhoneNumber varchar(MAx)
			)

			EXEC sp_xml_removedocument @DocHandle

			WHILE exists (select top 1 1 from #phoneNumbers)
			BEGIN
				select top 1 @Id=Id,@Comment=Comment,@PhoneNumber=PhoneNumber from  #phoneNumbers
				insert into dbo.AgentPhoneNumber (IdAgent, Comment, PhoneNumber) values (@IdAgentOut, @Comment, @PhoneNumber)

				EXEC [Corp].[st_saveAgentChangeHistory] @IdAgentOut, @PhoneNumber, @agentAdditionalPhoneType, @enteredByIdUser, 0;

				delete  #phoneNumbers where PhoneNumber = @PhoneNumber
			end

--XML Collection Calendar Hours

			Declare @IdAgentHr int, @DayNumber int, @StartTime time(0), @EndTime time(0)
			Declare @DocHandleHr INT 

			--delete from CollectionCallendarHours where IdAgent = @IdAgent
			create table #collectionHours
			(
				IdAgent int,
				DayNumber int,
				StartTime time(0),
				EndTime time(0)
			)
			
			EXEC sp_xml_preparedocument @DocHandleHr OUTPUT, @Hours
	
			insert into #collectionHours
			SELECT IdAgent, DayNumber, StartTime, EndTime From OPENXML (@DocHandleHr, N'/Hours/Detail', 2)
			WITH (
				IdAgent int,
				DayNumber int,
				StartTime time(0),

				EndTime time(0)
			)

			EXEC sp_xml_removedocument @DocHandleHr

			if exists (select top 1 1 from dbo.CollectionCallendarHours with(nolock) where IdAgent = @IdAgentOut)
			begin
				while exists (select top 1 1 from #collectionHours)
				begin
					select top 1 @IdAgentHr=IdAgent,@DayNumber=DayNumber,@StartTime=StartTime,@EndTime=EndTime from  #collectionHours
					update dbo.CollectionCallendarHours set StartTime = @StartTime, EndTime = @EndTime where IdAgent = @IdAgentHr and DayNumber = @DayNumber					
					delete  #collectionHours where DayNumber = @DayNumber and IdAgent = @IdAgentHr	
				end			
			end 
			else
				insert into dbo.CollectionCallendarHours
				select @IdAgentOut as IdAgent, DayNumber, StartTime, EndTime from #collectionHours
			
			drop table #collectionHours
			
			
			Declare @DocHandleCT INT
			
			CREATE TABLE #agentCollectTypeRelAgent
			(
				IdAgent 			INT,
				IdAgentCollectType	INT,
				IsDefault			BIT								
			)
			
			EXEC sp_xml_preparedocument @DocHandleCT OUTPUT, @AgentCollectTypeRelAgentXml
			
			INSERT INTO #agentCollectTypeRelAgent
			SELECT IdAgent, IdAgentCollectType, IsDefault FROM OPENXML(@DocHandleCT, N'/CollectTypeRelAgent/Detail', 2)
			WITH (
				IdAgent INT,
				IdAgentCollectType	INT,
				IsDefault			BIT
				)
				
			EXEC sp_xml_removedocument @DocHandleCT
			
			DELETE FROM Corp.AgentCollectTypeRelAgent WHERE IdAgent = @idAgent
			
			INSERT INTO Corp.AgentCollectTypeRelAgent (IdAgent, IdAgentCollectType, IsDefault, CreationDate, EnterByIdUser)
			SELECT @idAgent, IdAgentCollectType, IsDefault, getdate(), @enteredByIdUser FROM #agentCollectTypeRelAgent
			
			UPDATE Agent SET IdAgentCollectType = (SELECT TOP 1 IdAgentCollectType FROM #agentCollectTypeRelAgent WHERE IsDefault = 1),
							DateOfLastChange = getdate()
			WHERE IdAgent = @idAgent

			
	end

End Try                                                
Begin Catch

	Set @HasError=1
	Select @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)
	Declare @ErrorMessage nvarchar(max)  
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_SaveAgent]',Getdate(),@ErrorMessage)                                                

End Catch


