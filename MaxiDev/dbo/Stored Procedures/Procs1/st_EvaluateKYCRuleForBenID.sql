
CREATE PROCEDURE [dbo].[st_EvaluateKYCRuleForBenID]
(
--@CustomerName nvarchar(max),
--@CustomerFirstLastName nvarchar(max),
--@CustomerSecondLastName nvarchar(max),
--@BeneficiaryName nvarchar(max),
--@BeneficiaryFirstLastName nvarchar(max),
--@BeneficiarySecondLastName nvarchar(max),
@IdPayer int,
@IdPaymenttype int,
@IdAgent int,
@IdCountry int,
@IdGateway int,
--@IdCustomer int,
--@IdBeneficiary int,
--@AmountInDollars money,
--@AmountInMN money,
@IdCountryCurrency int
)
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="16/08/2017" Author="mdelgado">Add New Columns S35</log>
</ChangeLog>
********************************************************************/
Set nocount on

--------------------- Id currency usa and country usa -------------------------------------------------------
Declare @GlobalIDUSacurrency int
Select @GlobalIDUSacurrency=convert(int,Value) from GlobalAttributes WITH(NOLOCK) where Name='IdCountryCurrencyDollars'


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
		[Action] int,
		MessageInSpanish nvarchar(max),
		MessageInEnglish nvarchar(max),
		IsDenyList bit,
		Factor Decimal (18,2),
		SSNRequired bit not null default 0,
		ComplianceFormatId INT,
		ComplianceFormatName NVARCHAR(MAX)
		/*>> S35*/
		,IdTypeRequired bit
		,IdNumberRequired bit
		,IdExpirationDateRequired bit
		,IdStateCountryRequired bit
		,DateOfBirthRequired bit
		/*<< S35*/
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
		[Action],
		MessageInSpanish,
		MessageInEnglish,
		IsDenyList,
		Factor,
		SSNRequired,
		ComplianceFormatId,
		ComplianceFormatName
		/*>> S35*/
		,IdTypeRequired
		,IdNumberRequired
		,IdExpirationDateRequired
		,IdStateCountryRequired
		,DateOfBirthRequired
		/*<< S35*/
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
		KYCR.ComplianceFormatId,
		CF.FileOfName
		/*>> S35*/
		,KYCR.IdTypeRequired
		,KYCR.IdNumberRequired
		,KYCR.IdExpirationDateRequired
		,KYCR.IdStateCountryRequired
		,KYCR.DateOfBirthRequired
		/*<< S35*/
	FROM [dbo].[KYCRule] KYCR WITH(NOLOCK)
	LEFT JOIN [dbo].[ComplianceFormat] CF WITH(NOLOCK) ON KYCR.[ComplianceFormatId] = CF.[ComplianceFormatId]
	WHERE
		(IdPayer=@IdPayer or IdPayer is NULL) 
		And (IdCountryCurrency=@GlobalIDUSacurrency or IdCountryCurrency=@IdCountryCurrency or IdCountryCurrency is NULL)
		And (IdPaymentType=@IdPaymenttype or IdPaymentType is NULL)
		And (IdAgent=@IdAgent or IdAgent is NULL)
		AND (IdCountry=@IdCountry or IdCountry is NULL)
		AND (IdGateway=@IdGateway or IdGateway is NULL)
		And [Action]=6
		And IdGenericStatus=1 


SELECT [RuleName],[Action],[MessageInSpanish],[MessageInEnglish],[IsDenyList],[SSNRequired], [ComplianceFormatId], [ComplianceFormatName]
		/*>> S35*/
		,IdTypeRequired
		,IdNumberRequired
		,IdExpirationDateRequired
		,IdStateCountryRequired
		,DateOfBirthRequired
		/*<< S35*/
FROM @Rules
