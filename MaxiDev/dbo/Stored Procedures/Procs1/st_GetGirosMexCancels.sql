-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-06-22
-- Description:	This stored gets transfers to be cancelled
-- =============================================
CREATE PROCEDURE [dbo].[st_GetGirosMexCancels]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @DateValue DATETIME = GETDATE()

	SELECT
		CONVERT(NVARCHAR(10), FORMAT(@DateValue,'MM/dd/yyyy')) FECHA_CAN
		,CONVERT(NVARCHAR(5), @DateValue, 108) HORA_CAN
		,CONVERT(NVARCHAR(10),T.[AmountInDollars]) MONTO_ENVIO
		,CONVERT(NVARCHAR(MAX),T.[ExRate]) TIPO_CAMBIO
		,CASE CU.[IdCurrency] WHEN 1 THEN 2 WHEN 2 THEN 1 ELSE 0 END MONEDA_PAGO -- 1 Peso, 2 Dollar
		,CONVERT(NVARCHAR(30),T.[ClaimCode]) CLAVE_COBRO
	FROM [dbo].[Transfer] T (NOLOCK)
	JOIN [dbo].[CountryCurrency] CC (NOLOCK) ON T.[IdCountryCurrency] = CC.[IdCountryCurrency]
	JOIN [dbo].[Currency] CU (NOLOCK) ON CC.[IdCurrency] = CU.[IdCurrency]
	WHERE
		T.[IdGateway] = 24 -- GIROSMEX
		AND T.[IdStatus] = 25 -- Cancel Stand By

END
