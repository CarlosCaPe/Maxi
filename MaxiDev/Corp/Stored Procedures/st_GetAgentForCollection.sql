Create procedure [Corp].[st_GetAgentForCollection]
(
	@idAgent int
)
as
begin try
    SELECT top 1
	a.IdAgent, IdAgentBankDeposit, AgentName, AgentCode, DoneOnSundayPayOn, DoneOnMondayPayOn, DoneOnTuesdayPayOn, DoneOnWednesdayPayOn,
	a.IdAgentStatus, AgentStatus, DoneOnThursdayPayOn, DoneOnFridayPayOn, DoneOnSaturdayPayOn, SubAccount, Balance, CreditAmount, a.IdAgentCollectType, ac.[Name]

	FROM Agent a with (NOLOCK) left join AgentBalance ab with (NOLOCK) on a.IdAgent=ab.IdAgent join AgentStatus aStatus with (NOLOCK) on a.IdAgentStatus=aStatus.IdAgentStatus 
				 join AgentCollectType ac with (NOLOCK) on a.IdAgentCollectType=ac.IdAgentCollectType
	where a.IdAgent = @idAgent
	order by ab.DateOfMovement desc
end try
begin catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetAgentForCollection',Getdate(),@ErrorMessage);
end catch
