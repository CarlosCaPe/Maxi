CREATE function [dbo].[fn_GetDateOfDebit](@IdAgent int, @CurrentDate datetime)
RETURNS datetime
AS 
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
begin
declare @DaysForDebit int
declare @DateOfDebit datetime
Declare @IdIdAgentDateDebit int
Declare @IdIdAgentDateDebitTop int
declare @DateOfTMP datetime
DECLARE @Amount MONEY
declare @AgentDateDebit table
(
    IdAgentDateDebit int identity(1,1),
    dateofdebit datetime,
    amount money
);

select @DaysForDebit = convert(int,[dbo].[GetGlobalAttributeByName]('DaysForDebitDate'));

insert into @AgentDateDebit
select 
   min(dateofcollection) dateofdebit, sum(amount)-sum(collectamount) amount
from 
    maxicollection WITH(NOLOCK)
where 
    dateofcollection>=[dbo].[RemoveTimeFromDatetime](@CurrentDate)-@DaysForDebit and dateofcollection<[dbo].[RemoveTimeFromDatetime](@CurrentDate) and
    Idagent=@IdAgent
group by idagent,dateofcollection
order by dateofcollection desc;

SELECT @IdIdAgentDateDebit = 1,@IdIdAgentDateDebitTop=MAX(IdAgentDateDebit) FROM @AgentDateDebit;

WHILE @IdIdAgentDateDebit <= (@IdIdAgentDateDebitTop)
BEGIN
    select @DateOfTMP=dateofdebit, @Amount=Amount from  @AgentDateDebit where IdAgentDateDebit=@IdIdAgentDateDebit;

    if(round(@Amount,2)>0)
        set @DateOfDebit=@DateOfTMP;
    else
        begin            
            break;
        end

    SET @IdIdAgentDateDebit = @IdIdAgentDateDebit + 1;
END

if ([dbo].[RemoveTimeFromDatetime](@DateOfDebit)=[dbo].[RemoveTimeFromDatetime](getdate()))
begin
    set @DateOfDebit=null;
end

return @DateOfDebit;

end