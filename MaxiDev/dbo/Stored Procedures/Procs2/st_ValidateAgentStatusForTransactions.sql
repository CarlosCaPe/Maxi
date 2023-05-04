CREATE procedure [dbo].[st_ValidateAgentStatusForTransactions]
(
    @IdLenguage int,
    @IdAgent int,
    @HasError bit OUTPUT,
	@Message nvarchar(max) OUTPUT       
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;


set @IdLenguage = isnull(@IdLenguage,2)

declare @IdStatus int     
    
	select 
        @IdStatus = a.idAgentStatus 
    from 
        Agent a with(nolock) 
    where 
        a.idagent = @IdAgent    


if (@IdStatus=2) or (@IdStatus=3) or (@IdStatus=4) or (@IdStatus=5) or (@IdStatus=6) or (@IdStatus=7) or (@IdStatus is null)
begin
    Set @HasError=1   
    Set @Message = [dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'MESSAGE29')
    return
end
    
Set @HasError = 0
set @Message = ''
