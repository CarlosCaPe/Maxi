CREATE PROCEDURE [dbo].[st_AMLPGetSuspiciousKYCHoldReasonById]
(
	@Id INT
)
AS
BEGIN
	SELECT * FROM AMLP_SuspiciousKYCHoldReason s WITH(NOLOCK) WHERE s.Id = @Id
END
