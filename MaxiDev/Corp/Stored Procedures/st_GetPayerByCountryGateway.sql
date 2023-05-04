Create PROCEDURE [Corp].[st_GetPayerByCountryGateway]
(
    @IdCountry int = null ,
    @IdGateway int = null
)
as


if (isnull(@IdGateway,0)<>0)
begin
	if (isnull(@IdCountry,0)<>0)
	begin

		select distinct c.idpayer,payername
		from 
			PayerConfig c with(nolock)
		join 
			gateway g with(nolock) on g.idgateway=c.idgateway
		join
			Countrycurrency cc with(nolock) on c.IdCountryCurrency=cc.IdCountryCurrency
		join
			  payer p with(nolock) on c.idpayer=p.idpayer    		
		where 
		c.idgateway!=17 and cc.idcountry=isnull(@IdCountry,cc.idcountry) and c.idgenericstatus=1 and c.idgateway=isnull(@IdGateway,c.idgateway)
	end
	else
	begin
		select distinct c.idpayer,payername
		from 
			PayerConfig c with(nolock)
		join 
			gateway g with(nolock) on g.idgateway=c.idgateway
		join
			Countrycurrency cc with(nolock) on c.IdCountryCurrency=cc.IdCountryCurrency
		join
			  payer p with(nolock) on c.idpayer=p.idpayer		
		where 
		c.idgateway!=17 and c.idgenericstatus=1 and c.idgateway=isnull(@IdGateway,c.idgateway)
	end
end
else
begin
	select distinct c.idpayer,payername
	from 
		PayerConfig c with(nolock)
	join 
		gateway g with(nolock) on g.idgateway=c.idgateway
	join
		Countrycurrency cc with(nolock) on c.IdCountryCurrency=cc.IdCountryCurrency
	join
		  payer p with(nolock) on c.idpayer=p.idpayer    
	--join 
		--country cy  on cc.idcountry=cy.idcountry
	where 
    c.idgateway!=17 and cc.idcountry=isnull(@IdCountry,cc.idcountry) and c.idgenericstatus=1 
end
