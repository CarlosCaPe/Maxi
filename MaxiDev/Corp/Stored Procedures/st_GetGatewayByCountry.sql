CREATE PROCEDURE [Corp].[st_GetGatewayByCountry]
(
    @IdCountry int
)
as

if (@IdCountry<>0)
begin
	select distinct g.idgateway,gatewayname
	from 
		PayerConfig c with(nolock)
	join 
		gateway g with(nolock) on g.idgateway=c.idgateway
	join
		Countrycurrency cc with(nolock) on c.IdCountryCurrency=cc.IdCountryCurrency
	--join 
		--country cy  on cc.idcountry=cy.idcountry
	where 
		c.idgateway!=17 and cc.idcountry=@IdCountry and c.idgenericstatus=1
	order by gatewayname
end
else
begin
	select distinct g.idgateway,gatewayname
	from 
		PayerConfig c with(nolock)
	join 
		gateway g with(nolock) on g.idgateway=c.idgateway
	join
		Countrycurrency cc with(nolock) on c.IdCountryCurrency=cc.IdCountryCurrency
	--join 
		--country cy  on cc.idcountry=cy.idcountry
	where 
		c.idgateway!=17 and c.idgenericstatus=1
		order by gatewayname
end
