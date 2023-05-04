-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-02-19
-- Description:	Get check extra info. This stored is used in Corporate (BackOffice)
-- =============================================
CREATE PROCEDURE [dbo].[st_GetCheckExtraInfo]
	-- Add the parameters for the stored procedure here
	@CheckId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT
		C.[IdCheck]
		, C.[IdCustomer]
		, CU.[Address]
		, C.[DateOfBirth]
		, CU.[CelullarNumber]
		, CU.[City]
		, CU.[Country]
		, CU.[ExpirationIdentification]
		, CU.[Name]
		, CU.[FirstLastName]
		, CU.[SecondLastName]
		, CU.[IdAgentCreatedBy]
		, CU.[IdCarrier]
		, CU.[IdentificationNumber]
		, CU.[Occupation]
		, CU.[PhoneNumber]
		, CU.[SSNumber]
		, CU.[State]
		, CU.[Zipcode]
		, CU.[PhysicalIdCopy]
	FROM [dbo].[Checks] C
	JOIN [dbo].[Customer] CU ON C.[IdCustomer] = CU.[IdCustomer]
	WHERE [IdCheck] = @CheckId

END
