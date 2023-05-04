-- =============================================
-- Author:		Aldo Morán Márquez
-- Create date: 28/04/2015
-- Description:	Get Denay Issuers and messages
-- =============================================
CREATE PROCEDURE [dbo].[st_VerifyDenyIssuers](@IdIssuer int)
AS
BEGIN

	select 
		IdKYCAction,
		MessageInSpanish,
		MessageInEnglish
	from 
		DenyListIssuerCheckActions 
	where 
		IdDenyListIssuerCheck  in (select IdDenyListIssuerCheck from DenyListIssuerChecks where IdIssuerCheck = @IdIssuer AND IdGenericStatus = 1) 
			
END
