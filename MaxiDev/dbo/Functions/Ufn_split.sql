 
CREATE FUNCTION [dbo].[Ufn_split] (@string    NVARCHAR(max),
 
@delimiter CHAR(1))
 
 
 /********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Optener Biller By </Description>

<ChangeLog>

<log Date="15/06/2018" Author="amoreno">Creation</log>
</ChangeLog>
*********************************************************************/

returns @output TABLE(
 
splitdata NVARCHAR(max))
 
BEGIN
 
DECLARE @start INT,
 
@end   INT
 
SELECT @start = 1,
 
@end = Charindex(@delimiter, @string)
 
WHILE @start < Len(@string) + 1
 
BEGIN
 
IF @end = 0
 
SET @end = Len(@string) + 1
 
INSERT INTO @output
 
(splitdata)
 
VALUES     (Substring(@string, @start, @end - @start))
 
SET @start = @end + 1
 
SET @end = Charindex(@delimiter, @string, @start)
 
END
 
RETURN
 
END
 
