CREATE PROCEDURE [Corp].[st_SaveAgentMirror]
(

    @IdAgent int

)


as

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="04/07/2017" Author="mdelgado">S27 :: Add Fields for Changes to Needs/Request Wells Fargo</log>
<log Date="13/12/2018" Author="adominguez">Se agrega "with(nolock)" a las consultas</log>
</ChangeLog>
********************************************************************/

begin try   

declare @Action nvarchar(max)



if exists(select top 1 1 from [AgentMirror] with(nolock) where idagent=@IdAgent)

begin

    set @Action = 'Update'

end

else

begin

    set @Action = 'Insert'

end



INSERT INTO [dbo].[AgentMirror]

           ([IdAgent]

           ,[IdAgentCommunication]

           ,[IdAgentType]

           ,[IdUserSeller]

           ,[IdUserOpeningSalesRep]

           ,[IdAgentStatus]

           ,[IdAgentPaymentSchema]

           ,[IdAgentReceiptType]

           ,[IdAgentBankDeposit]

           ,[AgentName]

           ,[AgentCode]

           ,[AgentAddress]

           ,[AgentCity]

           ,[AgentState]

           ,[AgentZipcode]

           ,[AgentPhone]

           ,[AgentFax]

           ,[AgentEmail]

           ,[AgentContact]

           ,[AgentTimeInBusiness]

           ,[AgentBusinessType]

           ,[GuarantorName]

           ,[GuarantorLastName]

           ,[GuarantorSecondLastName]

           ,[GuarantorAddress]

           ,[GuarantorCity]

           ,[GuarantorState]

           ,[GuarantorZipcode]

           ,[GuarantorPhone]

           ,[GuarantorCel]

           ,[GuarantorEmail]

           ,[GuarantorSSN]

           ,[GuarantorIdType]

           ,[GuarantorIdNumber]

           ,[GuarantorIdExpirationDate]

           ,[GuarantorBornDate]

           ,[TaxID]

           ,[CreditAmount]

           --,[Folio]

           ,[AmountRequiredToAskId]

           ,[CreationDate]

           ,[OpenDate]

           ,[Notes]

           ,[CloseDate]

           ,[BusinessPermissionNumber]

           ,[BusinessPermissionExpiration]

           ,[DoneOnSundayPayOn]

           ,[DoneOnMondayPayOn]

           ,[DoneOnTuesdayPayOn]

           ,[DoneOnWednesdayPayOn]

           ,[DoneOnThursdayPayOn]

           ,[DoneOnFridayPayOn]

           ,[DoneOnSaturdayPayOn]

           ,[DateOfLastChange]

           ,[EnterByIdUser]

           ,[SwitchCommission]

           ,[SwitchExrate]

           ,[CommissionTop]

           ,[CommissionBottom]

           ,[ExrateTop]

           ,[ExrateBottom]

           ,[ACHWellsFargo]

           --,[county]

           ,[idcounty]

           ,[idcountyguarantor]

           ,[ShowAgentProfitWhenSendingTransfer]

           ,[GuarantorBornCountry]

           ,[ExcludeReportSignatureHold]

           ,[ExcludeReportExRates]

           ,[InsertDate]

           ,[Action]

           ,[IdAgentClass]

           ,[IdOwner]

           ,[IdAgentCollectType]

           ,[AccountNumber]

           ,[RoutingNumber]

           ,[RetainMoneyCommission]

           ,[ShowLogo]

           ,[CancelReturnCommission]

           --,[PreFolio]

           ,[DoingBusinessAs]

           ,[IdAgentCommissionPay]

           ,[SubAccount]

           ,[RoutingNumberCommission]

           ,[AccountNumberCommission]

           ,[UsePin]

           ,[UsePayNow]

		   ,[SuspendedDatePendingFile] --New RMM

		   ,[BlockPhoneTransactions]

		   ,MoneyAlertInvitation

		   ,IdTimeZone

		   ,NeedsWFSubaccount

		   ,NeedsWFSubaccountDate

		   ,NeedsWFSubaccountIduser

		   ,RequestWFSubaccount

		   ,RequestWFSubaccountDate

		   ,RequestWFSubaccountIdUser

		   ) --New

select [IdAgent]

           ,[IdAgentCommunication]

           ,[IdAgentType]

           ,[IdUserSeller]

           ,[IdUserOpeningSalesRep]

           ,[IdAgentStatus]

           ,[IdAgentPaymentSchema]

           ,[IdAgentReceiptType]

           ,[IdAgentBankDeposit]

           ,[AgentName]

           ,[AgentCode]

           ,[AgentAddress]

           ,[AgentCity]

           ,[AgentState]

           ,[AgentZipcode]

           ,[AgentPhone]

           ,[AgentFax]

           ,[AgentEmail]

           ,[AgentContact]

           ,[AgentTimeInBusiness]

           ,[AgentBusinessType]

           ,[GuarantorName]

           ,[GuarantorLastName]

           ,[GuarantorSecondLastName]

           ,[GuarantorAddress]

           ,[GuarantorCity]

           ,[GuarantorState]

           ,[GuarantorZipcode]

           ,[GuarantorPhone]

           ,[GuarantorCel]

           ,[GuarantorEmail]

           ,[GuarantorSSN]

           ,[GuarantorIdType]

           ,[GuarantorIdNumber]

           ,[GuarantorIdExpirationDate]

           ,[GuarantorBornDate]

           ,[TaxID]

           ,[CreditAmount]

           --,[Folio]

           ,[AmountRequiredToAskId]

           ,[CreationDate]

           ,[OpenDate]

           ,[Notes]

           ,[CloseDate]

           ,[BusinessPermissionNumber]

           ,[BusinessPermissionExpiration]

           ,[DoneOnSundayPayOn]

           ,[DoneOnMondayPayOn]

           ,[DoneOnTuesdayPayOn]

           ,[DoneOnWednesdayPayOn]

           ,[DoneOnThursdayPayOn]

           ,[DoneOnFridayPayOn]

           ,[DoneOnSaturdayPayOn]

           ,[DateOfLastChange]

           ,[EnterByIdUser]

           ,[SwitchCommission]

           ,[SwitchExrate]

           ,[CommissionTop]

           ,[CommissionBottom]

           ,[ExrateTop]

           ,[ExrateBottom]

           ,[ACHWellsFargo]

           --,[county]

           ,[idcounty]

           ,[idcountyguarantor]

           ,[ShowAgentProfitWhenSendingTransfer]

           ,[GuarantorBornCountry]

           ,[ExcludeReportSignatureHold]

           ,[ExcludeReportExRates]

           ,getdate()

           ,@Action

           ,[IdAgentClass]

           ,[IdOwner]

           ,[IdAgentCollectType]

           ,[AccountNumber]

           ,[RoutingNumber]

           ,[RetainMoneyCommission]

           ,[ShowLogo]

           ,[CancelReturnCommission]

           --,[PreFolio]

           ,[DoingBusinessAs]

           ,[IdAgentCommissionPay]

           ,[SubAccount]

           ,[RoutingNumberCommission]

           ,[AccountNumberCommission]

           ,[UsePin]

           ,[UsePayNow]

		   ,[SuspendedDatePendingFile] --New RMM

		   ,[BlockPhoneTransactions]

		   ,[MoneyAlertInvitation]

		   ,[IdTimeZone] --New

		   ,NeedsWFSubaccount

		   ,NeedsWFSubaccountDate

		   ,NeedsWFSubaccountIduser

		   ,RequestWFSubaccount

		   ,RequestWFSubaccountDate

		   ,RequestWFSubaccountIdUser

from agent with(nolock)

where idagent=@IdAgent

End try
begin catch 
Declare @ErrorMessage nvarchar(max)                                                                                             
Select @ErrorMessage=ERROR_MESSAGE()                                                        
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_SaveAgentMirror',Getdate(),@ErrorMessage)                                                                                            
end catch
