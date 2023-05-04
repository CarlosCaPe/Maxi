CREATE PROCEDURE [dbo].[st_GetOFACSDN]
AS
BEGIN
	DECLARE @AllowedTypes TABLE (TypeName VARCHAR(200))
	INSERT INTO @AllowedTypes
	VALUES ('Individual '), ('Entity')


	;WITH CTE (EntNum, AltNum, NameComplete, Name, LastName, Remarks, Type)
	AS
	(
		SELECT 
			oa.ent_num,
			oa.alt_num,
			oa.alt_name,
			oa.ALT_PrincipalName,
			oa.ALT_FirstLastName,
			CASE 
				WHEN ISNULL(oa.alt_remarks, '') <> '' THEN oa.alt_remarks
				ELSE sd.remarks
			END,
			oa.alt_type
		FROM OFAC_ALT oa WITH(NOLOCK)
			JOIN OFAC_SDN sd WITH(NOLOCK) ON sd.ent_num = oa.ent_num
		WHERE EXISTS (SELECT 1 FROM @AllowedTypes att WHERE att.TypeName = sd.SDN_type)
		UNION
		SELECT 
			sd.ent_num,
			NULL,
			sd.SDN_name,
			sd.SDN_PrincipalName,
			sd.SDN_FirstLastName,
			sd.remarks,
			sd.SDN_type	
		FROM OFAC_SDN sd WITH(NOLOCK)
		WHERE EXISTS (SELECT 1 FROM @AllowedTypes att WHERE att.TypeName = sd.SDN_type)
	) 
	SELECT
		c.*,
		ISNULL(a.address, '') Address,
		ISNULL(a.city_name, '') CityName,
		ISNULL(a.country, '') Country,
		ISNULL(a.add_remarks, '') AddRemarks
	FROM CTE c
		LEFT JOIN OFAC_ADD a ON a.ENT_NUM = c.EntNum
	ORDER BY c.EntNum
END
