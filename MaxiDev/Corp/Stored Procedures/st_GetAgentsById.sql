CREATE PROCEDURE [Corp].[st_GetAgentsById]
	@IdAgent int
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DateActual datetime = GETDATE(),
	@DateExiration datetime,
	@DaysDiference int

	SELECT @DateExiration = ExpirationDateExRateGroup from Agent with(nolock) where IdAgent = @idAgent AND IsSwitchSpecExRateGroup = 1
	SELECT @DaysDiference = DATEDIFF(day, @DateExiration, @DateActual);

	--if (@DaysDiference >= 1)
	--begin
	--update Agent set IsSwitchSpecExRateGroup = 0 where IdAgent = @idAgent
	--end

	SELECT 
    A.[IdAgent], 
    A.[IdAgentCommunication], 
    A.[IdAgentType], 
    A.[IdUserSeller], 
    A.[IdUserOpeningSalesRep], 
    A.[IdAgentStatus], 
    A.[IdAgentPaymentSchema], 
    A.[IdAgentReceiptType], 
    A.[IdAgentBankDeposit], 
    A.[IdAgentCollectType], 
    A.[IdOwner], 
    A.[AgentName], 
    A.[AgentCode], 
    A.[StateCode], 
    A.[AgentAddress], 
    A.[AgentCity], 
    A.[AgentState], 
    A.[AgentZipcode], 
    A.[AgentFax], 
    A.[AgentPhone], 
    A.[AgentEmail], 
    A.[AgentContact], 
    A.[AgentTimeInBusiness], 
    A.[AgentBusinessType], 
    A.[GuarantorName], 
    A.[GuarantorLastName], 
    A.[GuarantorSecondLastName], 
    A.[GuarantorAddress], 
    A.[GuarantorCity], 
    A.[GuarantorState], 
    A.[GuarantorZipcode], 
    A.[GuarantorPhone], 
    A.[GuarantorCel], 
    A.[GuarantorEmail], 
    A.[GuarantorSSN], 
    A.[GuarantorIdType], 
    A.[GuarantorIdNumber], 
    A.[GuarantorIdExpirationDate], 
    A.[GuarantorBornDate], 
    A.[TaxID], 
    A.[CreditAmount], 
    A.[AmountRequiredToAskId], 
    A.[OpenDate], 
    A.[Notes], 
    A.[CloseDate], 
    A.[BusinessPermissionNumber], 
    A.[BusinessPermissionExpiration], 
    A.[DoneOnSundayPayOn], 
    A.[DoneOnMondayPayOn], 
    A.[DoneOnTuesdayPayOn], 
    A.[DoneOnWednesdayPayOn], 
    A.[DoneOnThursdayPayOn], 
    A.[DoneOnFridayPayOn], 
    A.[DoneOnSaturdayPayOn], 
    A.[SwitchCommission], 
    A.[SwitchExrate], 
    A.[CommissionTop], 
    A.[CommissionBottom], 
    A.[ExrateTop], 
    A.[ExrateBottom], 
    A.[ShowAgentProfitWhenSendingTransfer], 
    A.[GuarantorBornCountry], 
    A.[ExcludeReportSignatureHold], 
    A.[ExcludeReportExRates], 
    A.[ShowLogo], 
    A.[CancelReturnCommission], 
    A.[IdAgentClass], 
    A.[AccountNumber], 
    A.[RoutingNumber], 
    A.[RetainMoneyCommission], 
    A.[DoingBusinessAs], 
    A.[IdAgentCommissionPay], 
    A.[subAccount], 
    A.[AccountNumberCommission], 
    A.[RoutingNumberCommission], 
    A.[UsePIN], 
    A.[UsePayNow], 
    A.[IdCounty], 
    A.[IdCountyGuarantor], 
    A.[SuspendedDatePendingFile], 
    A.[BlockPhoneTransactions], 
    A.[MoneyAlertInvitation], 
    A.[CheckEditMicr], 
    A.[IdTimeZone], 
    A.[NeedsWFSubaccount], 
    A.[RequestWFSubaccount], 
    A.[CreationDate], 
    A.[DateOfLastChange], 
    A.[EnterByIdUser], 
    SA.[IdAgentStatus] AS [IdAgentStatus1], 
    SA.[AgentStatus], 
    SA.[VisibleForUser],
	A.IsSwitchSpecExRateGroup --M00256
	,A.ApplyKYCRules    --M00248
	,A.AgentBusinessEmail
	,A.AgentBusinessWebsite
	,A.AgentFinCENReg
	,isnull(A.AgentFinCENRegExpiration, '1900-01-01') AS 'AgentFinCENRegExpiration'
	,A.AgentCheckCasher
	,A.AgentCheckLicense
	,A.AgentCheckLicenseNumber
	,A.MailCheckTo
	,isnull(A.ComplianceOfficerDateOfBirth, '1900-01-01') AS 'ComplianceOfficerDateOfBirth'
	,A.ComplianceOfficerPlaceOfBirth
	,isnull(A.ComplianceOfficerName, '') AS 'ComplianceOfficerName' 
	,A.IdAgentBusinessType
	,A.IdTaxIDType
    FROM  [dbo].[Agent] AS A WITH(NOLOCK)
    INNER JOIN [dbo].[AgentStatus] AS SA WITH(NOLOCK) ON A.[IdAgentStatus] = SA.[IdAgentStatus]
    WHERE A.[IdAgentCollectType] IN (1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14) AND A.IdAgent = @IdAgent


End Try
Begin Catch
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetAgentsById]',Getdate(),ERROR_MESSAGE())    
End Catch



