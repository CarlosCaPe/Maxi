
CREATE   PROCEDURE [dbo].[st_FindMoneyOrders]
    @BeginDate DATETIME,
    @EndDate DATETIME,
    @IdAgent INT,
	@AdditionalFilter VARCHAR(4000) = NULL
AS
/********************************************************************
<Author>Roman Arce</Author>
<app>MaxiAgente</app>
<Description>This stored is used in agent for search screen</Description>
<ChangeLog>
	<log Date="25/01/2016" Author="raarce">Creacion del Store</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	DECLARE @SearchOption INT;
	DECLARE @XML XML;
	
	IF ((@AdditionalFilter IS NOT NULL) AND len(@AdditionalFilter) > 0)
	BEGIN
		SET @XML = CAST(@AdditionalFilter AS XML)
	END
	
	IF @BeginDate IS NOT NULL
		SELECT @BeginDate = [dbo].[RemoveTimeFromDatetime] (@BeginDate)
		
	IF @EndDate IS NOT NULL
		SELECT @EndDate = [dbo].[RemoveTimeFromDatetime](@EndDate+1);
		
	DECLARE @ExistsParametersXml BIT;
	SET @ExistsParametersXml =0;
	IF EXISTS (SELECT 1 FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)') IN ('Folio','CustomerName','CustomerFirstLastName','CustomerPhone','VIPCard'))
	BEGIN
		SET @ExistsParametersXml = 1;
		DECLARE
			@FTSCTransferFolio BIGINT,
			@FTSCustomerName VARCHAR(200),
			@FTSCustomerFirstLastName VARCHAR(200),
			@FTSCustomerSecondLastName VARCHAR(200),
			@FTSCustomerPhone VARCHAR(200),
			@FTSCustomerPhoneNotFormatted VARCHAR(200),
			@FTSCustomerVCard VARCHAR(200);
			
		SELECT @FTSCTransferFolio = doc.col.value('Value[1]', 'VARCHAR(200)') FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)')='Folio';
		SELECT @FTSCustomerName  = doc.col.value('Value[1]', 'VARCHAR(200)') FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)')='CustomerName';
		SELECT @FTSCustomerFirstLastName = doc.col.value('Value[1]', 'VARCHAR(200)') FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)')='CustomerFirstLastName';
		SELECT @FTSCustomerSecondLastName = doc.col.value('Value[1]', 'VARCHAR(200)') FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)')='CustomerSecondLastName';
		SELECT @FTSCustomerPhone = dbo.fnFormatPhoneNumber(dbo.fn_GetNumeric(doc.col.value('Value[1]', 'VARCHAR(200)'))) FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)')='CustomerPhone';
		SELECT @FTSCustomerPhoneNotFormatted = dbo.fn_GetNumeric(doc.col.value('Value[1]', 'VARCHAR(200)')) FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)')='CustomerPhone';
		SELECT @FTSCustomerVCard = doc.col.value('Value[1]', 'VARCHAR(200)') FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)')='VIPCard';
	END
	
	--@SearchOption = 1 Busqueda por Fechas
	--@SearchOption = 2 Busqueda por Secuencia
	--@SearchOption = 3 Busqueda por Celular
	--@SearchOption = 4 Busqueda por Nombre, Apellido Paterno, Apellido Materno 
	--@SearchOption = 5 Busqueda por Tarjeta VIP
	
	IF @ExistsParametersXml = 0
	BEGIN
		SET @SearchOption = 1
	END
	ELSE
	BEGIN
		IF @FTSCTransferFolio IS NOT NULL
			SET @SearchOption = 2
		ELSE IF @FTSCustomerPhone IS NOT NULL
			SET @SearchOption = 3
		ELSE IF @FTSCustomerName IS NOT NULL AND @FTSCustomerFirstLastName IS NOT NULL
			SET @SearchOption = 4
		ELSE IF	@FTSCustomerVCard IS NOT NULL
			SET @SearchOption = 5
	END
	
	CREATE TABLE #tmpMoneyOrder(
		[RowNumber] INT IDENTITY,
		[IdSaleRecord] INT
		);

	CREATE INDEX IX_tmpTransfer_IdTransfer ON #tmpMoneyOrder (IdSaleRecord)

	--Validar Opción 1 Busqueda por Fechas
	IF @SearchOption = 1
	BEGIN
		INSERT INTO #tmpMoneyOrder
		SELECT R.IdSaleRecord
		FROM [MoneyOrder].[SaleRecord] R WITH (NOLOCK) 
		WHERE R.IdAgent = @IdAgent AND R.IdStatus <> 1
		AND R.CreationDate BETWEEN @BeginDate AND @EndDate
	END
	--Validar Opción 2 Busqueda por Folio
	ELSE IF @SearchOption = 2
	BEGIN
		INSERT INTO #tmpMoneyOrder
		SELECT R.IdSaleRecord
		FROM [MoneyOrder].[SaleRecord] R WITH (NOLOCK) 
		WHERE R.IdAgent = @IdAgent AND R.IdStatus <> 1
		AND R.SequenceNumber = @FTSCTransferFolio
	END
	--Validar Opción 3 Busqueda por Celular
	ELSE IF @SearchOption = 3
	BEGIN
		SELECT @FTSCustomerPhone = '"'+@FTSCustomerPhone+'*"';
			
		INSERT INTO #tmpMoneyOrder
		SELECT R.IdSaleRecord
		FROM [MoneyOrder].[SaleRecord] R WITH (NOLOCK) 
		WHERE R.IdAgent = @IdAgent AND R.IdStatus <> 1
		AND R.IdCustomer IN (SELECT IdCustomer FROM Customer WITH (NOLOCK)  WHERE Contains(CelullarNumber,@FTSCustomerPhone) OR Contains(CelullarNumber,@FTSCustomerPhoneNotFormatted))
	END
	--Validar Opción 4 Busqueda por Nombre, Apellido Paterno, Apellido Materno 
	ELSE IF @SearchOption = 4
	BEGIN
		SELECT @FTSCustomerName = '"'+@FTSCustomerName+'*"',
		@FTSCustomerFirstLastName = '"'+@FTSCustomerFirstLastName+'*"';
					
		INSERT INTO #tmpMoneyOrder
		SELECT R.IdSaleRecord
		FROM [MoneyOrder].[SaleRecord] R WITH (NOLOCK) 
		WHERE R.IdAgent = @IdAgent AND R.IdStatus <> 1
		AND R.IdCustomer IN  (SELECT IdCustomer FROM Customer  WITH (NOLOCK)
				WHERE CONTAINS(Name,@FTSCustomerName)
				AND CONTAINS(FirstLastName,@FTSCustomerFirstLastName)
				AND ((@FTSCustomerSecondLastName IS NOT NULL AND SecondLastName LIKE @FTSCustomerSecondLastName+'%')
				OR @FTSCustomerSecondLastName IS NULL))
	END
	--Validar Opción 5 Busqueda por Tarjeta VIP
	ELSE IF @SearchOption = 5
	BEGIN	
		INSERT INTO #tmpMoneyOrder
		SELECT R.IdSaleRecord
		FROM [MoneyOrder].[SaleRecord] R WITH (NOLOCK) 
		WHERE R.IdAgent = @IdAgent AND R.IdStatus <> 1
		AND R.IdCustomer IN (SELECT vp.IdCustomer FROM CardVIP vp  WITH (NOLOCK) 
				JOIN Customer c  WITH (NOLOCK) 
				ON c.IdCustomer = vp.IdCustomer
				AND vp.IdGenericStatus = 1
				AND vp.CardNumber = @FTSCustomerVCard)
	END
	
	SELECT
		R.IdSaleRecord IdMoneyOrder,
		R.CreationDate CreationDate,
		R.SequenceNumber Sequence,
		R.CustomerName + ' ' + R.CustomerFirstLastName + IIF(R.CustomerSecondLastName = '', '', ' ' + R.CustomerSecondLastName) CustomerName,
		R.CustomerCelullarNumber CustomerPhone,
		R.Payee Payee,
		R.Amount Amount,
		R.FeeAmount Fee,
		R.TotalAmount Total,
		S.StatusName StatusName,
		C.Zipcode CustomerZipCode,
		C.City CustomerCity,
		C.State CustomerState,
		C.Address CustomerAddress,
		C.Country CustomerCountry,
		R.IdStatus IdStatus
	FROM 
		[MoneyOrder].[SaleRecord] R WITH (NOLOCK) 
		INNER JOIN #tmpMoneyOrder T ON T.IdSaleRecord = R.IdSaleRecord
		INNER JOIN [dbo].[Status] S WITH (NOLOCK) ON S.IdStatus = R.IdStatus
		INNER JOIN [dbo].[Customer] C WITH (NOLOCK) ON C.IdCustomer = R.IdCustomer
	ORDER BY
		R.IdSaleRecord DESC
		
	DROP TABLE #tmpMoneyOrder

END TRY
BEGIN CATCH
	DECLARE @Message varchar(max) = ERROR_MESSAGE()
	DECLARE @ErrorLine varchar(20) = CONVERT(VARCHAR(20), ERROR_LINE())
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_FindMoneyOrders', GETDATE(), 'Line: ' + @ErrorLine + '. ' + @Message)
END CATCH
