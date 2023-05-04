CREATE PROCEDURE [dbo].[st_GetWfSubAccountDepositDetail]
(
    @DepositData XML
)
AS
BEGIN TRY
/********************************************************************
<Author>???</Author>
<app>Corporate</app>
<Description>Valida Archivos de Depositos Wells Fargo</Description>
<ChangeLog>
<log Date="16/03/2017" Author="fgonzalez">Se agrega validacion para Reference Number duplicadas</log>
<log Date="17/09/2020" Author="jgomez">M00247 - Manejo de Subcuentas de Nevada y Nebraska en depósitos</log>
<log Date="09/11/2020" Author="jgomez">M00247 - se agrega para mostrar la fecha correspondiente al documento</log>
</ChangeLog>
*********************************************************************/

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
DECLARE @AccountNumber NVARCHAR(max)
declare @BankReference NVARCHAR(max)
declare @SubAccount NVARCHAR(max),
@SimilarDeposit int,
@AgentCode NVARCHAR(max),
@AgentName NVARCHAR(max)

SELECT @SearchDays = CONVERT(INT,dbo.GetGlobalAttributeByName('DaysforSearchDeposit'))
Set @IdAgentCollectType=3    --Fichas Codificadas
---SELECT @IdBank = CONVERT(INT,dbo.GetGlobalAttributeByName('DefaultBankSubAccount'))
--SELECT @BankName=BankName FROM dbo.AgentBankDeposit with(nolock) WHERE IdAgentBankDeposit=@IdBank

--Tabla Temporal
Create Table #Deposit
(
    IdDeposits INT IDENTITY(1,1),
    SubAccount NVARCHAR(max),      
    DepositDate datetime,
    Amount MONEY,
    IdAgent INT,
    AgentCode NVARCHAR(max),
    AgentName NVARCHAR(max),
    SimilarDeposit INT,
    TotalDeposits INT,
    BankReference NVARCHAR(max),
	AccountNo nvarchar(max), -- CR M00247
	BankName nvarchar(max) -- CR M00247
) 

Create Table #Deposit2
(
    IdDeposits INT IDENTITY(1,1),
    SubAccount NVARCHAR(max),      
    DepositDate datetime,
    Amount MONEY,
    IdAgent INT,
    AgentCode NVARCHAR(max),
    AgentName NVARCHAR(max),
    SimilarDeposit INT,
    TotalDeposits INT,
    BankReference NVARCHAR(max),
    AccountNo nvarchar(max),
	BankName nvarchar(max)
)  -- CR M00247

EXEC sp_xml_preparedocument @DocHandle OUTPUT,@DepositData 

--Obtener informacion de la agencia
INSERT INTO #Deposit2  
 Select x.SubAccount,dbo.RemoveTimeFromDatetime(DepositDate),Amount,A.IdAgent,ISNULL(A.AgentCode,''),ISNULL(A.AgentName,''),1,0,x.BankReference, x.AccountNo, ISNULL(x.BankName,'') From OPENXML (@DocHandle, '/WFSubAccountDeposits/WFSubAccountDeposit',2) 
    WITH (      
        SubAccount NVARCHAR(max),      
        DepositDate datetime,
        Amount money,
        BankReference nvarchar(max),
		AccountNo nvarchar(max),
		BankName nvarchar(max)
    )  x
 LEFT join dbo.Agent a ON a.SubAccount=LTRIM(RTRIM(x.SubAccount)) and a.idagentstatus not in (2,7)

   while exists(select * from #Deposit2) -- CR M00247
 begin 

  SELECT top 1 @IdDeposits = IdDeposits, @AccountNumber = AccountNo, @BankReference = BankReference, @TotalDeposits = TotalDeposits, @SimilarDeposit = SimilarDeposit, @AgentName = AgentName,@AgentCode = AgentCode, @SubAccount = SubAccount, @IdAgent=IdAgent,@Amount=Amount,@DepositDate=dbo.RemoveTimeFromDatetime(DepositDate), @AccountNumber = AccountNo FROM #Deposit2
  
  select  @BankName = BankName from dbo.AgentBankDeposit with(nolock) where SubAccountRequired = 1 AND AccountNumber = @AccountNumber

 insert into #Deposit(SubAccount,DepositDate, Amount, IdAgent, AgentCode, AgentName, SimilarDeposit, TotalDeposits, BankReference, AccountNo,BankName) values 
 (@SubAccount, @DepositDate, @Amount,  @IdAgent, @AgentCode, @AgentName, @SimilarDeposit, @TotalDeposits, @BankReference, @AccountNumber, @BankName )
 
 set @BankName = ''
 DELETE FROM #Deposit2 where IdDeposits = @IdDeposits
 END
--Verificar si ya existe un deposito similar

SELECT @IdDeposits = 1,@TopIdDeposits=MAX(IdDeposits) FROM #Deposit

WHILE @IdDeposits <= (@TopIdDeposits)
BEGIN    
    SELECT @BankName=BankName, @IdAgent=IdAgent,@Amount=Amount,@DepositDate=dbo.RemoveTimeFromDatetime(getdate()) FROM #Deposit WHERE IdDeposits=@IdDeposits
    SET @BeginDate=dateadd(day,@SearchDays*-1,@DepositDate)
    
    --SET @TotalDeposits = ISNULL((SELECT COUNT(1) FROM dbo.AgentDeposit WHERE IdAgent=@IdAgent AND Amount=@Amount AND (dbo.RemoveTimeFromDatetime(DepositDate)=@DepositDate) AND @BankName=BankName),0)
    SET @TotalDeposits = ISNULL((SELECT COUNT(1) FROM dbo.AgentDeposit with(nolock) WHERE IdAgent=@IdAgent AND Amount=@Amount AND (dbo.RemoveTimeFromDatetime([DateOfLastChange])=@DepositDate) AND @BankName=BankName),0)

    IF @TotalDeposits>0
    BEGIN    
        UPDATE #Deposit SET SimilarDeposit=2, TotalDeposits = @TotalDeposits WHERE IdDeposits=@IdDeposits
    END
    ELSE
    BEGIN
        --SET @TotalDeposits  = ISNULL((SELECT COUNT(1) FROM dbo.AgentDeposit WHERE IdAgent=@IdAgent AND Amount=@Amount AND (dbo.RemoveTimeFromDatetime(DepositDate)>=@BeginDate and dbo.RemoveTimeFromDatetime(DepositDate)<@DepositDate) AND BankName=@BankName),0)
        SET @TotalDeposits  = ISNULL((SELECT COUNT(1) FROM dbo.AgentDeposit with(nolock) WHERE IdAgent=@IdAgent AND Amount=@Amount AND (dbo.RemoveTimeFromDatetime([DateOfLastChange])>=@BeginDate and dbo.RemoveTimeFromDatetime([DateOfLastChange])<@DepositDate) AND BankName=@BankName),0)
        IF  @TotalDeposits > 0
        BEGIN
             UPDATE #Deposit SET SimilarDeposit=3, TotalDeposits = @TotalDeposits WHERE IdDeposits=@IdDeposits     
        end      
    END  
    SET @IdDeposits = @IdDeposits + 1
END


  DECLARE @diffMargin MONEY = 0

  select ReferenceNumber,idAgent,amount into #reference from agentdeposit with(nolock) where ReferenceNumber is not null
  
  SELECT    
    d.BankReference,
    d.SubAccount, 
    c.name AgentClass,  
    d.IdAgent,
    d.AgentCode,
    d.AgentName,
    d.BankName BankName, -- CR M00247
    DepositDate,
    Amount,
    SimilarDeposit,
    TotalDeposits,
    BankReference
  FROM #Deposit d
  join agent a on d.idagent=a.idagent
  join agentclass c on a.idagentclass=c.idagentclass
  where a.AgentCode not like '%-B' AND a.AgentCode not like '%-P' and isnumeric(substring(a.agentcode,1,1))=1
  AND NOT EXISTS 
  (SELECT 1 FROM #reference ref 
  		WHERE ref.ReferenceNumber COLLATE DATABASE_DEFAULT = d.BankReference COLLATE DATABASE_DEFAULT
  		 	    AND ref.idAgent = d.idAgent
  		  	    AND (ref.Amount <= (d.amount + @diffMargin) AND ref.amount >= (d.amount - @diffMargin) )
  		 	  )
  --and BankReference not in (select ReferenceNumber collate SQL_Latin1_General_CP1_CI_AS from #reference)
  ORDER BY IdDeposits


  
  select  
  distinct BankReference 
  from #Deposit dp 
  WHERE EXISTS 
  (SELECT 1 FROM #reference ref 
  		WHERE ref.ReferenceNumber COLLATE DATABASE_DEFAULT = dp.BankReference COLLATE DATABASE_DEFAULT
  		 	    AND ref.idAgent = dp.idAgent
  		  	    AND (ref.Amount <= (dp.amount + @diffMargin) AND ref.amount >= (dp.amount - @diffMargin) )
  		 	  )
  
  
  --select distinct BankReference from #Deposit where BankReference in (select ReferenceNumber collate SQL_Latin1_General_CP1_CI_AS from #reference)
  
    END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[dbo].[st_GetWfSubAccountDepositDetail]',GETDATE(),@ErrorMessage)
END CATCH
