CREATE   procedure [DTOne].[GetCarrierByCountry]
(
    @Idcountry int
)
as

	SELECT 
		c.IdCarrier,
		CarrierName,
		c.IdCarrierDTO
	FROM [DTOne].[Carrier] c
	JOIN [DTOne].[product]  p ON c.idcarrier=p.idcarrier and p.IdGenericStatus=1
	JOIN [DTOne].country t ON c.idcountry=t.idcountry
	WHERE t.IdCountry=@Idcountry
	GROUP BY c.idcarrier,CarrierName,c.IdCarrierDTO
	HAVING count(1)>1
	ORDER BY CarrierName