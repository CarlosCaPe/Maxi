
/********************************************************************
<Author>Alejandro Cardenas</Author>
<date>26/01/2023</date>
<app>MaxiAgente</app>
<Description>Sp para obtener el PayerCode para consumir el api de ClaimsCode</Description>
*********************************************************************/
CREATE   PROCEDURE [dbo].[st_GetCodeByPreTransfer]
(
	@IdPretransfer		BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @IdGateway		INT,
			@IdPayer		INT,
			@Code			NVARCHAR(MAX),
			@ActiveProfile BIT,
			@IdPaymentType  INT

	SELECT @IdGateway = IdGateway,
		   @IdPayer = IdPayer,
		   @IdPaymentType = IdPaymentType
	FROM PreTransfer preTransfer WITH(NOLOCK)
	WHERE IdPreTransfer = @IdPretransfer

	IF @IdGateway IN (3, 10, 9, 8, 11, 13, 14, 15, 16, 18, 20, 22, 19, 24, 26, 28, 30, 31, 33, 35, 38, 42, 37)
		BEGIN
			SELECT	@Code=PayerCode, 
					@ActiveProfile = claimCode.ActiveProfile 
			FROM Payer payer WITH(NOLOCK) 
			INNER JOIN ClaimCodeProfileForApi claimCode  WITH (NOLOCK)
			ON payer.PayerCode = claimCode.ProfileKey
			WHERE IdPayer=@IdPayer AND claimCode.ActiveProfile = 1 
  
			IF (@Code='INMOB')--#1
				SET @Code='MiCoope'
			IF (@Code='MT' AND @IdPaymentType=6)
				SET @Code='MiCoope'
			PRINT @Code
		END
	ELSE IF @IdGateway IN (39, 43, 44, 53, 40 /*46*/, 56, 55, 54, 51, 47, 34, 32, 4)
		BEGIN
			SELECT	@Code = g.Code, 
					@ActiveProfile = claimCode.ActiveProfile  
			FROM Gateway g WITH (NOLOCK)	
			INNER JOIN ClaimCodeProfileForApi claimCode  WITH (NOLOCK)
			ON g.Code = claimCode.ProfileKey
			WHERE g.IdGateway = @IdGateway AND claimCode.ActiveProfile = 1 
		END

	SELECT @Code AS Code, @ActiveProfile AS ActiveProfile;

	SET NOCOUNT OFF;
END

