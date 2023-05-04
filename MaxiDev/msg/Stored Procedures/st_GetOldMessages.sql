
create Procedure [msg].[st_GetOldMessages]
(
    --@idMessageProvider int,
    @idUser int,
    @userSession nvarchar(max),
    @PageIndex INT = 1,
	@PageSize INT = 3,
	@PageCount INT OUTPUT        
)
as

Create table #Messages(Id int IDENTITY (1,1),IdMessageSubscriber int,IdMessageStatus int, IdMessageProvider int, RawMessage nvarchar(max), DateOfLastChange datetime)

Insert into #Messages
select MS.IdMessageSubscriber, MS.IdMessageStatus,M.IdMessageProvider, M.RawMessage,m.DateOfLastChange from msg.Messages M 
Inner Join msg.MessageSubcribers MS on /*M.IdMessageProvider=@IdMessageProvider and */M.IdMessage = MS.IdMessage 
Where   MS.IdMessageStatus in (5)
	   and MS.IdUser=@idUser 
	   and not exists(select top 1 1 from msg.MessageSubscriberDetails 
				    where IdMessageSubscriber=MS.IdMessageSubscriber 
						  and UserSession = @userSession 
						  and IdMessageStatus= MS.IdMessageStatus
				    )
order by m.DateOfLastChange desc

SELECT @PageCount = COUNT(*) FROM #Messages

Select IdMessageSubscriber,IdMessageStatus,IdMessageProvider,RawMessage,DateOfLastChange from #Messages
WHERE Id BETWEEN @PageIndex + 1 AND @PageIndex + @PageSize