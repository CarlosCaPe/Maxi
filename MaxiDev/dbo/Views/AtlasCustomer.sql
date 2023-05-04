CREATE VIEW AtlasCustomer
AS
SELECT IdCustomer,
	   [Name] as [Name],
	   FirstLastName,
	   SecondLastName,
	   CAST(BornDate AS DATE) AS BornDate,
	   '' as Gender,
	   '' AS Email,
	   ISNULL(REPLACE(REPLACE(REPLACE(REPLACE(PhoneNumber,')',''),'(',''),'-',''),' ',''),'') AS PhoneNumber,
	   ISNULL(REPLACE(REPLACE(REPLACE(REPLACE(CelullarNumber,')',''),'(',''),'-',''),' ',''),'') AS CelullarNumber,
	   D.Prefix AS PrefixPhone,
	   [Address],
	   Zipcode,
	   City,
	   [State],
	   Country
FROM dbo.Customer C WITH (NOLOCK)
INNER JOIN dbo.DialingCodePhoneNumber D WITH (NOLOCK) ON C.IdDialingCodePhoneNumber=D.IdDialingCodePhoneNumber
