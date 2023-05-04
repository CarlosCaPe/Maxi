-- =============================================
-- Author:		Francisco Lara
-- Create date: 216-04-01
-- Description:	Return customer by VipCard // This stored is used in Agent FrontOffice
--<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
--<log Date="2020/11/21" Author="jgomez" Name="SSN">-- CR M00298 	</log>
--<log Date="2022/07/04" Author="maprado" Name="IdDialingCodePhoneNumber"> 	</log>
-- ============================================
CREATE PROCEDURE [dbo].[st_FindCustomerByVipCard]
	-- Add the parameters for the stored procedure here
	@VipCard NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @InterCode NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName]('InfiniteCountryCode')

    -- Insert statements for procedure here
	SELECT TOP 1
		C.[Address]
		, C.[BornDate]
		, C.[CelullarNumber]
		, C.[IdDialingCodePhoneNumber]
		, C.[City]
		, CV.[CardNumber]
		, C.[IdAgentCreatedBy]
		, C.[FirstLastName]
		, C.[IdCustomer]
		, C.[IdCustomerIdentificationType]
		, C.[Name]
		, C.[IdentificationNumber]
		, C.[Occupation]
		, C.[PhoneNumber]
		, C.[SecondLastName]
		, C.[SSNumber]
		, C.[State]
		, C.[ZipCode]
		, C.[ExpirationIdentification]
		, C.[IdCarrier]
		, C.[IdentificationIdCountry]
		, C.[IdentificationIdState]
		, CV.[IdGenericStatus]
		, C.[IdCountryOfBirth]
		, C.[IdOccupation]
		, C.[IdSubcategoryOccupation]
		, C.[SubcategoryOccupationOther]
		, ISNULL([CN].[AllowSentMessages],0) [ReceiveSms]
		, C.[IdTypeTax] -- CR M00298
	FROM [dbo].[CardVIP] CV WITH (NOLOCK)
	JOIN [dbo].[Customer] C WITH (NOLOCK) ON CV.[IdCustomer] = C.[IdCustomer]
	LEFT JOIN [Infinite].[CellularNumber] CN WITH (NOLOCK) ON C.[CelullarNumber] = CN.[NumberWithFormat] AND [CN].[IsCustomer] = 1 AND [CN].[InterCode] = @InterCode
	WHERE CV.[CardNumber] = @VipCard
		AND CV.[IdGenericStatus] = 1

END
