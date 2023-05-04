CREATE PROCEDURE [dbo].[st_GetACHCollection]
    @ACHDate DATETIME,
    @IdUser INT,
    @IdAgentCollectType  INT,
    @DateOfLastChange DATETIME out,
    @ApplyDate DATETIME OUT    
AS

/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="2023/02/10" Author="jdarellano">Se agregan WITH(NOLOCK) faltantes.</log>
</ChangeLog>
*********************************************************************/

--Declaracion de Variables
DECLARE @IdACHSummary INT;
DECLARE @NumAgent int;
--DECLARE @ACHAgent TABLE
CREATE TABLE #ACHAgent
(
    IdAgent INT,
    AgentCode NVARCHAR(max),
    Agent NVARCHAR(max),
    ReferenceAmount money,    
    AmountByCalendar MONEY, 
    AmountByLastDay MONEY, 
    AmountByCollectPlan MONEY,
    Amount money,
    Note NVARCHAR(max),
    IsManual bit
);

--Inicializacion de variables
SET @ACHDate = dbo.RemoveTimeFromDatetime(@ACHDate);

--Verificar si existe un Summary para ACH
IF  NOT EXISTS (SELECT 1 FROM dbo.ACHSummary WITH (NOLOCK) WHERE ACHDate = @ACHDate AND IdAgentCollectType = @IdAgentCollectType)
BEGIN
     --Obtener ACH por agencia
    INSERT INTO #ACHAgent    
    --EXEC [st_GetAgentACH] @ACHDate,@IdAgentCollectType  
    SELECT a.idagent,a.agentcode,a.agentname,SUM(ISNULL(AmountByCalendar,0)+ISNULL(AmountByLastDay,0)+ISNULL(AmountByCollectPlan,0)),SUM(AmountByCalendar), SUM(AmountByLastDay), SUM(AmountByCollectPlan), SUM(ISNULL(AmountByCalendar,0)+ISNULL(AmountByLastDay,0)+ISNULL(AmountByCollectPlan,0)) Amount,'',0 FROM dbo.MaxiCollection AS m WITH (NOLOCK)
		INNER JOIN dbo.Agent AS a WITH (NOLOCK) ON m.idagent = a.idagent
			WHERE m.IdAgentCollectType = @IdAgentCollectType AND DateOfCollection = @ACHDate AND a.IdAgentStatus = 1
				GROUP BY a.idagent,a.agentcode,a.agentname;

    SELECT @NumAgent = COUNT(1) FROM #ACHAgent;

    IF (@NumAgent > 0)
    BEGIN
        --Insercion del Summary
        INSERT INTO dbo.ACHSummary
            (ACHDate,CreationDate,EnterByIdUser,IdAgentCollectType)
        VALUES
            (@ACHDate,GETDATE(),@IdUser,@IdAgentCollectType);
    
        SET @IdACHSummary = SCOPE_IDENTITY();

        --Insercion de movimientos de ACH
        INSERT INTO [ACHMovement]        
			SELECT @IdACHSummary,IdAgent,ReferenceAmount,Amount,note,AmountByCalendar,AmountByLastDay,AmountByCollectPlan,0 FROM #ACHAgent;
    END
END

ELSE
BEGIN
    INSERT INTO #ACHAgent 
		SELECT 
			m.idagent,
			a.AgentCode,
			a.AgentName,
			m.ReferenceAmount,
			AmountByCalendar,AmountByLastDay,AmountByCollectPlan,
			m.amount,
			m.note,
			m.IsManual
		FROM dbo.ACHSummary AS s WITH (NOLOCK)
		JOIN dbo.ACHMovement AS m WITH (NOLOCK) ON s.IdACHSummary = m.IdACHSummary
		JOIN dbo.Agent AS a WITH (NOLOCK) ON a.IdAgent = m.idagent
    WHERE s.ACHDate = @ACHDate AND s.IdAgentCollectType = @IdAgentCollectType;
END

SELECT @DateOfLastChange = DateofLastChange,@ApplyDate = ApplyDate FROM dbo.ACHSummary WITH (NOLOCK) WHERE ACHDate = @ACHDate AND IdAgentCollectType = @IdAgentCollectType;

SELECT 
    c.[Name] AgentClass,
    A.IdAgent,
    A.AgentCode,
    Agent,
    ISNULL(AccountNumber,'') AccountNumber,
    ISNULL(RoutingNumber,'') RoutingNumber,
    ReferenceAmount,
    AmountByCalendar,AmountByLastDay,AmountByCollectPlan,
    --CASE (@IdAgentCollectType) 
    --    WHEN 1 THEN Amount 
    --    ELSE Amount-ISNULL(OtherAmount,0) 
    --end Amount,
    ISNULL(CASE	WHEN (ISNULL([Amount],0) != ISNULL([ReferenceAmount],0)) OR (ISNULL([Amount],0) = 0 OR ISNULL([ReferenceAmount],0) = 0) OR (ISNULL([ReferenceAmount],0) < ISNULL(D.[OtherAmount],0)) THEN ISNULL([Amount],0)
			ELSE ISNULL([ReferenceAmount],0) - ISNULL(D.[OtherAmount],0)
	END,0) [Amount],
    ISNULL(Note,'') Note, 
    --CASE (@IdAgentCollectType) 
    --    WHEN 1 THEN 0 
    --    else ISNULL(OtherAmount,0) 
    --end OtherDeposit 
    --case when @IdAgentCollectType=1 then 0 else ISNULL(OtherAmount,0) end OtherDeposit,
	ISNULL(D.[OtherAmount],0) OtherDeposit,
    case when AmountByCalendar>0 then 1 else 0 end IsPayDay
FROM #ACHAgent AS A
JOIN dbo.Agent AS b WITH (NOLOCK) ON a.IdAgent = b.IdAgent
JOIN dbo.AgentClass AS c WITH (NOLOCK) ON b.idagentclass = c.idagentclass    
LEFT JOIN(
    SELECT Idagent,SUM(Amount) OtherAmount 
	FROM dbo.AgentDeposit WITH (NOLOCK)
    WHERE dateoflastchange >= @ACHDate AND dateoflastchange < @ACHDate+1 
    AND 
    (
		(@IdAgentCollectType = 2 AND ISNULL(IdAgentCollectType,0) NOT IN (2)) OR
        (@IdAgentCollectType = 1 AND ISNULL(IdAgentCollectType,0) NOT IN (1))
    )
    AND Amount > 0
    GROUP BY IdAgent
) d ON a.IdAgent = d.Idagent
--where ReferenceAmount>case when @IdAgentCollectType=1 then 0 else ISNULL(d.OtherAmount,0) end and ismanual=0
WHERE (ReferenceAmount > ISNULL(d.OtherAmount,0)) AND ismanual = 0 /*2016-Ago-05*/
UNION ALL
SELECT 
    c.[Name] AgentClass,
    A.IdAgent,
    A.AgentCode,
    Agent,
    ISNULL(AccountNumber,'') AccountNumber,
    ISNULL(RoutingNumber,'') RoutingNumber,
    ReferenceAmount,
    AmountByCalendar,AmountByLastDay,AmountByCollectPlan,
    --CASE (@IdAgentCollectType) 
    --    WHEN 1 THEN Amount 
    --    ELSE Amount-ISNULL(OtherAmount,0) 
    --end Amount,
     ISNULL(
		CASE	
			WHEN (ISNULL([Amount],0) != ISNULL([ReferenceAmount],0)) OR (ISNULL([Amount],0) = 0 OR ISNULL([ReferenceAmount],0) = 0) OR (ISNULL([ReferenceAmount],0) < ISNULL(D.[OtherAmount],0)) THEN ISNULL([Amount],0)
			ELSE ISNULL([ReferenceAmount],0) - ISNULL(D.[OtherAmount],0)
	END,0) [Amount],
    ISNULL(Note,'') Note, 
    --CASE (@IdAgentCollectType) 
    --    WHEN 1 THEN 0 
    --    else ISNULL(OtherAmount,0) 
    --end OtherDeposit 
    --case when @IdAgentCollectType=1 then 0 else ISNULL(OtherAmount,0) end OtherDeposit,
	ISNULL(d.OtherAmount,0)  OtherDeposit,
    CASE WHEN AmountByCalendar > 0 THEN 1 ELSE 0 END IsPayDay
FROM #ACHAgent AS A
JOIN dbo.Agent AS b WITH (NOLOCK) ON a.IdAgent = b.IdAgent
JOIN dbo.AgentClass AS c WITH (NOLOCK) ON b.idagentclass = c.idagentclass    
LEFT JOIN(
    SELECT Idagent,SUM(Amount) OtherAmount 
	FROM dbo.AgentDeposit WITH (NOLOCK)
    WHERE  
        dateoflastchange >= @ACHDate AND dateoflastchange < @ACHDate+1 
        AND 
        (
            (@IdAgentCollectType = 2 and isnull(IdAgentCollectType,0) NOT IN (2)) or
            (@IdAgentCollectType = 1 and isnull(IdAgentCollectType,0) NOT IN (1))
        )
        AND Amount > 0
    GROUP BY IdAgent
) d ON a.IdAgent = d.Idagent
WHERE IsManual = 1
ORDER BY A.AgentCode;