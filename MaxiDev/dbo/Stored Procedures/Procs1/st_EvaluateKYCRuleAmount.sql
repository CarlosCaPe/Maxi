
CREATE PROCEDURE [dbo].[st_EvaluateKYCRuleAmount]
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

)
AS
Set nocount on
SET ARITHABORT ON

Begin try

declare @pivotdate datetime= '9/7/2015  11:51:02 AM'

--------------------------------------------- Nexts lines must be commented------------------------------
/*
declare @RuleName as nvarchar(max)
Declare @Action as int
Declare @MessageInSpanish as nvarchar(max)
Declare @MessageInEnglish as nvarchar(max)
Declare @IsDenyList as bit

Select @RuleName as RuleName,@Action as Action,@MessageInSpanish as MessageInSpanish, @MessageInEnglish as MessageInEnglish,@IsDenyList as IsDenyList
*/


-------------------------------  Incremento Performance , uso de Customer.FullName y Beneficiary.FullName ---------------------------------
Declare @CustomerFullName nvarchar(120)
Declare @BeneficiaryFullName nvarchar(120)

Set @CustomerFullName=REPLACE ( Substring(@CustomerName,1,40)+Substring(@CustomerFirstLastName,1,40)+Substring(@CustomerSecondLastName,1,40), ' ','')
Set @BeneficiaryFullName =REPLACE ( Substring(@BeneficiaryName,1,40)+Substring(@BeneficiaryFirstLastName,1,40)+Substring(@BeneficiarySecondLastName,1,40), ' ','')


--------------------- Id currency usa and country usa -------------------------------------------------------
Declare @GlobalIDUSacurrency int
Select @GlobalIDUSacurrency=convert(int,Value) from GlobalAttributes where Name='IdCountryCurrencyDollars'


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
				IsConsecutive bit not null default 0,
                IsBlackList bit not null default 0,
				Transfers int,
				ComplianceFormatId INT,
				ComplianceFormatName NVARCHAR(MAX)
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
				IsConsecutive,
				Transfers,
				ComplianceFormatId,
				ComplianceFormatName
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
		KYCR.IsConsecutive,
		KYCR.Transactions,
		KYCR.ComplianceFormatId,
		CF.FileOfName
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
				IsConsecutive,
				Transfers,
				ComplianceFormatId,
				ComplianceFormatName
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
		KYCR.IsConsecutive,
		KYCR.Transactions,
		KYCR.ComplianceFormatId,
		CF.FileOfName
	FROM [dbo].[KYCRule] KYCR (NOLOCK)
	LEFT JOIN [dbo].[ComplianceFormat] CF (NOLOCK) ON KYCR.[ComplianceFormatId] = CF.[ComplianceFormatId]
	WHERE
		(IdPayer=@IdPayer or IdPayer is NULL) 		
		And (IdCountryCurrency=@GlobalIDUSacurrency or IdCountryCurrency=@IdCountryCurrency or IdCountryCurrency is NULL)
		And (IdPaymentType=@IdPaymenttype or IdPaymentType is NULL)
		And (IdAgent=@IdAgent or IdAgent is NULL)
		AND (IdCountry=@IdCountry or IdCountry is NULL)
		AND (IdGateway=@IdGateway or IdGateway is NULL)
		And IdGenericStatus=1 and IsExpire=1 and ExpirationDate>=@pivotdate
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

        insert into @TBen
        --select AmountInDollars,AmountInMN,DateOfTransfer from (
        Select AmountInDollars,AmountInMN,DateOfTransfer,IdPayer,IdPaymenttype
		From Transfer With (nolock)
		Where 
        --IdPayer = Case When @IdPayerRule IS NULL THEN IdPayer ELSE @IdPayer END And
		--IdPaymentType = Case When @IdPaymentTypeRule IS not NULL Then @IdPaymentType Else IdPaymentType End And
		IdBeneficiary in (Select IdBeneficiary From @Beneficiary) And
		DATEDIFF (day,DateOfTransfer,@pivotdate ) <= @MaxTimeInDays And
		IdStatus Not In (22,31 ) --(25= Rejected, 16= Cancelled)
        union all
		Select AmountInDollars,AmountInMN,DateOfTransfer,IdPayer,IdPaymenttype
		From TransferClosed With (nolock)
		Where 
        --IdPayer = Case When @IdPayerRule IS NULL THEN IdPayer ELSE @IdPayer END And
		--IdPaymentType = Case When @IdPaymentTypeRule IS not NULL Then @IdPaymentType Else IdPaymentType End And
		IdBeneficiary in (Select IdBeneficiary From @Beneficiary) And
		DATEDIFF (day,DateOfTransfer,@pivotdate ) <= @MaxTimeInDays And
		IdStatus Not In (22,31 ) --(25= Rejected, 16= Cancelled)        
        --)t

        insert into @TCus
        --select AmountInDollars,AmountInMN,DateOfTransfer into #TCus from (
        Select AmountInDollars,AmountInMN,DateOfTransfer,IdPayer,IdPaymenttype
		From Transfer With (nolock)
		Where 
        --IdPayer = Case When @IdPayerRule IS Null Then IdPayer ELSE @IdPayer END And
		--IdPaymentType = Case When @IdPaymentTypeRule Is Not Null Then @IdPaymentType Else IdPaymentType End And
		IdCustomer = @IdCustomer And
		DATEDIFF (day,DateOfTransfer,@pivotdate ) <= @MaxTimeInDays And
		IdStatus Not In (22,31 ) --(25= Rejected, 16= Cancelled)
        Union all
		Select AmountInDollars,AmountInMN,DateOfTransfer,IdPayer,IdPaymenttype
		From TransferClosed With (nolock)
		Where 
        --IdPayer = Case When @IdPayerRule IS Null Then IdPayer ELSE @IdPayer END And
		--IdPaymentType = Case When @IdPaymentTypeRule Is Not Null Then @IdPaymentType Else IdPaymentType End And
		IdCustomer = @IdCustomer And
		DATEDIFF (day,DateOfTransfer,@pivotdate ) <= @MaxTimeInDays And
		IdStatus Not In (22,31 ) --(25= Rejected, 16= Cancelled)
        union all
        select ReceiptAmount AmountInDollars,0 AmountInMN,PaymentDate DateOfTransfer,null IdPayer,@IdPaymenttype IdPaymenttype from BillPaymentTransactions where customerid=@IdCustomer and status=1 and DATEDIFF (day,PaymentDate,@pivotdate ) < @MaxTimeInDays
        --)t

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

	If @ActorRule = 'Beneficiary' And @TimeInDaysRule>0
	Begin
		Select @TotalAmount= ISNULL( Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN SUM( AmountInDollars) ELSE SUM( AmountInMN) END , 0)
		From @TBen
		Where 
        isnull(IdPayer,0) = Case When @IdPayerRule IS NULL THEN isnull(IdPayer,0) ELSE @IdPayer END And
		isnull(IdPaymentType,0) = Case When @IdPaymentTypeRule IS not NULL Then @IdPaymentType Else isnull(IdPaymentType,0) End And
		--IdBeneficiary in (Select IdBeneficiary From @Beneficiary) And
		DATEDIFF (day,DateOfTransfer,@pivotdate ) <= @TimeInDaysRule --And
		--IdStatus Not In (22,31 ) --(25= Rejected, 16= Cancelled)

		--Select @TotalAmount2= ISNULL( Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN SUM( AmountInDollars) ELSE SUM( AmountInMN) END , 0)
		--From TransferClosed With (nolock)
		--Where IdPayer = Case When @IdPayerRule IS NULL THEN IdPayer ELSE @IdPayer END And
		--IdPaymentType = Case When @IdPaymentTypeRule IS not NULL Then @IdPaymentType Else IdPaymentType End And
		--IdBeneficiary in (Select IdBeneficiary From @Beneficiary) And
		--DATEDIFF (day,DateOfTransfer,@pivotdate ) < @TimeInDaysRule And
		--IdStatus Not In (22,31 ) --(25= Rejected, 16= Cancelled)

		Select @TotalAmount=@TotalAmount--+@TotalAmount2
	End --END If @ActorRule='Beneficiary' And @TimeInDaysRule>0

	If @ActorRule = 'Customer' And @TimeInDaysRule>0
	Begin

		Select @TotalAmount=ISNULL( Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN SUM( AmountInDollars) ELSE SUM( AmountInMN) END , 0)
		From @TCus
		Where 
        isnull(IdPayer,0) = Case When @IdPayerRule IS NULL THEN isnull(IdPayer,0) ELSE @IdPayer END And
		isnull(IdPaymentType,0) = Case When @IdPaymentTypeRule IS not NULL Then @IdPaymentType Else isnull(IdPaymentType,0) End And
		---IdCustomer = @IdCustomer And
		DATEDIFF (day,DateOfTransfer,@pivotdate ) <= @TimeInDaysRule --And
		--IdStatus Not In (22,31 ) --(25= Rejected, 16= Cancelled)

		--Select @TotalAmount2=ISNULL( Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN SUM( AmountInDollars) ELSE SUM( AmountInMN) END , 0)
		--From TransferClosed With (nolock)
		--Where IdPayer = Case When @IdPayerRule IS Null Then IdPayer ELSE @IdPayer END And
		--IdPaymentType = Case When @IdPaymentTypeRule Is Not Null Then @IdPaymentType Else IdPaymentType End And
		--IdCustomer = @IdCustomer And
		--DATEDIFF (day,DateOfTransfer,@pivotdate ) < @TimeInDaysRule And
		--IdStatus Not In (22,31 ) --(25= Rejected, 16= Cancelled)

		Select @TotalAmount=@TotalAmount--+@TotalAmount2


		--Select @IdCountryCurrencyRule,@IdPayerRule,@IdPayer,@IdPaymentTypeRule,@IdPaymentType,@IdCustomer,@TimeInDaysRule

		--Select ISNULL( Case When 10 = 17 THEN SUM( AmountInDollars) ELSE SUM( AmountInMN) END , 0)
		--From Transfer
		--Where
		--IdPayer =Case When Null IS null Then IdPayer ELSE 74 END And
		----IdPaymentType = Case When null IS not null Then 1 Else IdPaymentType End And
		--IdCustomer = 654491 And
		--DATEDIFF (day,DateOfTransfer,@pivotdate ) <= 1 -1 And
		--IdStatus Not In (25,16 ) --(25= Rejected, 16= Cancelled)

	End --END If @ActorRule='Customer' And @TimeInDaysRule>0

	If @ActorRule = 'NewCustomer' And @DateOfLastTransfer is not null--Si la regla es NewCustomer y la fecha de último envío no es null (El cliente ya ha realizado un envío) la regla no aplica, borrarla
	Begin 
		Delete @Rules Where Id=@Id
		Set @Id=@Id+1
		Set @TotalAmount=0
		Continue
	End --END If @ActorRule='NewCustomer' And @IdCustomer is not null 

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
		select @lastActivityLimit= DATEADD(day,-1*@TimeInDaysRule,CONVERT(date,@pivotdate))

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
	    select @SentAverage = SentAverage from Customer where IdCustomer = @IdCustomer
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
			set @DateTRansfer = @pivotdate
		
		
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
					Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN t.AmountInDollars ELSE t.AmountInMN END as TransferAmount, t.DateOfTransfer
					from Transfer t With (nolock)
					where t.IdAgent = @IdAgent and t.IdStatus not in (22, 31) order by DateOfTransfer desc -- Todos los status menos Cacelado y rechazado

				
				Insert into @TransferFilterTemp
						(
						TransferAmount
						) Select tem.TransferAmount from @TransferAgentTemp tem
						join CountryCurrency cc
					on tem.IdCountryCurrency = cc.IdCountryCurrency
					where tem.TransferAmount > isnull(@AmountRule, TransferAmount) and @transfeAmount > isnull(@AmountRule, @transfeAmount) and
					 DateOfTransfer >= isnull(@DateTRansfer, DateOfTransfer) and IdPayer = isnull(@IdPayerRule, IdPayer) 
					and IdPaymentType = isnull(@IdPaymentTypeRule, IdPaymentType) and IdGateway = isnull(@IdGatewayRule, IdGateway) and cc.IdCountry = isnull(@IdCountryRule, cc.IdCountry)

			end
			else
			begin 
				set @DateTRansfer = DateAdd(day, -@TimeInDaysRule, @pivotdate)
			
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
					Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN t.AmountInDollars ELSE t.AmountInMN END as TransferAmount, t.DateOfTransfer
					from Transfer t With (nolock)
					join CountryCurrency cc
					on t.IdCountryCurrency = cc.IdCountryCurrency
					where @transfeAmount > isnull(@AmountRule, @transfeAmount) and DateOfTransfer >= isnull(@DateTRansfer, DateOfTransfer) and IdPayer = isnull(@IdPayerRule, IdPayer) 
					and IdPaymentType = isnull(@IdPaymentTypeRule, IdPaymentType) and IdGateway = isnull(@IdGatewayRule, IdGateway) and cc.IdCountry = isnull(@IdCountryRule, cc.IdCountry)
					and t.IdAgent = @IdAgent and t.IdStatus not in (22, 31) order by DateOfTransfer desc
				
					Insert into @TransferFilterTemp
					(
					TransferAmount
					) Select top (@transfers) TransferAmount from @TransferAgentTemp where TransferAmount > isnull(@AmountRule, TransferAmount)
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
			If (@TotalAmount+@AmountInMN) <= @AmountRule
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
			If (@TotalAmount+@AmountInMN) >= @AmountRule
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
JOIN Customer B With (nolock) ON (A.IdCustomer=B.IdCustomer)
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
JOIN Beneficiary B With (nolock) ON (A.IdBeneficiary=B.IdBeneficiary)
JOIN DenyListBeneficiaryActions C With (nolock) on (C.IdDenyListBeneficiary=A.IdDenyListBeneficiary)
Where A.IdGenericStatus=1 AND B.FullName=@BeneficiaryFullName

/*
if @IdCountryCurrency=8 and @pivotdate>dateadd(hour,13,dbo.RemoveTimeFromDatetime(@pivotdate))
begin
    insert into @Rules
    (RuleName,Action,MessageInSpanish,MessageInEnglish,IsDenyList,SSNRequired)
    values
    ('Horario Honduras',5,'No se pueden llevar a cabo envios a Honduras(Lempira) despues de las 22:00','You can''t sent transfers to Honduras(Lempira) after 22:00',0,0)
end
*/

Select IdRule,RuleName,Action,MessageInSpanish,MessageInEnglish,IsDenyList,SSNRequired,IsBlackList, ComplianceFormatId, ComplianceFormatName from @Rules

End try
Begin Catch    
DECLARE @ErrorMessage varchar(max)                                                                 
    Select @ErrorMessage=ERROR_MESSAGE()   
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_EvaluateKYCRuleAmount',@pivotdate,@ErrorMessage)
End catch