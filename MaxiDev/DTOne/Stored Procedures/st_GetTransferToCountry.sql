CREATE   procedure [DTOne].[st_GetTransferToCountry]
(
    @All bit
)
as
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		SELECT
		idcountry,countryname,PhoneCountryCode,IdGenericStatus 
		FROM [DTOne].Country 
		WHERE IdGenericStatus = CASE WHEN @All=1 THEN IdGenericStatus ELSE 1 END  
		ORDER BY countryname
END