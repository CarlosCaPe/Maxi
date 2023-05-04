CREATE PROCEDURE [dbo].[st_FilterPreTransferNewAgent]
(
    @IdAgent INT,
    @Folio NVARCHAR(max)
    ,@IdUser INT = NULL /*Req_M2An055*/
)
AS
/********************************************************************
<Author> ??? </Author>
<app> Agent, Corporative </app>
<Description> Gets print information for Tickets and Recepits</Description>

<ChangeLog>
<log Date="19/05/2017" Author="jmoreno">se obtienen las prestransferencias para el nuevo agente</log>
<log Date="2018/03/16" Author="snevarez">MA_008: Add field from ATM</log>
<log Date="18/05/2015" Author="snevarez">Modificacion Req_M2An055</log>
</ChangeLog>
*********************************************************************/

    IF @Folio='' SET @Folio=null;

    DECLARE @IdGenericStatusEnable INT;
    SET @IdGenericStatusEnable = 1;

    SELECT 
	   T.[IdAgent]
	   , T.[IdPreTransfer]
	   , T.[DateOfPreTransfer]
	   , A.[AgentCode]
	   , A.[AgentName]
	   , T.[Folio]
	   , T.[CustomerName] + ' ' + T.[CustomerFirstLastName] + ' ' + T.[CustomerSecondLastName] [CustomerName]
	   , T.CustomerAddress
	   , T.CustomerState
	   , T.CustomerCity
	   , T.CustomerZipcode
	   , T.[BeneficiaryName] + ' ' + T.[BeneficiaryFirstLastName] + ' ' + T.[BeneficiarySecondLastName] [BeneficiaryName]
	   , P.[PayerName]
	   , PT.[PaymentName] [PaymentTypeName]
	   , C.[CountryName]
	   , T.[AmountInDollars]
	   , T.[AmountInMN]
	   , T.[IdAgentSchema]
	   , T.[IdPaymentType]
    --	, T.[IdCity]
	   , T.[Fee]
	   , T.[StateTax]
	   , T.[IsValid]
	   , CC.[Idcountry]
	   , A.AgentState
	   , Br.[BranchName]
	   , T.BeneficiaryState
	   , T.BeneficiaryCity
	   , Ci.[CityName]
	   , T.IdCity
	   , S.[StateName]
	   , S.IdState
	   , T.[BeneficiaryCelularNumber],
	 		 CASE
		 		    WHEN T.[IdAgentSchema] IS NOT NULL THEN AC.[SchemaName]
		 		    WHEN T.[IdCountryCurrency] IS NOT NULL THEN -- A1.[SchemaName]
			 (SELECT 
				TOP 1 A1.SchemaName      
				    FROM AgentSchema A1 WHERE 
				  	   IdGenericStatus = @IdGenericStatusEnable 
				    AND A1.IdCountryCurrency = T.IdCountryCurrency
				ORDER BY A1.IdAgentSchema ASC
			 )
	   END [SchemaName]
	   , T.ExRate
	   , ISNULL(PSSN.[SSNRequired],0) SSNRequired,
		T.Discount,
		cpm.PaymentMethod,
		(T.AmountInDollars + T.Fee + T.StateTax - T.Discount) TotalAmountPaid

	   --, T.[TransferIdCity] /*MA_008*/
	   --, T.BeneficiaryIdCarrier	 /*MA_008*/

    FROM dbo.PreTransfer T WITH (NOLOCK)
    JOIN [dbo].[Agent] A WITH (NOLOCK) ON T.[IdAgent]=A.[IdAgent]
    LEFT JOIN [dbo].[AgentSchema] AC on AC.IdAgentSchema=T.IdAgentSchema   
    JOIN [dbo].[Payer] P WITH (NOLOCK) ON T.IdPayer=P.IdPayer
    LEFT JOIN [dbo].[Branch] Br on Br.[IdBranch] =T.[IdBranch]
    LEFT JOIN [dbo].[City] Ci on Ci.[IdCity] =Br.[IdCity]
    LEFT JOIN [dbo].[State] S on Ci.[IdState] = S.[IdState]	
    JOIN [dbo].[PaymentType] PT WITH (NOLOCK) ON T.IdPaymentType=PT.IdPaymentType
    JOIN [dbo].[CountryCurrency] CC WITH (NOLOCK) ON T.[IdCountryCurrency] = CC.[IdCountryCurrency]
    JOIN [dbo].[Country] C WITH (NOLOCK) ON CC.[IdCountry] = C.[IdCountry]
    LEFT JOIN [dbo].[PreTransferSSN] PSSN WITH (NOLOCK) ON T.[IdPreTransfer]= PSSN.[IdPreTransfer]
	JOIN PaymentMethod cpm WITH(NOLOCK) ON cpm.IdPaymentMethod = ISNULL(T.IdPaymentMethod, 1)
    WHERE T.[IdAgent]=@IdAgent
	   AND T.[Folio]=ISNULL(@Folio,T.[Folio])
	   AND T.[Status]=0
	   AND T.EnterByIdUser = (CASE (dbo.fn_ProductsPermissions(@IdUser, 0)) WHEN 1 THEN T.EnterByIdUser ELSE @IdUser END) /*Req_M2An055*/
    ORDER BY T.[DateOfPreTransfer] DESC;
