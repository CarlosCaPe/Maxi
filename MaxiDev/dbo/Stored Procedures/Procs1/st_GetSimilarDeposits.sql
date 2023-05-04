CREATE PROCEDURE [dbo].[st_GetSimilarDeposits]
(
    @IdAgent INT,
    @Amount money, 
    @BankName NVARCHAR(max), 
    @DepositDate DATETIME,
    @AgentCurrentBalance MONEY OUT 
)
AS 
--Declaracion de variables
DECLARE @SearchDays INT
DECLARE @BeginDate DATETIME
DECLARE @IdBank INT

CREATE TABLE #DepositData
(
    IdDepositData INT IDENTITY(1,1),    
    BankName NVARCHAR(max),
    Amount MONEY,
    DepositDate DATETIME,
    CollectType NVARCHAR(max)    
)

set @DepositDate = getdate()

--Inicializacion de varioables
SELECT  @SearchDays = CONVERT(INT,dbo.GetGlobalAttributeByName('DaysforSearchDeposit')),
        @DepositDate = dbo.RemoveTimeFromDatetime(@DepositDate),
        @BeginDate=dateadd(day,@SearchDays*-1,@DepositDate),
        @IdBank = CONVERT(INT,dbo.GetGlobalAttributeByName('DefaultBankEncodeDeposit')),
        @DepositDate = dbo.RemoveTimeFromDatetime(@DepositDate)

--SELECT @DepositDate,@BeginDate,@SearchDays

IF (ISNULL(@BankName,'')='')
begin
    SELECT @BankName=BankName FROM dbo.AgentBankDeposit  with(nolock) WHERE IdAgentBankDeposit=@IdBank
END

SELECT @AgentCurrentBalance=Balance FROM dbo.AgentCurrentBalance  with(nolock) WHERE IdAgent=@IdAgent

SET @AgentCurrentBalance=ISNULL(@AgentCurrentBalance,0)

SELECT DepositDate,d.DateOfLastChange ApplyDate,Notes Note,u.UserLogin [User],c.NAME AgentCollectType
FROM 
    dbo.AgentDeposit d
JOIN 
    AgentCollectType c ON d.IdAgentCollectType =c.IdAgentCollectType
JOIN
    dbo.Users u ON d.EnterByIdUser=u.IdUser
WHERE 
    IdAgent=@IdAgent AND
    Amount=@Amount AND
    BankName= @BankName AND 
    dbo.RemoveTimeFromDatetime(d.[DateOfLastChange])>=@BeginDate AND dbo.RemoveTimeFromDatetime(d.[DateOfLastChange])<=@DepositDate


