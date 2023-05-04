CREATE PROCEDURE [dbo].[st_GetOtherBanksDepositDetail]
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
DECLARE @IdAgentBankDeposit INT
DECLARE @SearchDays INT
DECLARE @BeginDate DATETIME
DECLARE @TotalDeposits int

SELECT @SearchDays = CONVERT(INT,dbo.GetGlobalAttributeByName('DaysforSearchDeposit'))

Set @IdAgentCollectType=4    --Fichas No Codificadas

--Tabla Temporal
Create Table #Deposit
(
    IdDeposits INT IDENTITY(1,1),
	IdAgent INT,   
    AgentCode NVARCHAR(MAX),
	IdAgentBankDeposit INT,
	[Date] DATETIME,
	Amount MONEY,
	Note NVARCHAR(MAX),
    SimilarDeposit Int,
    TotalDeposits INT
)  

EXEC sp_xml_preparedocument @DocHandle OUTPUT,@DepositData 

--Obtener informacion de la agencia
INSERT INTO #Deposit
SELECT A.IdAgent, x.AgentCode, x.IdAgentBankDeposit, dbo.RemoveTimeFromDatetime(x.[Date]),x.Amount,x.Note, 1,0 From OPENXML (@DocHandle, '/OtherBanksDeposits/OtherBanksDeposit',2)
    WITH (      
			AgentCode NVARCHAR(MAX),
			IdAgentBankDeposit INT,
			[Date] DATETIME,
			Amount MONEY,
			Note NVARCHAR(MAX)
    )x
LEFT join dbo.Agent a with(nolock) ON case when (dbo.fn_GetNumeric(a.AgentCode))='0000' then '' else dbo.fn_GetNumeric(a.AgentCode) end = LTRIM(RTRIM(x.AgentCode));

--Verificar si ya existe un deposito similar

SELECT @IdDeposits = 1,@TopIdDeposits=MAX(IdDeposits) FROM #Deposit

WHILE @IdDeposits <= (@TopIdDeposits)
BEGIN    
    SELECT @IdAgent=IdAgent,@Amount=Amount,@DepositDate=dbo.RemoveTimeFromDatetime(getdate()), @IdAgentBankDeposit=IdAgentBankDeposit FROM #Deposit WHERE IdDeposits=@IdDeposits
    SET @BeginDate=dateadd(day,@SearchDays*-1,@DepositDate)

    SET @TotalDeposits = ISNULL((SELECT COUNT(1) 
								FROM dbo.AgentDeposit AD with(nolock) JOIN AgentBankDeposit ABD with(nolock) ON AD.BankName =ABD.BankName  
								WHERE IdAgent=@IdAgent 
									AND Amount=@Amount 
									AND (dbo.RemoveTimeFromDatetime(ad.[DateOfLastChange])=@DepositDate) 
									AND ABD.IdAgentBankDeposit=@IdAgentBankDeposit),0)    

    IF @TotalDeposits>0
    BEGIN    
        UPDATE #Deposit SET SimilarDeposit=2, TotalDeposits = @TotalDeposits WHERE IdDeposits=@IdDeposits;
    END
    ELSE
    BEGIN
        SET @TotalDeposits = ISNULL((SELECT COUNT(1) 
									FROM dbo.AgentDeposit AD with(nolock) JOIN AgentBankDeposit ABD with(nolock) ON AD.BankName =ABD.BankName
									WHERE IdAgent=@IdAgent 
										AND Amount=@Amount 
										AND (dbo.RemoveTimeFromDatetime(ad.[DateOfLastChange])>=@BeginDate and dbo.RemoveTimeFromDatetime(ad.[DateOfLastChange])<@DepositDate) 
										AND ABD.IdAgentBankDeposit=@IdAgentBankDeposit),0)  
        IF @TotalDeposits>0  
        BEGIN
             UPDATE #Deposit SET SimilarDeposit=3, TotalDeposits = @TotalDeposits WHERE IdDeposits=@IdDeposits;     
        end      
    END  
    SET @IdDeposits = @IdDeposits + 1
END
  
  SELECT    
    c.name AgentClass,    
    d.IdAgent,
    a.AgentCode,
    a.AgentName,
    d.[Date] DepositDate,
    adb.BankName,
    Amount,
    Note,
    SimilarDeposit,
    TotalDeposits
  FROM #Deposit d
  join agent a with(nolock) on d.idagent=a.idagent
  join agentclass c with(nolock) on a.idagentclass=c.idagentclass
  join AgentBankDeposit adb with(nolock) on d.IdAgentBankDeposit = adb.IdAgentBankDeposit 
  where a.AgentCode not like '%-B' AND a.AgentCode not like '%-P' and isnumeric(substring(a.agentcode,1,1))=1
  ORDER BY IdDeposits;