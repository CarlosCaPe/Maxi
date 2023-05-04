CREATE PROCEDURE [Corp].[st_GetEncondeDepositDetail]
(
    @DepositData XML
)
as
--Declaracion de variables
DECLARE @DocHandle INT 
DECLARE @IdDeposits INT
DECLARE @TopIdDeposits INT
DECLARE @DepositDate datetime
DECLARE @Amount MONEY
DECLARE @IdAgent INT
DECLARE @IdAgentCollectType INT
DECLARE @SearchDays INT
DECLARE @BeginDate DATETIME
declare @IdBank INT
declare @BankName NVARCHAR(max)
DECLARE @TotalDeposits int

SELECT @SearchDays = CONVERT(INT,dbo.GetGlobalAttributeByName('DaysforSearchDeposit'))
Set @IdAgentCollectType=3    --Fichas Codificadas
SELECT @IdBank = CONVERT(INT,dbo.GetGlobalAttributeByName('DefaultBankEncodeDeposit'))
SELECT @BankName=BankName FROM dbo.AgentBankDeposit WITH(NOLOCK) WHERE IdAgentBankDeposit=@IdBank

--Tabla Temporal
Create Table #Deposit
(
    IdDeposits INT IDENTITY(1,1),
    Concept NVARCHAR(max),      
    DepositDate datetime,
    Amount MONEY,
    IdAgent INT,
    AgentCode NVARCHAR(max),
    AgentName NVARCHAR(max),
    SimilarDeposit INT,
    TotalDeposits INT,
    ReferenceNumber nvarchar(max)
) 

EXEC sp_xml_preparedocument @DocHandle OUTPUT,@DepositData 

--Obtener informacion de la agencia
INSERT INTO #Deposit  
 Select Concept,dbo.RemoveTimeFromDatetime(DepositDate),Amount,A.IdAgent,ISNULL(A.AgentCode,''),ISNULL(A.AgentName,''),1,0,ReferenceNumber From OPENXML (@DocHandle, '/BankCodifiedDeposits/BankCodifiedDeposit',2) 
    WITH (      
        Concept NVARCHAR(max),      
        DepositDate datetime,
        Amount money,
        ReferenceNumber nvarchar(max)
    )  x
 LEFT join dbo.Agent a ON dbo.fn_GetNumeric(a.AgentCode)=LTRIM(RTRIM(x.Concept))

--Verificar si ya existe un deposito similar

SELECT @IdDeposits = 1,@TopIdDeposits=MAX(IdDeposits) FROM #Deposit

WHILE @IdDeposits <= (@TopIdDeposits)
BEGIN    
    SELECT @IdAgent=IdAgent,@Amount=Amount,@DepositDate=dbo.RemoveTimeFromDatetime(getdate()) FROM #Deposit WHERE IdDeposits=@IdDeposits
    SET @BeginDate=dateadd(day,@SearchDays*-1,@DepositDate)
    
    --SET @TotalDeposits = ISNULL((SELECT COUNT(1) FROM dbo.AgentDeposit WHERE IdAgent=@IdAgent AND Amount=@Amount AND (dbo.RemoveTimeFromDatetime(DepositDate)=@DepositDate) AND @BankName=BankName),0)
    SET @TotalDeposits = ISNULL((SELECT COUNT(1) FROM dbo.AgentDeposit WITH(NOLOCK) WHERE IdAgent=@IdAgent AND Amount=@Amount AND (dbo.RemoveTimeFromDatetime([DateOfLastChange])=@DepositDate) AND @BankName=BankName),0)

    IF @TotalDeposits>0
    BEGIN    
        UPDATE #Deposit SET SimilarDeposit=2, TotalDeposits = @TotalDeposits WHERE IdDeposits=@IdDeposits
    END
    ELSE
    BEGIN
        --SET @TotalDeposits  = ISNULL((SELECT COUNT(1) FROM dbo.AgentDeposit WHERE IdAgent=@IdAgent AND Amount=@Amount AND (dbo.RemoveTimeFromDatetime(DepositDate)>=@BeginDate and dbo.RemoveTimeFromDatetime(DepositDate)<@DepositDate) AND BankName=@BankName),0)
        SET @TotalDeposits  = ISNULL((SELECT COUNT(1) FROM  dbo.AgentDeposit WITH(NOLOCK) WHERE IdAgent=@IdAgent AND Amount=@Amount AND (dbo.RemoveTimeFromDatetime([DateOfLastChange])>=@BeginDate and dbo.RemoveTimeFromDatetime([DateOfLastChange])<@DepositDate) AND BankName=@BankName),0)
        IF  @TotalDeposits > 0
        BEGIN
             UPDATE #Deposit SET SimilarDeposit=3, TotalDeposits = @TotalDeposits WHERE IdDeposits=@IdDeposits     
        end      
    END  
    SET @IdDeposits = @IdDeposits + 1
END
  
select ReferenceNumber into #reference from agentdeposit WITH(NOLOCK) where ReferenceNumber is not null


  SELECT    
    Concept, 
    c.name AgentClass,  
    d.IdAgent,
    d.AgentCode,
    d.AgentName,
    @BankName BankName,
    DepositDate,
    Amount,
    SimilarDeposit,
    TotalDeposits,
    ReferenceNumber
  FROM #Deposit d
  join agent a WITH(NOLOCK) on d.idagent=a.idagent
  join agentclass c WITH(NOLOCK) on a.idagentclass=c.idagentclass
  where a.AgentCode not like '%-B' AND a.AgentCode not like '%-P' and isnumeric(substring(a.agentcode,1,1))=1
  and ReferenceNumber not in (select ReferenceNumber collate SQL_Latin1_General_CP1_CI_AS from #reference)
  ORDER BY IdDeposits


select ReferenceNumber from #Deposit where ReferenceNumber in (select ReferenceNumber collate SQL_Latin1_General_CP1_CI_AS from #reference)
