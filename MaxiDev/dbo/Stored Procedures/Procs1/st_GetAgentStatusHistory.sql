CREATE procedure [dbo].[st_GetAgentStatusHistory]
(
    @IdAgent int
    ,@IsSubAccount bit
)
as
/********************************************************************
<Author> ??? </Author>
<app> Corporative </app>
<Description> Gets history agent status</Description>

<ChangeLog>
<log Date="13/09/2017" Author="snevarez">Gets Agent Status History</log>
</ChangeLog>
*********************************************************************/
begin try

--Table:AgentStatus
--IdAgentStatus	AgentStatus
--8	Needs Wells Fargo
--9	Request Wells Fargo
--10	Wells Fargo Sub Account Report Generated

    SELECT 
	   ASH.IdAgentStatusHistory
	   ,ASH.IdUser
	   ,ASH.IdAgent
	   ,ASH.IdAgentStatus
	   ,ASH.DateOfchange
	   ,ASH.Note
	   ,AST.AgentStatus AS StatusName
	   ,U.UserName AS UserName
    FROM [dbo].[AgentStatusHistory] AS ASH WITH(NOLOCK)
	   Inner Join AgentStatus AS AST WITH(NOLOCK) ON ASH.IdAgentStatus = AST.IdAgentStatus
	   Inner Join Users AS U WITH(NOLOCK) ON ASH.IdUser = U.IdUser
    WHERE IdAgent = @IdAgent
	   And
		  (
			 (@IsSubAccount = 0 AND ASH.IdAgentStatus = ASH.IdAgentStatus)
			 OR
			 (@IsSubAccount = 1 AND ASH.IdAgentStatus NOT IN (8,9,10))
		  )
    ORDER BY ASH.DateOfchange DESC;

End Try
begin catch
    Declare @ErrorMessage nvarchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetAgentStatusHistory',Getdate(),@ErrorMessage);
End Catch