CREATE PROCEDURE [Corp].[st_GetIssuers]
@Search varchar(max)
as
Begin
	SELECT
		ic.Name as Name,
		ic.RoutingNumber as RoutingNumber,
		ic. AccountNumber as AccountNumber,
		ic.IdIssuer as IdIssuer
		
	FROM
		IssuerChecks ic with(nolock)
	WHERE
		--ic.IdIssuer not in (select IdIssuerCheck from denylistissuerchecks)
		--and 
		ic.Name like '%' + @Search  + '%'
End
