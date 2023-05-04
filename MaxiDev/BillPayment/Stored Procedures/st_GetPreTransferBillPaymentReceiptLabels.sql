CREATE PROCEDURE [BillPayment].[st_GetPreTransferBillPaymentReceiptLabels]
(
	@IdPreTransfer	INT
)
AS
/********************************************************************
<Author>MAPRADO</Author>
<app>MaxiAgent</app>
<Description>This stored is used to get labels for especific receipt</Description>

<ChangeLog>
	<log Date="05/12/2022" Author="MAPRADO">Se crea Sp</log>
</ChangeLog>
*********************************************************************/
BEGIN
	DECLARE @ReceiptPrefix VARCHAR(200);
	
	SELECT @ReceiptPrefix = 'PreReceipt.BP.'

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

	IF EXISTS(SELECT 1 FROM CountryCurrency cc WHERE cc.IdCountryCurrency = @IdCountryCurrency AND cc.IdCountry = 3)
		SET @CustomerLenguage = 3
	ELSE IF EXISTS(SELECT 1 FROM CountryCurrency cc WHERE cc.IdCountryCurrency = @IdCountryCurrency AND cc.IdCountry IN (@IdCountryVNM, @IdCountryPHL, @IdCountryIDN))
		SET @CustomerLenguage = NULL

	DECLARE @Labels TABLE (LabelName VARCHAR(300), CorporativeLabel VARCHAR(MAX), CustomerLabel VARCHAR(MAX))

	INSERT INTO @Labels(LabelName, CorporativeLabel, CustomerLabel)
	SELECT 
		REPLACE(lr.MessageKey, @ReceiptPrefix, '') LabelName, 
		MAX(CASE WHEN lr.IdLenguage = @CorporativeLenguage THEN lr.Message END) CorporativeLabel,
		MAX(CASE WHEN lr.IdLenguage = @CustomerLenguage THEN lr.Message END) CustomerLabel
	FROM LenguageResource lr WITH(NOLOCK)
	WHERE lr.MessageKey LIKE CONCAT(@ReceiptPrefix, '%')
	GROUP BY lr.MessageKey

	SELECT
		l.LabelName,
		CASE 
			WHEN l.CorporativeLabel IS NULL THEN l.CustomerLabel
			WHEN l.CustomerLabel IS NULL THEN l.CorporativeLabel
			ELSE CONCAT(l.CorporativeLabel, '/', l.CustomerLabel)
		END LabelValue
	FROM @Labels l
END
