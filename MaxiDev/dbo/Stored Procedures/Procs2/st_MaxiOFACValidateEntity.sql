CREATE PROCEDURE [dbo].[st_MaxiOFACValidateEntity]
(
	@Name			NVARCHAR(MAX),
	@LastName		NVARCHAR(MAX),
	@SecondName		NVARCHAR(MAX),
	@PercentMatch	FLOAT	OUT,
	@IsFullMatch	BIT		OUT,
	@XMLData		XML		OUT,
	@PercentOfac	FLOAT	= NULL
)
AS
SET NOCOUNT ON
BEGIN
	SET @PercentOfac =  [dbo].[GetGlobalAttributeByName]('MinOfacMatch')

	DECLARE @OFACResult TABLE (
		EntNum			INT, 
		AltNum			INT,
		Name			NVARCHAR(500),
		LastName		NVARCHAR(500),
		NameComplete	NVARCHAR(500),
		Qualification	FLOAT
	)
	DECLARE @OFACEntity TABLE(EntNum INT)


	SET @Name = dbo.fn_EspecialChrOFF(@Name)
	SET @Name = dbo.fn_EspecialChrEKOFF(@Name)

	SET @LastName = dbo.fn_EspecialChrOFF(@LastName)
	SET @LastName = dbo.fn_EspecialChrEKOFF(@LastName)

	SET @SecondName = dbo.fn_EspecialChrOFF(@SecondName)
	SET @SecondName = dbo.fn_EspecialChrEKOFF(@SecondName)

	DECLARE @XMLOut TABLE
	(
		SDN_NAME nvarchar(max),
		SDN_REMARKS nvarchar(max),
		ALT_TYPE nvarchar(max),
		ALT_NAME nvarchar(max),
		ALT_REMARKS nvarchar(max),
		ADD_ADDRESS nvarchar(max),
		ADD_CITY_NAME nvarchar(max),
		ADD_COUNTRY nvarchar(max),
		ADD_REMARKS nvarchar(max),
		FULL_Match bit not null default 0,
		Percent_Match NUMERIC(9, 2) not null default 0
	)


	INSERT @OFACResult
	EXEC st_MaxiOFACFetchCLR @Name, @LastName, @SecondName

	DELETE FROM @OFACResult WHERE Qualification < @PercentOfac

	INSERT @XMLOut
	SELECT
		sdn.SDN_name,
		sdn.remarks,
		alt.alt_type,
		alt.alt_name,
		alt.alt_remarks,
		ad.address,
		ad.city_name,
		ad.country,
		ad.add_remarks,
		CASE WHEN o.Qualification >= 100 
			THEN 1 
			ELSE 0 
		END,
		o.Qualification
	FROM @OFACResult o
		JOIN OFAC_SDN sdn ON sdn.ent_num = o.EntNum
		LEFT JOIN OFAC_ALT alt ON alt.alt_num = o.AltNum AND alt.ent_num = o.EntNum
		LEFT JOIN OFAC_ADD ad ON ad.ent_num = sdn.ent_num

	SELECT TOP 1
		@PercentMatch = o.Percent_Match,
		@IsFullMatch = o.FULL_Match
	FROM @XMLOut o
	ORDER BY o.Percent_Match DESC

	IF @PercentMatch >= @PercentOfac
	BEGIN

		INSERT INTO @OFACEntity(EntNum)
		SELECT EntNum FROM @OFACResult GROUP BY EntNum

		INSERT INTO @XMLOut
		SELECT
			sdn.SDN_name,
			sdn.remarks,
			alt.alt_type,
			alt.alt_name,
			alt.alt_remarks,
			ad.address,
			ad.city_name,
			ad.country,
			ad.add_remarks,
			0,
			0
		FROM @OFACEntity o
			JOIN OFAC_SDN sdn ON sdn.ent_num = o.EntNum
			LEFT JOIN OFAC_ALT alt ON alt.ent_num = o.EntNum
			LEFT JOIN OFAC_ADD ad ON ad.ent_num = sdn.ent_num
		WHERE
			NOT EXISTS(
				SELECT 
					1 
				FROM @OFACResult ort 
				WHERE ort.EntNum = o.EntNum 
				AND (alt.alt_num IS NULL OR ort.AltNum = alt.alt_num)
			)

		SET @XMLData = (SELECT
			ISNULL(c.SDN_NAME, '') 		SDN_NAME,
			ISNULL(c.SDN_REMARKS, '') 	SDN_REMARKS,
			ISNULL(c.ALT_TYPE, '') 		ALT_TYPE,
			ISNULL(c.ALT_NAME, c.SDN_NAME) 		ALT_NAME,
			ISNULL(c.ALT_REMARKS, '') 	ALT_REMARKS,
			ISNULL(c.ADD_ADDRESS, '') 	ADD_ADDRESS,
			ISNULL(c.ADD_CITY_NAME, '') ADD_CITY_NAME,
			ISNULL(c.ADD_COUNTRY, '') 	ADD_COUNTRY,
			ISNULL(c.ADD_REMARKS, '') 	ADD_REMARKS,
			c.FULL_Match,
			c.Percent_Match,
			'Percent' Method 
		FROM @XMLOut c ORDER BY c.Percent_Match DESC FOR XML RAW,ROOT('OFACInfo'))
	END

END
