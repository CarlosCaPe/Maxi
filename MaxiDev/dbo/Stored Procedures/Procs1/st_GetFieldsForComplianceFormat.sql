-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-08-20
-- Description:	Get required filds by transfer for Compliance Format
-- =============================================
CREATE PROCEDURE [dbo].[st_GetFieldsForComplianceFormat]
	-- Add the parameters for the stored procedure here
	@TransferId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF EXISTS (SELECT TOP 1 1 FROM [dbo].[Transfer] WITH (NOLOCK) WHERE [IdTransfer] = @TransferId)
		SELECT
			T.[ClaimCode]
			,LTRIM(ISNULL(A.[AgentCode],'') + ' ' + ISNULL(A.[AgentName],'')) AgentName
			,T.[Folio] TransferFolio
			,LTRIM(ISNULL(T.[CustomerName],'') + ' ' + ISNULL(T.[CustomerFirstLastName],'') + ' ' + ISNULL(T.[CustomerSecondLastName],'')) CustomerName
			,ISNULL(CIT.[Name],'') IdentificationType
			,ISNULL(T.[CustomerIdentificationNumber],'') IdentificationNumber
			,T.[CustomerBornDate] BornDate
			,T.[CustomerExpirationIdentification] ExpirationDate
			,ISNULL(T.[CustomerSSNumber],'') SsnOrTaxId
			,ISNULL(T.[CustomerOccupation],'') Occupation
			,ISNULL(T.[Purpose],'') PurposeOfTransfer
			,ISNULL(T.[Relationship],'') RelationshipWithRecipient
			,LTRIM(ISNULL(OWB.[Name],'') + ' ' + ISNULL(OWB.[FirstLastName],'') + ' ' + ISNULL(OWB.[SecondLastName],'')) Owb
			,ISNULL(C.[CityName] + ', ' + S.[StateName], ISNULL(C.[CityName],'') + ISNULL(S.[StateName],'')) DestinationCityAndState,
			t.DateOfTransfer,
			t.AmountInDollars as Amount
		FROM [dbo].[Transfer] T (NOLOCK)
		JOIN [dbo].[Agent] A (NOLOCK) ON T.[IdAgent] = A.[IdAgent]
		LEFT JOIN [dbo].[Branch] B (NOLOCK) ON T.[IdBranch] = B.[IdBranch]
		LEFT JOIN [dbo].[City] C (NOLOCK) ON B.[IdCity] = C.[IdCity]
		LEFT JOIN [dbo].[State] S (NOLOCK) ON C.[IdState] = S.[IdState]
		LEFT JOIN [dbo].[CustomerIdentificationType] CIT (NOLOCK) ON T.[CustomerIdCustomerIdentificationType] = CIT.[IdCustomerIdentificationType]
		LEFT JOIN [dbo].[OnWhoseBehalf] OWB (NOLOCK) ON T.[IdOnWhoseBehalf] = OWB.[IdOnWhoseBehalf]
		WHERE T.[IdTransfer] = @TransferId

	ELSE
		SELECT
			T.[ClaimCode]
			,LTRIM(ISNULL(A.[AgentCode],'') + ' ' + ISNULL(A.[AgentName],'')) AgentName
			,T.[Folio] TransferFolio
			,LTRIM(ISNULL(T.[CustomerName],'') + ' ' + ISNULL(T.[CustomerFirstLastName],'') + ' ' + ISNULL(T.[CustomerSecondLastName],'')) CustomerName
			,ISNULL(CIT.[Name],'') IdentificationType
			,ISNULL(T.[CustomerIdentificationNumber],'') IdentificationNumber
			,T.[CustomerBornDate] BornDate
			,T.[CustomerExpirationIdentification] ExpirationDate
			,ISNULL(T.[CustomerSSNumber],'') SsnOrTaxId
			,ISNULL(T.[CustomerOccupation],'') Occupation
			,ISNULL(T.[Purpose],'') PurposeOfTransfer
			,ISNULL(T.[Relationship],'') RelationshipWithRecipient
			,LTRIM(ISNULL(OWB.[Name],'') + ' ' + ISNULL(OWB.[FirstLastName],'') + ' ' + ISNULL(OWB.[SecondLastName],'')) Owb
			,ISNULL(C.[CityName] + ', ' + S.[StateName], ISNULL(C.[CityName],'') + ISNULL(S.[StateName],'')) DestinationCityAndState
			,t.DateOfTransfer
			,t.AmountInDollars as Amount
		FROM [dbo].[TransferClosed] T (NOLOCK)
		JOIN [dbo].[Agent] A (NOLOCK) ON T.[IdAgent] = A.[IdAgent]
		LEFT JOIN [dbo].[Branch] B (NOLOCK) ON T.[IdBranch] = B.[IdBranch]
		LEFT JOIN [dbo].[City] C (NOLOCK) ON B.[IdCity] = C.[IdCity]
		LEFT JOIN [dbo].[State] S (NOLOCK) ON C.[IdState] = S.[IdState]
		LEFT JOIN [dbo].[CustomerIdentificationType] CIT (NOLOCK) ON T.[CustomerIdCustomerIdentificationType] = CIT.[IdCustomerIdentificationType]
		LEFT JOIN [dbo].[OnWhoseBehalf] OWB (NOLOCK) ON T.[IdOnWhoseBehalf] = OWB.[IdOnWhoseBehalf]
		WHERE T.[IdTransferClosed] = @TransferId

END
