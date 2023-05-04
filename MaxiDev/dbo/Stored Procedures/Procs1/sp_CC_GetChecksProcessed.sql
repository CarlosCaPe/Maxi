-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_CC_GetChecksProcessed]
	@FechaIni DATE,
	@FechaFin DATE,
	@IdAgent INT,
	@CustName VARCHAR(100) = NULL,
	@CheckNum VARCHAR(50) = NULL
AS

-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

--Select @FechaIni=dbo.RemoveTimeFromDatetime(@FechaIni), @FechaFin=dbo.RemoveTimeFromDatetime(@FechaFin+1)


SELECT @CustName = RTRIM(LTRIM(ISNULL(@CustName,'')))
IF @CustName != ''
BEGIN
	SELECT @CustName = '%' + REPLACE(@CustName,' ','%') + '%'
END


SELECT @CheckNum = RTRIM(LTRIM(ISNULL(@CheckNum,'')))
IF @CheckNum='' SET @CheckNum='0'


DECLARE	@sql NVARCHAR(MAX)

SET @sql = N'
    
SELECT
	CH.IdCheck,                                                
	CH.CheckNumber, CH.RoutingNumber, CH.Account,
	CH.IdIssuer, CH.IssuerName, CH.DateOfIssue,
	CH.IdCustomer,
	CONCAT(CH.Name,'' '',CH.FirstLastName,'' '',CH.SecondLastName) [CustomerName],
	CH.IdStatus,
	-- Se comentan las siguientes líneas para mostrar lo del status MP-1047 - Autor: Gerardo Reyes
	--CASE WHEN CH.IdStatus=30  THEN '' '' ELSE 
	--	CASE WHEN CH.IdStatus IN (31,22) AND TypeOfMovement=''CH''  AND 
	--		 ( SELECT COUNT (val.TypeOfMovement) as nMoves 
	--			FROM AgentBalance val	WHERE  val.IdAgent= @IdAgent
	--			AND val.Reference=ab.Reference
	--			HAVING COUNT(val.TypeOfMovement) > 1) is not null
	--		THEN '' ''
	--	ELSE ST.StatusName END
	--END
	ST.StatusName
	AS [StatusName],
	CH.IdAgent, AG.AgentName,
	CASE WHEN CH.IdStatus=30 AND TypeOfMovement=''CH'' THEN CH.Amount
	ELSE 
		CASE WHEN CH.IdStatus IN (31,22) AND TypeOfMovement=''CH''  AND 
		 ( SELECT COUNT (val.TypeOfMovement) as nMoves 
			FROM AgentBalance val	WHERE  val.IdAgent= @IdAgent
			AND val.Reference=ab.Reference
			HAVING COUNT(val.TypeOfMovement) > 1) is not null
		THEN CH.Amount
		ELSE 0 END 
	END	
	AS [Amount],

	ab.DateOfMovement,
	CASE WHEN ab.Reference IS NULL THEN convert(varchar,ab.IdAgentBalance) ELSE ab.Reference END AS [BaReference],
	CASE WHEN CH.IdStatus IN (31,22) AND TypeOfMovement=''CHRTN'' THEN CH.fee*(-1)
			ELSE 
					CASE WHEN CH.IdStatus IN (31,22) AND TypeOfMovement=''CH'' AND 
						 ( SELECT COUNT (val.TypeOfMovement)  
						FROM AgentBalance val	WHERE  val.IdAgent= @IdAgent
						AND val.Reference=ab.Reference
						HAVING COUNT(val.TypeOfMovement) > 1) is not null
					 THEN CH.fee
					ELSE
						CASE WHEN CH.IdStatus IN (31,22) AND TypeOfMovement=''CH'' AND 
							 ( SELECT COUNT (val.TypeOfMovement)  
								FROM AgentBalance val	WHERE  val.IdAgent= @IdAgent
								AND val.Reference=ab.Reference
								HAVING COUNT(val.TypeOfMovement) > 1) is null
						 THEN CH.fee*(-1)
						 ELSE 0 END  
					END
			END
	AS [Fee],
	ab.FxFee [BaValFee],
	CASE WHEN CH.IdStatus IN (31) AND TypeOfMovement=''CHRTN'' THEN CH.ReturnFee
	  ELSE 
		CASE WHEN CH.IdStatus IN (31) AND TypeOfMovement=''CH''  AND 
		 ( SELECT COUNT (val.TypeOfMovement) as nMoves 
			FROM AgentBalance val	WHERE  val.IdAgent= @IdAgent
			AND val.Reference=ab.Reference
			HAVING COUNT(val.TypeOfMovement) > 1) is null
		THEN CH.ReturnFee
		ELSE 0 END 
	END
	
	
	AS [BaNSFFee],
	CASE WHEN DebitOrCredit = ''Credit'' THEN ab.Amount*(-1) ELSE ab.Amount END AS [BaCredit],
		
	ab.Balance AS Balance,
	ab.TypeOfMovement [BaTypeOfMovement],
		
	( SELECT TOP 1 Balance FROM AgentBalance WHERE TypeOfMovement IN (''CH'',''CHRTN'') AND IdAgent = @IdAgent
		AND CAST(DateOfMovement AS DATE) BETWEEN @FechaIni AND @FechaFin
		ORDER BY DateOfMovement DESC
	) [LastBalance],
	0 CanReProcessCheck

FROM dbo.AgentBalance(NOLOCK) ab
JOIN dbo.checks(NOLOCK) CH ON CH.IdCheck = ab.reference
JOIN dbo.Status(NOLOCK) ST ON ST.IdStatus = CH.IdStatus
JOIN dbo.Agent(NOLOCK) AG ON AG.IdAgent = CH.IdAgent

WHERE ab.TypeOfMovement IN (''CH'',''CHRTN'') 
AND ab.IdAgent = @IdAgent
AND CAST(ab.DateOfMovement AS DATE) BETWEEN @FechaIni AND @FechaFin
';

IF @CheckNum!='0'
BEGIN
  SET @sql = @sql + ' AND CH.CheckNumber = @CheckNum ';
END


IF @CustName!='' AND @CheckNum='0'
BEGIN
	SET @sql = @sql+' AND CONCAT(CH.Name,'' '',CH.FirstLastName,'' '',CH.SecondLastName) LIKE @CustName  ';
END


SET @sql = @sql+' ORDER BY ab.DateOfMovement ASC ';
--SET @sql = @sql+' ORDER BY BaReference ASC ';


--PRINT @sql

EXEC sp_executesql @sql,
N'@FechaIni DATE,  @FechaFin Date,  @IdAgent INT,  @CustName VARCHAR(100),  @CheckNum VARCHAR(50)',
  @FechaIni,       @FechaFin,       @IdAgent,      @CustName,               @CheckNum;
