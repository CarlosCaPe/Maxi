CREATE FUNCTION [dbo].[ValidateLaboralDay] (@InputDate DATETIME)
RETURNS DATETIME
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
AS
BEGIN
	IF CAST(@InputDate as time)  >= (SELECT Value FROM GlobalAttributes with(nolock) WHERE Name = 'LimitHourForNextDay')
	BEGIN
		SET @InputDate = [dbo].[GetNextLaboralDay](DATEADD(DAY, 1, @InputDate)) 
	END
	RETURN @InputDate
END