CREATE PROCEDURE [Corp].[st_GetIssuerByData]
(@RoutingNumber varchar(100), @AccountNumber varchar(100))
AS
BEGIN
	select top 1 IdIssuer, Name, RoutingNumber, AccountNumber, PhoneNumber from IssuerChecks where RoutingNumber = @RoutingNumber AND AccountNumber = @AccountNumber order by IdIssuer desc
END
