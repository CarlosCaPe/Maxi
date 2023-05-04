CREATE PROCEDURE [dbo].[st_GetDialingCode]
(
	@IdDialingCodePhoneNumber    INT
	
)
AS
BEGIN

  select DialingCode from DialingCodePhoneNumber
	where IdDialingCodePhoneNumber=@IdDialingCodePhoneNumber


END