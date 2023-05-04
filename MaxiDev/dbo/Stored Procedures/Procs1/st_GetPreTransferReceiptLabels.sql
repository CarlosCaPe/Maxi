CREATE PROCEDURE [dbo].[st_GetPreTransferReceiptLabels]
(
	@IdPreTransfer	INT
)
AS
/********************************************************************
<Author></Author>
<app>MaxiAgent</app>
<Description>This stored is used to get labels for pretransfer thermal ticket</Description>

<ChangeLog>
	<log Date="15/11/2022" Author="maprado">Se agregan WITH(NOLOCK) faltantes </log>
	<log Date="15/11/2022" Author="maprado">Se agrega validacion para Indonesia</log>
	<log Date="07/12/2022" Author="jcsierra">Se muestran solo los labels de los idiomas seleccionados</log>
	<log Date="14/02/2023" Author="maprado">BM-810  Fix para renombrar etiquete de telefono si es Asia</log>
	<log Date="24/04/2023" Author="maprado">BM-1678 Se agrega validacion para obtener etiquetas desde PreTransferClosed</log>
</ChangeLog>
*********************************************************************/
BEGIN
	DECLARE @ReceiptPrefix VARCHAR(200) = 'PreReceipt.MT.'

	DECLARE @CorporativeLenguage	INT = 1,
			@CustomerLenguage		INT = 2,
			@IdCountryCurrency		INT,
			@IdCountryPHL			INT,
			@IdCountryVNM			INT,
			@IdCountryIDN			INT

	SET @IdCountryPHL = dbo.GetGlobalAttributeByName('IdCountryPHL')
	SET @IdCountryVNM = dbo.GetGlobalAttributeByName('IdCountryVNM')
	SET @IdCountryIDN = dbo.GetGlobalAttributeByName('IdCountryIDN')

	SELECT 
		@IdCountryCurrency = t.IdCountryCurrency
	FROM PreTransfer t WITH(NOLOCK)
	WHERE t.IdPreTransfer = @IdPreTransfer

	IF @IdCountryCurrency IS NULL
		SELECT
			@IdCountryCurrency = t.IdCountryCurrency
		FROM PreTransferClosed t WITH(NOLOCK)
		WHERE t.IdPreTransferClosed = @IdPreTransfer 

	IF EXISTS(SELECT 1 FROM CountryCurrency cc WITH(NOLOCK) WHERE cc.IdCountryCurrency = @IdCountryCurrency AND cc.IdCountry = 3)
		SET @CustomerLenguage = 3
	ELSE IF EXISTS(SELECT 1 FROM CountryCurrency cc WITH(NOLOCK) WHERE cc.IdCountryCurrency = @IdCountryCurrency AND cc.IdCountry IN (@IdCountryVNM, @IdCountryPHL, @IdCountryIDN))
		SET @CustomerLenguage = NULL

	DECLARE @Labels TABLE (LabelName VARCHAR(300), CorporativeLabel VARCHAR(MAX), CustomerLabel VARCHAR(MAX))

	INSERT INTO @Labels(LabelName, CorporativeLabel, CustomerLabel)
	SELECT 
		REPLACE(lr.MessageKey, @ReceiptPrefix, '') LabelName, 
		MAX(CASE WHEN lr.IdLenguage = @CorporativeLenguage THEN lr.Message END) CorporativeLabel,
		MAX(CASE WHEN lr.IdLenguage = @CustomerLenguage THEN lr.Message END) CustomerLabel
	FROM LenguageResource lr WITH(NOLOCK)
	WHERE lr.MessageKey LIKE CONCAT(@ReceiptPrefix, '%')
	AND lr.IdLenguage IN (@CustomerLenguage, @CorporativeLenguage)
	GROUP BY lr.MessageKey

	-- BM-810 BEGIN
	IF @CustomerLenguage IS NULL
	BEGIN
		UPDATE @Labels SET CorporativeLabel = 'Ph'
		WHERE LabelName = 'General.PhoneLabel'
	END
	-- BM-810 END

	SELECT
		l.LabelName,
		CASE 
			WHEN l.CorporativeLabel IS NULL THEN l.CustomerLabel
			WHEN l.CustomerLabel IS NULL THEN l.CorporativeLabel
			ELSE CONCAT(l.CorporativeLabel, '/', l.CustomerLabel)
		END LabelValue
	FROM @Labels l
END
