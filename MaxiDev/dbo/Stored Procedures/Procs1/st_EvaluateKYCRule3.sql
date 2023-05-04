CREATE PROCEDURE [dbo].[st_EvaluateKYCRule3]
(
@CustomerName nvarchar(max),
@CustomerFirstLastName nvarchar(max),
@CustomerSecondLastName nvarchar(max),
@BeneficiaryName nvarchar(max),
@BeneficiaryFirstLastName nvarchar(max),
@BeneficiarySecondLastName nvarchar(max),
@IdPayer int,
@IdPaymenttype int,
@IdAgent int,
@IdCountry int,
@IdGateway int,
@IdCustomer int,
@IdBeneficiary int,
@AmountInDollars money,
@AmountInMN money,
@IdCountryCurrency int

,@IdBranch int = NULL /*S49*/
,@IdCity int = NULL	/*S49*/

,@Fee MONEY = NULL	/*S50*/
,@ExRate MONEY = NULL	/*S50*/
,@IdState int = null

)
AS

/**/
/**/

Set nocount on
SET ARITHABORT ON

Begin try

									
		
/*Quitar en produccion*/
/*--------------------*/
--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
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
Declare @CustomerFullName nvarchar(120)
Declare @BeneficiaryFullName nvarchar(120)

Set @CustomerFullName=REPLACE ( Substring(@CustomerName,1,40)+Substring(@CustomerFirstLastName,1,40)+Substring(@CustomerSecondLastName,1,40), ' ','')
Set @BeneficiaryFullName =REPLACE ( Substring(@BeneficiaryName,1,40)+Substring(@BeneficiaryFirstLastName,1,40)+Substring(@BeneficiarySecondLastName,1,40), ' ','')

--------------------- Add Fee to Amount --------------------------------------------------------------------

SET @AmountInDollars = (@AmountInDollars + ISNULL(@Fee,0)); /*S50*/
SET @AmountInMN = (@AmountInMN + (ISNULL(@Fee,0)*ISNULL(@ExRate,0))); /*S50*/

--------------------- Id currency usa and country usa -------------------------------------------------------
Declare @GlobalIDUSacurrency int
Select @GlobalIDUSacurrency=convert(int,Value) from GlobalAttributes where Name='IdCountryCurrencyDollars'

   select 
    @IdState= s.IdState  
   from 
    Agent a 
   inner join 
    State s 
   on 
    a.AgentState = s.StateCode 
   where 
    a.IdAgent = @IdAgent 


-----------------------------Tabla temporal de reglas-----------------------------------------
Declare @Rules Table
				(
				Id int identity(1,1),
				IdRule int,
				RuleName nvarchar(max),
				IdPayer int,
				IdPaymentType int,
				IdAgent int,
				IdCountry int,
				IdGateway int,
				Actor nvarchar(max),
				Symbol nvarchar(max),
				Amount money,
				AgentAmount bit,
				IdCountryCurrency int,
				TimeInDays int,
				Action int,
				MessageInSpanish nvarchar(max),
				MessageInEnglish nvarchar(max),
				IsDenyList bit,
				Factor Decimal (18,2),
				SSNRequired bit not null default 0,
				OccupationRequired BIT NOT NULL DEFAULT 0,
				IsConsecutive bit not null default 0,
                IsBlackList bit not null default 0,
				Transfers int,
				ComplianceFormatId INT,
				ComplianceFormatName NVARCHAR(MAX),
				IdState   int
				)

------------------------ Se cargan las reglas, sólo aquellas que aplicaran ---------------
Insert into @Rules
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
				Action,
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
				)
Select
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
FROM [dbo].[KYCRule] KYCR (NOLOCK)
LEFT JOIN [dbo].[ComplianceFormat] CF (NOLOCK) ON KYCR.[ComplianceFormatId] = CF.[ComplianceFormatId]
WHERE
		(IdPayer=@IdPayer or IdPayer is NULL) 		
		And (IdCountryCurrency=@GlobalIDUSacurrency or IdCountryCurrency=@IdCountryCurrency or IdCountryCurrency is NULL)
		And (IdPaymentType=@IdPaymenttype or IdPaymentType is NULL)
		And (IdAgent=@IdAgent or IdAgent is NULL)
		AND (IdCountry=@IdCountry or IdCountry is NULL)
		AND (IdGateway=@IdGateway or IdGateway is NULL)
		And IdGenericStatus=1 and IsExpire=0
	    AND (IdState=@IdState or IdState is NULL)

Insert into @Rules
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
				Action,
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
				)
Select
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
	FROM [dbo].[KYCRule] KYCR (NOLOCK)
	LEFT JOIN [dbo].[ComplianceFormat] CF (NOLOCK) ON KYCR.[ComplianceFormatId] = CF.[ComplianceFormatId]
	WHERE
		(IdPayer=@IdPayer or IdPayer is NULL) 		
		And (IdCountryCurrency=@GlobalIDUSacurrency or IdCountryCurrency=@IdCountryCurrency or IdCountryCurrency is NULL)
		And (IdPaymentType=@IdPaymenttype or IdPaymentType is NULL)
		And (IdAgent=@IdAgent or IdAgent is NULL)
		AND (IdCountry=@IdCountry or IdCountry is NULL)
		AND (IdGateway=@IdGateway or IdGateway is NULL)
		And IdGenericStatus=1 and IsExpire=1 and ExpirationDate>=getdate()
	    AND (IdState=@IdState or IdState is NULL)
--and IdRule >100

--------------------- Si existe regla de beneficiario entonces llenar temporal de beneficiario---------------

If EXISTS (Select 1 From @rules Where Actor='Beneficiary')
Begin

	Declare @Beneficiary Table (IdBeneficiary int)

	Insert into @Beneficiary (IdBeneficiary)
	Select IdBeneficiary From Beneficiary With (nolock) Where
	FullName=@BeneficiaryFullName
End

--------------------- Si existe regla de NewCustomer o InactiveCustomer     ---------------------
--------------------- entonces buscar la fecha de la última  transferencia  ---------------------

Declare @DateOfLastTransfer datetime
Declare @FolioOfLastTransfer int
Declare @AmountOfLastTransfer money 
Declare @BeneficiaryOfLastTransfer varchar(max)
Declare @ClaimCode varchar(max)
If EXISTS (Select 1 From @rules Where Actor='NewCustomer' or Actor='InactiveCustomer' or Actor='AverageCustomer')
Begin
	If (@IdCustomer is not null And @IdCustomer!=0)
	   Begin 
		  declare @Dates Table (
			DateOfTransfer datetime,
			Folio int,
			Amount money,
			Beneficiary varchar(max),
			ClaimCode varchar(max)
		  )
		  
		  insert into @Dates 
		  select top 1 DateOfTransfer, Folio, @AmountInDollars, CONCAT(@BeneficiaryName, ' ', BeneficiaryFirstLastName, ' ', BeneficiarySecondLastName), ClaimCode from [Transfer] With (nolock) where IdCustomer = @IdCustomer order by DateOfTransfer desc
		  
		  insert into @Dates 
		  select top 1 DateOfTransfer, Folio, @AmountInDollars, CONCAT(@BeneficiaryName, ' ', BeneficiaryFirstLastName, ' ', BeneficiarySecondLastName), ClaimCode  from [TransferClosed] With (nolock)  where IdCustomer = @IdCustomer order by DateOfTransfer desc
		  
		  select top 1 @DateOfLastTransfer = DateOfTransfer, @FolioOfLastTransfer = Folio, @AmountOfLastTransfer = Amount, @BeneficiaryOfLastTransfer = Beneficiary, @ClaimCode = ClaimCode from @Dates order by DateOfTransfer desc
	   End
End


----------------------------------------- declaración de variables -----------------------------
Declare @Id int,
@IdPayerRule int,
@IdPaymentTypeRule int,
@ActorRule nvarchar(max),
@SymbolRule nvarchar(max),
@AmountRule money,
@AgentAmountRule bit,
@IdCountryCurrencyRule int,
@TimeInDaysRule int,
@ActionRule int,
@TotalAmount money,
@TotalAmount2 money,
@Factor Decimal (18,2),
@IsConsecutive bit, 
@Transfers int,
@IdAgentRule int,
@IdGatewayRule int,
@IdCountryRule int

Set @Id=1

declare @TBen table
(
    AmountInDollars money,
    AmountInMN money,
	
	DateOfTransfer datetime,
    IdPayer int,
    IdPaymentType int

	/*Semana 49*/
	/*---------*/
	,[IdCustomer] int
	,[CustomerFullName] varchar(250)  DEFAULT(NULL)
	,[CustomerState] varchar(250)  DEFAULT(NULL)

	,[IdBeneficiary] int
	
	,[IdAgent] int
	,[AgentState] varchar(250)  DEFAULT(NULL)
	,[AgentZipCode] varchar(12)  DEFAULT(NULL)

	,[IdBranch] int
	,[BranchState] varchar(250)  DEFAULT(NULL)
	,[BranchCity] varchar(250)  DEFAULT(NULL)
	,[BranchCountry] varchar(250)  DEFAULT(NULL)


	,[ClaimCode] varchar(50)

	,[KYCRule] int  DEFAULT(0)
	/*---------*/
)
declare @TCus table
(
    AmountInDollars money,
    AmountInMN money,

	DateOfTransfer datetime,
    IdPayer int,
    IdPaymentType int
)

declare @MaxTimeInDays int 
select @MaxTimeInDays=max(TimeInDays) from @Rules where TimeInDays is not null
set @MaxTimeInDays=isnull(@MaxTimeInDays,0)

        insert into @TBen (	AmountInDollars, AmountInMN, DateOfTransfer, IdPayer, IdPaymentType, [IdCustomer], [CustomerState], [IdBeneficiary], [IdAgent], [IdBranch], [ClaimCode]	)
        Select 
			(T.AmountInDollars+ISNULL(T.Fee,0)) AS AmountInDollars /*S49,50*/
			,(T.AmountInMN+(ISNULL(T.Fee,0)*ISNULL(T.ExRate,0))) AS AmountInMN /*S49,50*/
			,T.DateOfTransfer,T.IdPayer,T.IdPaymenttype
			, T.IdCustomer, UPPER(LTRIM(RTRIM(T.CustomerState))) AS CustomerState, T.IdBeneficiary, T.IdAgent, T.IdBranch, T.ClaimCode /*S46*/
		From Transfer AS T With (nolock)
		Where 
			IdBeneficiary in (Select IdBeneficiary From @Beneficiary) And
			DATEDIFF (day,DateOfTransfer,GETDATE() ) <= @MaxTimeInDays And
			IdStatus Not In (22,31 )
        union all
		Select 
			(TC.AmountInDollars+ISNULL(TC.Fee,0)) AS AmountInDollars /*S49,50*/
			,(TC.AmountInMN+(ISNULL(TC.Fee,0)*ISNULL(TC.ExRate,0))) AS AmountInMN /*S49,50*/
			,TC.DateOfTransfer,TC.IdPayer,TC.IdPaymenttype
			, TC.IdCustomer, UPPER(LTRIM(RTRIM(TC.CustomerState))) AS CustomerState, TC.IdBeneficiary, TC.IdAgent, TC.IdBranch, TC.ClaimCode /*S46*/
		From TransferClosed  AS TC With (nolock)
		Where 
			IdBeneficiary in (Select IdBeneficiary From @Beneficiary) And
			DATEDIFF (day,DateOfTransfer,GETDATE() ) <= @MaxTimeInDays And
			IdStatus Not In (22,31 )

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
			FROM @TBen AS T
				Inner Join Customer AS C ON T.IdCustomer = C.IdCustomer
				Inner Join Agent AS A ON T.IdAgent = A.IdAgent
				Inner Join Branch AS B ON T.IdBranch = B.IdBranch
					Inner Join City AS Cy ON B.IdCity = Cy.IdCity
					Inner Join State AS S ON Cy.IdState = S.IdState
					Inner Join Country AS Ct ON S.IdCountry = Ct.IdCountry
		)UPDATE B 
			SET
				CustomerFullName = C.CustomerFullName

				,AgentState = C.AgentState
				,AgentZipCode = C.AgentZipCode

				,BranchState = C.BranchState
				,BranchCity = C.BranchCity
				,BranchCountry = C.BranchCountry

			FROM  @TBen AS B
				Inner Join CTE_BEN AS C ON B.ClaimCode = C.ClaimCode;

		/*PASO 2: Obtencion de valores de referencia para la evaluacion*/
		Declare 
		@AgentState varchar(150) = NULL
		,@AgentZipCode varchar(150) = NULL

		,@CustomerState varchar(150) = NULL

		,@BranchState varchar(150) = NULL
		,@BranchCity varchar(150) = NULL
		,@BranchCountry varchar(150) = NULL;

		/*PASO 2.1:Obtiene datos del agente*/
		SELECT TOP 1
			@AgentState = A.AgentState
			,@AgentZipCode = A.AgentZipcode
		FROM Agent AS A WITH(NOLOCK)
			WHERE A.IdAgent = @IdAgent;

		/*Obtiene estado del cliente*/
		SELECT TOP 1
			@CustomerState = C.State
		FROM Customer AS C WITH(NOLOCK)
			WHERE C.IdCustomer = @IdCustomer;

		/*PASO 2.2:Validacion de punto de pago y lo busca de ser necesario(default)*/
		/*----- Special case when Idbranch is null but transfer is cash ----------------*/
		If ((@IdBranch is null or @IdBranch=0) and (@IdPaymentType=1 or @IdPaymentType=4 or @IdPaymentType=2))
		Begin
		 If @IdCity is Null
		 Begin
			Select top 1 @IdBranch=IdBranch from Branch with(nolock) where IdPayer=@IdPayer and (IdGenericStatus=1 or IdGenericStatus is null)  order by IdBranch
		 End
		 Else
		 Begin
		  Select top 1 @IdBranch=IdBranch from Branch with(nolock) where IdPayer=@IdPayer and (IdGenericStatus=1 or IdGenericStatus is null) and IdCity=@IdCity order by IdBranch
		 End                                
		End   

		-- Check Again IdBranch in case @IdCity was not null but not exists
		If ((@IdBranch is null or @IdBranch=0) and (@IdPaymentType=1 or @IdPaymentType=4 or @IdPaymentType=2))
		Begin
		  Select top 1 @IdBranch=IdBranch from Branch with(nolock) where IdPayer=@IdPayer and (IdGenericStatus=1 or IdGenericStatus is null)  order by IdBranch
		End  
		
		/*PASO 2.3:Obtiene datos del punto de pago*/
		SELECT TOP 1
			@BranchState = S.StateName
			,@BranchCity = Cy.CityName
			,@BranchCountry = C.CountryName
		FROM Branch AS B  WITH(NOLOCK)
			Inner Join City AS Cy  WITH(NOLOCK) ON B.IdCity = Cy.IdCity
			Inner Join State AS S  WITH(NOLOCK) ON Cy.IdState = S.IdState
			Inner Join Country AS C  WITH(NOLOCK) ON S.IdCountry = C.IdCountry
		WHERE B.IdBranch = @IdBranch;

		/*PASO 3: Evaluacion de casos(Total de casos 8 con 2 incisos cada uno(A&B))*/
		/*CASO I-VII INCISOS A's*/
		UPDATE @TBen 
		SET
			KYCRule = 1
		WHERE
			IdBeneficiary = @IdBeneficiary
			AND KYCRule = 0;

		/*CASO I : B*/
		UPDATE @TBen 
		SET
			KYCRule = 1
		WHERE
			AgentZipcode = @AgentZipCode
			AND CustomerState = @CustomerState
			AND BranchState = @BranchState	
			AND BranchCountry = @BranchCountry
			AND KYCRule = 0;

		/*CASO II : B*/
		UPDATE @TBen 
		SET
			KYCRule = 2
		WHERE
			AgentZipcode <> @AgentZipCode
			AND CustomerState = @CustomerState
			AND BranchState = @BranchState	
			AND BranchCountry = @BranchCountry
			AND KYCRule = 0;

		/*CASO III : B*/
		UPDATE @TBen 
		SET
			KYCRule = 3
		WHERE
			AgentZipcode = @AgentZipCode
			AND CustomerState = @CustomerState
			AND BranchState <> @BranchState	
			AND BranchCountry = @BranchCountry
			AND KYCRule = 0;

		/*PASO 3.1: Descarte de trabnsaciones que no pertenecena los casos establecidos*/
		DELETE FROM @TBen WHERE KYCRule = 0;

		/*-------------------------------------------------------------------------------*/
		/*-------------------------------------------------------------------------------*/

        insert into @TCus        
        Select 
			(AmountInDollars+ISNULL(Fee,0)) AS AmountInDollars /*S50*/
			,(AmountInMN+(ISNULL(Fee,0)*ISNULL(ExRate,0))) AS AmountInMN /*S50*/
			,DateOfTransfer,IdPayer,IdPaymenttype
		From Transfer With (nolock)
		Where 
			IdCustomer = @IdCustomer And
			DATEDIFF (day,DateOfTransfer,GETDATE() ) <= @MaxTimeInDays And
			IdStatus Not In (22,31 )
        Union all
		Select 
			(AmountInDollars+ISNULL(Fee,0)) AS AmountInDollars /*S50*/
			,(AmountInMN+(ISNULL(Fee,0)*ISNULL(ExRate,0))) AS AmountInMN /*S50*/
			,DateOfTransfer,IdPayer,IdPaymenttype
		From TransferClosed With (nolock)
		Where 
			IdCustomer = @IdCustomer And
			DATEDIFF (day,DateOfTransfer,GETDATE() ) <= @MaxTimeInDays And
			IdStatus Not In (22,31)
        union all
        Select 
			(ReceiptAmount + ISNULL(Fee,0)) AS AmountInDollars /*S50*/
			,0 AS AmountInMN
			,PaymentDate AS DateOfTransfer,null AS IdPayer,@IdPaymenttype AS IdPaymenttype 
		From BillPaymentTransactions 
		Where customerid=@IdCustomer and status=1 and DATEDIFF (day,PaymentDate,GETDATE() ) <= @MaxTimeInDays
        
---------------------------------- Inicia ciclo principal de evaluacion de Reglas ---------------

While exists (Select 1 from @Rules where @Id<=Id)
Begin
	--Select * from @Rules where @Id<=Id --TODO Remove this query	

	Select
	@IdPayerRule=IdPayer,
	@IdPaymentTypeRule=IdPaymentType,
	@ActorRule=Actor,
	@SymbolRule=Symbol,
	@AmountRule=Amount,
	@AgentAmountRule=AgentAmount,
	@IdCountryCurrencyRule=IdCountryCurrency,
	@TimeInDaysRule=TimeInDays,
	@ActionRule=Action,
	@Factor=factor,
	@IsConsecutive = IsConsecutive, 
	@Transfers = Transfers,
	@IdAgentRule = IdAgent,
	@IdGatewayRule = IdGateway,
	@IdCountryRule = IdCountry
	From @Rules Where Id=@Id

	Set @TotalAmount=0
	
	
	
	SELECT * FROM @TBen
	If @ActorRule = 'Beneficiary' And @TimeInDaysRule>0
	Begin

		Select @TotalAmount= ISNULL( Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN SUM( AmountInDollars) ELSE SUM( AmountInMN) END , 0)
		From @TBen
		Where 
			isnull(IdPayer,0) = Case When @IdPayerRule IS NULL THEN isnull(IdPayer,0) ELSE @IdPayer END And
			isnull(IdPaymentType,0) = Case When @IdPaymentTypeRule IS not NULL Then @IdPaymentType Else isnull(IdPaymentType,0) End And
			DATEDIFF (day,DateOfTransfer,GETDATE() ) <= @TimeInDaysRule

		Select @TotalAmount = @TotalAmount;
		
	End 
	
	

	If @ActorRule = 'Customer' And @TimeInDaysRule>0
	Begin
		Select @TotalAmount=ISNULL( Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN SUM( AmountInDollars) ELSE SUM( AmountInMN) END , 0)
		From @TCus
		Where 
        isnull(IdPayer,0) = Case When @IdPayerRule IS NULL THEN isnull(IdPayer,0) ELSE @IdPayer END And
		isnull(IdPaymentType,0) = Case When @IdPaymentTypeRule IS not NULL Then @IdPaymentType Else isnull(IdPaymentType,0) End And
		DATEDIFF (day,DateOfTransfer,GETDATE() ) <= @TimeInDaysRule

		Select @TotalAmount=@TotalAmount
	End

	

	If @ActorRule = 'NewCustomer' And @DateOfLastTransfer is not null--Si la regla es NewCustomer y la fecha de último envío no es null (El cliente ya ha realizado un envío) la regla no aplica, borrarla
	Begin 
		Delete @Rules Where Id=@Id
		Set @Id=@Id+1
		Set @TotalAmount=0
		Continue
	End

	If @ActorRule = 'InactiveCustomer'
	Begin
		If (@DateOfLastTransfer is null) --Si el customer nunca ha realizado un envío, ignorar esta regla
		Begin
			Delete @Rules Where Id=@Id
			Set @Id=@Id+1
			Set @TotalAmount=0
			Continue
		End

		declare @lastActivityLimit datetime
		select @lastActivityLimit= DATEADD(day,-1*@TimeInDaysRule,CONVERT(date,GETDATE()))

		declare @messageEn varchar(max)
		declare @messageEs varchar(max)
		set @messageEn = CONCAT('Claim Code: ', @ClaimCode, ', Date: ', FORMAT(@DateOfLastTransfer , 'MM/dd/yyyy HH:mm:ss'));
		set @messageEs = CONCAT('Claim Code: ', @ClaimCode, ', Fecha: ',FORMAT(@DateOfLastTransfer , 'MM/dd/yyyy HH:mm:ss') );
		
		update @Rules set MessageInSpanish = CONCAT(MessageInSpanish, ' (-Delete-!)', @messageEs, ')'), MessageInEnglish = CONCAT(MessageInEnglish, ' (-Delete-!)',@messageEn, ')') where Id = @Id

		If(@DateOfLastTransfer>=@lastActivityLimit) --Si la fecha del último envío es mayor que el limite, la regla no aplica, borrarla
		Begin
			Delete @Rules Where Id=@Id
			Set @Id=@Id+1
			Set @TotalAmount=0
			Continue
		End
	End --END If @ActionRule = 'InactiveCustomer'

	If @ActorRule = 'CountyIdentification'
	Begin
		declare @IdentificationIdCountry int 
		select @IdentificationIdCountry = IdentificationIdCountry from Customer where IdCustomer = @IdCustomer

		if (@IdentificationIdCountry is null or @IdentificationIdCountry = @IdCountry)  --Si la Identificación es null o es igual a IdCountry, la regla no aplica, borrarla
			OR @IdentificationIdCountry = (Select value from GlobalAttributes where Name = 'IdCountryUSA') --Tampoco es valida si la Identificación es de USA
		Begin 
			Delete @Rules Where Id=@Id
			Set @Id=@Id+1
			Set @TotalAmount=0
			Continue --Continuamos con la siguiente iteración
		End 
	End --END If @ActionRule = 'CountyIdentification'

	If @ActorRule = 'AverageCustomer'
	Begin		
	    declare @SentAverage decimal(18,2)
	    select @SentAverage = SentAverage from Customer where IdCustomer = @IdCustomer /*st_GetCustomerSentAverage*/
	    if (@DateOfLastTransfer is null or @AmountInDollars <=@SentAverage*@Factor) 
		-- Si el customer nunca ha realizado un envío, ignorar esta regla
		-- O si la cantidad en dolares es menor o igual al promedio por el factor de la regla(@SentAverage*@Factor) la regla no aplica, borrarla
	    Begin
	        Delete @Rules Where Id=@Id
			Set @Id=@Id+1
			Set @TotalAmount=0 
			Continue --Continuamos con la siguiente iteración
	    End
	End --END If @ActionRule = 'AverageCustomer'
	
	If @ActorRule = 'Transfer' 
	begin

		--Validar agencia
		declare @ruleValid int
		if(@IdAgentRule is null)
		begin
			set @ruleValid = 1
		END
		ELSE
		BEGIN
			if(@IdAgentRule = @IdAgent)
			begin
				set @ruleValid = 1
			END
			ELSE
			BEGIN
				set @ruleValid = 0
			END
		end

		if(@ruleValid = 1)
		BEGIN
			Declare @TransferAgentTemp Table(
				IdTransfer int,
				IdPayer int,
				IdPaymentType int,
				IdGateway int, 
				IdCountryCurrency int,
				TransferAmount money,
				DateOfTransfer datetime
			)
			delete @TransferAgentTemp
		
			Declare @TransferFilterTemp Table(
				transferAmount money
			)
			delete @TransferFilterTemp
			Declare @DateTRansfer DateTime
			set @DateTRansfer = getDate()
		
		
			declare @transfeAmount money
			set @transfeAmount = Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN @AmountInDollars ELSE @AmountInMN END

			If (@TimeInDaysRule is null)
			begin
				set @DateTRansfer = null
			
			-- Se obtinen las ultimas * transferencias del cliente
				Insert into @TransferAgentTemp
					(
					IdTransfer, 
					IdPayer,
					IdPaymentType,
					IdGateway, 
					IdCountryCurrency,
					TransferAmount,
					DateOfTransfer
					) Select top (@transfers) t.IdTransfer, t.IdPayer, t.IdPaymentType, t.IdGateway, t.IdCountryCurrency, 
						Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency 
							Then (t.AmountInDollars+ISNULL(t.Fee,0)) /*S50*/
							Else (t.AmountInMN+(ISNULL(t.Fee,0)*ISNULL(t.ExRate,0)))  /*S50*/
						End AS TransferAmount
						, t.DateOfTransfer
					from Transfer t With (nolock)
						where t.IdAgent = @IdAgent and t.IdStatus not in (22, 31) 
							order by DateOfTransfer desc -- Todos los status menos Cacelado y rechazado

				
				Insert into @TransferFilterTemp	(TransferAmount	) 
					Select tem.TransferAmount from @TransferAgentTemp tem
						join CountryCurrency cc
					on tem.IdCountryCurrency = cc.IdCountryCurrency
					where tem.TransferAmount > isnull(@AmountRule, TransferAmount) and @transfeAmount > isnull(@AmountRule, @transfeAmount) and
						DateOfTransfer >= isnull(@DateTRansfer, DateOfTransfer) and IdPayer = isnull(@IdPayerRule, IdPayer) 
						and IdPaymentType = isnull(@IdPaymentTypeRule, IdPaymentType) and IdGateway = isnull(@IdGatewayRule, IdGateway) and cc.IdCountry = isnull(@IdCountryRule, cc.IdCountry)

			end
			else
			begin 
				set @DateTRansfer = DateAdd(day, -@TimeInDaysRule, getDate())
			
				-- Se obtinen las ultimas * transferencias del cliente
			
				Insert into @TransferAgentTemp
					(
						IdTransfer, 
						IdPayer,
						IdPaymentType,
						IdGateway, 
						IdCountryCurrency,
						TransferAmount,
						DateOfTransfer
					) Select t.IdTransfer, t.IdPayer, t.IdPaymentType, t.IdGateway, t.IdCountryCurrency, 
						Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency 
						Then (t.AmountInDollars+ISNULL(t.Fee,0)) /*S50*/
						Else (t.AmountInMN+(ISNULL(t.Fee,0)*ISNULL(t.ExRate,0)))  /*S50*/
						End AS TransferAmount
						, t.DateOfTransfer
					from Transfer t With (nolock)
					join CountryCurrency cc
					on t.IdCountryCurrency = cc.IdCountryCurrency
					where @transfeAmount > isnull(@AmountRule, @transfeAmount) and DateOfTransfer >= isnull(@DateTRansfer, DateOfTransfer) and IdPayer = isnull(@IdPayerRule, IdPayer) 
					and IdPaymentType = isnull(@IdPaymentTypeRule, IdPaymentType) and IdGateway = isnull(@IdGatewayRule, IdGateway) and cc.IdCountry = isnull(@IdCountryRule, cc.IdCountry)
					and t.IdAgent = @IdAgent and t.IdStatus not in (22, 31) order by DateOfTransfer desc
				
					Insert into @TransferFilterTemp (TransferAmount)
						Select top (@transfers) TransferAmount 
							from @TransferAgentTemp 
								where TransferAmount > isnull(@AmountRule, TransferAmount)
			end
			
			if (not exists (Select 1 from @TransferAgentTemp))
			Begin
				Delete @Rules Where Id=@Id
				Set @Id=@Id+1
				Continue --Continuamos con la siguiente iteración
			End
			else
			begin 
				if (Select count(*) from @TransferFilterTemp) < @Transfers
				Begin
					Delete @Rules Where Id=@Id
					Set @Id=@Id+1
					Continue --Continuamos con la siguiente iteración
				End
			end
		END
		ELSE
		BEGIN
			Delete @Rules Where Id=@Id
			Set @Id=@Id+1
			Continue --Continuamos con la siguiente iteración
		end
	end 
	

 ---------------- Get the Amount Limit and Days to Add to Ask Id----------------------------
	If @AgentAmountRule=1
	Select @AmountRule = AmountRequiredToAskId From AGENT Where IdAgent = @IdAgent
 -------------------------------------------------------------------------------------------
	
	If @SymbolRule='>'
	Begin
		if @IdCountryCurrencyRule=@GlobalIDUSacurrency
		Begin
			If (@TotalAmount+@AmountInDollars) <=@AmountRule
			Begin
				Delete @Rules Where Id=@Id
			End 
		End
		Else
		Begin
			If (@TotalAmount+(@AmountInMN - (ISNULL(@Fee,0)*ISNULL(@ExRate,0)))) <= @AmountRule
			Begin
				Delete @Rules Where Id=@Id
			End
		End
	End

	If @SymbolRule='<'
	Begin

		if @IdCountryCurrencyRule=@GlobalIDUSacurrency
		Begin
			If (@TotalAmount+@AmountInDollars) >=@AmountRule
			Begin
				Delete @Rules Where Id=@Id
			End
		End
		Else
		Begin
			If (@TotalAmount+(@AmountInMN- (ISNULL(@Fee,0)*ISNULL(@ExRate,0)))) >= @AmountRule
			Begin
				Delete @Rules Where Id=@Id
			End
		End
	End

 ------------------ Las reglas que se borran son las que no se cumplen ------------------------

	Set @Id=@Id+1
	Set @TotalAmount=0
End --END While exists (Select 1 from @Rules where @Id<=Id)

----------------------------------------------------  black list --------------------------------------------------

Insert into @Rules (IdRule,RuleName,Action,MessageInEnglish,MessageInSpanish,IsDenyList,IsBlackList)
select b.IdCustomerBlackListRule,RuleNameInEnglish RuleName,r.IdCBLaction [Action],MessageInEnglish,MessageInSpanish,0 IsDenyList,1 IsBlackList
from customerblacklist b
left join customerblacklistrule r on b.IdCustomerBlackListRule=r.idcustomerblacklistrule
where r.idgenericstatus=1 and b.idgenericstatus=1 and b.idcustomer=@IdCustomer

------------------------------------------- end black list --------------------------------------------------------


----------------------------------------- variables for Deny List -----------------------------------------------

Declare @CustomerIdKYCAction int
Declare @BeneficiaryIdKYCAction int
Declare @DenyListMessageInSpanish nvarchar(max)
Declare @DenyListMessageInEnglish nvarchar(max)
Set @CustomerIdKYCAction=0
Set @BeneficiaryIdKYCAction=0


--------------------------- Deny List for customer -------------------------------------------------------------------------------------

Insert into @Rules (RuleName,Action,MessageInEnglish,MessageInSpanish,IsDenyList)
Select
'Deny List' as RuleName,
C.IdKYCAction,
C.MessageInEnglish,
C.MessageInSpanish,
1 as IsDenyList
From dbo.DenyListCustomer A With (nolock)
JOIN Customer B With (nolock) ON (B.IdCustomer=A.IdCustomer)
JOIN DenyListCustomerActions C With (nolock) ON (C.IdDenyListCustomer=A.IdDenyListCustomer)
Where A.IdGenericStatus=1 AND B.FullName=@CustomerFullName


-------------------------- Deny List for Beneficiary ------------------------------------------------------------------------------------
Insert into @Rules (RuleName,Action,MessageInEnglish,MessageInSpanish,IsDenyList)
Select
'Deny List' as RuleName,
IdKYCAction,
MessageInEnglish,
MessageInSpanish,
1 as IsDenyList
From dbo.DenyListBeneficiary A With (nolock)
JOIN Beneficiary B With (nolock) ON (B.IdBeneficiary=A.IdBeneficiary)
JOIN DenyListBeneficiaryActions C With (nolock) on (C.IdDenyListBeneficiary=A.IdDenyListBeneficiary)
Where A.IdGenericStatus=1 AND B.FullName=@BeneficiaryFullName

/*
if @IdCountryCurrency=8 and getdate()>dateadd(hour,13,dbo.RemoveTimeFromDatetime(getdate()))
begin
    insert into @Rules
    (RuleName,Action,MessageInSpanish,MessageInEnglish,IsDenyList,SSNRequired)
    values
    ('Horario Honduras',5,'No se pueden llevar a cabo envios a Honduras(Lempira) despues de las 22:00','You can''t sent transfers to Honduras(Lempira) after 22:00',0,0)
end
*/

	
Select IdRule,RuleName,Action,MessageInSpanish,MessageInEnglish,IsDenyList,SSNRequired,OccupationRequired,IsBlackList, ComplianceFormatId, ComplianceFormatName from @Rules
	
	
	
End try
Begin Catch    
DECLARE @ErrorMessage varchar(max)                                                                 
    Select @ErrorMessage=ERROR_MESSAGE()   
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_EvaluateKYCRule3',Getdate(),@ErrorMessage)
End catch






