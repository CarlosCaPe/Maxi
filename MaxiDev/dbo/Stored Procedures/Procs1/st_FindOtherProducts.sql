
CREATE PROCEDURE [dbo].[st_FindOtherProducts]
(
    @BeginDate DATETIME,
    @EndDate DATETIME,
    @IdAgent INT ,
    @TransferFolio INT = NULL,
    @IsMonoAgent BIT = 1,
    @ProductType INT,
    @AdditionalFilter VARCHAR(4000) = NULL,
    @IdUser INT = NULL
)
AS 
/********************************************************************
<Author>Fabian Gonzalez</Author>
<app>MaxiAgente</app>
<Description>This stored is used in agent for search screen</Description>

<ChangeLog>
<log Date="20/09/2017" Author="Fgonzalez">Creacion del Store</log>
<log Date="31/10/2017" Author="JDArellano">Modificación de fechas para búsqueda "#01"</log>
<log Date="18/05/2015" Author="snevarez">Modificación para el requerimiento Req_M2An055</log>
<log Date="18/05/2015" Author="amoreno">Modificación para obtener resultados de FidelityEXpress</log>
<log Date="11/01/2015" Author="jmolina">Se agregaron NOLOCK</log>
<log Date="06/02/2019" Author="azaala">Modificación para obtener resultados de FiServ - REF: 06022019_azavala</log>
</ChangeLog>
*********************************************************************/
BEGIN

    set @EndDate=DATEADD(D,1,@EndDate)--#01

	INSERT INTO dbo.ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) 
	VALUES ('st_FindOtherProducts', getdate(),Convert(VARCHAR,@EndDate) +' - '+ Convert(VARCHAR,@BeginDate))



    DECLARE @DocHandle INT 
    DECLARE @FilterTable TABLE (idFilter INT IDENTITY, Type VARCHAR(200), Value VARCHAR(200) )
    DECLARE @FastCustomer TABLE (idCustomer INT )
    DECLARE @FastTransfer TABLE (idProductTransfer INT )
			
    IF @AdditionalFilter IS NOT NULL AND len(@AdditionalFilter) > 0 
    BEGIN 
			   	
	   EXEC sp_xml_preparedocument @DocHandle OUTPUT, @AdditionalFilter;
			
	   INSERT INTO @FilterTable (Type,Value)
		  SELECT Type, Value
			 FROM OPENXML (@DocHandle, 'ArrayOfFilter/Filter',2)
				    WITH ( 
						  Type VARCHAR(200),
						  Value VARCHAR(200)
					   );
    END 

    IF EXISTS (SELECT 1 FROM @FilterTable WHERE Type IN ('Folio','CustomerName','CustomerFirstLastName','CustomerPhone','VIPCard')) 
    BEGIN

	   DECLARE 
		  @FTSCustomerName VARCHAR(200),
		  @FTSCustomerFirstLastName VARCHAR(200), 
		  @FTSCustomerSecondLastName VARCHAR(200),
		  @FTSCustomerPhone VARCHAR(200),
		  @FTSCustomerVCard VARCHAR(200),
		  @ProductId VARCHAR(200);

	   SELECT @TransferFolio = VALUE FROM  @FilterTable WHERE Type='Folio'
	   SELECT @FTSCustomerName  = VALUE FROM  @FilterTable WHERE Type='CustomerName'
	   SELECT @FTSCustomerFirstLastName = VALUE FROM  @FilterTable WHERE Type='CustomerFirstLastName'
	   SELECT @FTSCustomerSecondLastName = VALUE FROM  @FilterTable WHERE Type='CustomerSecondLastName'
	   SELECT @FTSCustomerPhone = dbo.fnFormatPhoneNumber(value) FROM  @FilterTable WHERE Type='CustomerPhone'
	   SELECT @FTSCustomerVCard = value FROM  @FilterTable WHERE Type='VIPCard'
	   SELECT @ProductId = value FROM  @FilterTable WHERE Type='Product'

	   IF @FTSCustomerName IS NOT NULL AND @FTSCustomerFirstLastName IS NOT NULL BEGIN 
				
	   SELECT @FTSCustomerName = '"'+@FTSCustomerName+'*"'
			 ,@FTSCustomerFirstLastName = '"'+@FTSCustomerFirstLastName+'*"'
		
	   INSERT INTO @FastCustomer
		  SELECT IdCustomer FROM Customer WITH(NOLOCK) WHERE CONTAINS(Name,@FTSCustomerName) AND CONTAINS(FirstLastName,@FTSCustomerFirstLastName)
		  AND ((@FTSCustomerSecondLastName IS NOT NULL AND SecondLastName LIKE @FTSCustomerSecondLastName+'%') 
				OR @FTSCustomerSecondLastName IS NULL)
		  UNION 
		  SELECT 0
				    
	   END 
					 
	   IF (@FTSCustomerPhone IS NOT NULL) 
	   BEGIN 
				
		  SELECT @FTSCustomerPhone = '"'+@FTSCustomerPhone+'*"'
				
		  INSERT INTO @FastCustomer
			 SELECT IdCustomer FROM Customer WITH(NOLOCK) WHERE Contains(CelullarNumber,@FTSCustomerPhone)
			 UNION 
			 SELECT 0
		
	   END 

	   IF (@FTSCustomerVCard IS NOT NULL) 
	   BEGIN 
				
		  INSERT INTO @FastCustomer
			 SELECT vp.IdCustomer FROM CardVIP vp WITH(NOLOCK)
				JOIN Customer c WITH(NOLOCK)
				    ON c.IdCustomer = vp.IdCustomer
					   AND vp.IdGenericStatus = 1
					   AND vp.CardNumber = @FTSCustomerVCard
			 UNION 
			 SELECT 0
					
	   END 
						
	   IF (@TransferFolio IS NOT NULL OR EXISTS (SELECT 1 FROM @FastCustomer))
	   BEGIN 
			 SET @BeginDate = NULL
			 SET @EndDate = NULL 
	   END 

    END 
	
    --NOMENCLATURA PARA BUSQUEDA
    --1 Bill Payments
    --2 TopUps
    --3 E-Regalo
    --4 Long Distance
 --5 Checks
		
    DECLARE @Products TABLE (LocalType INT , idOtherProduct INT)
    INSERT INTO @Products VALUES 
						  (1,1),(1,14), (1,18), (1,19), --06022019_azavala
						  (2,6),(2,7),(2,9),(2,17),
						  (3,11),
						  (4,5),(4,16),(4,10),(4,13);

    -- SI Se está filtrando por cliente
    IF EXISTS (SELECT 1 FROM @FastCustomer) 
    BEGIN 
	  	
	   SELECT @FTSCustomerName  = VALUE FROM  @FilterTable WHERE Type='CustomerName'
	   SELECT @FTSCustomerFirstLastName = VALUE FROM  @FilterTable WHERE Type='CustomerFirstLastName'
	   SELECT @FTSCustomerSecondLastName = VALUE FROM  @FilterTable WHERE Type='CustomerSecondLastName'
	   SELECT @FTSCustomerPhone = replace(replace(replace(replace(ltrim(rtrim(value)),' ',''),'(',''),')',''),'-','') FROM  @FilterTable WHERE Type='CustomerPhone'
		
	   INSERT INTO @FastTransfer
		  SELECT IdProductTransfer FROM PureMinutesTransaction WITH(NOLOCK)
			 WHERE SenderName LIKE '%'+@FTSCustomerName+'%' or SenderFirstLastName like '%'+@FTSCustomerFirstLastName+'%' or SenderSecondLastName like '%'+@FTSCustomerSecondLastName+'%'
		  UNION
		  SELECT IdProductTransfer FROM Lunex.TransferLN WITH(NOLOCK) 
			 WHERE SenderName LIKE @FTSCustomerName+'%' +@FTSCustomerFirstLastName+'%'+@FTSCustomerSecondLastName+'%'
		  UNION 
		  SELECT IdProductTransfer FROM regalii.TransferR WITH(NOLOCK) 
			 WHERE idCustomer IN (SELECT idCustomer FROM @FastCustomer)
		  UNION 
		  SELECT IdProductTransfer FROM TransFerTo.TransferTTo WITH(NOLOCK) 
			 WHERE IdCustomer in (SELECT idCustomer FROM @FastCustomer)
		  UNION 
		  SELECT IdProductTransfer FROM Lunex.TransferLN WITH(NOLOCK) 
			 WHERE TopupPhone = @FTSCustomerPhone
		  UNION	
		  SELECT IdProductTransfer FROM PureMinutesTopUpTransaction WITH(NOLOCK) 
			 WHERE TopUpNumber = @FTSCustomerPhone
		  UNION	
		  SELECT IdProductTransfer FROM TransFerTo.TransferTTo WITH(NOLOCK)
			 WHERE Destination_Msisdn = @FTSCustomerPhone
      UNION 
		  SELECT IdProductTransfer FROM BillPayment.TransferR WITH(NOLOCK) 
			 WHERE idCustomer IN (SELECT idCustomer FROM @FastCustomer)			 
		  UNION SELECT 0 
    END 

    DECLARE @Results TABLE 
    (
	   idAgent INT 
	   , IdOtherProduct INT 
	   , [Description] VARCHAR(200)
	   , idProvider INT 
	   , ProviderName VARCHAR(200)
	   , Biller VARCHAR(200)
	   , Product VARCHAR(200)
	   , Folio BIGINT 
	   , TrackingNumber VARCHAR(200) 
	   , DateOfCreation DATETIME
	   , TotalOperation MONEY 
	   , Fee MONEY 
	   , ProviderFee MONEY
	   , Amount MONEY
	   , TotalAmountToCorporate MONEY
	   , AgentCommission MONEY
	   , CorpCommission MONEY 
	   , idStatus INT 
	   , statusName VARCHAR(200)
	   , LocalAmount MONEY
	   , LocalCurrency VARCHAR(200)
	   , Country VARCHAR(200)
	   , CustomerName VARCHAR(200)
	   , PhoneNumber VARCHAR(200)
	   , CheckNumber VARCHAR(200)
	   , RoutingNumber VARCHAR(200)
	   , AccountNumber VARCHAR(200)
	   , Bank VARCHAR(200)
	   , IssuerName VARCHAR(200)
	   , IdentificationType VARCHAR(200)
	   , internalid INT
	   , RejectReason VARCHAR(500));

    INSERT INTO @Results                    
	   SELECT 
		  pt.idAgent,
		  pt.IdOtherProduct,
		  o.[Description],
		  pt.idProvider,
		  pv.ProviderName, 
		  Biller= ltrim(rtrim(isnull(CASE 
		  WHEN pt.idProvider = 5 THEN (SELECT b.Name FROM Regalii.Billers b WITH(NOLOCK) JOIN regalii.TransferR tr  WITH(NOLOCK) ON tr.idBiller = b.idBiller WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 8 THEN (SELECT b.Name FROM Billpayment.Billers b WITH(NOLOCK) JOIN Billpayment.TransferR tr  WITH(NOLOCK) ON tr.idBiller = b.idBiller WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 9 THEN (SELECT b.Name FROM Billpayment.Billers b WITH(NOLOCK) JOIN Billpayment.TransferR tr  WITH(NOLOCK) ON tr.idBiller = b.idBiller WHERE tr.IdProductTransfer = pt.IdProductTransfer) --06022019_azavala
		  WHEN pt.idProvider = 3 THEN (SELECT CarrierName FROM Lunex.TransferLN tr WITH(NOLOCK) JOIN Lunex.Product p WITH(NOLOCK) ON p.SKU = tr.sku JOIN Operation.carrier c ON c.idCarrier = p.idCarrier WHERE tr.IdProductTransfer = pt.IdProductTransfer) 	
		  WHEN pt.idProvider = 2 THEN  (SELECT Operator FROM TransFerTo.TransferTTo tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 4 AND idOtherProduct = 6 THEN  (SELECT CarrierName FROM PureMinutesTopUpTransaction tr WITH(NOLOCK) JOIN CarrierPureMinutesTopUp cc WITH(NOLOCK) ON cc.IdCarrierPureMinutesTopUp = tr.CarrierID WHERE tr.IdProductTransfer = pt.IdProductTransfer) --Topup
		 WHEN pt.idProvider = 4 AND idOtherProduct = 5 THEN  ''--LD
		  ELSE '' END ,''))),
		  Product =
		  ltrim(rtrim(isnull(CASE 
		  WHEN pt.idProvider = 5 THEN (SELECT BillerType FROM regalii.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 8 THEN (SELECT BillerType FROM Billpayment.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer)
		  WHEN pt.idProvider = 9 THEN (SELECT BillerType FROM Billpayment.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) --06022019_azavala
		  WHEN pt.idProvider = 3 THEN (SELECT SKUNAME FROM Lunex.TransferLN tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 	
		  WHEN pt.idProvider = 2 THEN (SELECT Operator FROM TransFerTo.TransferTTo tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 4 AND idOtherProduct = 6 THEN  'Topup' --Topup
		  WHEN pt.idProvider = 4 AND idOtherProduct = 5 THEN  'Long Distance'
		  ELSE '' END ,''))),
		  Folio = pt.idProductTransfer,
		  TrackingNumber= ( CASE
         		     		WHEN pt.idProvider = 8 THEN (SELECT TraceNumber FROM Billpayment.TransferR AS tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer)
							WHEN pt.idProvider = 9 THEN (SELECT TraceNumber FROM Billpayment.TransferR AS tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) --06022019_azavala  
		                else  Convert(VARCHAR(200),TransactionProviderID)
		                end),
		  pt.DateOfCreation,
		  TotalOperation=  TotalAmountToCorporate + CASE WHEN IdAgentPaymentSchema = 2 THEN AgentCommission ELSE 0 END ,
		  Fee,
		  ProviderFee=TransactionFee,
		  Amount,
		  TotalAmountToCorporate,
		  AgentCommission,
		  CorpCommission,
		  pt.idStatus,
		  s.statusName,
		  LocalAmount = Convert(Money,ltrim(rtrim(isnull(CASE 
		  WHEN pt.idProvider = 5 THEN (SELECT AmountInMN FROM regalii.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 8 THEN (SELECT AmountInMN FROM Billpayment.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 9 THEN (SELECT AmountInMN FROM Billpayment.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) --06022019_azavala
		  WHEN pt.idProvider = 3 THEN (SELECT isnull(ReceivedValue,0) FROM Lunex.TransferLN tr WITH(NOLOCK) JOIN Lunex.Product lp WITH(NOLOCK) ON lp.sku = tr.sku JOIN Operation.Country c ON c.IdCountry = lp.idCountry WHERE tr.IdProductTransfer = pt.IdProductTransfer) 	
		  WHEN pt.idProvider = 2 THEN (SELECT LocalInfoAmount FROM TransFerTo.TransferTTo tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 4 THEN (SELECT CASE WHEN isnumeric(ReceiverAmount) = 1 THEN ReceiverAmount ELSE pt.Amount END FROM PureMinutesTopUpTransaction tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  ELSE '' END ,'')
		  ))),
		  LocalCurrency = Convert(VARCHAR(200),ltrim(rtrim(isnull(CASE 
		  WHEN pt.idProvider = 5 THEN (SELECT LocalCurrency FROM regalii.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 8 THEN (SELECT LocalCurrency FROM Billpayment.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer)
		  WHEN pt.idProvider = 9 THEN (SELECT LocalCurrency FROM Billpayment.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) --06022019_azavala
		  WHEN pt.idProvider = 3 THEN (SELECT ReceivedCurrency FROM Lunex.TransferLN tr WITH(NOLOCK) JOIN Lunex.Product lp WITH(NOLOCK) ON lp.sku = tr.sku JOIN Operation.Country c ON c.IdCountry = lp.idCountry WHERE tr.IdProductTransfer = pt.IdProductTransfer) 	
		  WHEN pt.idProvider = 2 THEN (SELECT DestinationCurrency FROM TransFerTo.TransferTTo tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 4 THEN (SELECT ReceiverCurrency FROM PureMinutesTopUpTransaction tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  ELSE '' END ,'')
		  ))),
		  Country=Convert(VARCHAR(200),ltrim(rtrim(isnull(CASE 
		  WHEN pt.idProvider = 5 THEN (SELECT Country FROM regalii.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 8 THEN (SELECT Country FROM Billpayment.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer)
		  WHEN pt.idProvider = 9 THEN (SELECT Country FROM Billpayment.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) --06022019_azavala
		  WHEN pt.idProvider = 3 THEN (SELECT CountryName FROM Lunex.TransferLN tr WITH(NOLOCK) JOIN Lunex.Product lp WITH(NOLOCK) ON lp.sku = tr.sku JOIN Operation.Country c ON c.IdCountry = lp.idCountry WHERE tr.IdProductTransfer = pt.IdProductTransfer) 	
		  WHEN pt.idProvider = 2 THEN (SELECT Country FROM TransFerTo.TransferTTo tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 4 THEN 'Estados Unidos'
		  ELSE '' END ,'')
		  ))),
		  CustomerName= Convert(VARCHAR(200),ltrim(rtrim(isnull(CASE 
		  WHEN pt.idProvider = 5 THEN (SELECT CustomerName+' '+CustomerFirstLastName+' '+CustomerSecondLastName FROM regalii.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 8 THEN (SELECT CustomerName+' '+CustomerFirstLastName+' '+CustomerSecondLastName FROM Billpayment.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 9 THEN (SELECT CustomerName+' '+CustomerFirstLastName+' '+CustomerSecondLastName FROM Billpayment.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) --06022019_azavala
		  WHEN pt.idProvider = 3 THEN (SELECT SenderName FROM Lunex.TransferLN tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 	
		  WHEN pt.idProvider = 2 THEN (SELECT c.Name+' '+c.FirstLastName+' '+c.SecondLastName FROM TransFerTo.TransferTTo tr WITH(NOLOCK) JOIN Customer c WITH(NOLOCK) ON c.IdCustomer=tr.idCustomer WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 4 THEN ''
		  ELSE '' END ,'')
		  ))),
		  PhoneNumber =Convert(VARCHAR(200),ltrim(rtrim(isnull(CASE 
		  WHEN pt.idProvider = 5 THEN (SELECT dbo.fnFormatPhoneNumber(isnull(nullif(CustomerCellPhoneNumber,''),Account_Number)) FROM regalii.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
          WHEN pt.idProvider = 8 THEN (SELECT dbo.fnFormatPhoneNumber(isnull(nullif(CustomerCellPhoneNumber,''),Account_Number)) FROM Billpayment.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 9 THEN (SELECT dbo.fnFormatPhoneNumber(isnull(nullif(CustomerCellPhoneNumber,''),Account_Number)) FROM Billpayment.TransferR tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) --06022019_azavala
		  WHEN pt.idProvider = 3 THEN (SELECT dbo.fnFormatPhoneNumber(isnull(nullif(TopupPhone,''),Phone)) FROM Lunex.TransferLN tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 	
		  WHEN pt.idProvider = 2 THEN (SELECT dbo.fnFormatPhoneNumber(Msisdn)+' / '+dbo.fnFormatPhoneNumber(Destination_Msisdn) FROM TransFerTo.TransferTTo tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 4 THEN (SELECT dbo.fnFormatPhoneNumber(TopUpNumber) FROM PureMinutesTopUpTransaction tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  ELSE '' END ,'')
		  ))),
		  CheckNumber =Convert(VARCHAR(200),''),
		  RoutingNumber=Convert(VARCHAR(200),''),
		  AccountNumber=Convert(VARCHAR(200),''),
		  Bank = Convert(VARCHAR(200),''),
		  IssuerName =Convert(VARCHAR(200),'') ,
		  IdentificationType =Convert(VARCHAR(200),''),
		  InternalId = isnull(
		  CASE 
		  WHEN pt.idProvider = 5 THEN (SELECT IdTransferR FROM regalii.TransferR AS tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 8 THEN (SELECT IdTransferR FROM Billpayment.TransferR AS tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer)
		  WHEN pt.idProvider = 9 THEN (SELECT IdTransferR FROM Billpayment.TransferR AS tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) --06022019_azavala
		  WHEN pt.idProvider = 3 THEN (SELECT IdTransferLN FROM Lunex.TransferLN AS tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 	
		  WHEN pt.idProvider = 2 THEN (SELECT IdTransferTTo FROM TransFerTo.TransferTTo AS tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  WHEN pt.idProvider = 4 THEN (SELECT IdPureMinutesTopUp FROM PureMinutesTopUpTransaction AS tr WITH(NOLOCK) WHERE tr.IdProductTransfer = pt.IdProductTransfer) 
		  ELSE 0 END ,0),
		  RejectReason = ''
	   FROM Operation.ProductTransfer AS pt WITH(NOLOCK)
		  INNER JOIN OtherProducts AS o WITH(NOLOCK) ON o.IdOtherProducts = pt.IdOtherProduct
		  INNER JOIN Providers AS pv WITH(NOLOCK) ON pv.IdProvider = pt.idProvider
		  INNER JOIN Status AS s WITH(NOLOCK) ON s.IdStatus = pt.idStatus
	   WHERE idagent = @IdAgent
		  AND pt.DateOfCreation >= isnull(@BeginDate,pt.DateOfCreation)
		  AND pt.DateOfCreation <= isnull(@EndDate,pt.DateOfCreation)		
		  AND pt.idOtherProduct IN (SELECT idOtherProduct FROM @Products WHERE LocalType = @ProductType)
		  AND (
				EXISTS (SELECT 1 FROM @FastTransfer) AND pt.idProductTransfer IN (SELECT idProductTransfer FROM @FastTransfer)
				    OR NOT EXISTS (SELECT 1 FROM @FastTransfer)
			 )
		  --agregar folio
		  and pt.idProductTransfer=isnull(@TransferFolio,pt.idProductTransfer)
		  AND pt.EnterByIdUser = (CASE (dbo.fn_ProductsPermissions(@IdUser, @ProductType)) WHEN 1 THEN pt.EnterByIdUser ELSE @IdUser END) /*Req_M2An055*/;
	
    --Se inserta la informacion de softgate
    INSERT INTO @results 
	   SELECT 
		  idAgent,idOtherproduct=1,
		  Description='Bill Payment Softgate',
		  idProvider=1,
		  ProviderName='Softgate',
		  Biller=BillerPaymentProviderVendorId, 
		  Product='bill payment',
		  Folio=IdBillPayment,
		  TrackingNumber=Convert(VARCHAR(200),MerchId+'-'+ReferenceNumber),
		  DateOfCreation =PaymentDate,
		  TotalOperation = ReceiptAmount+ Fee, 
		  Fee,
		  ProviderFee=BillPaymentProviderFee, 
		  Amount = ReceiptAmount, 
		  TotalAmountToCorporate=ReceiptAmount+BillPaymentProviderFee+CorpCommission, 
		  AgentCommission, 
		  CorpCommission, 
		  idStatus = Status, 
		  statusName=CASE [Status] WHEN 1 THEN 'Paid' ELSE 'Cancelled' END , 
		  LocalAmount=ReceiptAmount, 
		  LocalCurrency='USD', 
		  Country='Estados Unidos', 
		  CustomerName=CustomerFirstName+' '+CustomerLastName+' '+CustomerMiddleName, 
		  PhoneNumber=CustomerTelephone, 
		  CheckNumber='', 
		  RoutingNumber=TrackingNumber, 
		  AccountNumber=Convert(VARCHAR(200),AccountNumber), 
		  Bank='', 
		  IssuerName='', 
		  IdentificationType='',
		  IdBillPayment,
		  RejectReason = ''
	   FROM BillPaymentTransactions AS pt WITH(NOLOCK)
	   WHERE IdAgent =@IdAgent
		  AND 1 = @ProductType
		  AND Status IN (1,2)
		  AND pt.PaymentDate >= isnull(@BeginDate,pt.PaymentDate)
		  AND pt.PaymentDate <= isnull(@EndDate,pt.PaymentDate)		
		  AND (EXISTS (SELECT 1 FROM @FastCustomer) AND pt.CustomerId IN (SELECT idCustomer FROM @FastCustomer)
			 OR NOT EXISTS (SELECT 1 FROM @FastCustomer)
			 )
		  --agregar folio
		  and pt.IdBillPayment=isnull(@TransferFolio,pt.IdBillPayment)
		  AND pt.IdUser = (CASE (dbo.fn_ProductsPermissions(@IdUser, @ProductType)) WHEN 1 THEN pt.IdUser ELSE @IdUser END) /*Req_M2An055*/;

    --Se inserta la informacion de cheques
    INSERT INTO @results 
	   SELECT 
		  idAgent,idOtherproduct=15,
		  Description='Checks',
		  idProvider=0,
		  ProviderName='',
		  Biller=(SELECT '\Issuer\'+Convert(VARCHAR,IdIssuer)+ '\Checks\' +Convert(VARCHAR,IdCheck)+'\'+FileGuid+'.tif' FROM UploadFiles WITH(NOLOCK) WHERE IdDocumentType=69 AND IdReference = IdCheck AND LastChange_LastNoteChange LIKE '%Back%'), 
		  Product=(SELECT '\Issuer\'+Convert(VARCHAR,IdIssuer)+ '\Checks\' +Convert(VARCHAR,IdCheck)+'\'+FileGuid+'.tif' FROM UploadFiles WITH(NOLOCK) WHERE IdDocumentType=69 AND IdReference = IdCheck AND LastChange_LastNoteChange LIKE '%front%'),
		  Folio=IdCheck,
		  TrackingNumber=ClaimCheck,
		  DateOfCreation =DateOfMovement,
		  TotalOperation = Amount, -- Fee, 
		  Fee,
		  ProviderFee= Comission, 
		  Amount = Amount, 
		  TotalAmountToCorporate=Amount-Fee+Comission, 
		  AgentCommission=0, 
		  CorpCommission=0, 
		  c.idStatus, 
		  StatusName, 
		  LocalAmount=Amount, 
		  LocalCurrency='USD', 
		  Country='Estados Unidos', 
		  CustomerName= c.Name+' '+FirstLastName+' '+SecondLastName, 
		  PhoneNumber='', 
		  CheckNumber=CheckNumber, 
		  RoutingNumber=RoutingNumber, 
		  AccountNumber=Account, 
		  Bank=isnull(b.Name,''), 
		  IssuerName, 
		  IdentificationType,
		  IdCheck,
		  RejectReason = isnull(case when c.IdStatus=31 then (select top 1 note from CheckDetails WITH(NOLOCK) where IdStatus=31 and IdCheck=c.IdCheck order by 1 desc) else '' end,'')
		  FROM Checks AS c WITH(NOLOCK)
			 INNER JOIN [Status] AS s WITH(NOLOCK) ON s.idStatus = c.IdStatus
			 LEFT JOIN CheckProcessorBank AS b WITH(NOLOCK) ON b.IdCheckProcessorBank = c.IdCheckProcessorBank
		  WHERE IdAgent =@IdAgent
			 AND 5 = @ProductType
			 AND c.DateOfMovement >= isnull(@BeginDate,c.DateOfMovement)
			 AND c.DateOfMovement <= isnull(@EndDate,c.DateOfMovement)
			 AND (EXISTS (SELECT 1 FROM @FastCustomer) AND c.idCustomer IN (SELECT idCustomer FROM @FastCustomer)
				OR NOT EXISTS (SELECT 1 FROM @FastCustomer)
				)
			 --agregar folio
			 and c.IdCheck=isnull(@TransferFolio,c.IdCheck)
			 AND C.EnteredByIdUser = (CASE (dbo.fn_ProductsPermissions(@IdUser, @ProductType)) WHEN 1 THEN C.EnteredByIdUser ELSE @IdUser END) /*Req_M2An055*/;
		
 	SELECT idAgent
	   , IdOtherProduct
	   , [Description]
	   , idProvider
	   , ProviderName
	   , Biller
	   , Product
	   , Folio
	   , TrackingNumber
	   , DateOfCreation
	   , TotalOperation
	   , Fee
	   , ProviderFee
	   , Amount
	   , TotalAmountToCorporate
	   , AgentCommission
	   , CorpCommission
	   , idStatus
	   , statusName
	   , LocalAmount
	   , LocalCurrency
	   , Country
	   , CustomerName
	   , PhoneNumber
	   , CheckNumber
	   , RoutingNumber
	   , AccountNumber
	   , Bank 
	   , IssuerName 
	   , IdentificationType
	   , internalid 
	   , RejectReason FROM @results  where Folio not in (SELECT Folio FROM @results where (idotherProduct=18 or idotherProduct=19) and idstatus in (1,31)) order by DateOfCreation desc  -- 06022019_azavala
END 





