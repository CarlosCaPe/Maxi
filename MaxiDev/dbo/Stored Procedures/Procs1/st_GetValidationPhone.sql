CREATE PROCEDURE [dbo].st_GetValidationPhone
AS
BEGIN

  select Value from GlobalAttributes
	where Name='ACTIVEVALIDATIONPHONE'


END