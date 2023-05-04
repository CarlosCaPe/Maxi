

CREATE PROCEDURE [dbo].[st_CheckOfacByName]
(
	@Name				NVARCHAR(MAX),
	@LastName			NVARCHAR(MAX),
	@SecondLastName		NVARCHAR(MAX),
	@IsValid			BIT OUTPUT
)   
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @OFACTable TABLE (
		EntNum			INT, 
		AltNum			INT,
		Name			NVARCHAR(500),
		LastName		NVARCHAR(500),
		NameComplete	NVARCHAR(500),
		Qualification	FLOAT
	);

	DECLARE @OfacResult		INT,
			@UseMaxiOFAC	BIT = 0

	SET @IsValid=0

	IF EXISTS(SELECT 1 FROM GlobalAttributes ga WHERE ga.Name = 'UseMaxiOfacMatch' AND ga.Value = '1')
		SET @UseMaxiOFAC = 1

	IF @UseMaxiOFAC = 1
	BEGIN
		INSERT @OFACTable
		EXEC st_MaxiOFACFetchCLR @Name, @LastName, @SecondLastName

		SELECT TOP 1
			@OfacResult = CASE WHEN ot.Qualification >= 70 THEN 1 ELSE 0 END
		FROM @OFACTable ot ORDER BY ot.Qualification DESC

		IF @OfacResult = 1
		BEGIN
			SET @IsValid=1
			SELECT 
				SDN_NAME, 
				ISNULL(REMARKS,'') SDN_REMARKS,
				ISNULL(ALT_TYPE,'') ALT_TYPE,
				ISNULL(ALT_NAME,'') ALT_NAME, 
				ISNULL(ALT_REMARKS,'') ALT_REMARKS,
				isnull(ADDRESS,'') ADD_ADDRESS,
				isnull(CITY_NAME,'') ADD_CITY_NAME,
				isnull(COUNTRY,'') ADD_COUNTRY,
				isnull(ADD_REMARKS,'') ADD_REMARKS 
			FROM (SELECT ot.EntNum FROM @OFACTable ot GROUP BY ot.EntNum) L
				JOIN OFAC_SDN (nolock) ON OFAC_SDN.ENT_NUM = L.EntNum
				LEFT join OFAC_ALT  (nolock) ON OFAC_SDN.ENT_NUM=OFAC_ALT.ENT_NUM 
				LEFT JOIN OFAC_ADD  (nolock) ON OFAC_SDN.ENT_NUM=OFAC_ADD.ENT_NUM
		END
	END
	ELSE
	BEGIN
		SET @OfacResult= (SELECT dbo.fun_OfacSearch (@Name,@LastName,''))
		IF @OfacResult = 1
		BEGIN
			SET @IsValid=1
			EXEC ST_OFAC_SEARCH_DETAILS @Name,@LastName,''
		END
	END
END