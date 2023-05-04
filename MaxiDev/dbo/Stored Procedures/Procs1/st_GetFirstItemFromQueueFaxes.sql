CREATE procedure [dbo].[st_GetFirstItemFromQueueFaxes]
as

declare @IdQueueFax int
set @IdQueueFax = (select top 1	IdQueueFax 
					from dbo.QueueFaxes (nolock)
						where IdQueueFaxStatus=1
					order by Priority asc, IdQueueFax asc)
					
Update dbo.QueueFaxes set IdQueueFaxStatus=2, DateBeginProcess=GETDATE() where IdQueueFax=@IdQueueFax

SELECT q.[IdQueueFax]
      ,q.[Parameters]
      ,q.[ReportName]
      ,q.[Priority]
      ,a.AgentFax
  FROM [dbo].[QueueFaxes] q (nolock)
  inner join dbo.Agent a (nolock) on a.IdAgent=q.IdAgent
  where q.IdQueueFax=@IdQueueFax
