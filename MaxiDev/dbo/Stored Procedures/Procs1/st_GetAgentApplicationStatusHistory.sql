CREATE procedure [dbo].[st_GetAgentApplicationStatusHistory]
(
    @IdAgentApplication int
    ,@IsSubAccount bit
)
as
/********************************************************************
<Author> ??? </Author>
<app> Corporative </app>
<Description> Gets history agent status</Description>

<ChangeLog>
<log Date="14/09/2017" Author="snevarez">Gets Agent Application Status History</log>
</ChangeLog>
*********************************************************************/
begin try

--Table:AgentApplicationStatuses
--IdAgentApplicationStatus	StatusCodeName						  StatusName
--21						NeedsWellsFargo					Needs Wells Fargo
--22						RequestWellsFargo					Request Wells Fargo
--23						WellsFargoSubAccountReportGenerated	Wells Fargo Sub Account Report Generated
--QA:26/Stage:24			RequestWellsFargoCancelled			Request for Wells Fargo Sub Account was cancelled
--QA:28/Stage:25			DoesntNeedWellsFargo				Doesn’t Need Wells Fargo Sub Account 

    SELECT 
	   AASH.IdAgentApplicationStatusHistory
	   ,AASH.IdAgentApplication
	   ,AASH.IdAgentApplicationStatus
	   ,AASH.DateOfMovement
	   ,AASH.Note
	   ,AASH.DateOfLastChange
	   ,AASH.IdUserLastChange
	   ,AASH.IdType
	   ,u.UserName
	   ,s.StatusName
    FROM [dbo].[AgentApplicationStatusHistory] AS AASH WITH(NOLOCK)
	   join AgentApplicationStatuses s WITH(NOLOCK) on AASH.IdAgentApplicationStatus=s.IdAgentApplicationStatus
	   join users u WITH(NOLOCK) on AASH.IdUserLastChange=u.IdUser
	   WHERE IdAgentApplication = @IdAgentApplication
	   And
		  (
			 (@IsSubAccount = 0 AND AASH.IdAgentApplicationStatus = AASH.IdAgentApplicationStatus)
			 OR
			 (@IsSubAccount = 1 AND AASH.IdAgentApplicationStatus NOT IN (21,22,23,24,25))
		  )
    ORDER BY AASH.DateOfLastChange DESC;

End Try
begin catch
    Declare @ErrorMessage nvarchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetAgentApplicationStatusHistory',Getdate(),@ErrorMessage);
End Catch