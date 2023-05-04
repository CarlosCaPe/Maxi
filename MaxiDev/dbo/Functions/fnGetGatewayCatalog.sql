CREATE FUNCTION [dbo].[fnGetGatewayCatalog]
(
	@IdGateway		INT,
	@CatalogType	NVARCHAR(100),
	@IdPaymentType	INT
)
RETURNS @Result TABLE
(
	Code			NVARCHAR(200),
	IdReference		INT
)
AS
BEGIN

	--IF NOT EXISTS (SELECT 1 FROM GatewayCatalogType gct WHERE gct.Name = @CatalogType)
	--BEGIN
	--	DECLARE @MSG_ERROR NVARCHAR(500) = 'The catalog type (' + @CatalogType + ') not exists'
	--	RAISERROR(@MSG_ERROR, 16, 1);
	--END

	INSERT INTO @Result(Code, IdReference)
	SELECT 
		gc.Code,
		gc.IdReference
	FROM GatewayCatalog gc 
		JOIN GatewayCatalogType gct ON gct.IdGatewayCatalogType = gc.IdGatewayCatalogType
	WHERE gc.IdGateway = @IdGateway
		AND gc.IdPaymentType = @IdPaymentType
		AND gct.Name = @CatalogType

	RETURN
END
