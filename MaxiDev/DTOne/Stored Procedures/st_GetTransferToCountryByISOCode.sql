CREATE     procedure [DTOne].[st_GetTransferToCountryByISOCode]
(
    @isoCode varchar(3)
)
as
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		SELECT
		idcountry,countryname,PhoneCountryCode,IdGenericStatus 
		FROM [DTOne].Country 
		WHERE CountryCode like @isoCode 
		ORDER BY countryname
END