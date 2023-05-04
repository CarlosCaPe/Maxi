CREATE function [dbo].[funGetIdBranch] (@BranchReceive nvarchar(max), @Idgateway int, @IdPayer int)  
RETURNS int
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
BEGIN 

declare @BranchCodeAndName int

select top 1 
    @BranchCodeAndName = gb.IdBranch
from 
    GatewayBranch gb with(nolock)
join Branch 
        b with(nolock) on b.IdBranch=gb.IdBranch and IdPayer=@IdPayer
where 
    idgateway=@IdGateway and GatewayBranchCode = @BranchReceive


return isnull(@BranchCodeAndName,0)

end