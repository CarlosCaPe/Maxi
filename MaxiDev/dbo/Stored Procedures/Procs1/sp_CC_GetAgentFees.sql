-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_CC_GetAgentFees]
  @IdAgente int, 
  @CheckAmount money, 
  @State int
AS
BEGIN

DECLARE
@vlAgFeeFixed money,
@vlAgtFeePerc money,
@vlCustFee money,
@AgComm money,
@CustMaxStatePercFee money,
@CustMaxStateFixedFee money,
@ValidationFee money

DECLARE @IdCheckType int = 99

DECLARE @IdFeeChecks INT
DECLARE @IsFeePerc BIT = 0


--Obtiene el IdState del Agente
SELECT @State = ST.IdState
FROM Agent AG
LEFT JOIN [State] ST ON ST.StateCode = AG.AgentState AND ST.IdCountry=18
WHERE AG.IdAgent = @IdAgente


--Obtenemos el fee que el agente cobra al cliente
SELECT @vlAgFeeFixed=ACF_FeeFixed, @vlAgtFeePerc=ACF_FeePerc
FROM CC_AgFees
WHERE IdAgent = @IdAgente
AND IdCheckType = @IdCheckType
AND @CheckAmount BETWEEN ACF_CheckAmountFrom AND ACF_CheckAmountTo

--Si @vlAgFeeFixed es nulo, entonces no hay comision definida por tipo de cheque
IF @vlAgFeeFixed IS NULL
BEGIN
	-- En este caso, buscamos la comision general (sin tipo de cheque)
	SELECT @vlAgFeeFixed=ACF_FeeFixed, @vlAgtFeePerc=ACF_FeePerc
	FROM CC_AgFees
	WHERE IdAgent = @IdAgente
	AND @CheckAmount BETWEEN ACF_CheckAmountFrom AND ACF_CheckAmountTo
END

SELECT @vlAgFeeFixed=ISNULL(@vlAgFeeFixed, 0), @vlAgtFeePerc=ISNULL(@vlAgtFeePerc, 0)
SET @vlCustFee = @vlAgFeeFixed + ROUND( ((@CheckAmount * @vlAgtFeePerc) / 100), 2)


--Obtiene Maximos Fees por State
SELECT
  @CustMaxStatePercFee  = MaxPercFee,
  @CustMaxStateFixedFee = MaxFixedFee
FROM CC_MaxCustFeeByState
WHERE IdState = @State



--Obtenemos id de configuracion comisiones Al agente
SELECT @IdFeeChecks = IdFeeChecks FROM FeeChecks WHERE IdAgent = @IdAgente

--Obtiene el Fee por el uso de un servicio externo de validacion de cuenta
SELECT @ValidationFee = TransactionFee FROM FeeChecks WHERE IdFeeChecks = @IdFeeChecks

--Obtiene el fee cuando el monto del cheque esta en un rango
SELECT @AgComm = Fee,  @IsFeePerc = IsFeePercentage FROM FeeChecksDetail
WHERE IdFeeChecks = @IdFeeChecks
AND @CheckAmount BETWEEN FromAmount AND ToAmount

IF @IsFeePerc = 1
BEGIN
	SET @AgComm = ROUND(((@CheckAmount * @AgComm) / 100), 2)
END


--Revsion de nulos
SELECT @vlCustFee  = ISNULL(@vlCustFee,  0)
SELECT @AgComm = ISNULL(@AgComm, 0)
SELECT @CustMaxStatePercFee  = ISNULL(@CustMaxStatePercFee,  0)
SELECT @CustMaxStateFixedFee = ISNULL(@CustMaxStateFixedFee, 0)
SELECT @ValidationFee = ISNULL(@ValidationFee, 0)



--Resultado
SELECT
	CustFee = @vlCustFee,
	AgComm  = @AgComm,
	CustMaxStatePercFee = @CustMaxStatePercFee,
	CustMaxStateFixedFee = @CustMaxStateFixedFee,
	ValidationFee = @ValidationFee

END