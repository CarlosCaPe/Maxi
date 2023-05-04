
CREATE   PROCEDURE [dbo].[st_GetTransferNewStatusTime]
	  @idTransfer INT
AS

/********************************************************************
<Author></Author>
<app></app>
<Description></Description>

<ChangeLog>
	<log Date="25/01/2016" Author="raarce">Creacion del Store</log>
	<log Date="29/03/2023" Author="maprado">Se agrega campo directRefund para verificar si los estatus de transferDetail permiten cancelar directo</log>
	<log Date="29/03/2023" Author="maprado">Se agrega campo isRefund30 para verificar el tiempo de 30 min para Refund directo sin pantalla Refunds</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY

	DECLARE @PaymentTypesCannotModify TABLE ( IdPaymentType INT )
	INSERT INTO @PaymentTypesCannotModify VALUES (2)

	DECLARE @IdCountryUSA INT
	SET @IdCountryUSA = dbo.GetGlobalAttributeByName('IdCountryUSA')

	DECLARE @TransferDate DATETIME
	SELECT @TransferDate = DateOfTransfer FROM [dbo].[Transfer] WITH (NOLOCK) WHERE IdTransfer = @IdTransfer

	DECLARE @IdStatusCannotRefund TABLE (IdStatus INT)
	INSERT INTO @IdStatusCannotRefund
	SELECT IdStatus FROM [Status] ST WITH (NOLOCK) WHERE ST.StatusName IN ('Payment Ready','Pending Gateway Response','Transfer Accepted')

	DECLARE @directRefund BIT
	SELECT @directRefund = IIF (COUNT(*) > 0,0,1) FROM [dbo].[TransferDetail] TD WITH (NOLOCK)
	INNER JOIN @IdStatusCannotRefund SCR ON SCR.IdStatus = TD.IdStatus
	WHERE TD.IdTransfer = @idTransfer

	SELECT CASE
			WHEN ptm.IdPaymentType IS NOT NULL THEN 0
			WHEN T.IdPaymentMethod = 2 THEN 0
			WHEN CC.IdCountry = @IdCountryUSA THEN 0
			WHEN St.CanChangeRequest = 1 THEN 1
			ELSE 0
		END isModifyV2,
		@directRefund directRefund,
		IIF( DATEDIFF(minute, @TransferDate, GETDATE()) <=30,1,0) isRefund30
	FROM [dbo].[Transfer] T
	LEFT JOIN @PaymentTypesCannotModify ptm ON ptm.IdPaymentType = T.IdPaymentType
	LEFT JOIN [dbo].[Status] St ON St.[IdStatus] = T.[IdStatus]
	INNER JOIN [dbo].[CountryCurrency] CC ON CC.[IdCountryCurrency] = T.[IdCountryCurrency]
	WHERE T.IdTransfer = @idTransfer

END TRY
BEGIN CATCH
	DECLARE @Message VARCHAR(MAX) = ERROR_MESSAGE()
	DECLARE @ErrorLine VARCHAR(20) = CONVERT(VARCHAR(20), ERROR_LINE())
	INSERT INTO dbo.ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage)
	VALUES ('st_GetTransferNewStatusTime', GETDATE(), 'Line: ' + @ErrorLine + '. ' + @Message)
END CATCH