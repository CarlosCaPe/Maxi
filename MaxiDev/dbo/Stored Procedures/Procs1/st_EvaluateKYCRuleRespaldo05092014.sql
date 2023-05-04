create PROCEDURE [dbo].[st_EvaluateKYCRuleRespaldo05092014]
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
				SSNRequired bit not null default 0
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
				SSNRequired
				)
Select
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
		0,
		Factor,
		SSNRequired
from KYCRule With (nolock) Where 
		(IdPayer=@IdPayer or IdPayer is NULL) 		
		And (IdCountryCurrency=@GlobalIDUSacurrency or IdCountryCurrency=@IdCountryCurrency or IdCountryCurrency is NULL)
		And (IdPaymentType=@IdPaymenttype or IdPaymentType is NULL)
		And (IdAgent=@IdAgent or IdAgent is NULL)
		AND (IdCountry=@IdCountry or IdCountry is NULL)
		AND (IdGateway=@IdGateway or IdGateway is NULL)
		And IdGenericStatus=1 
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
If EXISTS (Select 1 From @rules Where Actor='NewCustomer' or Actor='InactiveCustomer' or Actor='AverageCustomer')
Begin
	If (@IdCustomer is not null And @IdCustomer!=0)
	   Begin 
		  declare @Dates Table (DateOfTransfer datetime)
		  
		  insert into @Dates 
		  select top 1 DateOfTransfer from [Transfer] With (nolock) where IdCustomer = @IdCustomer order by DateOfTransfer desc
		  
		  insert into @Dates 
		  select top 1 DateOfTransfer from [TransferClosed] With (nolock)  where IdCustomer = @IdCustomer order by DateOfTransfer desc
		  
		  select top 1 @DateOfLastTransfer = DateOfTransfer from @Dates order by DateOfTransfer desc
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
@Factor Decimal (18,2)

Set @Id=1

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
	@Factor=factor
	From @Rules Where Id=@Id

	Set @TotalAmount=0

	If @ActorRule = 'Beneficiary' And @TimeInDaysRule>0
	Begin
		Select @TotalAmount= ISNULL( Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN SUM( AmountInDollars) ELSE SUM( AmountInMN) END , 0)
		From Transfer With (nolock)
		Where IdPayer = Case When @IdPayerRule IS NULL THEN IdPayer ELSE @IdPayer END And
		IdPaymentType = Case When @IdPaymentTypeRule IS not NULL Then @IdPaymentType Else IdPaymentType End And
		IdBeneficiary in (Select IdBeneficiary From @Beneficiary) And
		DATEDIFF (day,DateOfTransfer,GETDATE() ) < @TimeInDaysRule And
		IdStatus Not In (22,31 ) --(25= Rejected, 16= Cancelled)

		Select @TotalAmount2= ISNULL( Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN SUM( AmountInDollars) ELSE SUM( AmountInMN) END , 0)
		From TransferClosed With (nolock)
		Where IdPayer = Case When @IdPayerRule IS NULL THEN IdPayer ELSE @IdPayer END And
		IdPaymentType = Case When @IdPaymentTypeRule IS not NULL Then @IdPaymentType Else IdPaymentType End And
		IdBeneficiary in (Select IdBeneficiary From @Beneficiary) And
		DATEDIFF (day,DateOfTransfer,GETDATE() ) < @TimeInDaysRule And
		IdStatus Not In (22,31 ) --(25= Rejected, 16= Cancelled)

		Select @TotalAmount=@TotalAmount+@TotalAmount2
	End --END If @ActorRule='Beneficiary' And @TimeInDaysRule>0

	If @ActorRule = 'Customer' And @TimeInDaysRule>0
	Begin
		Select @TotalAmount=ISNULL( Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN SUM( AmountInDollars) ELSE SUM( AmountInMN) END , 0)
		From Transfer With (nolock)
		Where IdPayer = Case When @IdPayerRule IS Null Then IdPayer ELSE @IdPayer END And
		IdPaymentType = Case When @IdPaymentTypeRule Is Not Null Then @IdPaymentType Else IdPaymentType End And
		IdCustomer = @IdCustomer And
		DATEDIFF (day,DateOfTransfer,GETDATE() ) < @TimeInDaysRule And
		IdStatus Not In (22,31 ) --(25= Rejected, 16= Cancelled)

		Select @TotalAmount2=ISNULL( Case When @IdCountryCurrencyRule = @GlobalIDUSacurrency THEN SUM( AmountInDollars) ELSE SUM( AmountInMN) END , 0)
		From TransferClosed With (nolock)
		Where IdPayer = Case When @IdPayerRule IS Null Then IdPayer ELSE @IdPayer END And
		IdPaymentType = Case When @IdPaymentTypeRule Is Not Null Then @IdPaymentType Else IdPaymentType End And
		IdCustomer = @IdCustomer And
		DATEDIFF (day,DateOfTransfer,GETDATE() ) < @TimeInDaysRule And
		IdStatus Not In (22,31 ) --(25= Rejected, 16= Cancelled)

		Select @TotalAmount=@TotalAmount+@TotalAmount2


		--Select @IdCountryCurrencyRule,@IdPayerRule,@IdPayer,@IdPaymentTypeRule,@IdPaymentType,@IdCustomer,@TimeInDaysRule

		--Select ISNULL( Case When 10 = 17 THEN SUM( AmountInDollars) ELSE SUM( AmountInMN) END , 0)
		--From Transfer
		--Where
		--IdPayer =Case When Null IS null Then IdPayer ELSE 74 END And
		----IdPaymentType = Case When null IS not null Then 1 Else IdPaymentType End And
		--IdCustomer = 654491 And
		--DATEDIFF (day,DateOfTransfer,GETDATE() ) <= 1 -1 And
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
		select @lastActivityLimit= DATEADD(day,-1*@TimeInDaysRule,CONVERT(date,GETDATE()))

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



Select RuleName,Action,MessageInSpanish,MessageInEnglish,IsDenyList,SSNRequired from @Rules