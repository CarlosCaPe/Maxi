CREATE PROCEDURE [dbo].[st_GetAgentList]
(
    @All bit
)
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description>/Description>

<ChangeLog>
<log Date="01/02/2017" Author="dalmeida">Add new fields to request result "AgentZipcode" </log>
<log Date="01/02/2017" Author="mdelgado">Add new fields to request result "a.AgentAddress, a.AgentCity, a.AgentState, a.AgentPhone" </log>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
SET NOCOUNT ON;

	declare @Agentstatus table
	(
		Idagentstatus int
	)

	SELECT DISTINCT idagentcreatedby,1 iscustomer INTO #iscustomer FROM customer with(nolock)

	IF (@All = 1)
	BEGIN
		insert into @Agentstatus
		select IdAgentStatus  from AgentStatus with(nolock)
	END
	ELSE
	BEGIN
		insert into @Agentstatus
		select IdAgentStatus from AgentStatus with(nolock) where IdAgentStatus not in (2,6)
	END

	SELECT a.idagent, a.Agentname, a.AgentCode, a.IdAgentstatus, s.AgentStatus, a.IdAgentclass, c.Name agentclass, a.DateOfLastChange, 
			a.IdUserSeller,isnull(UserName,'') SalesRep, a.SubAccount, isnull(iscustomer,0) IsCustomers,
			a.AgentAddress, a.AgentCity, a.AgentState, a.AgentZipcode, a.AgentPhone
			,AC.Communication AS CommunicationType /*S12:REQ_VI03_Agregar communication Type a Agents*/
			,A.ExcludeReportExRates, a.AgentFax
		FROM agent a WITH(NOLOCK)
		LEFT JOIN users u WITH(NOLOCK) ON u.iduser=a.IdUserSeller
		LEFT JOIN #iscustomer ic ON ic.idagentcreatedby=a.idagent
		JOIN agentstatus s WITH(NOLOCK) ON a.idagentstatus=s.idagentstatus
		JOIN agentclass c WITH(NOLOCK) ON a.idagentclass=c.idagentclass
		Inner Join AgentCommunication AS AC WITH(NOLOCK) ON a.IdAgentCommunication = AC.IdAgentCommunication /*S12:REQ_VI03_Agregar communication Type a Agents*/
		WHERE 
			a.idagentstatus in (select idagentstatus from @Agentstatus)
		ORDER BY agentcode
