CREATE   PROCEDURE [dbo].[st_EvaluateKYCRule]
(
	@CustomerName nVARCHAR(MAX),
	@CustomerFirstLastName nVARCHAR(MAX),
	@CustomerSecondLastName nVARCHAR(MAX),
	@BeneficiaryName nVARCHAR(MAX),
	@BeneficiaryFirstLastName nVARCHAR(MAX),
	@BeneficiarySecondLastName nVARCHAR(MAX),
	@IdPayer INT,
	@IdPaymenttype INT,
	@IdAgent INT,
	@IdCountry INT,
	@IdGateway INT,
	@IdCustomer INT,
	@IdBeneficiary INT,
	@AmountInDollars MONEY,
	@AmountInMN MONEY,
	@IdCountryCurrency INT

	,@IdBranch INT = NULL /*S49*/
	,@IdCity INT = NULL	/*S49*/

	,@Fee MONEY = NULL	/*S50*/
	,@ExRate MONEY = NULL	/*S50*/

	,@IdStateDestination INT = null /*S28*/
	,@CustomerAddress nVARCHAR(MAX)
	,@CustomerCity nVARCHAR(MAX)
	,@CustomerStateO nVARCHAR(MAX)
	,@BeneficiaryAddress nVARCHAR(MAX)
	,@BeneficiaryCity nVARCHAR(MAX)
	,@BeneficiaryState nVARCHAR(MAX)
	,@FromBill bit = 0
	,@FromMoneyOrder BIT = 0
	,@IsEditTransfer bit = 0
	,@IdTransferOriginal INT = 0
)
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiAgent</app>
<Description></Description>

<ChangeLog>
<log Date="17/02/2017" Author="jmoreno">Se agrega el IdState para el guardado de la KYC</log>
<log Date="29/06/2017" Author="snevarez">Se agrega el IdStateDestination para el guardado de la KYC y usarlo en la aplicacion de reglas por estado destino</log>
<log Date="21/08/2017" Author="mdelgado">S35 - Anexo de columnas nuevas para kyc required. </log>
<log Date="24/05/2019" Author="azavala">Coincidencia de Customer y Beneficiario por ID o por 100% match en nombre, apellidos, Direccion, Ciudad y estado; Ref:: 240520190150_azavala </log>
<log Date="01/11/2019" Author="jrivera">se agrega OR dentro de AND al WHERE de DenyList for Customer para tomar las KYC por idcustomer tambien</log>
<log Date="2020/07/20" Author="adominguez"> Se agregan las tablas de Billpayment para validacion por customer </log>
<log Date="15/08/2022" Author="jsierra"> Se remplaza las variables tabla TBen y TCus por tablas temporales </log>
<log Date="2022/10/21" Author="jdarellano">Se agregan WITH (NOLOCK)'s faltantes.</log>
<log Date="03/10/2023" Author="jcsierra">Se agregan nuevos status de MO</log>
</ChangeLog>
********************************************************************/
SET NOCOUNT ON;
SET ARITHABORT ON;

SET @IdTransferOriginal = ISNULL(@IdTransferOriginal, 0);


BEGIN TRY
	DECLARE @IdState INT = NULL;
	DECLARE @Action INT = 0;

	DECLARE @SUPERTEXT VARCHAR(MAX)
	DECLARE @initializetime DATETIME = getdate()
	SET @SUPERTEXT='@CustomerName='+isnull(CONVERT(VARCHAR,@CustomerName),'NULL')
		+'@CustomerFirstLastName='+isnull(CONVERT(VARCHAR,@CustomerFirstLastName),'NULL')
		+'@CustomerSecondLastName='+isnull(CONVERT(VARCHAR,@CustomerSecondLastName),'NULL')
		+'@BeneficiaryName='+isnull(CONVERT(VARCHAR,@BeneficiaryName),'NULL')
		+'@BeneficiaryFirstLastName='+isnull(CONVERT(VARCHAR,@BeneficiaryFirstLastName),'NULL')
		+'@BeneficiarySecondLastName='+isnull(CONVERT(VARCHAR,@BeneficiarySecondLastName),'NULL')
		+'@IdPayer='+isnull(CONVERT(VARCHAR,@IdPayer),'NULL')
		+'@IdPaymenttype='+isnull(CONVERT(VARCHAR,@IdPaymenttype),'NULL')
		+'@IdAgent='+isnull(CONVERT(VARCHAR,@IdAgent),'NULL')
		+'@IdCountry='+isnull(CONVERT(VARCHAR,@IdCountry),'NULL')
		+'@IdGateway='+isnull(CONVERT(VARCHAR,@IdGateway),'NULL')
		+'@IdCustomer='+isnull(CONVERT(VARCHAR,@IdCustomer),'NULL')
		+'@IdBeneficiary='+isnull(CONVERT(VARCHAR,@IdBeneficiary),'NULL')		
		+'@AmountInDollars='+isnull(CONVERT(VARCHAR,@AmountInDollars),'NULL')
		+'@AmountInMN='+isnull(CONVERT(VARCHAR,@AmountInMN),'NULL')
		+'@IdCountryCurrency='+isnull(CONVERT(VARCHAR,@IdCountryCurrency),'NULL')
		+'@IdBranch='+isnull(CONVERT(VARCHAR,@IdBranch),'NULL')
   		+'@IdCity='+isnull(CONVERT(VARCHAR,@IdCity),'NULL')
		+'@Fee='+isnull(CONVERT(VARCHAR,@Fee),'NULL')
		+'@ExRate='+isnull(CONVERT(VARCHAR,@ExRate),'NULL')
		+'@IdState='+isnull(CONVERT(VARCHAR,@IdState),'NULL')	
		+'@IdStateDestination='+isnull(CONVERT(VARCHAR,@IdStateDestination),'NULL');	/*S28*/
		
/*Guarda ejecución de SP (PRUEBAS)*/
/*DECLARE @Parametess VARCHAR(MAX)
SET @Parametess = '@CustomerName=' + @CustomerName +
'@CustomerFirstLastName=' + @CustomerFirstLastName +
'@CustomerSecondLastName=' + @CustomerSecondLastName +
'@BeneficiaryName=' + @BeneficiaryName +
'@BeneficiaryFirstLastName=' + @BeneficiaryFirstLastName +
'@BeneficiarySecondLastName=' + @BeneficiarySecondLastName +
'@IdPayer=' + CONVERT(VARCHAR, @IdPayer) +
'@IdPaymenttype=' + CONVERT(VARCHAR, @IdPaymenttype) +
'@IdAgent=' + CONVERT(VARCHAR, @IdAgent) +
'@IdCountry=' + CONVERT(VARCHAR, @IdCountry) +
'@IdGateway=' + CONVERT(VARCHAR, @IdGateway) +
'@IdCustomer=' + CONVERT(VARCHAR, @IdCustomer) +
'@IdBeneficiary=' + CONVERT(VARCHAR, @IdBeneficiary) +
'@AmountInDollars=' + CONVERT(VARCHAR, @AmountInDollars) +
'@AmountInMN=' + CONVERT(VARCHAR, @AmountInMN) +
'@IdCountryCurrency=' + CONVERT(VARCHAR, @IdCountryCurrency)
EXEC soporte.st_AuditSPExecute N'[dbo]', N'[st_EvaluateKYCRule]', @Parametess*/

/*Quitar en produccion*/
/*--------------------*/
--INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
--	Values('st_EvaluateKYCRule',Getdate(),'Parameters:IdCustomer=' 
--		+ CONVERT(VARCHAR(25),@IdCustomer) 
--		+ ',IdBeneficiary=' 
--		+ CONVERT(VARCHAR(25),@IdBeneficiary) 
--		+ ',IdBranch=' + CONVERT(VARCHAR(25),ISNULL(@IdBranch,'')) 
--		+ ',IdCity=' + CONVERT(VARCHAR(25),ISNULL(@IdCity,''))
--		+ ',IdPayer=' + CONVERT(VARCHAR(25),ISNULL(@IdPayer,''))
--		+ ',Fee=' + CONVERT(VARCHAR(25),ISNULL(@Fee,''))
--		+ ',ExRate=' + CONVERT(VARCHAR(25),ISNULL(@ExRate,'')));
/*--------------------*/

-------------------------------  Incremento Performance , uso de Customer.FullName y Beneficiary.FullName ---------------------------------
	
	DECLARE @CustomerFullName NVARCHAR(120);
	DECLARE @BeneficiaryFullName NVARCHAR(120);

	SET @CustomerFullName=REPLACE(Substring(@CustomerName,1,40)+Substring(@CustomerFirstLastName,1,40)+Substring(@CustomerSecondLastName,1,40), ' ','');
	SET @BeneficiaryFullName =REPLACE(Substring(@BeneficiaryName,1,40)+Substring(@BeneficiaryFirstLastName,1,40)+Substring(@BeneficiarySecondLastName,1,40), ' ','');

--------------------- Add Fee to Amount --------------------------------------------------------------------
	
	DECLARE @AmountUSDOriginal MONEY =  @AmountInDollars;
	DECLARE @AmountMNOriginal  MONEY = @AmountInMN;
	DECLARE @AmountUSDFee MONEY = (@AmountInDollars + ISNULL(@Fee,0)); /*S50*/
	DECLARE @AmountMNFee  MONEY = (@AmountInMN + (ISNULL(@Fee,0)*ISNULL(@ExRate,0))); /*S50*/

	DECLARE @SkippedStatus TABLE (IdStatus INT);
	INSERT INTO @SkippedStatus (IdStatus)
	VALUES
	(22),	-- Cancelled
	(31),	-- Rejected
	--(70),	-- Update In Progress
	(72);	-- PENDing by change request

--------------------- Id currency usa AND country usa -------------------------------------------------------
	
	DECLARE @GlobalIDUSacurrency INT;
	SELECT @GlobalIDUSacurrency=CONVERT(INT,[Value]) FROM dbo.GlobalAttributes WITH (NOLOCK) WHERE [Name]='IdCountryCurrencyDollars';

	DECLARE @GlobalIDUSCountry INT;
	SELECT @GlobalIDUSCountry=CONVERT(INT,[Value]) FROM dbo.GlobalAttributes WITH (NOLOCK) WHERE [Name]='IdCountryUSA';

	SELECT 
		@IdState= s.IdState
	FROM dbo.Agent a WITH (NOLOCK)
		INNER JOIN dbo.[State] s WITH (NOLOCK) ON a.AgentState = s.StateCode
	WHERE
		a.IdAgent = @IdAgent; 

-----------------------------Tabla temporal de reglas-----------------------------------------
	DECLARE @Rules TABLE
	(
		Id INT identity(1,1),
		IdRule INT,
		RuleName nVARCHAR(MAX),
		IdPayer INT,
		IdPaymentType INT,
		IdAgent INT,
		IdCountry INT,
		IdGateway INT,
		Actor nVARCHAR(MAX),
		Symbol nVARCHAR(MAX),
		Amount MONEY,
		AgentAmount bit,
		IdCountryCurrency INT,
		TimeInDays INT,
		[Action] INT,
		MessageInSpanish nVARCHAR(MAX),
		MessageInEnglish nVARCHAR(MAX),
		IsDenyList bit,
		Factor Decimal (18,2),
		SSNRequired bit not null default 0,
		OccupationRequired BIT NOT NULL DEFAULT 0,
		IsConsecutive bit not null default 0,
		IsBlackList bit not null default 0,
		Transfers INT,
		ComplianceFormatId INT,
		ComplianceFormatName NVARCHAR(MAX),
		IdState   INT
		,IdStateDestination INT /*S28*/
		/*>> S35*/
		,IdTypeRequired bit
		,IdNumberRequired bit
		,IdExpirationDateRequired bit
		,IdStateCountryRequired bit
		,DateOfBirthRequired bit
		/*<< S35*/
	);

------------------------ Se cargan las reglas, sólo aquellas que aplicaran ---------------

	INSERT INTO @Rules
		(
		IdRule,
		RuleName,
		IdPayer,
		IdPaymentType,
		IdAgent,
		IdCountry,
		IdGateway,
		Actor,
		Symbol,
		Amount,
		AgentAmount,
		IdCountryCurrency,
		TimeInDays,
		[Action],
		MessageInSpanish,
		MessageInEnglish,
		IsDenyList,
		Factor,
		SSNRequired,
		OccupationRequired,
		IsConsecutive,
		Transfers,
		ComplianceFormatId,
		ComplianceFormatName,
		IdState
		,IdStateDestination /*S28*/
		/*>> S35*/
		,IdTypeRequired
		,IdNumberRequired
		,IdExpirationDateRequired
		,IdStateCountryRequired
		,DateOfBirthRequired
				/*<< S35*/
	)
	SELECT
		KYCR.IdRule,
		KYCR.RuleName,
		KYCR.IdPayer,
		KYCR.IdPaymentType,
		KYCR.IdAgent,
		KYCR.IdCountry,
		KYCR.IdGateway,
		KYCR.Actor,
		KYCR.Symbol,
		KYCR.Amount,
		KYCR.AgentAmount,
		KYCR.IdCountryCurrency,
		KYCR.TimeInDays,
		KYCR.[Action],
		KYCR.MessageInSpanish,
		KYCR.MessageInEnglish,
		0,
		KYCR.Factor,
		KYCR.SSNRequired,
		KYCR.OccupationRequired,
		KYCR.IsConsecutive,
		KYCR.Transactions,
		KYCR.ComplianceFormatId,
		CF.FileOfName,
		KYCR.IdState
		,KYCR.IdStateDestination /*S28*/
		/*>> S35*/
		,KYCR.IdTypeRequired
		,KYCR.IdNumberRequired
		,KYCR.IdExpirationDateRequired
		,KYCR.IdStateCountryRequired
		,KYCR.DateOfBirthRequired
		/*<< S35*/
	FROM [dbo].[KYCRule] KYCR (NOLOCK)
		LEFT JOIN [dbo].[ComplianceFormat] CF (NOLOCK) ON KYCR.[ComplianceFormatId] = CF.[ComplianceFormatId]
	WHERE
		(IdPayer=@IdPayer or IdPayer IS NULL) 		
		AND (IdCountryCurrency=@GlobalIDUSacurrency or IdCountryCurrency=@IdCountryCurrency or IdCountryCurrency IS NULL)
		AND (IdPaymentType=@IdPaymenttype or IdPaymentType IS NULL)
		AND (IdAgent=@IdAgent or IdAgent IS NULL)
		AND (IdCountry=@IdCountry or IdCountry IS NULL)
		AND (IdGateway=@IdGateway or IdGateway IS NULL)
		AND IdGenericStatus=1 AND IsExpire=0
	    AND (IdState=@IdState or IdState IS NULL)
		AND (IdStateDestination=@IdStateDestination or IdStateDestination IS NULL)/*S28*/
		AND (@FromBill = 0 or (@FromBill = 1 AND KYCR.[Action] in (1) AND KYCR.Actor in ('Customer','NewCustomer','InactiveCustomer')))
		AND ((@FromMoneyOrder = 0 AND KYCR.Actor NOT IN ('MoneyOrderCustomer')) OR (@FromMoneyOrder = 1 /*AND KYCR.[Action] in (1)*/ AND KYCR.Actor IN ('MoneyOrderCustomer')));

	INSERT INTO @Rules
	(
		IdRule,
		RuleName,
		IdPayer,
		IdPaymentType,
		IdAgent,
		IdCountry,
		IdGateway,
		Actor,
		Symbol,
		Amount,
		AgentAmount,
		IdCountryCurrency,
		TimeInDays,
		[Action],
		MessageInSpanish,
		MessageInEnglish,
		IsDenyList,
		Factor,
		SSNRequired,
		OccupationRequired,
		IsConsecutive,
		Transfers,
		ComplianceFormatId,
		ComplianceFormatName,
		IdState
		,IdStateDestination /*S28*/
		/*>> S35*/
		,IdTypeRequired
		,IdNumberRequired
		,IdExpirationDateRequired
		,IdStateCountryRequired
		,DateOfBirthRequired
		/*<< S35*/
	)
	SELECT
		KYCR.IdRule,
		KYCR.RuleName,
		KYCR.IdPayer,
		KYCR.IdPaymentType,
		KYCR.IdAgent,
		KYCR.IdCountry,
		KYCR.IdGateway,
		KYCR.Actor,
		KYCR.Symbol,
		KYCR.Amount,
		KYCR.AgentAmount,
		KYCR.IdCountryCurrency,
		KYCR.TimeInDays,
		KYCR.[Action],
		KYCR.MessageInSpanish,
		KYCR.MessageInEnglish,
		0,
		KYCR.Factor,
		KYCR.SSNRequired,
		KYCR.OccupationRequired,
		KYCR.IsConsecutive,
		KYCR.Transactions,
		KYCR.ComplianceFormatId,
		CF.FileOfName,
		KYCR.IdState
		,KYCR.IdStateDestination  /*S28*/
		/*>> S35*/
		,KYCR.IdTypeRequired
		,KYCR.IdNumberRequired
		,KYCR.IdExpirationDateRequired
		,KYCR.IdStateCountryRequired
		,KYCR.DateOfBirthRequired
		/*<< S35*/
	FROM [dbo].[KYCRule] KYCR (NOLOCK)
		LEFT JOIN [dbo].[ComplianceFormat] CF (NOLOCK) ON KYCR.[ComplianceFormatId] = CF.[ComplianceFormatId]
	WHERE
		(IdPayer=@IdPayer or IdPayer IS NULL) 		
		AND (IdCountryCurrency=@GlobalIDUSacurrency or IdCountryCurrency=@IdCountryCurrency or IdCountryCurrency IS NULL)
		AND (IdPaymentType=@IdPaymenttype or IdPaymentType IS NULL)
		AND (IdAgent=@IdAgent or IdAgent IS NULL)
		AND (IdCountry=@IdCountry or IdCountry IS NULL)
		AND (IdGateway=@IdGateway or IdGateway IS NULL)
		AND IdGenericStatus=1 AND IsExpire=1 AND ExpirationDate>=getdate()
	    AND (IdState=@IdState or IdState IS NULL)

		AND (IdStateDestination=@IdStateDestination or IdStateDestination IS NULL)
		AND (@FromBill = 0 or (@FromBill = 1 AND KYCR.Action in (1) AND KYCR.Actor in ('Customer','NewCustomer','InactiveCustomer')))
		AND ((@FromMoneyOrder = 0 AND KYCR.Actor NOT IN ('MoneyOrderCustomer')) OR (@FromMoneyOrder = 1 /*AND KYCR.[Action] in (1)*/ AND KYCR.Actor IN ('MoneyOrderCustomer')));

--------------------- Si existe regla de beneficiario entonces llenar temporal de beneficiario---------------

	IF EXISTS (SELECT 1 FROM @rules WHERE Actor='Beneficiary')
	BEGIN
		DECLARE @Beneficiary TABLE (IdBeneficiary INT);

		INSERT INTO @Beneficiary (IdBeneficiary)
		SELECT IdBeneficiary FROM dbo.Beneficiary WITH (NOLOCK) WHERE
		FullName=@BeneficiaryFullName;
	END;

--------------------- Si existe regla de NewCustomer o InactiveCustomer     ---------------------
--------------------- entonces buscar la fecha de la última  transferencia  ---------------------

	DECLARE @DateOfLastTransfer DATETIME;
	DECLARE @FolioOfLastTransfer INT;
	DECLARE @AmountOfLastTransfer MONEY;
	DECLARE @BeneficiaryOfLastTransfer VARCHAR(MAX);
	DECLARE @ClaimCode VARCHAR(MAX);

	IF EXISTS (SELECT 1 FROM @rules WHERE Actor='NewCustomer' or Actor='InactiveCustomer' or Actor='AverageCustomer')
	BEGIN
		IF (@IdCustomer IS NOT NULL AND @IdCustomer!=0)
		   BEGIN 
			  DECLARE @Dates TABLE (
				DateOfTransfer DATETIME,
				Folio INT,
				Amount MONEY,
				Beneficiary VARCHAR(MAX),
				ClaimCode VARCHAR(MAX)
			  );
		  
			  INSERT INTO @Dates 
			  SELECT top 1 DateOfTransfer, Folio, @AmountInDollars, CONCAT(@BeneficiaryName, ' ', BeneficiaryFirstLastName, ' ', BeneficiarySecondLastName), ClaimCode FROM dbo.[Transfer] WITH (NOLOCK) WHERE IdCustomer = @IdCustomer ORDER BY DateOfTransfer desc;
		  
			  INSERT INTO @Dates 
			  SELECT top 1 DateOfTransfer, Folio, @AmountInDollars, CONCAT(@BeneficiaryName, ' ', BeneficiaryFirstLastName, ' ', BeneficiarySecondLastName), ClaimCode  FROM dbo.[TransferClosed] WITH (NOLOCK)  WHERE IdCustomer = @IdCustomer ORDER BY DateOfTransfer desc;
		  
			  SELECT top 1 @DateOfLastTransfer = DateOfTransfer, @FolioOfLastTransfer = Folio, @AmountOfLastTransfer = Amount, @BeneficiaryOfLastTransfer = Beneficiary, @ClaimCode = ClaimCode FROM @Dates ORDER BY DateOfTransfer desc;
		   END
	END


----------------------------------------- declaración de variables -----------------------------
	DECLARE @Id INT,
		@IdPayerRule INT,
		@IdPaymentTypeRule INT,
		@ActorRule NVARCHAR(MAX),
		@SymbolRule NVARCHAR(MAX),
		@AmountRule MONEY,
		@AgentAmountRule BIT,
		@IdCountryCurrencyRule INT,
		@TimeInDaysRule INT,
		@ActionRule INT,
		@TotalAmount MONEY,
		@TotalAmount2 MONEY,
		@Factor DECIMAL (18,2),
		@IsConsecutive bit, 
		@Transfers INT,
		@IdAgentRule INT,
		@IdGatewayRule INT,
		@IdCountryRule INT;

	SET @Id=1;

	CREATE TABLE #TBen
	(
		AmountInDollars MONEY,
		AmountInMN MONEY,
	
		DateOfTransfer DATETIME,
		IdPayer INT,
		IdPaymentType INT

		/*Semana 49*/
		/*---------*/
		,[IdCustomer] INT
		,[CustomerFullName] VARCHAR(250)  DEFAULT(NULL)
		,[CustomerState] VARCHAR(250)  DEFAULT(NULL)

		,[IdBeneficiary] INT
	
		,[IdAgent] INT
		,[AgentState] VARCHAR(250)  DEFAULT(NULL)
		,[AgentZipCode] VARCHAR(12)  DEFAULT(NULL)

		,[IdBranch] INT
		,[BranchState] VARCHAR(250)  DEFAULT(NULL)
		,[BranchCity] VARCHAR(250)  DEFAULT(NULL)
		,[BranchCountry] VARCHAR(250)  DEFAULT(NULL)


		,[ClaimCode] VARCHAR(50)

		,[KYCRule] INT  DEFAULT(0)
		/*---------*/
	);

	CREATE TABLE #TCus
	(
		AmountInDollars MONEY,
		AmountInMN MONEY,

		DateOfTransfer DATETIME,
		IdPayer INT,
		IdPaymentType INT
	);

	DECLARE @MaxTimeInDays INT; 
	SELECT @MaxTimeInDays=max(TimeInDays) FROM @Rules WHERE TimeInDays is not null;
	SET @MaxTimeInDays=isnull(@MaxTimeInDays,0);

	--Add CalENDar Date
	DECLARE @MaxDate DATETIME =  DATEADD(dd,-@MaxTimeInDays+1,dbo.RemoveTimeFROMDATETIME(getdate())); 
	DECLARE @MaxTimeDate DATETIME ;

    INSERT INTO #TBen (	AmountInDollars, AmountInMN, DateOfTransfer, IdPayer, IdPaymentType, [IdCustomer], [CustomerState], [IdBeneficiary], [IdAgent], [IdBranch], [ClaimCode]	)
    SELECT 
		(T.AmountInDollars+ISNULL(T.Fee,0)) AS AmountInDollars /*S49,50*/
		,(T.AmountInMN+(ISNULL(T.Fee,0)*ISNULL(T.ExRate,0))) AS AmountInMN /*S49,50*/
		,T.DateOfTransfer,T.IdPayer,T.IdPaymenttype
		, T.IdCustomer, UPPER(LTRIM(RTRIM(T.CustomerState))) AS CustomerState, T.IdBeneficiary, T.IdAgent, T.IdBranch, T.ClaimCode /*S46*/
	FROM dbo.[Transfer] AS T WITH (NOLOCK)
	WHERE 
		IdBeneficiary in (SELECT IdBeneficiary FROM @Beneficiary) AND
		--DATEDIFF (day,DateOfTransfer,GETDATE() ) <= @MaxTimeInDays AND 
		--Add CalENDar Date
		T.DateOfTransfer >= @MaxDate AND
		IdStatus Not In (SELECT IdStatus FROM @SkippedStatus)
		AND T.IdTransfer NOT IN (@IdTransferOriginal)
    UNION ALL
	SELECT 
		(TC.AmountInDollars+ISNULL(TC.Fee,0)) AS AmountInDollars /*S49,50*/
		,(TC.AmountInMN+(ISNULL(TC.Fee,0)*ISNULL(TC.ExRate,0))) AS AmountInMN /*S49,50*/
		,TC.DateOfTransfer,TC.IdPayer,TC.IdPaymenttype
		, TC.IdCustomer, UPPER(LTRIM(RTRIM(TC.CustomerState))) AS CustomerState, TC.IdBeneficiary, TC.IdAgent, TC.IdBranch, TC.ClaimCode /*S46*/
	FROM dbo.TransferClosed AS TC WITH (NOLOCK)
	WHERE 
		IdBeneficiary in (SELECT IdBeneficiary FROM @Beneficiary) AND
		--DATEDIFF (day,DateOfTransfer,GETDATE() ) <= @MaxTimeInDays AND
		--Add CalENDar Date
		TC.DateOfTransfer >= @MaxDate AND
		IdStatus Not In (SELECT IdStatus FROM @SkippedStatus)
		AND TC.IdTransferClosed NOT IN (@IdTransferOriginal);


	/*-------------------------------------------------------------------------------*/
	/*-----------------------------------Semana 49-----------------------------------*/
	/*PASO 1: Obtencion informacion de la operacion para evaluacion*/
	;WITH CTE_BEN AS 
		(
		SELECT 
				T.AmountInDollars,
			T.AmountInMN,
			T.DateOfTransfer,
			T.IdPayer,
			T.IdPaymentType

			,T.IdCustomer
			,C.FullName AS CustomerFullName
			,T.CustomerState

			,T.IdBeneficiary
	
			,T.IdAgent
			,A.AgentState
			,A.AgentZipCode

			,T.IdBranch
			,S.StateName AS BranchState
			,Cy.CityName AS BranchCity
			,Ct.CountryName AS BranchCountry

			,T.ClaimCode
		FROM #TBen AS T
			INNER JOIN dbo.Customer AS C WITH (NOLOCK) ON T.IdCustomer = C.IdCustomer
			INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
			INNER JOIN dbo.Branch AS B WITH (NOLOCK) ON T.IdBranch = B.IdBranch
				INNER JOIN dbo.City AS Cy WITH (NOLOCK) ON B.IdCity = Cy.IdCity
				INNER JOIN dbo.[State] AS S WITH (NOLOCK) ON Cy.IdState = S.IdState
				INNER JOIN dbo.Country AS Ct WITH (NOLOCK) ON S.IdCountry = Ct.IdCountry
	)UPDATE B SET
		CustomerFullName = C.CustomerFullName,
				
		AgentState = C.AgentState,
		AgentZipCode = C.AgentZipCode,
				
		BranchState = C.BranchState,
		BranchCity = C.BranchCity,
		BranchCountry = C.BranchCountry
	FROM  #TBen AS B
		INNER JOIN CTE_BEN AS C ON B.ClaimCode = C.ClaimCode;

	/*PASO 2: Obtencion de valores de referencia para la evaluacion*/
	DECLARE 
		@AgentState VARCHAR(150) = NULL,
		@AgentZipCode VARCHAR(150) = NULL,
		@CustomerState VARCHAR(150) = NULL,
		@BranchState VARCHAR(150) = NULL,
		@BranchCity VARCHAR(150) = NULL,
		@BranchCountry VARCHAR(150) = NULL;

	/*PASO 2.1:Obtiene datos del agente*/
	SELECT TOP 1
		@AgentState = A.AgentState,
		@AgentZipCode = A.AgentZipcode
	FROM dbo.Agent AS A WITH(NOLOCK)
	WHERE A.IdAgent = @IdAgent;

	/*Obtiene estado del cliente*/
	SELECT TOP 1
		@CustomerState = C.[State]
	FROM dbo.Customer AS C WITH(NOLOCK)
		WHERE C.IdCustomer = @IdCustomer;

	/*PASO 2.2:Validacion de punto de pago y lo busca de ser necesario(default)*/
	/*----- Special case when Idbranch IS NULL but transfer is cash ----------------*/
	IF ((@IdBranch IS NULL or @IdBranch=0) AND (@IdPaymentType=1 or @IdPaymentType=4 or @IdPaymentType=2))
	BEGIN
		IF @IdCity IS NULL
			SELECT top 1 @IdBranch=IdBranch FROM dbo.Branch WITH(NOLOCK) WHERE IdPayer=@IdPayer AND (IdGenericStatus=1 or IdGenericStatus IS NULL)  ORDER BY IdBranch;
		ELSE
			SELECT top 1 @IdBranch=IdBranch FROM dbo.Branch WITH(NOLOCK) WHERE IdPayer=@IdPayer AND (IdGenericStatus=1 or IdGenericStatus IS NULL) AND IdCity=@IdCity ORDER BY IdBranch;                               
	END   

	-- Check Again IdBranch in case @IdCity was not null but not EXISTS
	IF ((@IdBranch IS NULL or @IdBranch=0) AND (@IdPaymentType=1 or @IdPaymentType=4 or @IdPaymentType=2))
	BEGIN
		SELECT top 1 @IdBranch=IdBranch FROM dbo.Branch WITH(NOLOCK) WHERE IdPayer=@IdPayer AND (IdGenericStatus=1 or IdGenericStatus IS NULL)  ORDER BY IdBranch;
	END  
		
	/*PASO 2.3:Obtiene datos del punto de pago*/
	SELECT TOP 1
		@BranchState = S.StateName
		,@BranchCity = Cy.CityName
		,@BranchCountry = C.CountryName
	FROM dbo.Branch AS B WITH(NOLOCK)
		INNER JOIN dbo.City AS Cy WITH (NOLOCK) ON B.IdCity = Cy.IdCity
		INNER JOIN dbo.[State] AS S WITH (NOLOCK) ON Cy.IdState = S.IdState
		INNER JOIN dbo.Country AS C WITH (NOLOCK) ON  S.IdCountry = C.IdCountry
	WHERE B.IdBranch = @IdBranch;

	/*PASO 3: Evaluacion de casos(Total de casos 8 con 2 incisos cada uno(A&B))*/
	/*CASO I-VII INCISOS A's*/
	UPDATE #TBen  SET
		KYCRule = 1
	WHERE
		IdBeneficiary = @IdBeneficiary
		AND KYCRule = 0;

	/*CASO I : B*/
	UPDATE #TBen SET
		KYCRule = 1
	WHERE
		AgentZipcode = @AgentZipCode
		AND CustomerState = @CustomerState
		AND BranchState = @BranchState	
		AND BranchCountry = @BranchCountry
		AND KYCRule = 0;

	/*CASO II : B*/
	UPDATE #TBen SET
		KYCRule = 2
	WHERE
		AgentZipcode <> @AgentZipCode
		AND CustomerState = @CustomerState
		AND BranchState = @BranchState	
		AND BranchCountry = @BranchCountry
		AND KYCRule = 0;

	/*CASO III : B*/
	UPDATE #TBen 
	SET
		KYCRule = 3
	WHERE
		AgentZipcode = @AgentZipCode
		AND CustomerState = @CustomerState
		AND BranchState <> @BranchState	
		AND BranchCountry = @BranchCountry
		AND KYCRule = 0;

	/*PASO 3.1: Descarte de trabnsaciones que no pertenecena los casos esTABLEcidos*/
	DELETE FROM #TBen WHERE KYCRule = 0;

	/*-------------------------------------------------------------------------------*/
	/*-------------------------------------------------------------------------------*/
		
	INSERT INTO #TCus  -- #Transfer
	SELECT 
		(AmountInDollars+ISNULL(Fee,0)) AS AmountInDollars /*S50*/
		,(AmountInMN+(ISNULL(Fee,0)*ISNULL(ExRate,0))) AS AmountInMN /*S50*/
		,DateOfTransfer,IdPayer,IdPaymenttype
	FROM dbo.[Transfer] WITH (NOLOCK)
	WHERE 
		IdCustomer = @IdCustomer AND
		--DATEDIFF (day,DateOfTransfer,GETDATE() ) <= @MaxTimeInDays AND
		--Add CalENDar Date
		DateOfTransfer >= @MaxDate AND 
		IdStatus Not In (SELECT IdStatus FROM @SkippedStatus)
		AND IdTransfer NOT IN (@IdTransferOriginal)
	UNION ALL -- #TransferClosed
	SELECT 
		(AmountInDollars+ISNULL(Fee,0)) AS AmountInDollars /*S50*/
		,(AmountInMN+(ISNULL(Fee,0)*ISNULL(ExRate,0))) AS AmountInMN /*S50*/
		,DateOfTransfer,IdPayer,IdPaymenttype
	FROM dbo.TransferClosed WITH (NOLOCK)
	WHERE 
		IdCustomer = @IdCustomer AND
		--DATEDIFF (day,DateOfTransfer,GETDATE() ) <= @MaxTimeInDays AND
		--Add CalENDar Date
		DateOfTransfer >= @MaxDate AND 
		IdStatus Not In (SELECT IdStatus FROM @SkippedStatus)
		AND IdTransferClosed NOT IN (@IdTransferOriginal)
	UNION ALL -- #BillPaymentTransactions
	SELECT 
		(ReceiptAmount + ISNULL(Fee,0)) AS AmountInDollars /*S50*/
		,0 AS AmountInMN
		,PaymentDate AS DateOfTransfer,null AS IdPayer,@IdPaymenttype AS IdPaymenttype 
	FROM dbo.BillPaymentTransactions WITH (NOLOCK) 
	WHERE 
		customerid=@IdCustomer 
		AND [Status]=1 
		AND 
		--DATEDIFF (day,PaymentDate,GETDATE() ) <= @MaxTimeInDays
		--Add CalENDar Date
		PaymentDate >= @MaxDate
	UNION ALL -- #[BillPayment].[TransferR]
	SELECT
	(Amount+ISNULL(Fee,0)) AS AmountInDollars 
		,(0) AS AmountInMN
		,DateOfCreation,
		@IdPayer as IdPayer, 
		@IdPaymenttype as IdPaymenttype
	FROM [BillPayment].[TransferR] WITH (NOLOCK)
	WHERE 
		IdCustomer=@IdCustomer AND @IdCustomer>0 AND
		DateOfCreation >= @MaxDate 
		AND	IdStatus = 30
	UNION ALL -- #[regalii].[TransferR]
	SELECT
		(Amount+ISNULL(Fee,0)) AS AmountInDollars
		,(AmountInMN+(ISNULL(Fee,0)*ISNULL(ExRate,0))) AS AmountInMN
		,DateOfCreation,
		@IdPayer as IdPayer, 
		@IdPaymenttype as IdPaymenttype
	FROM [regalii].[TransferR] WITH (NOLOCK)
	WHERE 
		IdCustomer=@IdCustomer AND @IdCustomer>0 AND
		DateOfCreation >= @MaxDate 
		AND	IdStatus = 30
	UNION ALL -- #MoneyOrder.SaleRecord
	SELECT 
		(Amount+ISNULL(FeeAmount, 0)) AS AmountInDollars,
		(0) AS AmountInMN,
		CreationDate DateOfCreation,
		@IdPayer as IdPayer, 
		@IdPaymenttype as IdPaymenttype
	FROM MoneyOrder.SaleRecord sr WITH(NOLOCK)
	WHERE
		sr.IdCustomer = @IdCustomer
		AND sr.CreationDate >= @MaxDate
		AND	IdStatus IN (30, 74, 75, 76);

---------------------------------- Inicia ciclo principal de evaluacion de Reglas ---------------

	WHILE EXISTS (SELECT 1 FROM @Rules WHERE @Id<=Id)
	BEGIN
		--SELECT * FROM @Rules WHERE @Id<=Id --TODO Remove this query	
		SELECT
			@IdPayerRule=IdPayer,
			@IdPaymentTypeRule=IdPaymentType,
			@ActorRule=Actor,
			@SymbolRule=Symbol,
			@AmountRule=Amount,
			@AgentAmountRule=AgentAmount,
			@IdCountryCurrencyRule=IdCountryCurrency,
			@TimeInDaysRule=TimeInDays,
			@ActionRule=[Action],
			@Factor=factor,
			@IsConsecutive = IsConsecutive, 
			@Transfers = Transfers,
			@IdAgentRule = IdAgent,
			@IdGatewayRule = IdGateway,
			@IdCountryRule = IdCountry,
			@Action = [Action]
		FROM @Rules WHERE Id=@Id;

		SET @TotalAmount=0;

		IF (@Action=5)
		BEGIN
			SET @AmountInDollars= @AmountUSDOriginal;
			SET @AmountInMN = @AmountMNOriginal;
		END	
		else
		BEGIN
			SET @AmountInDollars= @AmountUSDFee;
			SET @AmountInMN = @AmountMNFee;
		END	

		IF @ActorRule = 'Beneficiary' AND @TimeInDaysRule>0
		BEGIN

			--Add CalENDar Date
			SELECT @MaxTimeDate =  DATEADD(dd,-@TimeInDaysRule+1,dbo.RemoveTimeFROMDATETIME(getdate()));

			SELECT @TotalAmount= ISNULL( Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN SUM( AmountInDollars) ELSE SUM( AmountInMN) END , 0)
			FROM #TBen
			WHERE 
				isnull(IdPayer,0) = Case When @IdPayerRule IS NULL THEN isnull(IdPayer,0) ELSE @IdPayer END AND
				isnull(IdPaymentType,0) = Case When @IdPaymentTypeRule IS not NULL Then @IdPaymentType Else isnull(IdPaymentType,0) END AND
				--DATEDIFF (day,DateOfTransfer,GETDATE() ) <= @TimeInDaysRule
				--Add CalENDar Date
				DateOfTransfer >= @MaxTimeDate;

			SELECT @TotalAmount = @TotalAmount;
		
		END 
	
	

		IF @ActorRule IN ('Customer', 'MoneyOrderCustomer') AND @TimeInDaysRule>0
		BEGIN
			--Add CalENDar Date
			SELECT @MaxTimeDate =  DATEADD(dd,-@TimeInDaysRule+1,dbo.RemoveTimeFROMDATETIME(getdate()));

			SELECT @TotalAmount=ISNULL( Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN SUM( AmountInDollars) ELSE SUM( AmountInMN) END , 0)
			FROM #TCus
			WHERE 
				isnull(IdPayer,0) = Case When @IdPayerRule IS NULL THEN isnull(IdPayer,0) ELSE @IdPayer END AND
				isnull(IdPaymentType,0) = Case When @IdPaymentTypeRule IS not NULL Then @IdPaymentType Else isnull(IdPaymentType,0) END AND
				--DATEDIFF (day,DateOfTransfer,GETDATE() ) <= @TimeInDaysRule
				--Add CalENDar Date
				DateOfTransfer >= @MaxTimeDate;

			SELECT @TotalAmount=@TotalAmount;
		END

	

		IF @ActorRule = 'NewCustomer' AND @DateOfLastTransfer is not null--Si la regla es NewCustomer y la fecha de último envío no es null (El cliente ya ha realizado un envío) la regla no aplica, borrarla
		BEGIN 
			Delete @Rules WHERE Id=@Id;
			SET @Id=@Id+1;
			SET @TotalAmount=0;
			Continue;
		END

		IF @ActorRule = 'InactiveCustomer'
		BEGIN
			IF (@DateOfLastTransfer IS NULL) --Si el customer nunca ha realizado un envío, ignorar esta regla
			BEGIN
				Delete @Rules WHERE Id=@Id;
				SET @Id=@Id+1;
				SET @TotalAmount=0;
				Continue;
			END

			DECLARE @lastActivityLimit DATETIME;
			--SELECT @lastActivityLimit= DATEADD(day,-1*@TimeInDaysRule,CONVERT(date,GETDATE())) --Add CalENDar Date
			--Add CalENDar Date
			SELECT @lastActivityLimit = DATEADD(dd,-@TimeInDaysRule+1,dbo.RemoveTimeFROMDATETIME(getdate()));

			DECLARE @messageEn VARCHAR(MAX);
			DECLARE @messageEs VARCHAR(MAX);
			SET @messageEn = CONCAT('Claim Code: ', @ClaimCode, ', Date: ', FORMAT(@DateOfLastTransfer , 'MM/dd/yyyy HH:mm:ss'));
			SET @messageEs = CONCAT('Claim Code: ', @ClaimCode, ', Fecha: ',FORMAT(@DateOfLastTransfer , 'MM/dd/yyyy HH:mm:ss') );
		
			update @Rules SET MessageInSpanish = CONCAT(MessageInSpanish, ' (-Delete-!)', @messageEs, ')'), MessageInEnglish = CONCAT(MessageInEnglish, ' (-Delete-!)',@messageEn, ')') WHERE Id = @Id;

			IF(@DateOfLastTransfer>=@lastActivityLimit) --Si la fecha del último envío es mayor que el limite, la regla no aplica, borrarla
			BEGIN
				Delete @Rules WHERE Id=@Id;
				SET @Id=@Id+1;
				SET @TotalAmount=0;
				Continue;
			END
		END --END IF @ActionRule = 'InactiveCustomer'

		IF @ActorRule = 'CountyIdentIFication'
		BEGIN
			DECLARE @IdentIFicationIdCountry INT; 
			SELECT @IdentIFicationIdCountry = IdentIFicationIdCountry FROM dbo.Customer WITH (NOLOCK) WHERE IdCustomer = @IdCustomer;

			IF (@IdentIFicationIdCountry IS NULL or @IdentIFicationIdCountry = @IdCountry)  --Si la IdentIFicación es null o es igual a IdCountry, la regla no aplica, borrarla
				OR @IdentIFicationIdCountry = (SELECT [Value] FROM dbo.GlobalAttributes WITH (NOLOCK) WHERE [Name] = 'IdCountryUSA') --Tampoco es valida si la IdentIFicación es de USA
			BEGIN 
				Delete @Rules WHERE Id=@Id;
				SET @Id=@Id+1;
				SET @TotalAmount=0;
				Continue; --Continuamos con la siguiente iteración
			END 
		END --END IF @ActionRule = 'CountyIdentIFication'

		IF @ActorRule = 'AverageCustomer'
		BEGIN		
			DECLARE @SentAverage decimal(18,2);
			SELECT @SentAverage = SentAverage FROM dbo.Customer WITH (NOLOCK) WHERE IdCustomer = @IdCustomer; /*st_GetCustomerSentAverage*/
			IF (@DateOfLastTransfer IS NULL or @AmountInDollars <=@SentAverage*@Factor) 
			-- Si el customer nunca ha realizado un envío, ignorar esta regla
			-- O si la cantidad en dolares es menor o igual al promedio por el factor de la regla(@SentAverage*@Factor) la regla no aplica, borrarla
			BEGIN
				Delete @Rules WHERE Id=@Id;
				SET @Id=@Id+1;
				SET @TotalAmount=0; 
				Continue; --Continuamos con la siguiente iteración
			END
		END --END IF @ActionRule = 'AverageCustomer'
	
		IF @ActorRule = 'Transfer' 
		BEGIN

			--Validar agencia
			DECLARE @ruleValid INT;
			IF(@IdAgentRule IS NULL)
			BEGIN
				SET @ruleValid = 1;
			END
			ELSE
			BEGIN
				IF(@IdAgentRule = @IdAgent)
				BEGIN
					SET @ruleValid = 1;
				END
				ELSE
				BEGIN
					SET @ruleValid = 0;
				END
			END

			IF(@ruleValid = 1)
			BEGIN
				DECLARE @TransferAgentTemp TABLE(
					IdTransfer INT,
					IdPayer INT,
					IdPaymentType INT,
					IdGateway INT, 
					IdCountryCurrency INT,
					TransferAmount MONEY,
					DateOfTransfer DATETIME
				);
				delete @TransferAgentTemp
		
				DECLARE @TransferFilterTemp TABLE(
					transferAmount MONEY
				);
				delete @TransferFilterTemp;
				DECLARE @DateTRansfer DATETIME;
				SET @DateTRansfer = getDate();
		
		
				DECLARE @transfeAmount MONEY;
				SET @transfeAmount = Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN @AmountInDollars ELSE @AmountInMN END;

				IF (@TimeInDaysRule IS NULL)
				BEGIN
					SET @DateTRansfer = null;
			
					-- Se obtinen las ultimas * transferencias del cliente
					INSERT INTO @TransferAgentTemp
					(
						IdTransfer, 
						IdPayer,
						IdPaymentType,
						IdGateway, 
						IdCountryCurrency,
						TransferAmount,
						DateOfTransfer
					) 
					SELECT TOP (@transfers) 
						t.IdTransfer, 
						t.IdPayer, 
						t.IdPaymentType, 
						t.IdGateway, 
						t.IdCountryCurrency, 
						CASE WHEN @IdCountryCurrencyRule = @GlobalIDUSacurrency 
							THEN (t.AmountInDollars+ISNULL(t.Fee,0)) /*S50*/
							ELSE (t.AmountInMN+(ISNULL(t.Fee,0)*ISNULL(t.ExRate,0)))  /*S50*/
						END AS TransferAmount, 
						t.DateOfTransfer
					FROM dbo.[Transfer] t WITH (NOLOCK)
					WHERE 
						t.IdAgent = @IdAgent 
						AND t.IdStatus NOT IN (SELECT IdStatus FROM @SkippedStatus)
						AND T.IdTransfer NOT IN (@IdTransferOriginal)
					ORDER BY DateOfTransfer desc; -- Todos los status menos Cacelado y rechazado

				
					INSERT INTO @TransferFilterTemp	(TransferAmount	) 
					SELECT tem.TransferAmount 
					FROM @TransferAgentTemp tem
						JOIN dbo.CountryCurrency cc WITH (NOLOCK) ON tem.IdCountryCurrency = cc.IdCountryCurrency
					WHERE 
						tem.TransferAmount > isnull(@AmountRule, TransferAmount) 
						AND @transfeAmount > isnull(@AmountRule, @transfeAmount) 
						AND DateOfTransfer >= isnull(@DateTRansfer, DateOfTransfer) 
						AND IdPayer = isnull(@IdPayerRule, IdPayer) 
						AND IdPaymentType = isnull(@IdPaymentTypeRule, IdPaymentType) 
						AND IdGateway = isnull(@IdGatewayRule, IdGateway) 
						AND cc.IdCountry = isnull(@IdCountryRule, cc.IdCountry);

				END
				else
				BEGIN 
					--SET @DateTRansfer = DateAdd(day, -@TimeInDaysRule, getDate())
					--Add CalENDar Date
					SET @DateTRansfer =  DATEADD(dd,-@TimeInDaysRule+1,dbo.RemoveTimeFROMDATETIME(getdate()))
			
					-- Se obtinen las ultimas * transferencias del cliente
			
					INSERT INTO @TransferAgentTemp
					(
						IdTransfer, 
						IdPayer,
						IdPaymentType,
						IdGateway, 
						IdCountryCurrency,
						TransferAmount,
						DateOfTransfer
					) 
					SELECT 
						t.IdTransfer, 
						t.IdPayer, 
						t.IdPaymentType, 
						t.IdGateway, 
						t.IdCountryCurrency, 
						CASE WHEN @IdCountryCurrencyRule = @GlobalIDUSacurrency 
							THEN (t.AmountInDollars+ISNULL(t.Fee,0)) /*S50*/
							ELSE (t.AmountInMN+(ISNULL(t.Fee,0)*ISNULL(t.ExRate,0)))  /*S50*/
						END AS TransferAmount, 
						t.DateOfTransfer
					FROM dbo.[Transfer] t WITH (NOLOCK)
						JOIN dbo.CountryCurrency cc WITH (NOLOCK) ON t.IdCountryCurrency = cc.IdCountryCurrency
					WHERE 
						@transfeAmount > isnull(@AmountRule, @transfeAmount) 
						AND DateOfTransfer >= isnull(@DateTRansfer, DateOfTransfer) 
						AND IdPayer = isnull(@IdPayerRule, IdPayer) 
						AND IdPaymentType = isnull(@IdPaymentTypeRule, IdPaymentType) 
						AND IdGateway = isnull(@IdGatewayRule, IdGateway) 
						AND cc.IdCountry = isnull(@IdCountryRule, cc.IdCountry)
						AND t.IdAgent = @IdAgent AND t.IdStatus not in (SELECT IdStatus FROM @SkippedStatus)
						AND T.IdTransfer NOT IN (@IdTransferOriginal)
					ORDER BY DateOfTransfer desc;
				
					INSERT INTO @TransferFilterTemp (TransferAmount)
					SELECT top (@transfers) TransferAmount 
					FROM @TransferAgentTemp 
					WHERE TransferAmount > isnull(@AmountRule, TransferAmount);
				END
			
				IF (not EXISTS (SELECT 1 FROM @TransferAgentTemp))
				BEGIN
					Delete @Rules WHERE Id=@Id;
					SET @Id=@Id+1;
					Continue; --Continuamos con la siguiente iteración
				END
				else
				BEGIN 
					IF (SELECT count(*) FROM @TransferFilterTemp) < @Transfers
					BEGIN
						Delete @Rules WHERE Id=@Id;
						SET @Id=@Id+1;
						Continue; --Continuamos con la siguiente iteración
					END
				END
			END
			ELSE
			BEGIN
				Delete @Rules WHERE Id=@Id;
				SET @Id=@Id+1;
				Continue; --Continuamos con la siguiente iteración
			END
		END 

	 ---------------- Get the Amount Limit AND Days to Add to Ask Id----------------------------
		IF @AgentAmountRule=1
		SELECT @AmountRule = AmountRequiredToAskId FROM dbo.Agent WITH (NOLOCK) WHERE IdAgent = @IdAgent;
	 -------------------------------------------------------------------------------------------
	
		IF @SymbolRule='>'
		BEGIN
			IF @IdCountryCurrencyRule=@GlobalIDUSacurrency
			BEGIN
				IF (@TotalAmount+@AmountInDollars) <=@AmountRule
				BEGIN
					Delete @Rules WHERE Id=@Id;
				END 
			END
			Else
			BEGIN
				IF (@TotalAmount+(@AmountInMN /*- (ISNULL(@Fee,0)*ISNULL(@ExRate,0))*/)) <= @AmountRule
				BEGIN
					Delete @Rules WHERE Id=@Id;
				END
			END
		END

		IF @SymbolRule='<'
		BEGIN

			IF @IdCountryCurrencyRule=@GlobalIDUSacurrency
			BEGIN
				IF (@TotalAmount+@AmountInDollars) >=@AmountRule
				BEGIN
					Delete @Rules WHERE Id=@Id;
				END
			END
			Else
			BEGIN
				IF (@TotalAmount+(@AmountInMN/*- (ISNULL(@Fee,0)*ISNULL(@ExRate,0))*/)) >= @AmountRule
				BEGIN
					Delete @Rules WHERE Id=@Id;
				END
			END
		END

	 ------------------ Las reglas que se borran son las que no se cumplen ------------------------

		SET @Id=@Id+1
		SET @TotalAmount=0
	END --END While EXISTS (SELECT 1 FROM @Rules WHERE @Id<=Id)

----------------------------------------------------  black list --------------------------------------------------

	INSERT INTO @Rules (IdRule,RuleName,Action,MessageInEnglish,MessageInSpanish,IsDenyList,IsBlackList)
	SELECT b.IdCustomerBlackListRule,RuleNameInEnglish RuleName,r.IdCBLaction [Action],MessageInEnglish,MessageInSpanish,0 IsDenyList,1 IsBlackList
	FROM dbo.CustomerBlackList b WITH (NOLOCK)
		LEFT JOIN dbo.CustomerBlackListRule r WITH (NOLOCK) on b.IdCustomerBlackListRule=r.idcustomerblacklistrule
	WHERE 
		r.idgenericstatus=1 AND b.idgenericstatus=1 AND b.idcustomer=@IdCustomer;

------------------------------------------- END black list --------------------------------------------------------


----------------------------------------- variables for Deny List -----------------------------------------------

	DECLARE @CustomerIdKYCAction INT;
	DECLARE @BeneficiaryIdKYCAction INT;
	DECLARE @DenyListMessageInSpanish nVARCHAR(MAX);
	DECLARE @DenyListMessageInEnglish nVARCHAR(MAX);
	SET @CustomerIdKYCAction=0;
	SET @BeneficiaryIdKYCAction=0;

	IF (@FromBill = 0)
	BEGIN
		--------------------------- Deny List for customer -------------------------------------------------------------------------------------
		/*Start - 240520190150_azavala*/
		DECLARE @tempCustomer TABLE    
		(  
			Id INT,  
			[Name] VARCHAR(MAX),  
			[FirstLastName] VARCHAR(MAX),  
			[SecondLastName] VARCHAR(MAX),
			[Address] VARCHAR(MAX),
			[City] VARCHAR(MAX),
			[State] VARCHAR(MAX)
		)

		INSERT INTO @tempCustomer (Id,[Name], [FirstLastName],SecondLastName,[Address],[City],[State])
		SELECT C.IdCustomer, [Name], FirstLastName, SecondLastName, [Address], [City], [State] 
		FROM dbo.Customer C WITH(NOLOCK) 
			INNER JOIN dbo.DenyListCustomer D WITH(NOLOCK) on C.IdCustomer=D.IdCustomer
		WHERE 
			D.IdGenericStatus=1 AND C.IdCustomer=@IdCustomer;

		IF NOT EXISTS (SELECT 1 FROM @tempCustomer)
		BEGIN
			IF(ISNULL(@IdCustomer,0)!=0)
			BEGIN
				INSERT INTO @tempCustomer (Id,[Name], [FirstLastName],SecondLastName,[Address],[City],[State])
				SELECT t.IdCustomer, Cu.[Name], Cu.FirstLastName, Cu.SecondLastName, Cu.[Address], Cu.[City], Cu.[State] FROM 
				(SELECT C.IdCustomer, C.[Name], C.FirstLastName, C.SecondLastName, C.[Address], C.[City], C.[State] 
				FROM dbo.Customer C WITH(NOLOCK) INNER JOIN dbo.DenyListCustomer D WITH(NOLOCK) on C.IdCustomer=D.IdCustomer
				WHERE D.IdGenericStatus=1 AND C.FullName=@CustomerFullName) t, Customer Cu WITH(NOLOCK)
				WHERE Cu.IdCustomer=@IdCustomer AND t.[Address]=@CustomerAddress AND t.City=@CustomerCity AND t.[State]=@CustomerStateO;
			END
			ELSE
			BEGIN
				INSERT INTO @tempCustomer (Id,[Name], [FirstLastName],SecondLastName,[Address],[City],[State])
				SELECT t.IdCustomer, Cu.[Name], Cu.FirstLastName, Cu.SecondLastName, Cu.[Address], Cu.[City], Cu.[State] FROM 
				(SELECT C.IdCustomer, C.[Name], C.FirstLastName, C.SecondLastName, C.[Address], C.[City], C.[State] 
				FROM dbo.Customer C WITH(NOLOCK) INNER JOIN dbo.DenyListCustomer D WITH(NOLOCK) on C.IdCustomer=D.IdCustomer
				WHERE D.IdGenericStatus=1 AND C.FullName=@CustomerFullName) t left join dbo.Customer Cu WITH(NOLOCK) on Cu.IdCustomer=t.IdCustomer
				WHERE t.[Name]=@CustomerName AND t.[FirstLastName]=@CustomerFirstLastName AND t.[SecondLastName]=@CustomerSecondLastName AND t.[Address]=@CustomerAddress AND t.City=@CustomerCity AND t.[State]=@CustomerStateO
			END
		END
		/*END - 240520190150_azavala*/

		INSERT INTO @Rules (RuleName,[Action],MessageInEnglish,MessageInSpanish,IsDenyList, SSNRequired, OccupationRequired, IdTypeRequired, IdNumberRequired, IdExpirationDateRequired, IdStateCountryRequired, DateOfBirthRequired)
		SELECT
			'Deny List' as RuleName,
			C.IdKYCAction,
			C.MessageInEnglish,
			C.MessageInSpanish,
			1 as IsDenyList,
			C.SSNRequired,
			C.OccupationRequired,
			C.IdTypeRequired,
			C.IdNumberRequired,
			C.IdExpirationDateRequired,
			C.IdStateCountryRequired,
			C.DateOfBirthRequired
		FROM dbo.DenyListCustomer A WITH (NOLOCK)
			JOIN dbo.Customer B WITH (NOLOCK) ON (B.IdCustomer=A.IdCustomer)
			JOIN dbo.DenyListCustomerActions C WITH (NOLOCK) ON (C.IdDenyListCustomer=A.IdDenyListCustomer)
			join @tempCustomer t on t.id=B.IdCustomer --240520190150_azavala
		WHERE A.IdGenericStatus=1 AND (B.FullName=@CustomerFullName OR t.Id=@IdCustomer); --jrivera

	END


-------------------------- Deny List for Beneficiary ------------------------------------------------------------------------------------

	/*Start - 240520190150_azavala*/
	DECLARE @tempBeneficiary TABLE    
	(  
		Id INT,  
		[Name] VARCHAR(MAX),  
		[FirstLastName] VARCHAR(MAX),  
		[SecondLastName] VARCHAR(MAX),
		[Address] VARCHAR(MAX),
		[City] VARCHAR(MAX),
		[State] VARCHAR(MAX)
	);

	INSERT INTO @tempBeneficiary (Id,[Name], [FirstLastName],SecondLastName,[Address],[City],[State])
	SELECT B.IdBeneficiary, [Name], FirstLastName, SecondLastName, [Address], [City], [State] 
	FROM dbo.Beneficiary B WITH(NOLOCK) INNER JOIN dbo.DenyListBeneficiary D WITH(NOLOCK) on B.IdBeneficiary=D.IdBeneficiary
	WHERE D.IdGenericStatus=1 AND B.IdBeneficiary=@IdBeneficiary;

	IF not EXISTS (SELECT 1 FROM @tempBeneficiary)
	BEGIN
		IF(ISNULL(@IdBeneficiary,0)!=0)
		BEGIN
			--INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) values ('st_EvaluateKYCRule', GETDATE(),'IdBeneficiary is not 0');

			INSERT INTO @tempBeneficiary (Id,[Name], [FirstLastName],SecondLastName,[Address],[City],[State])
			SELECT t.IdBeneficiary, Be.[Name], Be.FirstLastName, Be.SecondLastName, Be.[Address], Be.[City], Be.[State] FROM 
			(SELECT B.IdBeneficiary, B.[Name], B.FirstLastName, B.SecondLastName, B.[Address], B.[City], B.[State] 
			FROM dbo.Beneficiary B WITH(NOLOCK) INNER JOIN dbo.DenyListBeneficiary D WITH(NOLOCK) on B.IdBeneficiary=D.IdBeneficiary
			WHERE D.IdGenericStatus=1 AND B.FullName=@BeneficiaryFullName) t, dbo.Beneficiary Be WITH(NOLOCK)
			WHERE Be.IdBeneficiary=@IdBeneficiary AND t.[Address]=@BeneficiaryAddress AND t.City=@BeneficiaryCity AND t.[State]=@BeneficiaryState;
		END
		ELSE
		BEGIN 
			--INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) values ('st_EvaluateKYCRule', GETDATE(),'IdBeneficiary is 0');

			INSERT INTO @tempBeneficiary (Id,[Name], [FirstLastName],SecondLastName,[Address],[City],[State])
			SELECT t.IdBeneficiary, Be.[Name], Be.FirstLastName, Be.SecondLastName, Be.[Address], Be.[City], Be.[State] FROM 
			(SELECT B.IdBeneficiary, B.[Name], B.FirstLastName, B.SecondLastName, B.[Address], B.[City], B.[State] 
			FROM dbo.Beneficiary B WITH(NOLOCK) INNER JOIN dbo.DenyListBeneficiary D WITH(NOLOCK) on B.IdBeneficiary=D.IdBeneficiary
			WHERE D.IdGenericStatus=1 AND B.FullName=@BeneficiaryFullName) t left join dbo.Beneficiary Be WITH(NOLOCK) on Be.IdBeneficiary=t.IdBeneficiary
			WHERE t.[Name]=@BeneficiaryName AND t.[FirstLastName]=@BeneficiaryFirstLastName AND t.[SecondLastName]=@BeneficiarySecondLastName AND t.[Address]=@BeneficiaryAddress AND t.City=@BeneficiaryCity AND t.[State]=@BeneficiaryState;
			--WHERE t.[Name]=@BeneficiaryName AND t.[FirstLastName]=@BeneficiaryFirstLastName AND t.[SecondLastName]=@BeneficiarySecondLastName AND t.[Address]=ISNULL(@BeneficiaryAddress, '') AND t.City=ISNULL(@BeneficiaryCity, '') AND t.[State]=ISNULL(@BeneficiaryState, '')
		END
	END
	/*END - 240520190150_azavala*/

	INSERT INTO @Rules (RuleName,[Action],MessageInEnglish,MessageInSpanish,IsDenyList, SSNRequired, OccupationRequired, IdTypeRequired, IdNumberRequired, IdExpirationDateRequired, IdStateCountryRequired, DateOfBirthRequired)
	SELECT
		'Deny List' as RuleName,
		IdKYCAction,
		MessageInEnglish,
		MessageInSpanish,
		1 as IsDenyList,
		C.SSNRequired,
		C.OccupationRequired,
		C.IdTypeRequired,
		C.IdNumberRequired,
		C.IdExpirationDateRequired,
		C.IdStateCountryRequired,
		C.DateOfBirthRequired
	FROM dbo.DenyListBeneficiary A WITH (NOLOCK)
		JOIN dbo.Beneficiary B WITH (NOLOCK) ON (B.IdBeneficiary=A.IdBeneficiary)
		JOIN dbo.DenyListBeneficiaryActions C WITH (NOLOCK) on (C.IdDenyListBeneficiary=A.IdDenyListBeneficiary)
		join @tempBeneficiary t on t.id=B.IdBeneficiary --240520190150_azavala
	WHERE 
		A.IdGenericStatus=1 AND B.IdBeneficiary = @IdBeneficiary; --B.FullName=@BeneficiaryFullName /*M00234-Ticket:2278*/

/*
IF @IdCountryCurrency=8 AND getdate()>dateadd(hour,13,dbo.RemoveTimeFROMDATETIME(getdate()))
BEGIN
    INSERT INTO @Rules
    (RuleName,Action,MessageInSpanish,MessageInEnglish,IsDenyList,SSNRequired)
    values
    ('Horario Honduras',5,'No se pueden llevar a cabo envios a Honduras(Lempira) despues de las 22:00','You can''t sent transfers to Honduras(Lempira) after 22:00',0,0)
END
*/

	IF EXISTS(SELECT 1 FROM @Rules WHERE IsBlackList=1)
	BEGIN
		UPDATE @Rules SET IsBlackList=1;
	END

	SELECT 
		IdRule,
		RuleName,
		[Action],
		MessageInSpanish,
		MessageInEnglish,
		IsDenyList,
		SSNRequired,
		OccupationRequired,
		IsBlackList, 
		ComplianceFormatId, 
		ComplianceFormatName, /*>> S35*/
		IdTypeRequired,
		IdNumberRequired,
		IdExpirationDateRequired,
		IdStateCountryRequired,
		DateOfBirthRequired
		/*<< S35*/
	FROM @Rules;

	
	
	DECLARE @ENDproceduretime DATETIME = getdate();
	IF (DATEDIFF(MILLISECOND,@initializetime,@ENDproceduretime) > 2000) BEGIN 
		INSERT INTO dbo.ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) 
		VALUES ('st_EvaluateKYCRule', getdate(),CONVERT(VARCHAR,DATEDIFF(millisecond,@initializetime,@ENDproceduretime))+'ms '+@SUPERTEXT);
	END 
	
END TRY
BEGIN Catch    
	DECLARE @ErrorMessage VARCHAR(MAX);                                                                 
    SELECT @ErrorMessage=ERROR_MESSAGE();   

    INSERT INTO dbo.ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_EvaluateKYCRule',Getdate(),@ErrorMessage);
END catch
