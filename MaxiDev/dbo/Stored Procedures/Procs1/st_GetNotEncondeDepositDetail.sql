CREATE PROCEDURE [dbo].[st_GetNotEncondeDepositDetail]
(
    @DepositData XML
)
AS
--Declaracion de variables
DECLARE @DocHandle INT 
DECLARE @IdDeposits INT
DECLARE @TopIdDeposits INT
DECLARE @DepositDate datetime
DECLARE @Amount MONEY
DECLARE @IdAgent INT
DECLARE @IdAgentCollectType INT
Declare @BankName NVARCHAR(max)
DECLARE @SearchDays INT
DECLARE @BeginDate DATETIME
DECLARE @TotalDeposits int

SELECT @SearchDays = CONVERT(INT,dbo.GetGlobalAttributeByName('DaysforSearchDeposit'))

Set @IdAgentCollectType=4    --Fichas No Codificadas

--Tabla Temporal
Create Table #Deposit
(
    IdDeposits INT IDENTITY(1,1),   
    DepositDate datetime,
    Amount MONEY,
    IdAgent INT,
    AgentCode NVARCHAR(max),
    AgentName NVARCHAR(max),
    BankName NVARCHAR(max),
    SimilarDeposit Int,
    Note NVARCHAR(max),
    TotalDeposits INT
) 

EXEC sp_xml_preparedocument @DocHandle OUTPUT,@DepositData 

--Obtener informacion de la agencia
INSERT INTO #Deposit  
 Select dbo.RemoveTimeFromDatetime(DepositDate),Amount,x.IdAgent,a.AgentCode,a.AgentName,BankName,1,Note,0 From OPENXML (@DocHandle, '/BankNoCodifiedDeposits/BankNoCodifiedDeposit',2) 
    WITH (      
        DepositDate datetime,
        Amount MONEY,
        IdAgent INT,        
        BankName NVARCHAR(max),
        Note NVARCHAR(max)
    )x
 LEFT join dbo.Agent a ON a.IdAgent=x.IdAgent

--Verificar si ya existe un deposito similar

SELECT @IdDeposits = 1,@TopIdDeposits=MAX(IdDeposits) FROM #Deposit

WHILE @IdDeposits <= (@TopIdDeposits)
BEGIN    
    SELECT @IdAgent=IdAgent,@Amount=Amount,@DepositDate=dbo.RemoveTimeFromDatetime(getdate()),@BankName=BankName FROM #Deposit WHERE IdDeposits=@IdDeposits
    SET @BeginDate=dateadd(day,@SearchDays*-1,@DepositDate)

    SET @TotalDeposits = ISNULL((SELECT COUNT(1) FROM dbo.AgentDeposit WHERE IdAgent=@IdAgent AND Amount=@Amount AND (dbo.RemoveTimeFromDatetime([DateOfLastChange])=@DepositDate) AND BankName=@BankName),0)    

    IF @TotalDeposits>0
    BEGIN    
        UPDATE #Deposit SET SimilarDeposit=2, TotalDeposits = @TotalDeposits WHERE IdDeposits=@IdDeposits
    END
    ELSE
    BEGIN
        SET @TotalDeposits = ISNULL((SELECT COUNT(1) FROM dbo.AgentDeposit WHERE IdAgent=@IdAgent AND Amount=@Amount AND (dbo.RemoveTimeFromDatetime([DateOfLastChange])>=@BeginDate and dbo.RemoveTimeFromDatetime([DateOfLastChange])<@DepositDate) AND BankName=@BankName),0)  
        IF @TotalDeposits>0  
        BEGIN
             UPDATE #Deposit SET SimilarDeposit=3, TotalDeposits = @TotalDeposits WHERE IdDeposits=@IdDeposits     
        end      
    END  
    SET @IdDeposits = @IdDeposits + 1
END
  
  SELECT    
    c.name AgentClass,    
    d.IdAgent,
    d.AgentCode,
    d.AgentName,
    DepositDate,
    BankName,
    Amount,
    Note,
    SimilarDeposit,
    TotalDeposits
  FROM #Deposit d
  join agent a on d.idagent=a.idagent
  join agentclass c on a.idagentclass=c.idagentclass
  where a.AgentCode not like '%-B' AND a.AgentCode not like '%-P' and isnumeric(substring(a.agentcode,1,1))=1
  ORDER BY IdDeposits