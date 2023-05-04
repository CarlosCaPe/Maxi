
CREATE procedure [dbo].[st_GetGatewayByCountry]
(
    @IdCountry int
)
as

if (@IdCountry<>0)
begin
	select distinct g.idgateway,gatewayname
	from 
		PayerConfig c
	join 
		gateway g on g.idgateway=c.idgateway
	join
		Countrycurrency cc on c.IdCountryCurrency=cc.IdCountryCurrency
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
		PayerConfig c
	join 
		gateway g on g.idgateway=c.idgateway
	join
		Countrycurrency cc on c.IdCountryCurrency=cc.IdCountryCurrency
	--join 
		--country cy  on cc.idcountry=cy.idcountry
	where 
		c.idgateway!=17 and c.idgenericstatus=1
		order by gatewayname
end