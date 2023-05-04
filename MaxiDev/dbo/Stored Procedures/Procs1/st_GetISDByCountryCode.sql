CREATE PROCEDURE st_GetISDByCountryCode
(
	@CountryCodeAlpha2	VARCHAR(10) = NULL,
	@CountryCodeAlpha3	VARCHAR(10) = NULL
)
AS
BEGIN
	IF @CountryCodeAlpha2 IS NOT NULL
		SELECT * FROM CountryCallingCodes ccc
		WHERE ccc.CountryCodeAlpha2 = @CountryCodeAlpha2
	ELSE 
		SELECT * FROM CountryCallingCodes ccc
		WHERE ccc.CountryCodeAlpha3 = @CountryCodeAlpha3
END