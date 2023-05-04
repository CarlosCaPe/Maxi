CREATE FUNCTION [dbo].[fn_GetIsAgentException] (@IdAgent int)
RETURNS bit
AS
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
BEGIN

DECLARE @result bit = 0

	
SELECT top 1 @result = Exception from AgentException with(nolock) where IdAgent=@IdAgent order by EnterDate desc

return  isnull(@result,0)

end
