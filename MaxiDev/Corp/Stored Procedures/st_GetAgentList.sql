CREATE PROCEDURE [Corp].[st_GetAgentList]
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
<log Date="23/02/2018" Author="snevarez">Change iscustomer to #iscustomer</log>
</ChangeLog>
*********************************************************************/
	
	--INSERT INTO iscustomer
	--SELECT DISTINCT idagentcreatedby FROM customer WITH (NOLOCK ,INDEX(nci_CustomerAgent)) WHERE IdGenericStatus =1 AND  IdAgentCreatedBy NOT IN (SELECT idAgent FROM iscustomer)

    SELECT DISTINCT 
		  idAgent = idagentcreatedby INTO #iscustomer
	   FROM customer WITH (NOLOCK ,INDEX(nci_CustomerAgent)) 
		  WHERE IdGenericStatus = 1;
		
	IF (@All = 1)
	BEGIN
		SELECT a.idagent, a.Agentname, a.AgentCode, a.IdAgentstatus, s.AgentStatus, a.IdAgentclass, c.Name agentclass, a.DateOfLastChange, 
			a.IdUserSeller,isnull(UserName,'') SalesRep, a.SubAccount, CASE WHEN ic.idAgent IS NULL THEN 0 ELSE 1 END  IsCustomers,
			a.AgentAddress, a.AgentCity, a.AgentState, a.AgentZipcode, a.AgentPhone
			,AC.Communication AS CommunicationType /*S12:REQ_VI03_Agregar communication Type a Agents*/
			,A.ExcludeReportExRates, a.AgentFax
		FROM agent a WITH(NOLOCK)
		    LEFT JOIN users u WITH(NOLOCK) on u.iduser=a.IdUserSeller
		    LEFT JOIN #iscustomer ic WITH(NOLOCK) on ic.idAgent=a.idagent
		    JOIN agentstatus s WITH(NOLOCK) on s.idagentstatus=a.idagentstatus
		    JOIN agentclass c WITH(NOLOCK) on c.idagentclass=a.idagentclass
		    Inner Join AgentCommunication AS AC WITH(NOLOCK) ON  AC.IdAgentCommunication = a.IdAgentCommunication /*S12:REQ_VI03_Agregar communication Type a Agents*/
		ORDER BY agentcode
	END
	ELSE
	BEGIN
		SELECT a.idagent, a.Agentname, a.AgentCode, a.IdAgentstatus, s.AgentStatus, a.IdAgentclass, c.Name agentclass, a.DateOfLastChange, 
			a.IdUserSeller,isnull(UserName,'') SalesRep, a.SubAccount, CASE WHEN ic.idAgent IS NULL THEN 0 ELSE 1 END  IsCustomers,
			a.AgentAddress, a.AgentCity, a.AgentState, a.AgentZipcode, a.AgentPhone
			,AC.Communication AS CommunicationType /*S12:REQ_VI03_Agregar communication Type a Agents*/
			,A.ExcludeReportExRates, a.AgentFax
		FROM agent a WITH(NOLOCK)
		    LEFT JOIN users u WITH(NOLOCK) ON u.iduser=a.IdUserSeller
		    LEFT JOIN #iscustomer ic WITH(NOLOCK) ON ic.idAgent=a.idagent
		    JOIN agentstatus s WITH(NOLOCK) ON s.idagentstatus=a.idagentstatus
		    JOIN agentclass c WITH(NOLOCK) ON c.idagentclass=a.idagentclass
		    Inner Join AgentCommunication AS AC WITH(NOLOCK) ON AC.IdAgentCommunication = a.IdAgentCommunication /*S12:REQ_VI03_Agregar communication Type a Agents*/
		WHERE 
			a.idagentstatus NOT IN (2,6)
		ORDER BY agentcode
	END

	DROP TABLE #iscustomer;
