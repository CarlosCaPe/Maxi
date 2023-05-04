
-- =============================================
-- Author:		TSI
-- Description:	Regresa lista de cheques rechazados por fecha y agente, entre otros parametros

--<ChangeLog>
--<log Date="2023/03/24" Author="jdarellano">Se recompila SP en atención a ticket 8005.</log>
--</ChangeLog>
-- =============================================
CREATE PROCEDURE [dbo].[sp_CC_GetChecksRejected]
	@FechaIni DATE,
	@FechaFin DATE,
	@IdAgent INT,
	@CustName VARCHAR(100) = NULL,
	@CheckNum VARCHAR(50) = NULL,
	@Printed INT = NULL --filtra [0 IRD No generados] [1 IRD generados]  [Otro Todos]
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;


SET @CustName = RTRIM(LTRIM(ISNULL(@CustName,'')))
IF @CustName != ''
BEGIN
	SET @CustName = '%' + REPLACE(@CustName,' ','%') + '%'
END

IF @Printed NOT IN (0,1)
BEGIN
	SET @Printed = NULL
END


SET @CheckNum = RTRIM(LTRIM(ISNULL(@CheckNum,'')))
SET @CheckNum = REPLACE(@CheckNum,' ','')
IF ISNUMERIC(@CheckNum + '.0e0')=0 OR @CheckNum=0
BEGIN
	SET @CheckNum = NULL
END

--si hay checknum => ya no necesita otros filtros
IF @CheckNum != ''
BEGIN
    --SET @FechaIni = NULL
	--SET @FechaFin = NULL
	SET @CustName = NULL
	--SET @Printed = NULL este filtro es obligatorio
END



;WITH t1 AS(
SELECT
	CH.IdCheck,
	CH.CheckNumber, CH.RoutingNumber, CH.Account,
	CH.IdIssuer, CH.IssuerName, CH.DateOfIssue,
	CH.IdCustomer,
	CONCAT(CH.Name,' ',CH.FirstLastName,' ',CH.SecondLastName) [CustomerName],
	CH.IdStatus, ST.StatusName,
	CH.IdAgent, AG.AgentName,
	CH.Amount,

	CR.IdReturnedReason [IdRejectReason],
	CR.DateOfReject [RejectDate],
	CR.EnterByIdUser [RejectByIdUser],
	RR.RTR_Name [RejectReasonName],
	ISNULL(CR.IrdPrinted,0) IrdPrinted,

	RR.CanReProcessCheck AS [CanReProcessCheck],
	RR.CanRePrintCheck   AS [CanRePrintCheck]
FROM dbo.Checks(NOLOCK) CH
JOIN dbo.CheckRejectHistory(NOLOCK) CR ON( CR.IdCheck = CH.IdCheck )
JOIN dbo.CC_ReturnedReasons(NOLOCK) RR ON( RR.ReturnedReason_ID = CR.IdReturnedReason)
LEFT JOIN dbo.Status(NOLOCK) ST ON ST.IdStatus = CH.IdStatus
LEFT JOIN dbo.Agent(NOLOCK) AG ON AG.IdAgent = CH.IdAgent

WHERE CH.IdAgent = @IdAgent
AND CAST(CR.DateOfReject AS DATE) >= CASE WHEN @FechaIni IS NULL THEN CAST(CR.DateOfReject AS DATE) ELSE @FechaIni END
AND CAST(CR.DateOfReject AS DATE) <= CASE WHEN @FechaFin IS NULL THEN CAST(CR.DateOfReject AS DATE) ELSE @FechaFin END
AND CH.CheckNumber = CASE WHEN @CheckNum>0 THEN TRY_CAST(@CheckNum AS BIGINT) ELSE CH.CheckNumber END
)

SELECT * FROM t1
WHERE 1=1
AND t1.CustomerName LIKE CASE WHEN @CustName>'' THEN @CustName ELSE t1.CustomerName END
AND t1.IrdPrinted = CASE WHEN @Printed IN (0,1) THEN @Printed ELSE t1.IrdPrinted END
AND t1.CanReProcessCheck = CASE WHEN @Printed=0 THEN 1 ELSE t1.CanReProcessCheck END


