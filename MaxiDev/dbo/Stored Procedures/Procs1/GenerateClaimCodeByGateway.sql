CREATE PROCEDURE [dbo].[GenerateClaimCodeByGateway] 
(
	@IdGateway	INT,
	@ClaimCode	NVARCHAR(MAX) OUT
)
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2022/09/14" Author="jcsierra" Name="#MP1276">SD1-2414, MP-1276: Se genera nuevo proceso de generacion de claimcodes</log>
</ChangeLog>
********************************************************************/  
BEGIN
	DECLARE @GatewayCode	VARCHAR(200),
			@MSG_ERROR		NVARCHAR(500)


	SELECT
		@GatewayCode = g.Code
	FROM Gateway g WITH (NOLOCK)
	WHERE g.IdGateway = @IdGateway

	IF ISNULL(@GatewayCode, '') = ''
	BEGIN
		SET @MSG_ERROR = CONCAT('The IdGateway (', @IdGateway ,') does not exist')
		RAISERROR(@MSG_ERROR, 16, 1);
	END

	CREATE TABLE #ResultCode (Result NVARCHAR(MAX))

	INSERT INTO #ResultCode (Result)
	EXEC st_GenerateClaimCode @GatewayCode
	--EXEC ST_TNC_CLAIM_CODE_GEN @GatewayCode


	SELECT TOP 1
		@ClaimCode = rc.Result
	FROM #ResultCode rc 
END