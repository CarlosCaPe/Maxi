


/****************************/
/* GetTransferBasicInfoById */
/****************************/
CREATE PROCEDURE [dbo].[st_GetTransferBasicInfoById]
(
	@IdTransfer int
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
declare @CurrentTransfer table (IdAgent int, ClaimCode nvarchar(max), Folio nvarchar(max),
						 AgentName nvarchar(max), AgentCode nvarchar(max), DateOfTransfer datetime, 
						 CustomerName nvarchar(max), CustomerFirstLastName nvarchar(max), CustomerSecondLastName nvarchar(max))

insert into @CurrentTransfer
select T.IdAgent, T.ClaimCode, T.Folio, A.AgentName, A.AgentCode, T.DateOfTransfer, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName 
from [Transfer] T with(nolock) 
inner join [Agent] A with(nolock) on T.IdAgent = A.IdAgent 
where IdTransfer = @IdTransfer;

If(@@ROWCOUNT=0)
begin
	insert into @CurrentTransfer
	select T.IdAgent, T.ClaimCode, T.Folio, A.AgentName, A.AgentCode, T.DateOfTransfer, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName 
	from [TransferClosed] T with(nolock)
	inner join [Agent] A  with(nolock) on T.IdAgent = A.IdAgent 
	where IdTransferClosed = @IdTransfer;
end

select * from @CurrentTransfer;
