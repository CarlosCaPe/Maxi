CREATE PROCEDURE [InternalSalesMonitor].[st_GetAgentSchemaDetails]  
(  
    @IdAgent int,
    @IdLenguage int = null   
)  
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Begin Try  

	If (@IdLenguage is null)
	Begin
		Set @IdLenguage=1;
	End

	Declare @IniDate DATETIME
	Set @IniDate=GETDATE()             
              
	Declare @IdPaymentTypeDirectCash int              
	Set @IdPaymentTypeDirectCash = 4              
              
	Declare @IdPaymentTypeCash int              
	Set @IdPaymentTypeCash =1              
              

	Declare @temp table
	(
		IdAgentSchemaDetail int,
		IdAgentSchema int,
		SchemaName varchar(255),
		IdCurrency int,
		CurrencyCode varchar(255),
		CurrencyName varchar(255),
		IdPaymentType int,
		PaymentName varchar(255),
		IdPayer int,
		PayerCode varchar(255),
		PayerName varchar(255),
		SchemaTempSpreadValue money,
		PayerSpreadValue money,
		SchemaSpreadValue money,
		SchemaIdSpread int,
		RefExRate money,
		IdPayerConfig int,
		IdCountry int,
		IdFee int
	);


	Select DISTINCT 
		E.IdAgentSchemaDetail, /**/
		B.IdAgentSchema,  
		B.SchemaName,  
		D.IdCurrency,  
		D.CurrencyCode,  
		[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,D.CurrencyCode) CurrencyName,  
		case              
		  when F.IdPaymentType=@IdPaymentTypeDirectCash then @IdPaymentTypeCash              
		  else F.IdPaymentType              
		 end IdPaymentType,  
		[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'PAYMENTTYPE'+convert(varchar,F.IdPaymentType))
		 PaymentName,  
		G.IdPayer,  
		G.PayerCode,  
		G.PayerName,  
		case          
		 when E.EndDateTempSpread>GETDATE() then E.TempSpread           
		 else 0          
		 end SchemaTempSpreadValue,   
		F.SpreadValue as PayerSpreadValue,  
		E.SpreadValue as SchemaSpreadValue,  
		E.IdSpread as SchemaIdSpread,  
		ISNULL(R1.RefExRate,ISNULL(R2.RefExRate,ISNULL(R3.RefExRate,0))) RefExRate,   
		F.IdPayerConfig,  
		C.IdCountry,
		E.IdFee
	INTO #refexrate  
	from AgentSchema B with(nolock)
	Join CountryCurrency C with (nolock) on (C.IdCountryCurrency=B.IdCountryCurrency)   
	Join Currency D with (nolock) on (D.IdCurrency=C.IdCurrency)  
	Join AgentSchemaDetail E with (nolock) on (B.IdAgentSchema=E.IdAgentSchema)  
	Join PayerConfig F with (nolock) on (F.IdPayerConfig=E.IdPayerConfig and F.IdCountryCurrency=B.IdCountryCurrency)  
	Join Payer G with (nolock) on (G.IdPayer=F.IdPayer)  
	Join PaymentType H with (nolock) on (H.IdPaymentType=F.IdPaymentType)
	LEFT JOIN RefExRate R1 with(nolock) ON R1.IdCountryCurrency=B.IdCountryCurrency and R1.Active=1 and R1.RefExRate<>0 and F.IdGateway=R1.IdGateway and F.IdPayer=R1.IdPayer  
	LEFT JOIN RefExRate R2 with(nolock) ON R2.IdCountryCurrency=B.IdCountryCurrency and R2.Active=1 and R2.RefExRate<>0 and F.IdGateway=R2.IdGateway and R2.IdPayer is NULL AND R1.RefExRate IS NULL
	LEFT JOIN RefExRate R3 with(nolock) ON R3.IdCountryCurrency=B.IdCountryCurrency and R3.Active=1 and R3.IdGateway is NULL and R3.IdPayer is NULL AND R1.RefExRate IS NULL AND R2.RefExRate IS NULL
	where 
		IdAgent=@IdAgent
			and F.IdGenericStatus=1
			and B.IdGenericStatus=1
			and G.IdGenericStatus=1;


	Select
		R.IdAgentSchemaDetail
		,R.IdAgentSchema
		,R.SchemaName
		,R.IdCurrency
		,R.CurrencyCode
		,R.CurrencyName
		,R.IdPaymentType
		,R.PaymentName
		,R.IdPayer
		,R.PayerCode
		,R.PayerName
		,R.SchemaTempSpreadValue
		,R.PayerSpreadValue
		,R.SchemaSpreadValue
		,R.SchemaIdSpread
		,R.RefExRate
		,R.IdPayerConfig
		,R.IdCountry
		,R.IdFee

		,ISNULL(ASD.IsEnabled,0) AS IsEnabled
		,ASD.EnterByIdUser
		,ASD.DateOfLastChange
	
	From #refexrate AS R
		Left Join InternalSalesMonitor.AgentSchemaDetails AS ASD with(nolock) On R.IdAgentSchemaDetail = ASD.IdAgentSchemaDetail
	Order by 
		R.SchemaName asc , R.PaymentName ASC, R.PayerSpreadValue+SchemaSpreadValue+RefExRate DESC, R.PayerName asc;


End Try
Begin Catch	
	Declare @ErrorMessage nvarchar(max);
	Select @ErrorMessage = ERROR_MESSAGE();
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('InternalSalesMonitor.st_UpdateAgentSchemaDetails',Getdate(),@ErrorMessage);
End Catch


