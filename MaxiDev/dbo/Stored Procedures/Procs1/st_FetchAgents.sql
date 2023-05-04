CREATE PROCEDURE [dbo].[st_FetchAgents]
(
	@AgentCode		VARCHAR(200),
	@IdOwner		INT,
	@IdSeller		INT,
	@AgentName		VARCHAR(200),
	@AgentAddress	VARCHAR(200),
	@OwnerName		VARCHAR(200),

	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
/********************************************************************
<Author></Author>
<app>CorporativeServices.Catalogs</app>
<Description>This stored is used in CorporativeServices.Catalogs API</Description>

<ChangeLog>
	<log Date="17/08/2022" Author="maprado">Add AgentCollectTypeRelAgent Entity foreach Agent </log>
	<log Date="27/12/2022" Author="maprado">Add @AgentName, @AgentAddress, @OwnerName parameters & OwnerName in result</log>
</ChangeLog>
*********************************************************************/
BEGIN

	SELECT
		COUNT(*) OVER() _PagedResult_Total,
		a.IdAgent,
		a.IdAgentCommunication,
		a.IdAgentType,
		a.IdUserSeller,
		a.IdUserOpeningSalesRep,
		a.IdAgentStatus,
		a.IdAgentPaymentSchema,
		a.IdAgentReceiptType,
		a.IdAgentBankDeposit,
		a.AgentName,
		a.AgentCode,
		a.AgentAddress,
		a.AgentCity,
		a.AgentState,
		a.AgentZipcode,
		a.AgentPhone,
		a.AgentFax,
		a.AgentEmail,
		a.AgentContact,
		a.AgentTimeInBusiness,
		a.AgentBusinessType,
		a.GuarantorName,
		a.GuarantorLastName,
		a.GuarantorSecondLastName,
		a.GuarantorAddress,
		a.GuarantorCity,
		a.GuarantorState,
		a.GuarantorZipcode,
		a.GuarantorPhone,
		a.GuarantorCel,
		a.GuarantorEmail,
		a.GuarantorSSN,
		a.GuarantorIdType,
		a.GuarantorIdNumber,
		a.GuarantorIdExpirationDate,
		a.GuarantorBornDate,
		a.TaxID,
		a.CreditAmount,
		a.AmountRequiredToAskId,
		a.CreationDate,
		a.OpenDate,
		a.Notes,
		a.CloseDate,
		a.BusinessPermissionNumber,
		a.BusinessPermissionExpiration,
		a.DoneOnSundayPayOn,
		a.DoneOnMondayPayOn,
		a.DoneOnTuesdayPayOn,
		a.DoneOnWednesdayPayOn,
		a.DoneOnThursdayPayOn,
		a.DoneOnFridayPayOn,
		a.DoneOnSaturdayPayOn,
		a.DateOfLastChange,
		a.EnterByIdUser,
		a.SwitchCommission,
		a.SwitchExrate,
		a.CommissionTop,
		a.CommissionBottom,
		a.ExrateTop,
		a.ExrateBottom,
		a.ACHWellsFargo,
		a.ShowAgentProfitWhenSendingTransfer,
		a.GuarantorBornCountry,
		a.ExcludeReportSignatureHold,
		a.ExcludeReportExRates,
		a.ShowLogo,
		a.CancelReturnCommission,
		a.IdAgentClass,
		a.IdOwner,
		a.IdAgentCollectType,
		a.AccountNumber,
		a.RoutingNumber,
		a.RetainMoneyCommission,
		a.DoingBusinessAs,
		a.IdAgentCommissionPay,
		a.SubAccount,
		a.AccountNumberCommission,
		a.RoutingNumberCommission,
		a.UsePin,
		a.UsePayNow,
		a.IdCounty,
		a.IdCountyGuarantor,
		a.SuspendedDatePendingFile,
		a.BlockPhoneTransactions,
		a.MoneyAlertInvitation,
		a.CheckEditMicr,
		a.NoteCreditAmountChange,
		a.IdTimeZone,
		a.OfacBusinessChecked,
		a.OfacGuarantorChecked,
		a.OfacOwnerChecked,
		a.NeedsWFSubaccount,
		a.NeedsWFSubaccountDate,
		a.NeedsWFSubaccountIduser,
		a.RequestWFSubaccount,
		a.RequestWFSubaccountDate,
		a.RequestWFSubaccountIdUser,
		a.IdAgentsReportWellsFargo,
		a.StateCode,
		a.IdLogAccVerif,
		a.IdAgentGroup,
		a.IsSwitchSpecExRateGroup,
		a.ExpirationDateExRateGroup,
		a.ApplyKYCRules,
		a.IdAgentEntityType,
		a.IdAgentTaxIdType,
		a.AgentBusinessEmail,
		a.AgentBusinessWebsite,
		a.AgentFinCENReg,
		a.AgentFinCENRegExpiration,
		a.AgentCheckCasher,
		a.AgentCheckLicense,
		a.AgentCheckLicenseNumber,
		a.MailCheckTo,
		a.ComplianceOfficerDateOfBirth,
		a.ComplianceOfficerPlaceOfBirth,
		a.ComplianceOfficerName,
		CONCAT(o.Name,' ',o.LastName,' ',o.SecondLastName) OwnerFullName
	INTO #Agents
	FROM Agent a WITH(NOLOCK)
	INNER JOIN Owner o WITH(NOLOCK) ON a.IdOwner = o.IdOwner
	WHERE 
		(ISNULL(@AgentCode, '') = '' OR a.AgentCode LIKE CONCAT('%', @AgentCode ,'%'))
		AND (@IdOwner IS NULL OR a.IdOwner = @IdOwner)
		AND (@IdSeller IS NULL OR a.IdUserSeller = @IdSeller)
		AND (ISNULL(@AgentName, '') = '' OR a.AgentName LIKE CONCAT('%', @AgentName ,'%'))
		AND (ISNULL(@AgentAddress, '') = '' OR a.AgentAddress LIKE CONCAT('%', @AgentAddress ,'%'))
		AND (ISNULL(@OwnerName, '') = '' OR CONCAT(o.Name,' ',o.LastName,' ',o.SecondLastName) LIKE CONCAT('%', @OwnerName ,'%'))
	ORDER BY a.IdAgent
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY

	SELECT * FROM #Agents

	SELECT
		r.IdAgent,
		r.IdAgentCollectType,
		t.Name,
		r.IsDefault,
		r.CreationDate,
		r.EnterByIdUser
	FROM [Corp].[AgentCollectTypeRelAgent] r WITH(NOLOCK)
		JOIN AgentCollectType t WITH(NOLOCK) ON t.IdAgentCollectType = r.IdAgentCollectType
	WHERE EXISTS(SELECT 1 FROM #Agents a WHERE a.IdAgent = r.IdAgent)
END