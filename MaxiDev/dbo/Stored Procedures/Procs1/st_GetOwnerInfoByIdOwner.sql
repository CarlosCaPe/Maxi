-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[st_GetOwnerInfoByIdOwner](
	@IdOwner INT
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT ISNULL(O.[IdOwner],'')[IdOwner]
		  ,ISNULL(O.[Name],'')[Name]
		  ,ISNULL(O.[LastName],'')[LastName]
		  ,ISNULL(O.[SecondLastName],'')[SecondLastName]
		  ,ISNULL(O.[Address],'')[Address]
		  ,ISNULL(O.[City],'')[City]
		  ,ISNULL(O.[State],'')[State]
		  ,ISNULL(O.[Zipcode],'')[Zipcode]
		  ,ISNULL(O.[Phone],'')[Phone]
		  ,ISNULL(O.[Cel],'')[Cel]
		  ,ISNULL(O.[Email],'')[Email]
		  ,ISNULL(O.[SSN],'')[SSN]
		  ,ISNULL(O.[IdType],'')[IdType]
		  ,ISNULL(O.[IdNumber],'')[IdNumber]
		  ,O.[IdExpirationDate]
		  ,O.[BornDate]
		  ,ISNULL(O.[BornCountry],'')[BornCountry]
		  ,ISNULL(O.[IdStatus],'')[IdStatus]
		  ,O.[IdCounty]
		  ,ISNULL(C.[CountyName],'') AS County
	  FROM [dbo].[Owner] O (NOLOCK)
		left join [dbo].[County] C (NOLOCK) ON C.IdCounty = O.IdCounty
	WHERE IdOwner = @IdOwner
		------AND IdStatus = 1
	DECLARE @IdCounty INT
	SELECT @IdCounty = IdCounty FROM [dbo].[Owner] O (NOLOCK) WHERE IdOwner = @IdOwner

	SELECT ISNULL(C.CountyClassName,'')CountyClassName FROM RelationCountyCountyClass Cl (NOLOCK)
		join CountyClass C on C.IdCountyClass = Cl.IdCountyClass
		WHERE Cl.IdCounty = @IdCounty
END
--GO
--EXEC [st_GetOwnerInfoByIdOwner] 2556