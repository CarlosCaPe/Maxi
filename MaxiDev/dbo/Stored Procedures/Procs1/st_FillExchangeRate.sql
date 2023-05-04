
Create procedure st_FillExchangeRate
as
Declare @NextTable nvarchar(max)
Select Top 1 @NextTable=NextTableToFill From FillExchangeRateFastRead

If @NextTable='ExchangeRateFastReadSecond'
 Begin
    Exec st_AgentSchemasWithPayersFillerSecond
    Update FillExchangeRateFastRead set NextTableToFill='ExchangeRateFastRead'
 End
 Else
 Begin
    Exec st_AgentSchemasWithPayersFiller 
    Update FillExchangeRateFastRead set NextTableToFill='ExchangeRateFastReadSecond'
 End 
