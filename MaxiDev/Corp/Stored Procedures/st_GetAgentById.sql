CREATE PROCEDURE [Corp].[st_GetAgentById]
	@idAgent int
as
begin try
	--Agent
    SELECT IdAgent, IdUserOpeningSalesRep, User2.UserName, --users
	IdUserSeller, AgentAddress, AgentName, AgentCode, StateCode, AgentContact, AgentTimeInBusiness, AgentBusinessType, AmountRequiredToAskId, OpenDate, TaxID, AgentEmail, 
	AgentFax, AgentPhone, AgentCity, AgentState, AgentZipcode,
	--Agent
	DoneOnSundayPayOn, DoneOnMondayPayOn, DoneOnTuesdayPayOn, DoneOnWednesdayPayOn, DoneOnThursdayPayOn, DoneOnFridayPayOn, DoneOnSaturdayPayOn, CloseDate, CreationDate,
	CreditAmount, Notes, BusinessPermissionExpiration, BusinessPermissionNumber, SwitchCommission, CommissionBottom, CommissionTop, SwitchExrate, ExRateBottom, ExRateTop,
	GuarantorName, GuarantorLastName, GuarantorSecondLastName, GuarantorAddress, GuarantorBornDate, GuarantorZipcode, GuarantorCity, GuarantorState,
	GuarantorEmail, GuarantorCel, GuarantorPhone, GuarantorIdExpirationDate, GuarantorIdNumber, GuarantorIdType, GuarantorSSN, GuarantorBornCountry,
	IdAgentBankDeposit, IdAgentCommunication, IdAgentPaymentSchema, IdAgentReceiptType,
	--AgentStatus 
	a.IdAgentStatus, astatus.AgentStatus,
	--Agent
	IdAgentType, ShowAgentProfitWhenSendingTransfer, CancelReturnCommission, ShowLogo, NeedsWFSubaccount, RequestWFSubaccount
	FROM Agent a with (nolock) join Users User2 with (nolock) on a.IdUserOpeningSalesRep=User2.IdUser join AgentStatus aStatus with (nolock) on a.IdAgentStatus = aStatus.IdAgentStatus
	where IdAgent=@idAgent

	Select IdAgent, IdAgentPhoneNumber, PhoneNumber, Comment
	from AgentPhoneNumber with (nolock) where IdAgent = @idAgent
end try
begin catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetAgentById]',Getdate(),@ErrorMessage);
end catch
