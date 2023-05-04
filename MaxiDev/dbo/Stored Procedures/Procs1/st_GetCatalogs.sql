
CREATE PROCEDURE st_GetCatalogs 
--  st_GetCatalogs 7
(
	@IdCountry int = null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Select StateCode, StateName from State with(nolock) where IdCountry = 18 order by StateCode

	select CountryCode, CountryName from country with(nolock) where idcountry = 18

	Select * from DictionarySource with(nolock)

	--Select Name, NameEs from DictionaryOccupation with(nolock)

	Select * from DictionaryPurpose with(nolock)

	Select * from DictionaryRelationship with(nolock)

	Select Name, NameEs from CustomerIdentificationType with(nolock)

	select Name, NameEs from BeneficiaryIdentificationType where (idcountry = @IdCountry or @IdCountry is null)

	Select AccountTypeName from AccountType with(nolock)
END
