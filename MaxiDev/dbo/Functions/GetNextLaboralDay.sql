CREATE FUNCTION [dbo].[GetNextLaboralDay] (@InputDate DATETIME)
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
	DECLARE @Day AS INT = DATEPART(DW, @InputDate)
	IF @Day IN (7,1) OR (SELECT COUNT(1) FROM FederalHolidays with(nolock) WHERE [Day] = CONVERT(DATE, @InputDate)) > 0
	BEGIN
		SET @InputDate = [dbo].[GetNextLaboralDay](DATEADD(DAY, 1, @InputDate))  
	END
	RETURN @InputDate
END