CREATE procedure [dbo].[st_GetAgentApplicationBasicInformationById]
(
    @idAgentApplication int
    ,@IsSubAccount bit =  null /*S39*/
)
as
/********************************************************************
<Author> ??? </Author>
<app> Corporative </app>
<Description> Gets history agent status</Description>

<ChangeLog>
<log Date="14/09/2017" Author="snevarez">Gets Agent Application Status History</log>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

begin try
	   select
		  o.Name ownerName,
		  o.LastName ownerLastName,
		  o.SecondLastName ownerSecondLastName,
		  a.guarantorName,
		  a.guarantorLastName,
		  a.guarantorSecondLastName,
		  a.AgentCode agentCode,
		  a.AgentName agentName,
		  a.IdAgentApplication id,
		  a.idAgentApplicationStatus IdStatus,
	      isnull(a.AgentState,'') agentState,
          isnull(st.StateName,'') agentStateName,
		  a.hasAch Ach,
		   case a.IdAgentCommissionPay when 1 then 1 else 0 end paymentTypeAch,-- Nuevo campo, para saber si selecciono el tipo de pago ACH en bussness application
		   --a.IsUploadACHCancelCheck -- Nuevo campo, para saber si subio el doc cancel check for comm
		  isnull((select top 1 1 from UploadFiles with(nolock) where IdReference = a.IdAgentApplication and IdDocumentType = 66),0) IsUploadACHCancelCheck,
		  CONCAT(LTRIM(RTRIM(a.ComplianceOfficerName)), ' (', a.ComplianceOfficerTitle, ')') ComplianceOfficer
	   from dbo.AgentApplications a with(nolock)
	   left join [owner] o with(nolock) on a.IdOwner=o.IdOwner
	   left join state st	WITH(NOLOCK) on a.AgentState=st.StateCode and st.IdCountry=18
	   where a.IdAgentApplication=@idAgentApplication

	   /*Orgin-Begin*/
	   --select
		  --h.DateOfMovement DateOfMovementStr,
		  --h.IdAgentApplicationStatusHistory,
		  --h.IdAgentApplicationStatus,
		  --h.Note,
		  --u.UserName,
		  --s.StatusName,
		  --h.DateOfMovement
	   --from AgentApplicationStatusHistory h
		  --join AgentApplicationStatuses s on h.IdAgentApplicationStatus=s.IdAgentApplicationStatus
		  --join users u on h.IdUserLastChange=u.IdUser
	   --where h.IdAgentApplication=@idAgentApplication
	   /*Origin-End*/

	   /*S39-Begin*/
	   set @IsSubAccount = ISNULL(@IsSubAccount,1);

	   --Table:AgentApplicationStatuses
	   --IdAgentApplicationStatus	 StatusCodeName					StatusName
	   --21						NeedsWellsFargo					Needs Wells Fargo
	   --22						RequestWellsFargo					Request Wells Fargo
	   --23						WellsFargoSubAccountReportGenerated	Wells Fargo Sub Account Report Generated
	   --26						RequestWellsFargoCancelled			Request for Wells Fargo Sub Account was cancelled
	   --28						DoesntNeedWellsFargo				Doesn’t Need Wells Fargo Sub Account

	    select
		  h.DateOfMovement DateOfMovementStr,
		  h.IdAgentApplicationStatusHistory,
		  h.IdAgentApplicationStatus,
		  h.Note,
		  u.UserName,
		  s.StatusName,
		  h.DateOfMovement
	   from AgentApplicationStatusHistory h with(nolock)
		  join AgentApplicationStatuses s with(nolock) on h.IdAgentApplicationStatus=s.IdAgentApplicationStatus
		  join users u with(nolock) on h.IdUserLastChange=u.IdUser
	   where h.IdAgentApplication=@idAgentApplication
		  And
			 (
				(@IsSubAccount = 0 AND h.IdAgentApplicationStatus = h.IdAgentApplicationStatus)
				OR
				(@IsSubAccount = 1 AND h.IdAgentApplicationStatus NOT IN (21,22,23,24,25))
			 )
	   order by  h.DateOfMovement desc;
	   /*S39-End*/

End Try
begin catch
    Declare @ErrorMessage nvarchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetAgentApplicationBasicInformationById',Getdate(),@ErrorMessage);
End Catch
