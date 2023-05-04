
CREATE Procedure [dbo].[st_GetDenyListIssuerCheckDetails]
@IdIssuer int
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Begin
	SELECT
		dl.IdDenyListIssuerCheckAction as Id,
		dl.IdDenyListIssuerCheck as DenlyListIssuerCheck,
		dl.IdKYCAction as KYCAction,
		dl.MessageInEnglish as EnglishMessage,
		dl.MessageInSpanish as SpanishMessage,
		kyc.[Action] as ActionName
	FROM
		DenyListIssuerCheckActions  dl with(nolock),KYCAction kyc with(nolock)
	WHERE
		dl.IdDenyListIssuerCheck=@IdIssuer
		and dl.IdKYCAction=kyc.IdKYCAction
End