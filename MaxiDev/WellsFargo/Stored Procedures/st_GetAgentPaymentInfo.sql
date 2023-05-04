create procedure WellsFargo.st_GetAgentPaymentInfo
(
    @IdAgent int
)
as 
begin
set nocount on
--Declaracion de Variables
declare @PaymentDate datetime
declare @balance money 
declare @expected money
declare @deposit money
declare @today int

--Inicializaacion de variables
set @PaymentDate=dbo.RemoveTimeFromDatetime(getdate())
set  @today=[dbo].[GetDayOfWeek] (@PaymentDate)         

        
if @today=6 or @today=7
begin            
    set @PaymentDate = case 
                        when @today=6 then
                            @PaymentDate-1 
                        when @today=7 then
                            @PaymentDate-2
                        end
end

print (@PaymentDate)

select @deposit=sum(amount) from agentdeposit where dateoflastchange>=@PaymentDate and  dateoflastchange<@PaymentDate+1 and idagent=@IdAgent

select @balance=balance from agentcurrentbalance where idagent=@IdAgent

select @expected=amount from maxicollection where idagent=@IdAgent and dateofcollection=@PaymentDate

select isnull(@balance,0) as balance, isnull(@expected,0) as expected, isnull(@deposit,0) depositAmount
end