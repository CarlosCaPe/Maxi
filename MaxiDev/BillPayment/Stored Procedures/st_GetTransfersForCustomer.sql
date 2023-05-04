
-- exec BillPayment.st_GetTransactionReceiptBillPaymentByIdTransfer 291687,'ok'

CREATE procedure[BillPayment].[st_GetTransfersForCustomer]
(
    @IdAgent INT,
    @IdCustomer INT,
    @IsNational BIT
)
AS 
/********************************************************************
<Author></Author>
<app>MaxiAgente</app>
<Description>This stored is used in agent for search screen billers transaction</Description>

<ChangeLog>
<log Date="10/08/2018" Author="snevarez">Creacion del Store</log>
<log Date="21/09/2018" Author="azavala">agregar filtro para nacionales en union parames</log>
<log Date="21/09/2018" Author="esalazar">campo Posting en @Billers</log>
<log Date="04/01/2019" Author="azavala">se agrega IdAggregator a tabla temporal - Ref: 04022019_azavala</log>
<log Date="25/01/2019" Author="amoreno">el campo de ZipBiller  amoreno</log>
<log Date="25/01/2019" Author="amoreno">el campo de [BillerInstructions] y [ChoiseData]  amoreno</log>
<log Date="04/04/2019" Author="azavala">se agrega IsFixedFee a la consulta saliente - Ref: 04042019_azavala</log>
<log Date="04/24/2019" Author="jdarellano" Name="#1">Se agrega valor máximo a campos de tabla temporal @Billers.</log>
</ChangeLog>
*********************************************************************/
BEGIN

 SET NOCOUNT ON;

 /*Test*/
 --Set @IdAgent = 4636;
 --Set @IdCustomer = 794972;
 --Set @IsNational = 1;

  Begin try

    DECLARE @DateOf3Months DATETIME = dateadd(month, datediff(month, 0, getdate()) - 3, 0);

	DECLARE @Billers Table--#1
	(
		IdBiller INT,
		Name VARCHAR(MAX),
		Category VARCHAR(MAX),
		Posting VARCHAR(MAX),
		[Fee] DECIMAL(18,3),
		[IdAggregator] int,--04022019_azavala
		[BillerInstructions] VARCHAR(Max),
		[ChoiseData] VARCHAR(MAX),
		[IsFixedFee] Bit
	)

	   /*Biller from Agent*/
	INSERT INTO @Billers (idBiller, Name, Category, Posting, [Fee], [IdAggregator],[BillerInstructions], [ChoiseData], [IsFixedFee])--04022019_azavala
	EXEC [BillPayment].[st_GetBillerAgent]  @IdAgent,@IsNational;

	/*Get info transaction - Regalii*/
	Select 
		IdProductTransfer
		,DateOfCreation
		,Amount
		,IdCountry
		,BillerType
		,Account_Number
		,Name_On_Account
		,IdBiller
		,BillerName

		,IdCurrency
		,Commission
		,Fee
		,ExRate

		,AgentCommission
		,CorpCommission
		,TransactionFee
		,ZipCodeBiller
		,ROW_NUMBER() over ( partition by IdBiller order by DateOfCreation desc) AS Flag
	into #TmpBillPayment
	From 
	(
	   
		Select 
			OPT.IdProductTransfer
			, OPT.DateOfCreation
			, OPT.Amount
			, RT.IdCountry
			, RT.BillerType
			, RT.Account_Number
			, RT.Name_On_Account
			, RT.IdBiller
			, RT.Name AS BillerName

			, RT.IdCurrency
			, RT.Commission
			, RT.Fee
			, RT.ExRate

			, RT.AgentCommission
			, RT.CorpCommission
			, RT.TransactionFee
			, ZipCodeBiller=''
		From Operation.ProductTransfer AS OPT WITH(NOLOcK)
			Inner Join regalii.TransferR AS RT WITH(NOLOcK) On OPT.IdProductTransfer = RT.IdProductTransfer
		Where RT.IdCustomer = @IdCustomer
			And EXISTS(
					SELECT 1 FROM @Billers AS B WHERE RT.IdBiller = B.IdBiller
					)
			And OPT.DateOfCreation >= @DateOf3Months
			And RT.IdStatus = 30 and @IsNational=0 /*Paid*/
	UNION

		/*Get info transaction - New */
		Select 
			OPT.IdProductTransfer
			, OPT.DateOfCreation
			, OPT.Amount
			, RT.IdCountry
			, RT.BillerType
			, RT.Account_Number
			, RT.Name_On_Account
			, RT.IdBiller
			, RT.Name AS BillerName

			, RT.IdCurrency
			, RT.Commission
			, RT.Fee
			, RT.ExRate

			, RT.AgentCommission
			, RT.CorpCommission
			, RT.TransactionFee
		    , RT.ZipCodeBiller
			 
		From Operation.ProductTransfer AS OPT WITH(NOLOcK)
			Inner Join BillPayment.TransferR AS RT WITH(NOLOcK) On OPT.IdProductTransfer = RT.IdProductTransfer
		Where RT.IdCustomer = @IdCustomer
			And EXISTS(
					SELECT 1 FROM @Billers AS B WHERE RT.IdBiller = B.IdBiller
					)
			And OPT.DateOfCreation >= @DateOf3Months
			And RT.IdStatus = 30 /*Paid*/
	) As BillPaymentTransfers
	   

	--SELECT * FROM #TmpBillPayment

	Select 
		IdProductTransfer
		,DateOfCreation
		,Amount
		,IdCountry
		,BillerType
		,Account_Number
		,Name_On_Account
		,IdBiller
		,BillerName
		  
		,IdCurrency
		,Commission
		,Fee
		,ExRate
		  
		,AgentCommission
		,CorpCommission
		,TransactionFee
		, ZipCodeBiller
	from #TmpBillPayment Where Flag = 1;
	   
	DROP TABLE #TmpBillPayment;

  End Try
  begin catch	  
	   Declare @ErrorMessage nvarchar(max);
	   Select @ErrorMessage=ERROR_MESSAGE();
	   Insert into Soporte.InfoLogForStoreProcedure (StoreProcedure,InfoDate,InfoMessage)Values('st_GetTransfersForCustomer',Getdate(),'IdCustomer:' + Convert(VARCHAR(250),@IdCustomer) + ',' + @ErrorMessage);
  End Catch
    
END