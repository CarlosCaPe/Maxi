CREATE PROCEDURE [dbo].[st_GetConfigureInfinite]

AS
BEGIN
	
	
	SELECT  Value  from Services.ServiceAttributes
	WHERE Code='INFINITE' order by [KEY];
	
	END