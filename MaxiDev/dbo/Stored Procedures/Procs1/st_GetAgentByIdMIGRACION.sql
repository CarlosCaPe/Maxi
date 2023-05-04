CREATE PROCEDURE [dbo].[st_GetAgentByIdMIGRACION] 
	@IdAgent INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdAgent], [IdAgentCommunication], [IdAgentType], [IdUserSeller], [IdUserOpeningSalesRep], [IdAgentStatus], [IdAgentPaymentSchema], [IdAgentReceiptType], [IdAgentBankDeposit]
		, [AgentName], [AgentCode], [AgentAddress], [AgentCity], [AgentState], [AgentZipcode], [AgentPhone], [AgentFax], [AgentEmail], [AgentContact]
		, [AgentTimeInBusiness], [AgentBusinessType], [GuarantorName], [GuarantorLastName], [GuarantorSecondLastName], [GuarantorAddress], [GuarantorCity], [GuarantorState]
		, [GuarantorZipcode], [GuarantorPhone], [GuarantorCel], [GuarantorEmail], [GuarantorSSN], [GuarantorIdType], [GuarantorIdNumber], [GuarantorIdExpirationDate]
		, [GuarantorBornDate], [TaxID], [CreditAmount], [AmountRequiredToAskId], [CreationDate], [OpenDate], [Notes], [CloseDate], [BusinessPermissionNumber]
		, [BusinessPermissionExpiration], [DoneOnSundayPayOn], [DoneOnMondayPayOn], [DoneOnTuesdayPayOn], [DoneOnWednesdayPayOn], [DoneOnThursdayPayOn], [DoneOnFridayPayOn]
		, [DoneOnSaturdayPayOn], [DateOfLastChange], [EnterByIdUser], [SwitchCommission], [SwitchExrate], [CommissionTop], [CommissionBottom], [ExrateTop]
		, [ExrateBottom], [ACHWellsFargo], [ShowAgentProfitWhenSendingTransfer], [GuarantorBornCountry], [ExcludeReportSignatureHold], [ExcludeReportExRates], [ShowLogo]
		, [CancelReturnCommission], [IdAgentClass], [IdOwner], [IdAgentCollectType], [AccountNumber], [RoutingNumber], [RetainMoneyCommission], [DoingBusinessAs]
		, [IdAgentCommissionPay], [SubAccount], [AccountNumberCommission], [RoutingNumberCommission], [UsePin], [UsePayNow], [IdCounty], [IdCountyGuarantor]
		, [SuspendedDatePendingFile], [BlockPhoneTransactions], [MoneyAlertInvitation], [CheckEditMicr], [NoteCreditAmountChange], [IdTimeZone], [OfacBusinessChecked]      
		, [OfacGuarantorChecked], [OfacOwnerChecked], [NeedsWFSubaccount], [NeedsWFSubaccountDate], [NeedsWFSubaccountIduser], [RequestWFSubaccount], [RequestWFSubaccountDate]
		, [RequestWFSubaccountIdUser], [IdAgentsReportWellsFargo], [StateCode]
	FROM [dbo].[Agent] WITH(NOLOCK)
	WHERE IdAgent = @IdAgent
END
