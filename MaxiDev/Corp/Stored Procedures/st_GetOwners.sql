
CREATE PROCEDURE [Corp].[st_GetOwners] 
	@searchParam NVARCHAR(50),
	@includeDisabled BIT,
	@all BIT,
	@IdOwner INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF (@all = 1) 
		BEGIN
			SELECT O.[IdOwner], O.[Name], O.[LastName], O.[SecondLastName], O.[Address], O.[City], O.[State], O.[Zipcode], O.[Phone], O.[Cel], O.[Email], O.[SSN], O.[IdType], O.[IdNumber], 
				O.[IdExpirationDate], O.[BornDate], O.[BornCountry], O.[IdStatus], O.[IdCounty], O.[CreationDate], O.[DateOfLastChange], O.[EnterByIdUser], C.CountyName as County,
				isnull(CT.CountryName, '') AS 'IdCountryEmission', isnull(S.StateName, '') AS 'IdStateEmission'
			FROM [dbo].[Owner] O WITH(NOLOCK)
			LEFT JOIN [dbo].[County] C WITH(NOLOCK) ON C.IdCounty = O.IdCounty 
			LEFT JOIN [dbo].[Country] CT WITH(NOLOCK) ON CT.IdCountry = O.IdCountryEmission
			LEFT JOIN [dbo].[State] S WITH(NOLOCK) ON S.IdState = O.IdStateEmission
		END
	ELSE IF (@IdOwner > 0) 
		BEGIN
			SELECT O.[IdOwner], O.[Name], O.[LastName], O.[SecondLastName], O.[Address], O.[City], O.[State], O.[Zipcode], O.[Phone], O.[Cel], O.[Email], O.[SSN], O.[IdType], O.[IdNumber], 
				O.[IdExpirationDate], O.[BornDate], O.[BornCountry], O.[IdStatus], O.[IdCounty], O.[CreationDate], O.[DateOfLastChange], O.[EnterByIdUser], C.CountyName as County,
				isnull(CT.CountryName, '') AS 'IdCountryEmission', isnull(S.StateName, '') AS 'IdStateEmission'
			FROM [dbo].[Owner] O WITH(NOLOCK)
			LEFT JOIN [dbo].[County] C WITH(NOLOCK) ON C.IdCounty = O.IdCounty 
			LEFT JOIN [dbo].[Country] CT WITH(NOLOCK) ON CT.IdCountry = O.IdCountryEmission
			LEFT JOIN [dbo].[State] S WITH(NOLOCK) ON S.IdState = O.IdStateEmission
			WHERE IdOwner = @IdOwner
		END
	ELSE IF (@includeDisabled = 1) 
		BEGIN
			SELECT O.[IdOwner], O.[Name], O.[LastName], O.[SecondLastName], O.[Address], O.[City], O.[State], O.[Zipcode], O.[Phone], O.[Cel], O.[Email], O.[SSN], O.[IdType], O.[IdNumber], 
				O.[IdExpirationDate], O.[BornDate], O.[BornCountry], O.[IdStatus], O.[IdCounty], O.[CreationDate], O.[DateOfLastChange], O.[EnterByIdUser], C.CountyName as County,
				isnull(CT.CountryName, '') AS 'IdCountryEmission', isnull(S.StateName, '') AS 'IdStateEmission'
			FROM [dbo].[Owner] O WITH(NOLOCK)
			LEFT JOIN [dbo].[County] C WITH(NOLOCK) ON C.IdCounty = O.IdCounty 
			LEFT JOIN [dbo].[Country] CT WITH(NOLOCK) ON CT.IdCountry = O.IdCountryEmission
			LEFT JOIN [dbo].[State] S WITH(NOLOCK) ON S.IdState = O.IdStateEmission
			WHERE NAME LIKE '%' + @searchParam + '%' OR LastName LIKE '%' + @searchParam + '%' OR SecondLastName LIKE '%' + @searchParam + '%'
			
		END
	ELSE 
		BEGIN 
			SELECT O.[IdOwner], O.[Name], O.[LastName], O.[SecondLastName], O.[Address], O.[City], O.[State], O.[Zipcode], O.[Phone], O.[Cel], O.[Email], O.[SSN], O.[IdType], O.[IdNumber], 
				O.[IdExpirationDate], O.[BornDate], O.[BornCountry], O.[IdStatus], O.[IdCounty], O.[CreationDate], O.[DateOfLastChange], O.[EnterByIdUser], C.CountyName as County,
				isnull(CT.CountryName, '') AS 'IdCountryEmission', isnull(S.StateName, '') AS 'IdStateEmission'
			FROM [dbo].[Owner] O WITH(NOLOCK)
			LEFT JOIN [dbo].[County] C WITH(NOLOCK) ON C.IdCounty = O.IdCounty 
			LEFT JOIN [dbo].[Country] CT WITH(NOLOCK) ON CT.IdCountry = O.IdCountryEmission
			LEFT JOIN [dbo].[State] S WITH(NOLOCK) ON S.IdState = O.IdStateEmission
			WHERE IdStatus = 1 AND (NAME LIKE '%' + @searchParam + '%' OR LastName LIKE '%' + @searchParam + '%' OR SecondLastName LIKE '%' + @searchParam + '%')	
		END 
END 

