CREATE PROCEDURE [dbo].[st_GetPin4Cancels]
AS
BEGIN
	DECLARE @IdGateway	INT = 53 /*46*/
	DECLARE @NewCancel_SMS VARCHAR(500)

	SELECT 
		@NewCancel_SMS = sa.Value
	FROM ServiceAttributes sa WITH(NOLOCK) 
		JOIN Gateway g WITH(NOLOCK) ON g.Code = sa.Code
	WHERE g.IdGateway = @IdGateway
	AND sa.AttributeKey = 'NewCancel_SMS'

	SELECT
		t.IdTransfer,
		t.ClaimCode,

		SUBSTRING(
			REPLACE(REPLACE(ISNULL(rc.Reason, ''), ')', ''), '(', ''),
			0, 
			15
		)										CancelationReason,
		'01'										CancellationReasonType,

		t.ConfirmationCode							IssuerTicket,
		@NewCancel_SMS								[Messages],

		'ENG'										BeneficiaryLanguage,
		'ENG'										SenderLanguage
	FROM Transfer t WITH(NOLOCK)
		LEFT JOIN ReasonForCancel rc WITH(NOLOCK) ON t.IdReasonForCancel = rc.IdReasonForCancel
	WHERE 
		t.IdGateway = @IdGateway
		AND t.IdStatus = 25
		AND ISNULL(t.ConfirmationCode, '') <> ''
END
