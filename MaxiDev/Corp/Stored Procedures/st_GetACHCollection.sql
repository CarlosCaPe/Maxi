CREATE PROCEDURE [Corp].[st_GetACHCollection]
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
<log Date="2023/02/27" Author="jdarellano" Name="#1">Se agrega WITH (NOLOCK).</log>
</ChangeLog>
*********************************************************************/

--Declaracion de Variables
DECLARE @IdACHSummary INT
DECLARE @NumAgent int
DECLARE @ACHAgent TABLE
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
)
--Inicializacion de variables
--SET @ACHDate = '2016-11-04 11:46:03.357'
SET @ACHDate = dbo.RemoveTimeFromDatetime(@ACHDate);


--Verificar si existe un Summary para ACH
IF  NOT exists (SELECT 1 FROM ACHSummary WITH(NOLOCK) WHERE ACHDate=@ACHDate AND IdAgentCollectType=@IdAgentCollectType)
BEGIN
     --Obtener ACH por agencia
    INSERT INTO @ACHAgent    
    --EXEC [Corp].[st_GetACHCollection] @ACHDate,@IdAgentCollectType  
    select a.idagent,a.agentcode,a.agentname,sum(isnull(AmountByCalendar,0)+isnull(AmountByLastDay,0)+isnull(AmountByCollectPlan,0)),sum(AmountByCalendar), sum(AmountByLastDay), sum(AmountByCollectPlan), sum(isnull(AmountByCalendar,0)+isnull(AmountByLastDay,0)+isnull(AmountByCollectPlan,0)) Amount,'',0 
	from dbo.MaxiCollection m WITH (NOLOCK)
	join dbo.Agent a WITH (NOLOCK) on m.idagent=a.idagent
	where m.IdAgentCollectType=@IdAgentCollectType and DateOfCollection=@ACHDate and a.IdAgentStatus=1
	group by a.idagent,a.agentcode,a.agentname;

    SELECT @NumAgent = COUNT(1) FROM @ACHAgent;

    IF (@NumAgent>0)
    begin
        --Insercion del Summary
        INSERT INTO ACHSummary
            (ACHDate,CreationDate,EnterByIdUser,IdAgentCollectType)
        VALUES
            (@ACHDate,GETDATE(),@IdUser,@IdAgentCollectType);
    
        SET @IdACHSummary = SCOPE_IDENTITY();

        --Insercion de movimientos de ACH
        INSERT INTO [ACHMovement]        
			SELECT @IdACHSummary,IdAgent,ReferenceAmount,Amount,note,AmountByCalendar,AmountByLastDay,AmountByCollectPlan,0 FROM @ACHAgent;
    end
END
ELSE
BEGIN
    INSERT INTO @ACHAgent 
		SELECT 
			m.idagent,
			a.AgentCode,
			a.AgentName,
			m.ReferenceAmount,
			AmountByCalendar,AmountByLastDay,AmountByCollectPlan,
			m.amount,
			m.note,
			m.IsManual
		FROM 
			ACHSummary s WITH(NOLOCK)
		JOIN 
			ACHMovement  m WITH(NOLOCK) ON s.IdACHSummary=m.IdACHSummary
		JOIN 
			dbo.Agent a WITH(NOLOCK) ON a.IdAgent=m.idagent
    WHERE s.ACHDate=@ACHDate AND s.IdAgentCollectType=@IdAgentCollectType;
END

SELECT @DateOfLastChange=DateofLastChange,@ApplyDate=ApplyDate FROM dbo.ACHSummary WITH (NOLOCK) WHERE ACHDate=@ACHDate AND IdAgentCollectType=@IdAgentCollectType;

SELECT 
    c.Name AgentClass,
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
FROM 
    @ACHAgent A
JOIN
    agent b WITH(NOLOCK) ON a.IdAgent=b.IdAgent
join
    agentclass c WITH(NOLOCK) on b.idagentclass=c.idagentclass    
LEFT JOIN(
    SELECT Idagent,SUM(Amount) OtherAmount FROM dbo.AgentDeposit WITH(NOLOCK)
    WHERE  
        dateoflastchange>=@ACHDate AND dateoflastchange<@ACHDate+1 
        and 
        (
            (@IdAgentCollectType=2 and isnull(IdAgentCollectType,0) not in (2)) or
            (@IdAgentCollectType=1 and isnull(IdAgentCollectType,0) not in (1))
        )
        and Amount>0
    GROUP BY 
        IdAgent
	) d ON a.IdAgent=d.Idagent
--where ReferenceAmount>case when @IdAgentCollectType=1 then 0 else ISNULL(d.OtherAmount,0) end and ismanual=0
where (ReferenceAmount>ISNULL(d.OtherAmount,0)) and ismanual=0 /*2016-Ago-05*/
union all
SELECT 
    c.Name AgentClass,
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
	ISNULL(d.OtherAmount,0)  OtherDeposit,
    case when AmountByCalendar>0 then 1 else 0 end IsPayDay
FROM 
    @ACHAgent A
JOIN
    agent b WITH(NOLOCK) ON a.IdAgent=b.IdAgent
join
    agentclass c WITH(NOLOCK) on b.idagentclass=c.idagentclass    
LEFT JOIN(
    SELECT Idagent,SUM(Amount) OtherAmount FROM dbo.AgentDeposit WITH(NOLOCK)
    WHERE  
        dateoflastchange>=@ACHDate AND dateoflastchange<@ACHDate+1 
        and 
        (
            (@IdAgentCollectType=2 and isnull(IdAgentCollectType,0) not in (2)) or
            (@IdAgentCollectType=1 and isnull(IdAgentCollectType,0) not in (1))
        )
        and Amount>0
    GROUP BY IdAgent
) d ON a.IdAgent=d.Idagent
where IsManual=1
ORDER BY A.AgentCode;

/*
if @IdAgentCollectType=1
	select * from ach110920162
else
	select * from ach110920162
	*/