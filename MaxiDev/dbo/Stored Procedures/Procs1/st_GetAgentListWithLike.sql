CREATE Procedure [dbo].[st_GetAgentListWithLike]
(
    @AgentName Varchar(50),
    @AgentCode Varchar(50),
    @All bit
)
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description>/Description>

<ChangeLog>
<log Date="29/12/2017" Author="snevarez">Get list of agents</log>
<log Date="23/02/2018" Author="snevarez">Change iscustomer to #iscustomer</log>
<log Date="01/03/2018" Author="snevarez">Exclude search in customers</log>
<log Date="22/05/2018" Author="jmolina">Se agrega validación si el agentcode es numerico para solo asignar el % a la derecha #1</log>
</ChangeLog>
*********************************************************************/
Begin try

    /*01/03/2018*/
    --SELECT DISTINCT idAgent = idagentcreatedby INTO #iscustomer
	   --FROM customer WITH (NOLOCK ,INDEX(nci_CustomerAgent)) 
		  --WHERE IdGenericStatus = 1;

	IF ISNUMERIC(@AgentCode) = 1 --#1
		SET @AgentCode = @AgentCode + '%'
	ELSE
		SET @AgentCode = '%' + @AgentCode + '%'

    IF (@All = 1)
	   BEGIN
		  SELECT 
			 a.idagent
			 , a.Agentname
			 , a.AgentCode
			 , a.IdAgentstatus
			 , s.AgentStatus
			 , a.IdAgentclass
			 , c.Name agentclass
			 , a.DateOfLastChange
			 , a.IdUserSeller,isnull(UserName,'') AS SalesRep
			 , a.SubAccount

			 --, CASE WHEN ic.idAgent IS NULL THEN 0 ELSE 1 END AS IsCustomers  /*01/03/2018*/
			 , 1 AS IsCustomers  /*01/03/2018*/

			 , a.AgentAddress
			 , a.AgentCity
			 , a.AgentState
			 , a.AgentZipcode
			 , a.AgentPhone
			 ,AC.Communication AS CommunicationType 
			 ,A.ExcludeReportExRates, a.AgentFax
		  FROM agent a WITH(NOLOCK)
			 LEFT JOIN users AS u WITH(NOLOCK) on u.iduser=a.IdUserSeller
			 --LEFT JOIN #iscustomer AS ic on ic.idAgent=a.idagent /*01/03/2018*/
			 JOIN agentstatus AS s WITH(NOLOCK) on s.idagentstatus=a.idagentstatus
			 JOIN agentclass AS c WITH(NOLOCK) on c.idagentclass=a.idagentclass
			 Inner Join AgentCommunication AS AC WITH(NOLOCK) ON  AC.IdAgentCommunication = a.IdAgentCommunication
		  --WHERE (a.Agentname LIKE '%'+@AgentName+'%' OR a.AgentCode LIKE '%'+@AgentCode+'%')
		  WHERE (a.Agentname LIKE '%'+@AgentName+'%' OR a.AgentCode LIKE @AgentCode) --#1
			 ORDER BY agentcode;
	   END
    ELSE
	   BEGIN
		  SELECT 
			 a.idagent
			 , a.Agentname
			 , a.AgentCode
			 , a.IdAgentstatus
			 , s.AgentStatus
			 , a.IdAgentclass
			 , c.Name agentclass
			 , a.DateOfLastChange
			 , a.IdUserSeller
			 , isnull(UserName,'') AS SalesRep
			 , a.SubAccount

			 --, CASE WHEN ic.idAgent IS NULL THEN 0 ELSE 1 END  AS IsCustomers /*01/03/2018*/
			 ,1 AS IsCustomers  /*01/03/2018*/

			 , a.AgentAddress
			 , a.AgentCity
			 , a.AgentState
			 , a.AgentZipcode
			 , a.AgentPhone
			 , AC.Communication AS CommunicationType 
			 , A.ExcludeReportExRates
			 , a.AgentFax
		  FROM agent AS a WITH(NOLOCK)
			 LEFT JOIN users AS u WITH(NOLOCK) ON u.iduser=a.IdUserSeller

			 --LEFT JOIN #iscustomer AS ic ON ic.idAgent=a.idagent	  /*01/03/2018*/

			 JOIN agentstatus AS s WITH(NOLOCK) ON s.idagentstatus=a.idagentstatus
			 JOIN agentclass AS c WITH(NOLOCK) ON c.idagentclass=a.idagentclass
			 Inner Join AgentCommunication AS AC WITH(NOLOCK) ON AC.IdAgentCommunication = a.IdAgentCommunication
		  WHERE 
			 a.idagentstatus NOT IN (2,6)
			 --AND (a.Agentname LIKE '%'+@AgentName+'%' OR a.AgentCode LIKE '%'+@AgentCode+'%') 
			 AND (a.Agentname LIKE '%'+@AgentName+'%' OR a.AgentCode LIKE @AgentCode) --#1
		  ORDER BY agentcode;
	   END

	   --DROP TABLE #iscustomer;	 /*01/03/2018*/

End Try
Begin Catch

	   Declare @ErrorMessage nvarchar(max);
	   Select @ErrorMessage=ERROR_MESSAGE();
	   Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetAgentListLike',Getdate(),@ErrorMessage);

End Catch