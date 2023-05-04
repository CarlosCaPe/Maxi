
CREATE PROCEDURE [Corp].[st_ReportAgingV2]
(
    @StartDate datetime,
    @DaysFirstLapse int,
    @PageIndex int = 1,
	@PageSize int = 10,
	@filter nvarchar(MAX) = NULL,
	@columOrdering nvarchar(MAX) = NULL,
	@order nvarchar(MAX) = NULL,
	@PageCount int OUTPUT
)
AS

/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="24/06/2022" Author="saguilar" Name="#1">Se agregan agencias en estatus Disabled y con Balance diferente de 0.00.</log>
<log Date="07/07/2022" Author="jdarellano" Name="#2">Performance: se agregan with(nolock) y se mejora método de búsqueda.</log>
<log Date="2023/01/16" Author="jdarellano">Se agregan cambios para considerar Other Credits (BM-446).</log>
</ChangeLog>
*********************************************************************/

SET ARITHABORT ON;
SET NOCOUNT ON;

DECLARE @FromDate10 datetime;
DECLARE @FromDateLapse datetime;
DECLARE @FromDate30 datetime;
DECLARE @FromDate60 datetime;
DECLARE @FromDate90 datetime;
DECLARE @Days int;
DECLARE @StartDate2 datetime;

SET @StartDate2 = dbo.RemoveTimeFromDatetime(@StartDate);

IF @StartDate2 = dbo.RemoveTimeFromDatetime(GETDATE())
BEGIN
	SET @StartDate2 = @StartDate2 - 1;
END
--print @startDate2

   
SELECT @StartDate = dbo.RemoveTimeFromDatetime(@StartDate + 1),
       @filter = UPPER(ISNULL(@filter,'')),
       @columOrdering = UPPER(ISNULL(@columOrdering,'AGENTCODE')),
       @order = UPPER(ISNULL(@order,'ASC')),
       @PageIndex = @PageIndex - 1;

SET @FromDateLapse = @StartDate - @DaysFirstLapse;
SET @FromDate10 = @StartDate - 10;
SELECT @Days = DAY(@FromDate10);

IF @Days > 1
	SET @Days = (@Days - 1) * -1;
ELSE
	SET @Days = 0;


SET @FromDate30 = DATEADD(dd,@Days,@FromDate10);
SET @FromDate60 = DATEADD(MM,-1,@FromDate30);
SET @FromDate90 = DATEADD(MM,-1,@FromDate60);


CREATE TABLE #temp
(
	id int identity(1,1),
	IdAgent int,
	IdAgentstatus int,
	AgentStatusName nvarchar(max),
	AgentName nvarchar(max),
	AgentCode nvarchar(max),
	CurrentBalance money,
	Last10 money,
	Last30 money,
	Last60 money,
	Last90 money,
	Older  money,
	IdAgentCurrentStatus int,
	AgentCurrentStatusName nvarchar(max)
);

/*     antes  
Insert into #temp (IdAgent,AgentName,AgentCode,IdAgentstatus,AgentStatusName)      
Select IdAgent,AgentName,AgentCode,a.IdAgentstatus,agentstatus from Agent a
join agentstatus s on a.IdAgentstatus=s.IdAgentstatus
where 
    a.IdAgentStatus!=2      
--AGREGADO PARA FILTRAR DESDE LA ENTRADA
AND (agentcode like '%'+@filter+'%' or AgentName like '%'+@filter+'%')
*/

--despues
INSERT INTO #temp (IdAgent,AgentName,AgentCode,IdAgentstatus,AgentStatusName,IdAgentCurrentStatus,AgentCurrentStatusName)
SELECT a.IdAgent,AgentName,AgentCode,f.IdAgentstatus,s.agentstatus,s2.IdAgentStatus,s2.AgentStatus
FROM dbo.Agent AS a WITH (NOLOCK)
INNER JOIN dbo.AgentFinalStatusHistory AS f WITH (NOLOCK) ON DateOfAgentStatus = @StartDate2 AND a.IdAgent = f.idagent
INNER JOIN dbo.AgentStatus AS s WITH (NOLOCK) ON f.IdAgentstatus = s.IdAgentstatus
INNER JOIN dbo.AgentStatus AS s2 WITH (NOLOCK) ON a.IdAgentStatus = s2.IdAgentStatus
WHERE f.IdAgentStatus != 2
--AGREGADO PARA FILTRAR DESDE LA ENTRADA
AND (A.AgentCode LIKE '%'+@filter+'%' OR A.AgentName LIKE '%'+@filter+'%');


-- Insertar Agencias Disabled con balance Distinto de Cero en tabla #temp--#1
INSERT INTO #temp (IdAgent,AgentName,AgentCode,IdAgentstatus,AgentStatusName,IdAgentCurrentStatus,AgentCurrentStatusName)
SELECT a.IdAgent,AgentName,AgentCode,f.IdAgentstatus,s.agentstatus,s2.IdAgentStatus,s2.AgentStatus
FROM dbo.Agent AS a with(nolock)
INNER JOIN dbo.AgentFinalStatusHistory AS f WITH (NOLOCK) ON DateOfAgentStatus = @StartDate2 AND a.IdAgent=f.idagent
INNER JOIN dbo.AgentStatus AS s WITH (NOLOCK) ON f.IdAgentstatus = s.IdAgentstatus
INNER JOIN dbo.AgentStatus AS s2 WITH (NOLOCK) ON a.IdAgentStatus = s2.IdAgentStatus
WHERE f.IdAgentStatus = 2
AND a.IdAgent IN (SELECT DISTINCT IdAgent FROM AgentBalance WITH (NOLOCK) WHERE DateOfMovement > DATEADD(MM,-1,@StartDate) AND DateOfMovement <= @StartDate);


DECLARE @TempId int,@TempIdAgent int,@TempBalance money;--,@SumDebit1 money,@SumCredit1 money;
--DECLARE @SumDebit2 money,@SumCredit2 money;
--DECLARE @SumDebit3 money,@SumCredit3 money;
--DECLARE @SumDebit4 money,@SumCredit4 money;
DECLARE @FCP money = 0;

DECLARE
	@Total1 money,
	@Total2 money,
	@Total3 money,
	@Total4 money;

SET @TempId = 1;

WHILE EXISTS(SELECT 1 FROM #temp WHERE Id = @TempId)
BEGIN
	SELECT @TempIdAgent = IdAgent FROM #temp WHERE id = @TempId;

	--Set @TempBalance=0       

	SET @TempBalance = ISNULL((SELECT TOP 1 Balance FROM dbo.AgentBalance WITH (NOLOCK) WHERE IdAgent = @TempIdAgent AND DateOfMovement < @StartDate ORDER BY DateOfMovement DESC),0);

	SELECT
		IdAgentBalance,
		CASE WHEN DebitOrCredit = 'Debit' THEN 'CHG' ELSE 'CRED' END AS TypeOfMovement,
		DateOfMovement,
		CASE
			WHEN ISNULL(Reference,'') = '' THEN CONVERT(varchar,IdAgentBalance)
			ELSE Reference
		END AS Reference,
		[Description],
		Country,
		0 AS Fee,
		CASE WHEN DebitOrCredit = 'Credit' THEN Amount ELSE 0 END AS Commission,
		CASE WHEN DebitOrCredit = 'Debit' THEN Amount ELSE 0 END AS FxFee,
		0 AS Amount,
		CASE WHEN DebitOrCredit = 'Debit' THEN Amount ELSE Amount * (-1) END AS AmountForBalance
		, 0.0 AS nsffee
	INTO #TempCRED
	FROM dbo.AgentBalance AS B WITH (NOLOCK)
	WHERE IdAgent = @TempIdAgent
	AND DateOfMovement < @StartDate AND DateOfMovement > @FromDate90
	AND Commission = 0
	AND B.TypeOfMovement = 'CGO';

	SELECT IdAgent,Amount,DebitOrCredit,DateOfMovement,Balance,TypeOfMovement
	INTO #temp2
	FROM dbo.AgentBalance AS AB WITH (NOLOCK)
	WHERE IdAgent = @TempIdAgent
	AND DateOfMovement < @StartDate AND DateOfMovement > @FromDate90
	AND TypeOfMovement NOT IN ('DEP','CH','CHRTN')--#2
	AND NOT EXISTS (SELECT 1 FROM #TempCRED AS C WHERE AB.IdAgentBalance = C.IdAgentBalance);
	--ORDER BY DateOfMovement DESC;      
       
	------ Primer Rango  ---------------      
	--SELECT @SumDebit1 = ISNULL(SUM(amount),0) 
	--FROM #temp2 
	--WHERE DebitOrCredit = 'Debit' 
	--AND DateOfMovement < @StartDate AND DateOfMovement > @FromDateLapse;
	----AND TypeOfMovement NOT IN ('DEP','CH','CHRTN');
       
	--SELECT @SumCredit1 = ISNULL(SUM(amount),0) 
	--FROM #temp2 
	--WHERE DebitOrCredit = 'Credit' 
	--AND DateOfMovement < @StartDate AND DateOfMovement > @FromDateLapse;
	----AND TypeOfMovement NOT IN ('DEP','CH','CHRTN');

	SELECT @Total1 = ISNULL(SUM(CASE WHEN DebitOrCredit = 'DEBIT' THEN Amount ELSE Amount * -1 END),0)--#2
	FROM #temp2 
	WHERE DateOfMovement < @StartDate AND DateOfMovement > @FromDateLapse;
       
	------- Segund0 Rango ------------------      
       
	--SELECT @SumDebit2 = ISNULL(SUM(amount),0) 
	--FROM #temp2 
	--WHERE DebitOrCredit = 'Debit'
	--AND DateOfMovement < @StartDate AND DateOfMovement > @FromDate30;
	----AND TypeOfMovement NOT IN ('DEP','CH','CHRTN');
       
	--SELECT @SumCredit2 = ISNULL(SUM(amount),0) 
	--FROM #temp2
	--WHERE DebitOrCredit = 'Credit'
	--AND	DateOfMovement < @StartDate AND DateOfMovement > @FromDate30;
	----AND TypeOfMovement NOT IN ('DEP','CH','CHRTN');

	SELECT @Total2 = ISNULL(SUM(CASE WHEN DebitOrCredit = 'DEBIT' THEN Amount ELSE Amount * -1 END),0)--#2
	FROM #temp2 
	WHERE DateOfMovement < @StartDate AND DateOfMovement > @FromDate30;
       
	------- Tercero Rango ------------------      
       
	--SELECT @SumDebit3 = ISNULL(SUM(amount),0)
	--FROM #temp2
	--WHERE DebitOrCredit = 'Debit'
	--AND DateOfMovement < @StartDate AND DateOfMovement > @FromDate60;
	----AND TypeOfMovement NOT IN ('DEP','CH','CHRTN');
       
	--SELECT @SumCredit3 = ISNULL(SUM(amount),0)
	--FROM #temp2
	--WHERE DebitOrCredit = 'Credit'
	--AND DateOfMovement < @StartDate AND DateOfMovement > @FromDate60;
	----AND TypeOfMovement NOT IN ('DEP','CH','CHRTN');

	SELECT @Total3 = ISNULL(SUM(CASE WHEN DebitOrCredit = 'DEBIT' THEN Amount ELSE Amount * -1 END),0)--#2
	FROM #temp2
	WHERE DateOfMovement < @StartDate AND DateOfMovement > @FromDate60;

	------- Cuarto Rango ------------------      
       
	--SELECT @SumDebit4 = ISNULL(SUM(amount),0) 
	--FROM #temp2 
	--WHERE DebitOrCredit = 'Debit' 
	--AND DateOfMovement < @StartDate AND DateOfMovement > @FromDate90;
	----AND TypeOfMovement NOT IN ('DEP','CH','CHRTN');
       
	--SELECT @SumCredit4 = ISNULL(SUM(amount),0) 
	--FROM #temp2
	--WHERE DebitOrCredit = 'Credit' 
	--AND DateOfMovement < @StartDate AND DateOfMovement > @FromDate90;
	----AND TypeOfMovement NOT IN ('DEP','CH','CHRTN');

	SELECT @Total4 = ISNULL(SUM(CASE WHEN DebitOrCredit = 'DEBIT' THEN Amount ELSE Amount * -1 END),0)--#2
	FROM #temp2
	WHERE DateOfMovement < @StartDate AND DateOfMovement > @FromDate90;

	------- Planes de financiamiento ------------------ 

	SET @FCP = 0;

	SELECT TOP 1 @FCP = d.ActualAmountToPay
	FROM dbo.AgentCollectionDetail AS d WITH (NOLOCK)
	INNER JOIN dbo.AgentCollection AS AC WITH (NOLOCK) ON d.idagentcollection = ac.IdAgentCollection AND ac.idagent = @TempIdAgent
	WHERE D.DateofLastChange < @StartDate
	ORDER BY IdAgentCollectionDetail DESC;

	SET @FCP = ISNULL(@FCP,0);

	--UPDATE #temp 
	--SET CurrentBalance = @TempBalance + @FCP,      
	--	Last10 = (@SumDebit1 - @SumCredit1) + @FCP,      
	--	Last30 = (@SumDebit2 - @SumCredit2) + @FCP,      
	--	Last60 = (@SumDebit3 - @SumCredit3) + @FCP,      
	--	Last90 = (@SumDebit4 - @SumCredit4) + @FCP      
	--WHERE id = @TempId;

	UPDATE #temp--#2
	SET CurrentBalance = @TempBalance + @FCP,
		Last10 = @Total1 + @FCP,
		Last30 = @Total2 + @FCP,
		Last60 = @Total3 + @FCP,
		Last90 = @Total4 + @FCP
	WHERE id = @TempId;

	DROP TABLE #temp2;
	DROP TABLE #TempCRED;

	SET @TempId = @TempId + 1;
END;

UPDATE #temp SET AgentCode = REPLACE(agentcode,'-B','') WHERE AgentCode LIKE '%-B';

DECLARE @Older Money;
SET @Older = 0;

SELECT AgentName,AgentCode,idagentstatus,agentstatusname,IdAgentCurrentStatus,AgentCurrentStatusName,SUM(CurrentBalance) AS CurrentBalance,SUM(Last10) AS Last10,SUM(last30) AS Last30,SUM(Last60) AS Last60,SUM(Last90) AS Last90,@Older AS Older   
INTO #result
FROM #temp
GROUP BY AgentName,AgentCode,idagentstatus,agentstatusname,IdAgentCurrentStatus,AgentCurrentStatusName
ORDER BY AgentCode;

UPDATE #result SET Last10 = CASE WHEN Last10 < CurrentBalance THEN Last10 ELSE CurrentBalance END;
UPDATE #result SET Last30 = CASE WHEN Last30 < CurrentBalance THEN Last30 ELSE CurrentBalance END;
UPDATE #result SET Last60 = CASE WHEN Last60 < CurrentBalance THEN Last60 ELSE CurrentBalance END;
UPDATE #result SET Last90 = CASE WHEN Last90 < CurrentBalance THEN Last90 ELSE CurrentBalance END;

UPDATE #result SET Last30 = Last30 - Last10;
UPDATE #result SET Last60 = Last60 - Last30 - Last10;
UPDATE #result SET Last90 = Last90 - Last60 - Last30 - Last10;
UPDATE #result SET Older = CurrentBalance - Last90 - Last60 - Last30 - Last10;


CREATE TABLE #output
(
    Id int IDENTITY (1,1),
    AgentName nvarchar(max),
    AgentCode nvarchar(max),
    IdAgentStatus int,
    AgentStatusName nvarchar(max),
    Last10 money,
    Last30 money,
    Last60 money,
    Last90 money,
    Older money,
    CurrentBalance money,
	IdAgentCurrentStatus int,
	AgentCurrentStatusName nvarchar(max)
);

--;WITH cte AS
--(--#2
SELECT
	ROW_NUMBER() OVER(
	ORDER BY
		CASE WHEN @columOrdering = 'AGENTNAME' THEN AGENTNAME END,
		CASE WHEN @columOrdering = 'AGENTCODE' THEN AGENTCODE END,
		CASE WHEN @columOrdering = 'AGENTSTATUSNAME' THEN AGENTSTATUSNAME END,
		CASE WHEN @columOrdering = 'LAST10' THEN LAST10 END,
		CASE WHEN @columOrdering = 'LAST30' THEN LAST30 END,
		CASE WHEN @columOrdering = 'LAST60' THEN LAST60 END,
		CASE WHEN @columOrdering = 'LAST90' THEN LAST90 END,
		CASE WHEN @columOrdering = 'OLDER' THEN OLDER END,
		CASE WHEN @columOrdering = 'CURRENTBALANCE' THEN CURRENTBALANCE END,
		CASE WHEN @columOrdering = 'IDAGENTCURRENTSTATUS' THEN IDAGENTCURRENTSTATUS END,
		CASE WHEN @columOrdering = 'AGENTCURRENTSTATUSNAME' THEN AGENTCURRENTSTATUSNAME END	
	)RowNumber,
	AgentName,AgentCode,IdAgentStatus,AgentStatusName,Last10,Last30,Last60,Last90,Older,CurrentBalance,IdAgentCurrentStatus,AgentCurrentStatusName
INTO #cte--#2
FROM #result;
--)--#2

INSERT INTO #output
SELECT AgentName,AgentCode,IdAgentStatus,AgentStatusName,ROUND(Last10,2),ROUND(Last30,2),ROUND(Last60,2),ROUND(Last90,2),ROUND(Older,2),ROUND(CurrentBalance,2),IdAgentCurrentStatus,AgentCurrentStatusName
FROM #cte--#2
ORDER BY
CASE WHEN @order = 'DESC' THEN - RowNumber ELSE RowNumber END;

-- removing agents with no movements, by ARR 28/08/2014
/*
delete from #output where (IdAgentStatus=2 or IdAgentCurrentStatus=2)
and Last10=0
and Last30=0
and Last60=0
and Last90=0
and Older=0
and CurrentBalance=0
*/


--SELECT @PageCount = COUNT(*) FROM #output
SELECT @PageCount = COUNT(1) FROM #output;--#2


--SALIDA
SELECT AgentName,AgentCode,IdAgentStatus,AgentStatusName,Last10,Last30,Last60,Last90,Older,CurrentBalance,IdAgentCurrentStatus,AgentCurrentStatusName
FROM #output
WHERE Id BETWEEN @PageIndex + 1 AND @PageIndex + @PageSize;

--Select '' AgentName,'' AgentCode,1 IdAgentStatus,'' AgentStatusName ,1.0 Last10, 1.0 Last30,1.0 Last60,1.0 Last90,1.0 Older,1.0 CurrentBalance

--select @StartDate, 
--@FromDate10    ,
-- @FromDateLapse                                          ,
-- @FromDate30                                             ,
-- @FromDate60                                             ,
-- @FromDate90    


/*
select
	sum(Last10) as Last10,
    sum(Last30) as Last30,
    sum(Last60) as Last60,
    sum(Last90) as Last90,
    sum(Older) as Older,
    sum(CurrentBalance) as CurrentBalance 
	from #result
	*/

SELECT
	ISNULL(SUM(ROUND(Last10, 2)),0) AS Last10,
    ISNULL(SUM(ROUND(Last30,2)),0) AS Last30,
    ISNULL(SUM(ROUND(Last60,2)),0) AS Last60,
    ISNULL(SUM(ROUND(Last90,2)),0) AS Last90,
    ISNULL(SUM(ROUND(Older,2)),0) AS Older,
    ISNULL(SUM(ROUND(CurrentBalance,2)),0) AS CurrentBalance
FROM #result;

	/*
	select 
	Last10 ,
    Last30 ,
    Last60 ,
    Last90 ,
    Older ,
    CurrentBalance 
	from #result

	*/