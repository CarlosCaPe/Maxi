CREATE PROCEDURE [Corp].[st_GetStatesLicensed]
AS
BEGIN
DECLARE @IdUsa INT;
SELECT @IdUsa = Convert(INT, Value) FROM dbo.GlobalAttributes WHERE Name = 'IdCountryUSA' 
SELECT 
			S.IdState,
			S.StateName,
			S.StateCode
FROM		dbo.State S WITH (NOLOCK) 
WHERE		S.IdCountry = @IdUsa AND S.SendLicense = 1
ORDER BY	S.StateCode

	
END





