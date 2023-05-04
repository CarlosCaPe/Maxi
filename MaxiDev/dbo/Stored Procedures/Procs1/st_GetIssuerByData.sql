-- =============================================
-- Author:		Aldo Morán Márquez
-- Create date: 10/04/2015
-- Description:	GetExisting Issuer by routing number and Account Number
-- =============================================
CREATE PROCEDURE [dbo].[st_GetIssuerByData](@RoutingNumber varchar(100), @AccountNumber varchar(100))
AS
BEGIN
	select top 1 IdIssuer, Name, RoutingNumber, AccountNumber, PhoneNumber from IssuerChecks where RoutingNumber = @RoutingNumber AND AccountNumber = @AccountNumber order by IdIssuer desc
END
