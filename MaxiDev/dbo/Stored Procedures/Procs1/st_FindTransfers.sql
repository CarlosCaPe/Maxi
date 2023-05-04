

CREATE     PROCEDURE [dbo].[st_FindTransfers]   
	@StatusesPreselected XML,
    @BeginDate DATETIME,
    @EndDate DATETIME,
    @IdAgent INT,
    @Customer NVARCHAR(MAX) = NULL,
    @Beneficiary NVARCHAR(MAX)= NULL,
    @IdStatus INT = NULL,
    @TransferFolio INT = NULL,
    @IdCurrency INT = NULL,
    @IdPayer INT = NULL,
    @IsTimeForVerifyHold BIT = NULL,
    @IsMonoAgent BIT = 0,
    @AdditionalFilter VARCHAR(4000) = NULL,
    @StatusesOmitted XML = NULL,
	@IdUser INT = NULL
AS


/********************************************************************
<Author>Francisco Lara</Author>
<app>MaxiAgente</app>
<Description>This stored is used in agent for search screen</Description>
<ChangeLog>
	<log Date="25/01/2016" Author="FranciscoLara">Creacion del Store</log>
	<log Date="13/12/2016" Author="mdelgado">Se agrego informacion de la ultima notificacion recibida de la transferencia.</log>
	<log Date="03/01/2017" Author="Fgonzalez">Se agregaron los estatus para cacnelacion y rechazo y se corrige bug con la ultima nota..</log>
	<log Date="28/04/2017" Author="mdelgado">Fix.. Aparicion de transferencia doble por notificaciones con status en detalles diferentes y fuera de rechazado o cancelado. </log>
	<log Date="12/09/2017" Author="Fgonzalez">Se agrega columna Fee, StateFee , PayInfo y HasTicket y Filtro AdditionalFilter</log>
	<log Date="25/10/2017" Author="Jvelarde">Se agrega columna AmountToReimburse</log>
	<log Date="26/10/2017" Author="snevarez">Modificacion S44:MA_023</log>
	<log Date="26/10/2017" Author="jmoreno">Se agrega el campo IsActiveRealse</log>
	<log Date="05/12/2017" Author="dalñmeida">Agregar motivo de rechazo</log>
	<log Date="20/12/2017" Author="mhinojo">Agregar state al JSON de payment info</log>
	<log Date="24/04/2018" Author="azavala">Add IsExternalToMaxi filter</log>
	<log Date="18/05/2015" Author="snevarez">Modificacion Req_M2An055</log>
	<log Date="25/07/2018" Author="esalazar">Add field IdBeneficiary</log>
	<log Date="07/08/2018" Author="esalazar">Add field NumModify</log>
	<log Date="17/08/2018" Author="esalazar">Add field IsModify30</log>
	<log Date="14/12/2018" Author="jmolina">Change index on table #temp and generate new index on #tmpMessages and variable table converted in table temporary --#1</log>
	<log Date="21/11/2019" Author="adominguez">Se quita la opcion de habilitar el boton de ComplianceFormat para las transacciones ya cerradas --#2</log>
	<log Date="05/08/2020" Author="jairgarza">Se detecta si se piden solo estatus cancel/rejected y se filtra por DateStatusChanged --#2</log>
	<log Date="02/24/2021" Author="jcsierra">En caso de modificaciones, se agrega un cambio de nombre en los status y detalle de la nueva transaccion</log>
	<log Date="03/17/2021" Author="jcsierra">Se oculta el botón de modificaciones para depósitos</log>
	<log Date="01/12/2022" Author="jcsierra">Se muestran los Origin de TDD</log>
	<log Date="02/14/2022" Author="jcsierra">Se bloquean las modificaciones para transacciones de TDD</log>
	<log Date="2022/06/13" Author="jcsierra">Se bloquean las modificaciones para envios domesticos</log>
	<log Date="2022/10/14" Author="gareyes">Se agrega el número de teléfono no formateado para mejorar resultados de búsqueda por número de teléfono.</log>
	<log Date="2022/11/15" Author="gareyes">Se agrega el parámetro histtrn para agregar la última nota del histórico en pagos rechazados para información del agente </log>
	<log Date="2022/12/07" Author="jcsierra">Se realizan optimizaciones en base de datos</log>
	<log Date="16/01/2023" Author="raarce">Se realizan cambios en base a ticket BM-211</log>
	<log Date="09/02/2023" Author="jacardenas">Se realizan cambios en base a ticket BM-788, se modifican las consultas y sus respectivos filtros</log>
	<log Date="15/02/2023" Author="jcsierra">Se corrige busqueda de telefono</log>
	<log Date="08/02/2023" Author="raarce">Se agrego la columna IdGateway</log>
	<log Date="17/02/2023" Author="jcsierra">Se corrige JOIN de CardVIP</log>
	<log Date="17/02/2023" Author="maprado">BM-707 Se quita opcion de modificar para transacciones de Honduras que no son del mismo dia</log>
	<log Date="24/02/2023" Author="jacardenas">Se corrige la lógica del proceso de cancelados INC- 7420 y se ajusta el proceso de transfernote duplicados INC- 7404</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
		SET NOCOUNT ON;

		DECLARE @SearchOption INT;
		DECLARE @XML XML
		
		IF ((@AdditionalFilter IS NOT NULL) AND len(@AdditionalFilter) > 0) 
		BEGIN 
			SET @XML = CAST(@AdditionalFilter AS XML)
		END 
	
		IF @IsMonoAgent = 1 AND @TransferFolio > 0 SET @BeginDate = DATEADD(MONTH,-1,GETDATE()) -- Mono Agent can get transfers from 1 month ago only

		SET @IsTimeForVerifyHold = ISNULL(@IsTimeForVerifyHold,0)

		IF @BeginDate IS NOT NULL
			SELECT @BeginDate = [dbo].[RemoveTimeFromDatetime] (@BeginDate)

		IF @EndDate IS NOT NULL
			SELECT @EndDate = [dbo].[RemoveTimeFromDatetime](@EndDate+1);

		DECLARE @ExistsParametersXml BIT;   
		SET @ExistsParametersXml =0;
        IF EXISTS (SELECT 1 FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)') IN ('Folio','CustomerName','CustomerFirstLastName','CustomerPhone','VIPCard'))--BM-211
		BEGIN
			   SET @ExistsParametersXml = 1;
			   DECLARE 
				 @FTSCustomerName VARCHAR(200),
				 @FTSCustomerFirstLastName VARCHAR(200), 
				 @FTSCustomerSecondLastName VARCHAR(200),
				 @FTSCustomerPhone VARCHAR(200),
				 @FTSCustomerPhoneNotFormatted VARCHAR(200),
				 @FTSCustomerVCard VARCHAR(200);

			   SELECT @TransferFolio = doc.col.value('Value[1]', 'VARCHAR(200)') FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)')='Folio';		--BM-211
			   SELECT @FTSCustomerName  = doc.col.value('Value[1]', 'VARCHAR(200)') FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)')='CustomerName';		--BM-211
			   SELECT @FTSCustomerFirstLastName = doc.col.value('Value[1]', 'VARCHAR(200)') FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)')='CustomerFirstLastName';		--BM-211
			   SELECT @FTSCustomerSecondLastName = doc.col.value('Value[1]', 'VARCHAR(200)') FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)')='CustomerSecondLastName';		--BM-211
			   SELECT @FTSCustomerPhone = dbo.fnFormatPhoneNumber(doc.col.value('Value[1]', 'VARCHAR(200)')) FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)')='CustomerPhone';		--BM-211
			   SELECT @FTSCustomerPhoneNotFormatted = doc.col.value('Value[1]', 'VARCHAR(200)') FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)')='CustomerPhone';		--BM-211
			   SELECT @FTSCustomerVCard = doc.col.value('Value[1]', 'VARCHAR(200)') FROM @XML.nodes('/ArrayOfFilter/Filter') doc(col) WHERE doc.col.value('Type[1]', 'VARCHAR(200)')='VIPCard';		--BM-211
			   IF (@TransferFolio IS NOT NULL OR @FTSCustomerName IS NOT NULL OR @FTSCustomerFirstLastName IS NOT NULL OR @FTSCustomerSecondLastName IS NOT NULL
			   OR @FTSCustomerPhone IS NOT NULL OR @FTSCustomerPhoneNotFormatted IS NOT NULL OR @FTSCustomerVCard IS NOT NULL)
			   BEGIN 
				  SET @BeginDate = NULL
	 			  SET @EndDate = NULL 
			   END 
			END

		DECLARE @hasStatus BIT	
	    IF EXISTS(SELECT 1 FROM @StatusesPreselected.nodes('/statuses/status') doc(col))		--BM-211
		BEGIN
			SET @hasStatus = 1
		END
		ELSE
		BEGIN
			SET @hasStatus = 0
		END
			
		DECLARE @IdGenericStatusEnable INT
		SET @IdGenericStatusEnable = 1

		--Si solo son estatus de cancell, reject
		DECLARE @hasOnlyStatusCan INT = 0
		DECLARE @DateStatusBegin DATETIME = NULL
		DECLARE @DateStatusEnd DATETIME = NULL
		
		IF @hasStatus = 1
		BEGIN
			SET @hasOnlyStatusCan = 1
			IF EXISTS(SELECT 1 FROM @StatusesPreselected.nodes('/statuses/status') doc(col)  WHERE doc.col.value('@id', 'int') NOT IN ( 22, 31 ))
			BEGIN
				SET @hasOnlyStatusCan = 0
			END
        END
        
		
		IF (@hasOnlyStatusCan = 1) AND (@BeginDate IS NOT NULL)
		BEGIN
		    SET @DateStatusBegin = CAST(@BeginDate AS DATE)
			SET @DateStatusEnd = CAST(@EndDate AS DATE)
			SET @BeginDate = NULL
			SET @EndDate = NULL
        END

		--@SearchOption = 1 Busqueda por Folio
		--@SearchOption = 2 Busqueda por Fechas
		--@SearchOption = 3 Busqueda por Celular
		--@SearchOption = 4 Busqueda por Nombre, Apellido Paterno, Apellido Materno 
		--@SearchOption = 5 Busqueda por Tarjeta VIP
		--@SearchOption = 6 Busqueda por Fechas y cliente
		--@SearchOption = 7 Busqueda por Fechas y beneficiario
		--@SearchOption = 8 Busqueda por Fechas y status
		--@SearchOption = 9 Busqueda por Fechas y moneda
		--@SearchOption = 10 Busqueda por Fechas y payer

		IF @TransferFolio IS NOT NULL
			SET @SearchOption = 1
		ELSE IF @BeginDate IS NOT NULL OR @EndDate IS NOT NULL OR @DateStatusBegin IS NOT NULL OR @DateStatusEnd IS NOT NULL
			SET @SearchOption = 2
		ELSE IF @FTSCustomerPhone IS NOT NULL
			SET @SearchOption = 3
		ELSE IF @FTSCustomerName IS NOT NULL AND @FTSCustomerFirstLastName IS NOT NULL
			SET @SearchOption = 4
		ELSE IF	@FTSCustomerVCard IS NOT NULL
			SET @SearchOption = 5
		ELSE IF	@Customer IS NOT NULL
			SET @SearchOption = 6
		ELSE IF	@Beneficiary IS NOT NULL
			SET @SearchOption = 7
		ELSE IF	@IdStatus IS NOT NULL
			SET @SearchOption = 8
		ELSE IF	@IdCurrency IS NOT NULL
			SET @SearchOption = 9
		ELSE IF	@IdPayer IS NOT NULL
			SET @SearchOption = 10


		CREATE TABLE #tmpTransfer(
			[RowNumber] INT IDENTITY,
			[IdTransfer] INT
		);
		CREATE TABLE #tmpTransferClosed(
			[RowNumber] INT IDENTITY,
			[IdTransferClosed] INT
		);

		CREATE INDEX IX_tmpTransfer_IdTransfer ON #tmpTransfer (IdTransfer)
		CREATE INDEX IX_tmpTransferClosed_IdTransferClosed ON #tmpTransferClosed (IdTransferClosed)

		--Validar Opción 1 Busqueda por Folio
		IF @SearchOption = 1
		BEGIN
			INSERT INTO #tmpTransfer
			SELECT T.IdTransfer 
			FROM [dbo].[Transfer] T WITH (NOLOCK) 
			LEFT JOIN [dbo].[TransferHolds] Th WITH (NOLOCK) 
			ON Th.[IdTransfer] = T.[IdTransfer]
			WHERE T.Folio = @TransferFolio
			AND T.IdAgent =@IdAgent
			AND  (@hasStatus = 0 OR (T.IdStatus in (SELECT doc.col.value('@id', 'int') id FROM @StatusesPreselected.nodes('/statuses/status') doc(col)))
									   OR (T.IdStatus = 41 and Th.IdStatus in (SELECT doc.col.value('@id', 'int') id FROM @StatusesPreselected.nodes('/statuses/status') doc(col)) and TH.IsReleased is null));

			INSERT INTO #tmpTransferClosed
			SELECT IdTransferClosed 
			FROM [dbo].TransferClosed T WITH (NOLOCK) 
			WHERE T.Folio = @TransferFolio
			AND T.IdAgent =@IdAgent
			AND  (@hasStatus = 0 OR (T.IdStatus in (SELECT doc.col.value('@id', 'int') id FROM @StatusesPreselected.nodes('/statuses/status') doc(col))));
		END
		--Validar Opción 2 Busqueda por Fechas
		ELSE IF @SearchOption = 2
		BEGIN
			INSERT INTO #tmpTransfer
			SELECT T.IdTransfer 
			FROM [dbo].[Transfer] T WITH (NOLOCK) 
			LEFT JOIN [dbo].[TransferHolds] Th WITH (NOLOCK) 
			ON Th.[IdTransfer] = T.[IdTransfer]
			WHERE (@BeginDate IS NULL OR T.DateOfTransfer>= @BeginDate)
					AND (@EndDate IS NULL OR T.DateOfTransfer<= @EndDate)
					AND (@DateStatusBegin IS NULL OR T.DateStatusChange >= @DateStatusBegin)
					AND (@DateStatusEnd IS NULL OR T.DateStatusChange <= @DateStatusEnd)
					AND T.IdAgent =@IdAgent
					AND  (@hasStatus = 0 OR (T.IdStatus in (SELECT doc.col.value('@id', 'int') id FROM @StatusesPreselected.nodes('/statuses/status') doc(col)))
									   OR (T.IdStatus = 41 and Th.IdStatus in (SELECT doc.col.value('@id', 'int') id FROM @StatusesPreselected.nodes('/statuses/status') doc(col)) and TH.IsReleased is null));

			INSERT INTO #tmpTransferClosed
			SELECT IdTransferClosed 
			FROM [dbo].TransferClosed T WITH (NOLOCK) 
			WHERE (@BeginDate IS NULL OR T.DateOfTransfer>= @BeginDate)
					AND (@EndDate IS NULL OR T.DateOfTransfer<= @EndDate)
					AND (@DateStatusBegin IS NULL OR T.DateStatusChange >= @DateStatusBegin)
					AND (@DateStatusEnd IS NULL OR T.DateStatusChange <= @DateStatusEnd)
					AND T.IdAgent =@IdAgent
					AND  (@hasStatus = 0 OR (T.IdStatus in (SELECT doc.col.value('@id', 'int') id FROM @StatusesPreselected.nodes('/statuses/status') doc(col))));
		END
		--Validar Opción 3 Busqueda por Celular
		ELSE IF @SearchOption = 3
		BEGIN
			SELECT @FTSCustomerPhone = '"'+@FTSCustomerPhone+'*"';

			INSERT INTO #tmpTransfer
			SELECT T.IdTransfer 
			FROM [dbo].[Transfer] T WITH (NOLOCK) 
			LEFT JOIN [dbo].[TransferHolds] Th WITH (NOLOCK) 
			ON Th.[IdTransfer] = T.[IdTransfer]
			WHERE T.IdAgent =@IdAgent
				AND T.[IdCustomer] IN (SELECT IdCustomer FROM Customer WITH (NOLOCK)  WHERE Contains(CelullarNumber,@FTSCustomerPhone) OR Contains(CelullarNumber,@FTSCustomerPhoneNotFormatted))
				AND  (@hasStatus = 0 OR (T.IdStatus in (SELECT doc.col.value('@id', 'int') id FROM @StatusesPreselected.nodes('/statuses/status') doc(col)))
									   OR (T.IdStatus = 41 and Th.IdStatus in (SELECT doc.col.value('@id', 'int') id FROM @StatusesPreselected.nodes('/statuses/status') doc(col)) and TH.IsReleased is null));

			INSERT INTO #tmpTransferClosed
			SELECT IdTransferClosed 
			FROM [dbo].TransferClosed T WITH (NOLOCK) 
			WHERE T.IdAgent =@IdAgent
				AND T.[IdCustomer] IN (SELECT IdCustomer FROM Customer WITH (NOLOCK)  WHERE Contains(CelullarNumber,@FTSCustomerPhone) OR Contains(CelullarNumber,@FTSCustomerPhoneNotFormatted))
				AND  (@hasStatus = 0 OR (T.IdStatus in (SELECT doc.col.value('@id', 'int') id FROM @StatusesPreselected.nodes('/statuses/status') doc(col))));
		END
		--Validar Opción 4 Busqueda por Nombre, Apellido Paterno, Apellido Materno 
		ELSE IF @SearchOption = 4
		BEGIN
			 SELECT @FTSCustomerName = '"'+@FTSCustomerName+'*"'
					,@FTSCustomerFirstLastName = '"'+@FTSCustomerFirstLastName+'*"';

			INSERT INTO #tmpTransfer
			SELECT T.IdTransfer 
			FROM [dbo].[Transfer] T WITH (NOLOCK) 
			LEFT JOIN [dbo].[TransferHolds] Th WITH (NOLOCK) 
			ON Th.[IdTransfer] = T.[IdTransfer]
			WHERE T.IdAgent =@IdAgent AND T.[IdCustomer] IN  (SELECT IdCustomer FROM Customer  WITH (NOLOCK) 
															WHERE CONTAINS(Name,@FTSCustomerName) 
															AND CONTAINS(FirstLastName,@FTSCustomerFirstLastName)
															AND ((@FTSCustomerSecondLastName IS NOT NULL AND SecondLastName LIKE @FTSCustomerSecondLastName+'%') 
															OR @FTSCustomerSecondLastName IS NULL))
									AND  (@hasStatus = 0 OR (T.IdStatus in (SELECT doc.col.value('@id', 'int') id FROM @StatusesPreselected.nodes('/statuses/status') doc(col)))
									OR (T.IdStatus = 41 and Th.IdStatus in (SELECT doc.col.value('@id', 'int') id FROM @StatusesPreselected.nodes('/statuses/status') doc(col)) and TH.IsReleased is null));

			INSERT INTO #tmpTransferClosed
			SELECT IdTransferClosed  
			FROM [dbo].TransferClosed T WITH (NOLOCK) 
			WHERE T.IdAgent =@IdAgent AND T.[IdCustomer] IN  (SELECT IdCustomer FROM Customer  WITH (NOLOCK) 
															WHERE CONTAINS(Name,@FTSCustomerName) 
															AND CONTAINS(FirstLastName,@FTSCustomerFirstLastName)
															AND ((@FTSCustomerSecondLastName IS NOT NULL AND SecondLastName LIKE @FTSCustomerSecondLastName+'%') 
															OR @FTSCustomerSecondLastName IS NULL))
									  AND  (@hasStatus = 0 OR (T.IdStatus in (SELECT doc.col.value('@id', 'int') id FROM @StatusesPreselected.nodes('/statuses/status') doc(col))));
		END
		--Validar Opción 5 Busqueda por Tarjeta VIP
		ELSE IF @SearchOption = 5
		BEGIN

			INSERT INTO #tmpTransfer
			SELECT T.IdTransfer 
			FROM [dbo].[Transfer] T WITH (NOLOCK) 
			LEFT JOIN [dbo].[TransferHolds] Th WITH (NOLOCK) 
			ON Th.[IdTransfer] = T.[IdTransfer]
			WHERE T.IdAgent =@IdAgent AND T.[IdCustomer] IN (SELECT vp.IdCustomer FROM CardVIP vp  WITH (NOLOCK) 
															JOIN Customer c  WITH (NOLOCK) 
															ON c.IdCustomer = vp.IdCustomer
															AND vp.IdGenericStatus = 1
															AND vp.CardNumber = @FTSCustomerVCard)
									  AND  (@hasStatus = 0 OR (T.IdStatus in (SELECT doc.col.value('@id', 'int') id FROM @StatusesPreselected.nodes('/statuses/status') doc(col)))
									  OR (T.IdStatus = 41 and Th.IdStatus in (SELECT doc.col.value('@id', 'int') id FROM @StatusesPreselected.nodes('/statuses/status') doc(col)) and TH.IsReleased is null));


			INSERT INTO #tmpTransferClosed
			SELECT IdTransferClosed FROM [dbo].TransferClosed T  WITH (NOLOCK) 
			WHERE T.IdAgent =@IdAgent AND T.[IdCustomer] IN (SELECT vp.IdCustomer FROM CardVIP vp  WITH (NOLOCK) 
															JOIN Customer c  WITH (NOLOCK) 
															ON c.IdCustomer = vp.IdCustomer
															AND vp.IdGenericStatus = 1
															AND vp.CardNumber = @FTSCustomerVCard)
									  AND  (@hasStatus = 0 OR (T.IdStatus in (SELECT doc.col.value('@id', 'int') id FROM @StatusesPreselected.nodes('/statuses/status') doc(col))));
		END
		--Validar Opción 6 Busqueda por Fechas y Cliente
		ELSE IF @SearchOption = 6
		BEGIN
			INSERT INTO #tmpTransfer
			SELECT IdTransfer 
			FROM [dbo].[Transfer] T WITH (NOLOCK) 
			WHERE  T.IdAgent =@IdAgent AND
				   T.[IdCustomer] IN (SELECT IdCustomer FROM Customer  WITH (NOLOCK) 
									 WHERE FullName Like '%' + REPLACE(@Customer,' ','') + '%') AND
					(@BeginDate IS NULL OR T.DateOfTransfer>= @BeginDate)
					AND (@EndDate IS NULL OR T.DateOfTransfer<= @EndDate)
					AND (@DateStatusBegin IS NULL OR T.DateStatusChange >= @DateStatusBegin)
					AND (@DateStatusEnd IS NULL OR T.DateStatusChange <= @DateStatusEnd)

			INSERT INTO #tmpTransferClosed
			SELECT IdTransferClosed 
			FROM [dbo].TransferClosed T WITH (NOLOCK) 
			WHERE  T.IdAgent =@IdAgent AND
				   T.[IdCustomer] IN(SELECT IdCustomer FROM Customer  WITH (NOLOCK) 
									 WHERE FullName Like '%' + REPLACE(@Customer,' ','') + '%') AND
					(@BeginDate IS NULL OR T.DateOfTransfer>= @BeginDate)
					AND (@EndDate IS NULL OR T.DateOfTransfer<= @EndDate)
					AND (@DateStatusBegin IS NULL OR T.DateStatusChange >= @DateStatusBegin)
					AND (@DateStatusEnd IS NULL OR T.DateStatusChange <= @DateStatusEnd)
		END
		--Validar Opción 7 Busqueda por Fechas y beneficiario
		ELSE IF @SearchOption = 7
		BEGIN
			INSERT INTO #tmpTransfer
			SELECT IdTransfer 
			FROM [dbo].[Transfer] T WITH (NOLOCK) 
			WHERE T.IdAgent =@IdAgent 
					AND T.[IdBeneficiary] IN (SELECT IdBeneficiary FROM [dbo].[Beneficiary]  WITH (NOLOCK) 
											  WHERE  FullName Like '%' + REPLACE(@Beneficiary,' ','') + '%')
					AND(@BeginDate IS NULL OR T.DateOfTransfer>= @BeginDate)
					AND (@EndDate IS NULL OR T.DateOfTransfer<= @EndDate)
					AND (@DateStatusBegin IS NULL OR T.DateStatusChange >= @DateStatusBegin)
					AND (@DateStatusEnd IS NULL OR T.DateStatusChange <= @DateStatusEnd);

					

			INSERT INTO #tmpTransferClosed
			SELECT IdTransferClosed 
			FROM [dbo].TransferClosed T WITH (NOLOCK) 
			WHERE T.IdAgent =@IdAgent 
					AND T.[IdBeneficiary] IN (SELECT IdBeneficiary FROM [dbo].[Beneficiary]  WITH (NOLOCK) 
											  WHERE  FullName Like '%' + REPLACE(@Beneficiary,' ','') + '%')
					AND(@BeginDate IS NULL OR T.DateOfTransfer>= @BeginDate)
					AND (@EndDate IS NULL OR T.DateOfTransfer<= @EndDate)
					AND (@DateStatusBegin IS NULL OR T.DateStatusChange >= @DateStatusBegin)
					AND (@DateStatusEnd IS NULL OR T.DateStatusChange <= @DateStatusEnd);
		END
		--Validar Opción 8 Busqueda por Fechas y status
		ELSE IF @SearchOption = 8
		BEGIN
			INSERT INTO #tmpTransfer
			SELECT T.IdTransfer 
			FROM [dbo].[Transfer] T WITH (NOLOCK) 
			LEFT JOIN [dbo].[TransferHolds] Th WITH (NOLOCK) 
			on Th.[IdTransfer] = T.[IdTransfer]
			WHERE T.IdAgent =@IdAgent
					AND (@BeginDate IS NULL OR T.DateOfTransfer>= @BeginDate)
					AND (@EndDate IS NULL OR T.DateOfTransfer<= @EndDate)
					AND (@DateStatusBegin IS NULL OR T.DateStatusChange >= @DateStatusBegin)
					AND (@DateStatusEnd IS NULL OR T.DateStatusChange <= @DateStatusEnd)
					AND  T.IdStatus= @IdStatus 
					OR (T.IdStatus = 41 AND Th.IdStatus=@IdStatus AND TH.IsReleased IS NULL);

			INSERT INTO #tmpTransferClosed
			SELECT IdTransferClosed 
			FROM [dbo].TransferClosed T WITH (NOLOCK) 
			WHERE (@BeginDate IS NULL OR T.DateOfTransfer>= @BeginDate)
					AND (@EndDate IS NULL OR T.DateOfTransfer<= @EndDate)
					AND (@DateStatusBegin IS NULL OR T.DateStatusChange >= @DateStatusBegin)
					AND (@DateStatusEnd IS NULL OR T.DateStatusChange <= @DateStatusEnd)
					AND  T.IdStatus= @IdStatus
					AND T.IdAgent =@IdAgent;
		END
		--Validar Opción 9 Busqueda por Fechas y moneda
		ELSE IF @SearchOption = 9
		BEGIN
			INSERT INTO #tmpTransfer
			SELECT T.IdTransfer 
			FROM [dbo].[Transfer] T WITH (NOLOCK) 
			WHERE T.IdAgent =@IdAgent 
					AND T.[IdCountryCurrency] IN (SELECT IdCountryCurrency  FROM [dbo].[CountryCurrency]  WITH (NOLOCK) 
													WHERE IdCurrency = @IdCurrency)
					AND (@BeginDate IS NULL OR T.DateOfTransfer>= @BeginDate)
					AND (@EndDate IS NULL OR T.DateOfTransfer<= @EndDate)
					AND (@DateStatusBegin IS NULL OR T.DateStatusChange >= @DateStatusBegin)
					AND (@DateStatusEnd IS NULL OR T.DateStatusChange <= @DateStatusEnd);

			INSERT INTO #tmpTransferClosed
			SELECT IdTransferClosed 
			FROM [dbo].TransferClosed T WITH (NOLOCK) 
			WHERE  T.IdCurrency = @IdCurrency
					AND T.IdAgent =@IdAgent
					AND (@BeginDate IS NULL OR T.DateOfTransfer>= @BeginDate)
					AND (@EndDate IS NULL OR T.DateOfTransfer<= @EndDate)
					AND (@DateStatusBegin IS NULL OR T.DateStatusChange >= @DateStatusBegin)
					AND (@DateStatusEnd IS NULL OR T.DateStatusChange <= @DateStatusEnd);
					
		END
		--Validar Opción 10 Busqueda por Fechas y payer
		ELSE IF @SearchOption = 10
		BEGIN
			INSERT INTO #tmpTransfer
			SELECT T.IdTransfer 
			FROM [dbo].[Transfer] T WITH (NOLOCK) 
			WHERE (@BeginDate IS NULL OR T.DateOfTransfer>= @BeginDate)
					AND (@EndDate IS NULL OR T.DateOfTransfer<= @EndDate)
					AND (@DateStatusBegin IS NULL OR T.DateStatusChange >= @DateStatusBegin)
					AND (@DateStatusEnd IS NULL OR T.DateStatusChange <= @DateStatusEnd)
					AND  T.IdPayer = @IdPayer
					AND T.IdAgent =@IdAgent;

			INSERT INTO #tmpTransferClosed
			SELECT IdTransferClosed 
			FROM [dbo].TransferClosed T WITH (NOLOCK) 
			WHERE (@BeginDate IS NULL OR T.DateOfTransfer>= @BeginDate)
					AND (@EndDate IS NULL OR T.DateOfTransfer<= @EndDate)
					AND (@DateStatusBegin IS NULL OR T.DateStatusChange >= @DateStatusBegin)
					AND (@DateStatusEnd IS NULL OR T.DateStatusChange <= @DateStatusEnd)
					AND T.IdPayer = @IdPayer
					AND T.IdAgent =@IdAgent;
		END


		CREATE TABLE #tmp
		(
			[RowNumber] INT IDENTITY,
			[IdTransfer] INT,	
			[CustomerName]	NVARCHAR(MAX),
			[CustomerFirstLastName]	NVARCHAR(MAX),
			[CustomerSecondLastName]	NVARCHAR(MAX),
			[CustomerZipcode]	NVARCHAR(MAX),
			[CustomerCity] NVARCHAR(MAX),
			[CustomerState] NVARCHAR(MAX),
			[CustomerAddress]	NVARCHAR(MAX),
			[CustomerPhoneNumber] NVARCHAR(MAX),
			[CustomerCelullarNumber] NVARCHAR(MAX),
			[NumModify] INT,
			IdBeneficiary INT,
			[BeneficiaryName] NVARCHAR(MAX),
			[BeneficiaryFirstLastName] NVARCHAR(MAX),
			[BeneficiarySecondLastName] NVARCHAR(MAX),
			[BeneficiaryCountry] NVARCHAR(MAX),
			[BeneficiaryZipcode] NVARCHAR(MAX),
			[BeneficiaryState] NVARCHAR(MAX),
			[BeneficiaryCity] NVARCHAR(MAX),
			[BeneficiaryAddress] NVARCHAR(MAX),
			[BeneficiaryPhoneNumber] NVARCHAR(MAX),
			[BeneficiaryCelularNumber] NVARCHAR(MAX),
			[SchemaName] NVARCHAR(MAX),
			[PaymentName] NVARCHAR(MAX),
			[PayerName]	NVARCHAR(MAX),
			[BranchName] NVARCHAR(MAX),
			[CityName] NVARCHAR(MAX),
			[StateName]	NVARCHAR(MAX),
			[ExRate] MONEY,
			[Commission] MONEY,
			[AmountInDollars] MONEY,
			[AmountInMN] MONEY,
			[Total]	MONEY,
			[DateOfTransfer] DATETIME,
			[Folio]	INT,
			[StatusName] VARCHAR(500),
			[DepositAccountNumber] NVARCHAR(MAX),
			[IdAgent] INT,
			[ClaimCode] NVARCHAR(MAX),
			[Semaphore] NVARCHAR(MAX),
			[IdPreTransfer] INT,
			[Idcountry] INT,
			[IdCustomer] INT,
			[IdStatus] INT,
			[SSNRequired] BIT
			,[HasComplianceFormat] BIT
			,[ComplianceFormats] NVARCHAR(MAX)
			,[PayDate] DATETIME
			,[PayDateReady] DATETIME
			,[AccountTypeName] NVARCHAR(MAX),
			[idreasonforcancel] INT NULL,
			Fee MONEY,
			PayInfo VARCHAR(8000),
			StateFee MONEY,
			HasTicket BIT,
			CardNumber VARCHAR(200),
			iscancel30 bit,
			[isModify30] bit,
			AmountToReimburse money not null default 0,
			CancelReason NVARCHAR(MAX),
			IsActiveRealse bit
			,IdPaymentType int
			,isModifyV2 bit,
			Discount		MONEY,
			IdPaymentMethod	INT,
			PaymentMethod	VARCHAR(200),
			TotalAmountPaid	MONEY,
			IdGateway INT
		);

		CREATE UNIQUE INDEX IX_tmp_RowNumber ON #tmp (RowNumber) INCLUDE([IdTransfer], [HasComplianceFormat]) --#1
		CREATE INDEX IX_tmp_IdTransfer ON #tmp (IdTransfer, IdStatus, idReasonForCancel) --#1

		DECLARE @Formats NVARCHAR(MAX)
    
		INSERT INTO #tmp
		SELECT * FROM
		(
			SELECT
				T.[IdTransfer],
				T.[CustomerName],
				T.[CustomerFirstLastName],
				T.[CustomerSecondLastName],
				T.[CustomerZipcode],
				T.[CustomerCity],
				T.[CustomerState],
				T.[CustomerAddress],
				T.[CustomerPhoneNumber],
				T.[CustomerCelullarNumber],
				T.[NumModify],
				T.IdBeneficiary,
				T.[BeneficiaryName],
				T.[BeneficiaryFirstLastName],
				T.[BeneficiarySecondLastName],
				T.[BeneficiaryCountry],
				T.[BeneficiaryZipcode],
				T.[BeneficiaryState],
				T.[BeneficiaryCity],
				T.[BeneficiaryAddress],
				T.[BeneficiaryPhoneNumber],
				T.[BeneficiaryCelularNumber],
				CASE
					WHEN T.[IdAgentSchema] IS NOT NULL THEN A.[SchemaName]
					WHEN T.[IdCountryCurrency] IS NOT NULL THEN 
						(SELECT 
						   TOP 1 A1.SchemaName      
				  			FROM AgentSchema A1 WHERE 
				  				IdGenericStatus = @IdGenericStatusEnable 
				  			AND A1.IdCountryCurrency = T.IdCountryCurrency
						 ORDER BY A1.IdAgentSchema ASC
						)
				END [SchemaName],--Nullable
				P.[PaymentName],
				Py.[PayerName],
				Br.[BranchName],--Nullable
				Ci.[CityName],--Nullable
				S.[StateName],--Nullable
				T.[ExRate],  
				T.[Fee] [Commission],
				T.[AmountInDollars],
				T.[AmountInMN],    
				T.[Fee] + T.[AmountInDollars] [Total],
				CASE WHEN @hasOnlyStatusCan=1 THEN T.DateStatusChange ELSE T.[DateOfTransfer] END [DateOfTransfer],
				T.[Folio],
				St.[StatusName],
				T.[DepositAccountNumber],
				T.[IdAgent],
				T.[ClaimCode],
				[dbo].[fun_GetTransferHoldSemaphore](T.IdTransfer) [Semaphore],
				Pre.[IdPreTransfer],
				CC.[idcountry],
				T.[IdCustomer],
				t.[IdStatus],
				ISNULL(SSN.[SSNRequired],0) [SSNRequired],
				0 HasComplianceFormat,
				'' [ComplianceFormats],
				CASE WHEN t.[idStatus] = 30 THEN t.[DateStatusChange] ELSE '' END [PayDate],
				CASE WHEN t.[idStatus] = 23 THEN t.[DateStatusChange] ELSE '' END [PayDateReady],
				AT.[AccountTypeName],
				T.idreasonforcancel,
				T.Fee, PayInfo = '', StateFee=T.StateTax, HasTicket=0, CardNumber='',
				case WHEN DATEDIFF(minute, t.DateOfTransfer, getdate())<=30 and t.IdStatus=41 then 1 else 0 end iscancel30,
				case WHEN (DATEDIFF(minute, t.DateOfTransfer, getdate())<=30 and t.IdStatus = 20) OR (DATEDIFF(minute, t.DateOfTransfer, getdate())<=30 and t.IdStatus = 41 and EXISTS(SELECT 1 FROM TransferHolds with(nolock) WHERE IdTransfer=t.IdTransfer AND IdStatus=3 AND (IsReleased=0 OR IsReleased IS NULL) and (SELECT count(*) FROM TransferHolds with(nolock) WHERE IdTransfer=t.IdTransfer AND (IsReleased=0 OR IsReleased IS NULL)) = 1)) then 1 else 0 end as [isModify30],
				case 
					WHEN t.IdStatus=22 then 
					CASE 
						WHEN DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange) <= 30 then  T.AmountInDollars + T.Fee - T.Discount --+ Isnull(SF.Tax,0) 
						WHEN TN.IdTransfer is not null THEN T.AmountInDollars + T.Fee - T.Discount --+ Isnull(SF.Tax,0) 						
						ELSE 
							CASE (rc.returnallcomission) 
								WHEN 1 then  T.AmountInDollars + T.Fee - T.Discount --+ Isnull(SF.Tax,0) 
								ELSE T.AmountInDollars              
							END
					END  
					WHEN t.IdStatus=31 then T.AmountInDollars + T.Fee - T.Discount
					ELSE 0 
				END AmountToReimburse,
				case when t.IdStatus=22 then isnull(rc.ReasonEn+' / '+rc.Reason,'') 
	 				when t.IdStatus=31 then isnull(trn.Note,isnull(histtrn.Note, '')) 
				else '' end CancelReason,
				IsActiveRealse =(case 
									when(exists(select 1 from TransferHolds 
												where IdTransfer =  T.IdTransfer
												and IdStatus = 3 and IsReleased is  null) 
												and T.IdStatus = 41)
									then 1 else 0 end)
				,P.IdPaymentType
				,case 
				when (St.CanChangeRequest =1) then 1
				ELSE 0
				end isModifyV2,
				T.Discount,
				T.IdPaymentMethod,
				cpm.PaymentMethod,
				(ISNULL(T.AmountInDollars, 0) + ISNULL(T.Fee, 0) + ISNULL(T.StateTax, 0) - ISNULL(T.Discount, 0)) TotalAmountPaid,
				T.IdGateway
			  FROM [dbo].[Transfer] T  WITH (NOLOCK)    
				 INNER JOIN #tmpTransfer tmpT WITH (NOLOCK) ON tmpT.IdTransfer = T.IdTransfer 
				 INNER JOIN [dbo].[PaymentType] P WITH (NOLOCK) ON P.[IdPaymentType] = T.[IdPaymentType]
				 INNER JOIN [dbo].[Payer] Py WITH (NOLOCK) ON Py.[IdPayer] =T.[IdPayer]
				 INNER JOIN [dbo].[CountryCurrency] CC WITH (NOLOCK) ON CC.[IdCountryCurrency] =T.[IdCountryCurrency]
				 INNER JOIN [dbo].[Customer] AS C WITH (NOLOCK) ON T.[IdCustomer] = C.[IdCustomer] /*28-Jul-2015 : Ampliar la busqueda*/
				 INNER JOIN [dbo].[Beneficiary] AS B WITH (NOLOCK) ON T.[IdBeneficiary] = B.[IdBeneficiary]
				 JOIN PaymentMethod cpm WITH(NOLOCK) ON cpm.IdPaymentMethod = ISNULL(T.IdPaymentMethod, 1)
				 LEFT JOIN [dbo].[AgentSchema] A WITH (NOLOCK) ON A.IdAgentSchema=T.IdAgentSchema 
				 LEFT JOIN [dbo].[Branch] Br WITH (NOLOCK) ON Br.[IdBranch] =T.[IdBranch]
				 LEFT JOIN [dbo].[City] Ci WITH (NOLOCK) ON Ci.[IdCity] =Br.[IdCity]
				 LEFT JOIN [dbo].[State] S WITH (NOLOCK) ON Ci.[IdState] = S.[IdState]
				 LEFT JOIN [dbo].[Status] St WITH (NOLOCK) ON St.[IdStatus] = T.[IdStatus]
				 LEFT JOIN [dbo].[TransferHolds] Th WITH (NOLOCK) ON Th.[IdTransfer] = T.[IdTransfer]
				 LEFT JOIN [dbo].[PreTransfer] Pre WITH (NOLOCK) ON Pre.[IdTransfer] = T.[IdTransfer]
				 LEFT JOIN [dbo].[TransferSSN] ssn WITH (NOLOCK) ON T.[IdTransfer] = ssn.[IdTransfer]
				 LEFT JOIN [dbo].[AccountType] AT WITH (NOLOCK) ON T.[AccountTypeId] = AT.[AccountTypeId]				
				 LEFT JOIN TransferNotAllowedResend TN WITH (NOLOCK) ON TN.IdTransfer =T.IdTransfer  
				 LEFT JOIN reasonforcancel rc WITH (NOLOCK) ON t.idreasonforcancel=rc.idreasonforcancel
				 LEFT JOIN TransferDetail td WITH (NOLOCK) ON T.IdTransfer = td.IdTransfer and t.IdStatus=31 and td.IdStatus=31
				 LEFT JOIN TRANSFERNOTE trn WITH (NOLOCK) ON trn.IdTransferDetail = TD.IdTransferDetail  and trn.IdTransferNoteType = 2 and td.IdStatus=31 
				 LEFT JOIN TRANSFERNOTE histtrn WITH (NOLOCK) ON histtrn.IdTransferDetail = TD.IdTransferDetail  and histtrn.IdTransferNoteType = 3 and td.IdStatus=31 
			UNION    
    
			  SELECT
				T.IdTransferClosed IdTransfer,    
				T.CustomerName,    
				T.CustomerFirstLastName,    
				T.CustomerSecondLastName,    
				T.CustomerZipcode,    
				T.CustomerCity,    
				T.CustomerState,    
				T.CustomerAddress,    
				T.CustomerPhoneNumber,    
				T.CustomerCelullarNumber,
				T.[NumModify],
				T.IdBeneficiary,  
				T.BeneficiaryName,    
				T.BeneficiaryFirstLastName,    
				T.BeneficiarySecondLastName,    
				T.BeneficiaryCountry,    
				T.BeneficiaryZipcode,    
				T.BeneficiaryState,    
				T.BeneficiaryCity,    
				T.BeneficiaryAddress,    
				T.BeneficiaryPhoneNumber,    
				T.BeneficiaryCelularNumber,    
				CASE    
					WHEN T.IdAgentSchema IS NOT NULL THEN T.SchemaName    
					WHEN T.IdCountryCurrency IS NOT NULL THEN --A1.SchemaName      
						(SELECT 
						   TOP 1 A1.SchemaName      
				  			FROM AgentSchema A1 WHERE 
				  				IdGenericStatus = @IdGenericStatusEnable 
				  			AND A1.IdCountryCurrency = T.IdCountryCurrency
						 ORDER BY A1.IdAgentSchema ASC
						)
				END SchemaName,--Nullable    
				T.PaymentTypeName,    
				T.PayerName,    
				Br.BranchName,--Nullable    
				Ci.CityName,--Nullable    
				S.StateName,--Nullable    
				T.ExRate,    
				T.Fee Commission,  
				T.AmountInDollars,    
				T.AmountInMN,        
				T.Fee+T.AmountInDollars Total,
				CASE WHEN @hasOnlyStatusCan=1 THEN T.DateStatusChange ELSE T.[DateOfTransfer] END [DateOfTransfer], 
				T.Folio,    
				T.StatusName,     
				T.DepositAccountNumber,    
				T.IdAgent,
				T.ClaimCode,
				'0|0|0|0|0|0' as Semaphore,
				Pre.IdPreTransfer,
				t.idcountry,
				T.IdCustomer,
				t.IdStatus,
				isnull([SSNRequired],0) SSNRequired,
	   		    0 HasComplianceFormat,
				'' [ComplianceFormats],
				CASE WHEN t.idStatus = 30 THEN t.DateStatusChange ELSE '' END PayDate,
				CASE WHEN t.idStatus = 23 THEN t.DateStatusChange ELSE '' END PayDateReady,
				AT.[AccountTypeName],
				T.idreasonforcancel,
				T.Fee, PayInfo='',StateFee=0, HasTicket=0, CardNumber='',
				0 iscancel30,
				0 isModify30,
				case 
					WHEN t.IdStatus=22 then 
					CASE 
						WHEN DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange) <= 30 then  T.AmountInDollars + T.Fee - T.Discount --+ Isnull(SF.Tax,0) 
						WHEN TN.IdTransfer is not null THEN T.AmountInDollars + T.Fee - T.Discount --+ Isnull(SF.Tax,0) 						
						ELSE 
							CASE (rc.returnallcomission) 
								WHEN 1 then  T.AmountInDollars + T.Fee - T.Discount --+ Isnull(SF.Tax,0) 
								ELSE T.AmountInDollars              
							END
					END  
					WHEN t.IdStatus=31 then T.AmountInDollars + T.Fee - T.Discount
					ELSE 0 
				END AmountToReimburse,
				case when t.IdStatus=22 then isnull(rc.ReasonEn+' / '+rc.Reason,'') 
					when t.IdStatus=31 then isnull(trn.Note,isnull(histtrn.Note,'')) 
				else '' end CancelReason
				, IsActiveRealse = 0 --,MAX(td.DateOfMovement) AS DTF	
				,T.IdPaymentType
				, 0 isModifyV2,
				T.Discount,
				T.IdPaymentMethod,
				cpm.PaymentMethod,
				(ISNULL(T.AmountInDollars, 0) + ISNULL(T.Fee, 0) + ISNULL(SF.Tax, 0) - ISNULL(T.Discount, 0)) TotalAmountPaid,
				T.IdGateway
			  FROM [dbo].TransferClosed T  
				 INNER JOIN #tmpTransferClosed tmpTC WITH (NOLOCK) ON tmpTC.IdTransferClosed = T.IdTransferClosed
				 INNER JOIN [dbo].[Customer] AS C WITH (NOLOCK) ON T.[IdCustomer] = C.[IdCustomer] /*28-Jul-2015 : Ampliar la busqueda*/
				 INNER JOIN [dbo].[Beneficiary] AS B WITH (NOLOCK) ON T.[IdBeneficiary] = B.[IdBeneficiary]
				 LEFT JOIN dbo.Branch Br WITH (NOLOCK) ON Br.IdBranch =T.IdBranch    
				 LEFT JOIN dbo.City Ci WITH (NOLOCK) ON Ci.IdCity =Br.IdCity     
				 LEFT JOIN dbo.State S WITH (NOLOCK) ON Ci.IdState = S.IdState  
				 LEFT JOIN PreTransfer Pre WITH (NOLOCK) ON Pre.IdTransfer = T.IdTransferClosed
				 LEFT JOIN [TransferSSN] ssn WITH (NOLOCK) ON T.IdTransferClosed=ssn.IdTransfer	 
				 LEFT JOIN [dbo].[AccountType] AT WITH (NOLOCK) ON T.[AccountTypeId] = AT.[AccountTypeId]
				 LEFT JOIN TransferNotAllowedResend TN WITH (NOLOCK) ON TN.IdTransfer =T.IdTransferClosed  
				 LEFT JOIN reasonforcancel rc WITH (NOLOCK) ON t.idreasonforcancel=rc.idreasonforcancel
				 LEFT JOIN TransferClosedDetail td WITH (NOLOCK) ON T.IdTransferClosed = td.IdTransferClosed and t.IdStatus=31 and td.IdStatus=31 
				 LEFT JOIN TransferClosedNote trn WITH (NOLOCK) ON trn.IdTransferClosedDetail = TD.IdTransferClosedDetail and trn.IdTransferNoteType = 2 and td.IdStatus=31
				 LEFT JOIN TransferClosedNote histtrn WITH (NOLOCK) ON histtrn.IdTransferClosedDetail = TD.IdTransferClosedDetail and histtrn.IdTransferNoteType = 3 and td.IdStatus=31
				 LEFT JOIN StateFee SF WITH (NOLOCK) ON SF.IdTransfer=T.IdTransferClosed  
				 JOIN PaymentMethod cpm WITH(NOLOCK) ON cpm.IdPaymentMethod = ISNULL(T.IdPaymentMethod, 1)
			) t
	
	
		IF @IsTimeForVerifyHold = 1
			DELETE FROM #tmp WHERE [StatusName] = 'Verify Hold' AND DateOfTransfer < dateadd(minute,-30, GETDATE())

		 CREATE TABLE #tmpMessages (idTransfer INT NULL, EnterDate DATETIME NULL, RAWMESSAGE NVARCHAR(max) NULL,IdGenericStatus INT NULL  )
		 CREATE INDEX IX_tmpMessages_IdTransfer_IdGenericStatus_EnterDate ON #tmpMessages(IdTransfer, IdGenericStatus, EnterDate)

   		 INSERT INTO #tmpMessages
		 SELECT 
		 TD.IdTransfer,
		 TN.EnterDate, 
		 MSG.RAWMESSAGE, 
		 TNN.IdGenericStatus
		 FROM TRANSFERDETAIL TD
						LEFT JOIN TRANSFERNOTE TN ON TN.IdTransferDetail = TD.IdTransferDetail AND
										TN.EnterDate = 
											(
												SELECT ISNULL(MAX(EnterDate),GETDATE() ) 
												FROM TRANSFERNOTE tu 
												INNER JOIN TRANSFERNOTENOTIFICATION TNN ON TNN.IdTransferNote = tu.IdTransferNote 
												WHERE tu.IdTransferDetail = TD.IdTransferDetail AND TNN.IdGenericStatus = 1
											)
						INNER JOIN TRANSFERNOTENOTIFICATION TNN ON TNN.IdTransferNote = TN.IdTransferNote 
						INNER JOIN MSG.[MESSAGES] MSG ON MSG.IdMessage = TNN.IdMessage	
		WHERE td.idTransfer IN (SELECT idTransfer FROM #tmp) AND TNN.IdGenericStatus = 1
				AND td.IdStatus NOT IN (22,31) --no cancelados ni rechazados
	
   		UNION 
	
		SELECT IdTransfer, EnterDate, RAWMESSAGE, IdGenericStatus FROM (
	
		 SELECT 
			 DISTINCT 
			 TD.IdTransfer,
	   			TN.EnterDate, 
	  		 RAWMESSAGE = Convert(NVARCHAR(max),'{"IdTransfer":'+Convert(VARCHAR,tmp.IdTransfer)+',"AgentCode":"","AgentName":"","Folio":"'+Convert(varchar,tmp.Folio)+'","ClaimCode":"","DateOfTransfer":"'+Convert(varchar,tmp.DateOfTransfer,127)+'","CustomerName":"","Note":"'+isnull(TN.note,'')+'","Requirement":[{"IdComplianceProduct":0,"Name":null,"IdStatus":0,"NameEs":"Motivo: '+rc.Reason+'","NameEn":"Reason: '+rc.ReasonEn+'"}]}') ,
			 1 AS IdGenericStatus
			 FROM TRANSFERDETAIL TD
			 LEFT JOIN TRANSFERNOTE TN 
			 ON TN.IdTransferDetail = TD.IdTransferDetail 
				AND TN.IdTransferNoteType = 2
		 		AND TN.EnterDate = 
						(
							SELECT ISNULL(MIN(EnterDate),GETDATE() ) 
							FROM TRANSFERNOTE tu 
							WHERE tu.IdTransferDetail = TD.IdTransferDetail 
							AND tu.IdTransferNoteType =2
						)
			INNER JOIN #tmp tmp
			ON tmp.IdTransfer = td.IdTransfer
			AND tmp.IdStatus = td.IdStatus
		
			INNER JOIN ReasonForCancel rc
			ON rc.idReasonForCancel = tmp.idReasonForCancel
			WHERE tmp.IdStatus = 22
		) Cancelled
    
       		UNION 
	
		SELECT IdTransfer, EnterDate, RAWMESSAGE, IdGenericStatus FROM (
	
		 SELECT 
			 DISTINCT 
			 TD.IdTransferClosed AS IdTransfer,
	   			TN.EnterDate, 
	  		 RAWMESSAGE = Convert(NVARCHAR(max),'{"IdTransfer":'+Convert(VARCHAR,tmp.IdTransfer)+',"AgentCode":"","AgentName":"","Folio":"'+Convert(varchar,tmp.Folio)+'","ClaimCode":"","DateOfTransfer":"'+Convert(varchar,tmp.DateOfTransfer,127)+'","CustomerName":"","Note":"'+isnull(TN.note,'')+'","Requirement":[{"IdComplianceProduct":0,"Name":null,"IdStatus":0,"NameEs":"Motivo: '+rc.Reason+'","NameEn":"Reason: '+rc.ReasonEn+'"}]}') ,
			 1 AS IdGenericStatus
			 FROM TransferClosedDetail TD
			 LEFT JOIN TransferClosedNote TN 
			 ON TN.IdTransferClosedDetail = TD.IdTransferClosedDetail 
				AND TN.IdTransferNoteType = 2
		 		AND TN.EnterDate = 
						(
							SELECT ISNULL(MIN(EnterDate),GETDATE() ) 
							FROM TransferClosedNote tu 
							WHERE tu.IdTransferClosedDetail = TD.IdTransferClosedDetail 
							AND tu.IdTransferNoteType =2
						)
			INNER JOIN #tmp tmp
			ON tmp.IdTransfer = td.IdTransferClosed
			AND tmp.IdStatus = td.IdStatus
		
			INNER JOIN ReasonForCancel rc
			ON rc.idReasonForCancel = tmp.idReasonForCancel
			WHERE tmp.IdStatus = 22
		) CancelledHist
    
   		UNION 
	
		SELECT IdTransfer, EnterDate, RAWMESSAGE, IdGenericStatus FROM (
		 SELECT 
			 DISTINCT 
			 TD.IdTransfer,
	   			TN.EnterDate, 
	  		 RAWMESSAGE = Convert(NVARCHAR(max),'{"IdTransfer":'+Convert(VARCHAR,tmp.IdTransfer)+',"AgentCode":"","AgentName":"","Folio":"'+Convert(varchar,tmp.Folio)+'","ClaimCode":"","DateOfTransfer":"'+Convert(varchar,tmp.DateOfTransfer,127)+'","CustomerName":"","Note":"'+isnull(TN.note,'')+'","Requirement":[]}') , 
			 1 AS IdGenericStatus
			 FROM TRANSFERDETAIL TD
			 LEFT JOIN TRANSFERNOTE TN 
			 ON TN.IdTransferDetail = TD.IdTransferDetail 
		 		AND TN.EnterDate = 
						(
							SELECT ISNULL(MIN(EnterDate),GETDATE() ) 
							FROM TRANSFERNOTE tu 
							WHERE tu.IdTransferDetail = TD.IdTransferDetail 
							AND tu.IdTransferNoteType = 2
						)
			AND TN.IdTransferNoteType = 2
			INNER JOIN #tmp tmp
			ON tmp.IdTransfer = td.IdTransfer
			AND tmp.IdStatus = td.IdStatus
			WHERE tmp.IdStatus = 31
		) Rejected
	
		UNION 
	
		SELECT IdTransfer, EnterDate, RAWMESSAGE, IdGenericStatus FROM (
		 SELECT 
			 DISTINCT 
			 TD.IdTransferClosed AS IdTransfer,
	   			TN.EnterDate, 
	  		 RAWMESSAGE = Convert(NVARCHAR(max),'{"IdTransfer":'+Convert(VARCHAR,tmp.IdTransfer)+',"AgentCode":"","AgentName":"","Folio":"'+Convert(varchar,tmp.Folio)+'","ClaimCode":"","DateOfTransfer":"'+Convert(varchar,tmp.DateOfTransfer,127)+'","CustomerName":"","Note":"'+isnull(TN.note,'')+'","Requirement":[]}') ,
			 1 AS IdGenericStatus
			 FROM TransferClosedDetail TD
			 LEFT JOIN TransferClosedNote TN 
			 ON TN.IdTransferClosedDetail = TD.IdTransferClosedDetail 
		 		AND TN.EnterDate = 
						(
							SELECT ISNULL(MIN(EnterDate),GETDATE() ) 
							FROM TransferClosedNote tu 
							WHERE tu.IdTransferClosedDetail = TD.IdTransferClosedDetail 
							AND tu.IdTransferNoteType = 2
						)
			AND TN.IdTransferNoteType = 2
			INNER JOIN #tmp tmp
			ON tmp.IdTransfer = td.IdTransferClosed
			AND tmp.IdStatus = td.IdStatus
			WHERE tmp.IdStatus = 31
		) RejectedHist
	
	
		UPDATE tmp SET  
		   PayInfo = '{"Country":"'+isnull(ct.CountryName,tmp.SchemaName)+'", "City":"'+isnull(c.CityName,tmp.CityName)+'", "BranchName":"'+isnull(b.BranchName,tmp.BranchName)+'", "Address":"'+isnull(b.Address,'')+'", "idNumber":"'+isnull(BeneficiaryIdNumber,'')+'", "idType":"'+isnull(BeneficiaryIdType,'')+'", "DateOfPayment":"'+Convert(varchar,DateOfPayment,111)+' '+Convert(varchar,DateOfPayment,108)+'", "State":"'+isnull(s.StateName,'')+'" }'
		FROM #tmp tmp 
		   INNER JOIN TransferPayInfo pi ON pi.IdTransfer = tmp.idTransfer
		   LEFT JOIN Branch b ON b.IdBranch = pi.IdBranch
		   LEFT JOIN City c ON c.IdCity = b.IdCity
		   LEFT JOIN State s ON s.IdState = c.IdState
		   LEFT JOIN Country ct ON ct.IdCountry = s.IdCountry
		

		DECLARE @PaymentTypesCannotModify TABLE (IdPaymentType INT)
		INSERT INTO @PaymentTypesCannotModify VALUES (2)

		DECLARE @IdCountryUSA INT,
				@IdCountryHND INT --BM-707

		SET @IdCountryUSA = dbo.GetGlobalAttributeByName('IdCountryUSA')
		SET @IdCountryHND = dbo.GetGlobalAttributeByName('IdCountryHND') --BM-707

		SELECT
			A.[IdTransfer],
			A.[CustomerName],
			A.[CustomerFirstLastName],
			A.[CustomerSecondLastName],
			A.[CustomerZipcode],
			A.[CustomerCity],
			A.[CustomerState],
			A.[CustomerAddress],
			A.[CustomerPhoneNumber],
			A.[CustomerCelullarNumber],
			A.[NumModify],
			CASE 
				WHEN ptm.IdPaymentType IS NOT NULL THEN 0 
				WHEN A.IdPaymentMethod = 2 THEN 0
				WHEN A.Idcountry = @IdCountryUSA THEN 0
				ELSE A.[isModify30] 
			END isModify30,
			A.[IdBeneficiary],
			A.[BeneficiaryName],
			A.[BeneficiaryFirstLastName],
			A.[BeneficiarySecondLastName],
			A.[BeneficiaryCountry],
			A.[BeneficiaryZipcode],
			A.[BeneficiaryState],
			A.[BeneficiaryCity],
			A.[BeneficiaryAddress],
			A.[BeneficiaryPhoneNumber],
			A.[BeneficiaryCelularNumber],
			A.[SchemaName],
			A.[PaymentName],
			A.[PayerName],
			A.[BranchName],
			A.[CityName],
			A.[StateName],
			A.[ExRate],
			A.[Commission],
			A.[AmountInDollars],
			A.[AmountInMN],
			A.[Total] + isnull(SF.Tax,0) AS Total,
			A.[DateOfTransfer],
			A.[Folio],
			CASE 
				WHEN (told.IdTransfer IS NOT NULL OR tcold.IdTransferClosed IS NOT NULL) THEN
					CASE A.IdStatus
						WHEN 22 THEN 'Modified'
						WHEN 25 THEN 'Modified Stand By'
						WHEN 26 THEN 'Modified In Process'
						WHEN 35 THEN 'Modified Accepted'
						ELSE A.[StatusName]
					END
				WHEN A.IdPaymentMethod = 2 AND A.IdStatus = 1 THEN 'Pending Payment'
				ELSE A.[StatusName]
			END StatusName,
			A.[DepositAccountNumber],
			A.[IdAgent],
			A.[ClaimCode],
			A.[Semaphore],
			A.[IdPreTransfer],
			A.[idcountry],
			A.[idcustomer],
			A.[IdStatus],
			A.[SSNRequired],
			IIF(CF.FileOfName is null, 0, 1) AS HasComplianceFormat,
			ISNULL(COALESCE(', ', '') + CF.FileOfName, '') AS ComplianceFormats,
			A.[PayDate],
			A.[PayDateReady],
			A.[AccountTypeName],
			Hold.EnterDate,
			ISNULL(Hold.RawMessage,'') AS RawMessage,
			A.Fee,
			A.PayInfo,
			isnull(SF.Tax,0) AS StateFee,
			IIF(TK.IdTicket IS NOT NULL, 1, 0) AS HasTicket,
			ISNULL(CV.CardNumber, '') AS CardNumber,		
			A.iscancel30 iscancel30, --
			A.AmountToReimburse + isnull(SF.Tax,0) AS AmountToReimburse,
			CASE 
				WHEN A.IdStatus = 22 AND tm.IsCancel = 1 AND (told.IdTransfer IS NOT NULL OR tcold.IdTransferClosed IS NOT NULL)
					THEN CONCAT(A.CancelReason, CHAR(13), 'Folio: ', ISNULL(told.Folio, tcold.Folio))
				ELSE A.CancelReason
			END CancelReason,
			A.IsActiveRealse,
			A.IdPaymentType,
			CASE 
				WHEN ptm.IdPaymentType IS NOT NULL THEN 0 
				WHEN A.IdPaymentMethod = 2 THEN 0
				WHEN A.Idcountry = @IdCountryUSA THEN 0
				WHEN A.Idcountry = @IdCountryHND AND DATEDIFF(DAY,A.DateOfTransfer,GETDATE()) >= 1 THEN 0 --BM-707
				ELSE A.isModifyV2 
			END isModifyV2,
			A.Discount,
			A.IdPaymentMethod,
			A.PaymentMethod,
			A.TotalAmountPaid,
			CASE WHEN A.IdStatus = 1 THEN 0 ELSE 1 END AllowPrintReceipt,
			A.IdGateway
		FROM #tmp A
			LEFT JOIN @PaymentTypesCannotModify ptm ON ptm.IdPaymentType = A.IdPaymentType
			LEFT JOIN TransferModify tm WITH(NOLOCK) ON tm.OldIdTransfer = A.IdTransfer AND tm.NewIdTransfer > 0
			LEFT JOIN Transfer told WITH(NOLOCK) ON told.IdTransfer = tm.NewIdTransfer
			LEFT JOIN TransferClosed tcold WITH(NOLOCK) ON tcold.IdTransferClosed = tm.NewIdTransfer
			LEFT JOIN #tmpMessages AS Hold ON Hold.IdTransfer = A.IdTransfer AND hold.IdGenericStatus = 1  AND Hold.EnterDate =
			(
				SELECT ISNULL(MAX(B.EnterDate),GETDATE()) 
				FROM #tmpMessages B
				WHERE B.idTransfer = A.IdTransfer
			)
			LEFT JOIN StateFee SF ON SF.IdTransfer = A.IdTransfer	
			LEFT JOIN Tickets TK ON TK.IdTransaction = A.IdTransfer		
			LEFT JOIN CardVIP CV ON CV.IdCustomer = A.idCustomer AND CV.IdGenericStatus = 1
			LEFT JOIN (SELECT DISTINCT CF.[FileOfName], BRT.[IdTransfer]
				FROM [dbo].[BrokenRulesByTransfer] BRT WITH (NOLOCK)		
				JOIN [dbo].[ComplianceFormat] CF WITH (NOLOCK) ON BRT.[ComplianceFormatId] = CF.[ComplianceFormatId]
				WHERE BRT.ComplianceFormatId IS NOT NULL) CF ON  CF.IdTransfer = A.IdTransfer
		ORDER BY [DateOfTransfer] DESC


		DROP TABLE #tmpTransfer
		DROP TABLE #tmpTransferClosed
		DROP TABLE #tmpMessages
		DROP TABLE #tmp

END TRY
BEGIN CATCH
	DECLARE @Message varchar(max) = ERROR_MESSAGE()
	DECLARE @ErrorLine varchar(20) = CONVERT(VARCHAR(20), ERROR_LINE())
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_FindTransfers', GETDATE(), 'Line: ' + @ErrorLine + '. ' + @Message)
END CATCH