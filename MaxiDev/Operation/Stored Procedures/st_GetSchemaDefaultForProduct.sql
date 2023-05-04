-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-03-29
-- Description:	Returns master scheme by product // This stored is used in MaxiBackOffice-Billpayments (TopUpSchemes)
-- =============================================
CREATE PROCEDURE [Operation].[st_GetSchemaDefaultForProduct]
(
    @IdProvider INT = NULL,
    @IdSchemaDefaultOut INT OUTPUT
)
AS
	DECLARE @IdOtherProduct INT
	SET @Idprovider = ISNULL(@Idprovider,2)
	SET @IdOtherProduct =	CASE
								WHEN @IdProvider=2 THEN 7	-- TransferTo Top Up
								WHEN @IdProvider=3 THEN 9	-- Lunex Top Up
								WHEN @IdProvider=5 THEN 17	-- Regalii Top Up
							ELSE 0 END

	SELECT @IdSchemaDefaultOut=[IdSchema] FROM [Operation].[SchemaDefaultForProduct] WITH (NOLOCK) WHERE IdOtherProduct=@IdOtherProduct

	SET @IdSchemaDefaultOut=ISNULL(@IdSchemaDefaultOut,0)

