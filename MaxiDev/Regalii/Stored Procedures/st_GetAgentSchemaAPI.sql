CREATE procedure [Regalii].[st_GetAgentSchemaAPI]
(
    @IdAgent int,
    @IdCountry int,
	@IdCarrier int
)
as

declare @IdOtherProduct int = 17	--Regalii Top Up
		--PorAgencia Country
		select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,ca.Name carriername,s.IdProduct,null Product,null RetailPrice,BeginValue,EndValue,Commission,IsDefault,
		case 
			when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
			when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
			when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
			when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
		end
		CommissionType 
		from [TransFerTo].[Schema] s
		left join dbo.country c on s.IdCountry=c.idcountry
		left join Regalii.Billers ca on s.idcarrier=ca.IdBiller    
		where     
			s.idcountry=@IdCountry and s.idcarrier is null and isdefault=0 and s.IdGenericStatus=1 and IdSchema in (select a.IdSchema from  [TransFerTo].[AgentSchema] a join [TransFerTo].[schema] s on a.idschema=s.idschema and s.IdOtherProduct=@IdOtherProduct where idagent=@IdAgent)
			and s.IdOtherProduct=@IdOtherProduct
    
    union all
		--Default Country
		select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,ca.Name carriername,s.IdProduct,null Product,null RetailPrice,BeginValue,EndValue,Commission,IsDefault ,
		case 
			when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
			when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
			when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
			when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
		end
		CommissionType
		from [TransFerTo].[Schema] s
		left join dbo.country c on s.IdCountry=c.idcountry
		left join Regalii.Billers ca on s.idcarrier=ca.IdBiller
		where s.idcountry=@IdCountry and s.idcarrier is null and isdefault=1 and s.IdGenericStatus=1 
		and s.IdOtherProduct=@IdOtherProduct
    
    union all
    
		select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,ca.Name carriername,s.IdProduct,null Product,null RetailPrice,BeginValue,EndValue,Commission,IsDefault ,
		case 
			when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
			when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
			when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
			when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
		end
		CommissionType
		from [TransFerTo].[Schema] s
		left join dbo.country c on s.IdCountry=c.idcountry
		left join Regalii.Billers ca on s.idcarrier=ca.IdBiller
		where s.idcountry is null and s.idcarrier is null and s.idproduct is null and @idcountry is not null and @IdCarrier is not null
		and s.IdOtherProduct=@IdOtherProduct

    union all
		--PorAgencia Country-Carrier
		select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,ca.Name carriername,s.IdProduct,null Product,null RetailPrice,BeginValue,EndValue,Commission,IsDefault,
		case 
			when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
			when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
			when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
			when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
		end
		CommissionType 
		from [TransFerTo].[Schema] s
		left join dbo.country c on s.IdCountry=c.idcountry
		left join Regalii.Billers ca on s.idcarrier=ca.IdBiller    
		where     
			s.idcountry=@IdCountry and s.idcarrier=@IdCarrier and isdefault=0 and s.IdGenericStatus=1 and IdSchema in (select a.IdSchema from  [TransFerTo].[AgentSchema] a join [TransFerTo].[schema] s on a.idschema=s.idschema and s.IdOtherProduct=@IdOtherProduct where idagent=@IdAgent)
			and s.IdOtherProduct=@IdOtherProduct
    
    union all
		--Default Country-Carrier
		select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,ca.Name carriername,s.IdProduct,null Product,null RetailPrice,BeginValue,EndValue,Commission,IsDefault ,
		case 
			when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
			when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
			when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
			when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
		end
		CommissionType
		from [TransFerTo].[Schema] s
		left join dbo.country c on s.IdCountry=c.idcountry
		left join Regalii.Billers ca on s.idcarrier=ca.IdBiller
		where s.idcountry=@IdCountry and s.idcarrier=@IdCarrier and isdefault=1 and s.IdGenericStatus=1 
		and s.IdOtherProduct=@IdOtherProduct

		order by IsDefault asc ,CommissionType desc