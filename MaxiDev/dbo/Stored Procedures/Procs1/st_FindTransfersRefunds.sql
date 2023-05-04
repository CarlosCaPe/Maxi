
CREATE   PROCEDURE [dbo].[st_FindTransfersRefunds]   
    @BeginDate				DATETIME, --= '2023-01-01 00:00:00',
    @EndDate				DATETIME, --= '2023-04-09 00:00:00',
    @IdAgent				INT, --=1242,
    @Customer				NVARCHAR(300) = NULL,
    @IdStatus				INT = NULL,
	@IdProduct				INT = NULL,
    @TransferFolio			INT = NULL,
    @IsMonoAgent			BIT = 0,--1,
	@IdUser					INT = NULL--16404
AS
/********************************************************************
<Author>Miguel Prado</Author>
<app>MaxiAgente</app>
<Description>This stored is used in agent for search refunds screen</Description>
<ChangeLog>
	<log Date="02/04/2023" Author="Maprado">Creacion del Store</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
		SET NOCOUNT ON;

		DECLARE @XML				XML;
		DECLARE @RefundsBeginDate	DATETIME;

		SET @RefundsBeginDate = dbo.GetGlobalAttributeByName('RefundsBeginDate')

		IF @RefundsBeginDate IS NOT NULL
			SELECT @RefundsBeginDate = [dbo].[RemoveTimeFromDatetime] (@RefundsBeginDate)

		IF @BeginDate IS NOT NULL
			SELECT @BeginDate = [dbo].[RemoveTimeFromDatetime] (@BeginDate)

		IF @BeginDate < @RefundsBeginDate  -- SE VALIDA QUE LA FECHA DE BUSQUEDA NO SEA MAYOR A LA FECHA DE LANZAMIENTO DE REEMBOLSOS
			SELECT @BeginDate = @RefundsBeginDate

		IF @EndDate IS NOT NULL
			SELECT @EndDate = [dbo].[RemoveTimeFromDatetime](@EndDate+1);
		
		IF @IdStatus = 0
			SELECT @IdStatus = NULL

		IF @IdProduct = 0
			SELECT @IdProduct = NULL

		DECLARE @IdGenericStatusEnable INT
		SET @IdGenericStatusEnable = 1

		CREATE TABLE #tmpRefundTransfer(
			[RowNumber] INT IDENTITY,
			[IdTransfer] INT
		);
		CREATE TABLE #tmpRefundTransferClosed(
			[RowNumber] INT IDENTITY,
			[IdTransferClosed] INT
		);

		CREATE INDEX IX_tmpRefundTransfer_IdTransfer ON #tmpRefundTransfer (IdTransfer)
		CREATE INDEX IX_tmpRefundTransferClosed_IdTransferClosed ON #tmpRefundTransferClosed (IdTransferClosed)

		INSERT INTO #tmpRefundTransfer
		SELECT T.IdTransfer 
		FROM [dbo].[Transfer] T WITH (NOLOCK) 
		WHERE (@TransferFolio IS NULL OR T.Folio = @TransferFolio)
		AND (@BeginDate IS NULL OR T.DateOfTransfer >= @BeginDate)
		AND (@EndDate IS NULL OR T.DateOfTransfer <= @EndDate)
		AND T.IdAgent =@IdAgent AND (@Customer IS NULL OR T.IdCustomer IN (SELECT IdCustomer FROM Customer  WITH (NOLOCK) 
														WHERE FullName Like '%' + REPLACE(@Customer,' ','') + '%'))
		AND T.IdStatus IN (22,25,26,31,35)
		AND (@IdStatus IS NULL OR T.IdStatus = @IdStatus)
		AND (ISNULL(T.IsRefunded,0) = 0);

		INSERT INTO #tmpRefundTransferClosed
		SELECT IdTransferClosed 
		FROM [dbo].TransferClosed T WITH (NOLOCK) 
		WHERE  (@TransferFolio IS NULL OR T.Folio = @TransferFolio)
		AND (@BeginDate IS NULL OR T.DateOfTransfer >= @BeginDate)
		AND (@EndDate IS NULL OR T.DateOfTransfer <= @EndDate)
		AND T.IdAgent =@IdAgent AND (@Customer IS NULL OR T.IdCustomer IN (SELECT IdCustomer FROM Customer  WITH (NOLOCK) 
														WHERE FullName Like '%' + REPLACE(@Customer,' ','') + '%'))
		AND T.IdStatus IN (22,25,26,31,35)
		AND (@IdStatus IS NULL OR T.IdStatus = @IdStatus)
		AND (ISNULL(T.IsRefunded,0) = 0);

		CREATE TABLE #tmpRefund
		(
			[RowNumber] INT IDENTITY,
			[IdTransfer] INT,	
			[CustomerName]	NVARCHAR(150),
			[CustomerFirstLastName]	NVARCHAR(150),
			[CustomerSecondLastName]	NVARCHAR(150),
			[CustomerZipcode]	NVARCHAR(10),
			[CustomerCity] NVARCHAR(75),
			[CustomerState] NVARCHAR(75),
			[CustomerAddress]	NVARCHAR(250),
			[CustomerPhoneNumber] NVARCHAR(20),
			[CustomerCelullarNumber] NVARCHAR(20),
			[NumModify] INT,
			IdBeneficiary INT,
			[BeneficiaryName] NVARCHAR(150),
			[BeneficiaryFirstLastName] NVARCHAR(150),
			[BeneficiarySecondLastName] NVARCHAR(150),
			[BeneficiaryCountry] NVARCHAR(75),
			[BeneficiaryZipcode] NVARCHAR(10),
			[BeneficiaryState] NVARCHAR(75),
			[BeneficiaryCity] NVARCHAR(75),
			[BeneficiaryAddress] NVARCHAR(250),
			[BeneficiaryPhoneNumber] NVARCHAR(20),
			[BeneficiaryCelularNumber] NVARCHAR(20),
			[SchemaName] NVARCHAR(150),
			[PaymentName] NVARCHAR(100),
			[PayerName]	NVARCHAR(150),
			[BranchName] NVARCHAR(150),
			[CityName] NVARCHAR(75),
			[StateName]	NVARCHAR(75),
			[ExRate] MONEY,
			[Commission] MONEY,
			[AmountInDollars] MONEY,
			[AmountInMN] MONEY,
			[Total]	MONEY,
			[DateOfTransfer] DATETIME,
			[DateStatusChange] DATETIME,
			[Product] NVARCHAR(3),
			[Folio]	INT,
			[StatusName] VARCHAR(75),
			[DepositAccountNumber] NVARCHAR(50),
			[IdAgent] INT,
			[ClaimCode] NVARCHAR(50),
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
			,[AccountTypeName] NVARCHAR(100),
			[idreasonforcancel] INT NULL,
			Fee MONEY,
			PayInfo VARCHAR(8000),
			StateFee MONEY,
			HasTicket BIT,
			CardNumber VARCHAR(200),
			iscancel30 bit,
			[isModify30] bit,
			AmountToReimburse money not null default 0,
			CancelReason NVARCHAR(500),
			IsActiveRealse bit
			,IdPaymentType int
			,isModifyV2 bit,
			Discount		MONEY,
			IdPaymentMethod	INT,
			PaymentMethod	VARCHAR(200),
			TotalAmountPaid	MONEY,
			IdGateway INT
		);

		CREATE UNIQUE INDEX IX_tmpRefund_RowNumber ON #tmpRefund (RowNumber) INCLUDE([IdTransfer], [HasComplianceFormat]) --#1
		CREATE INDEX IX_tmpRefund_IdTransfer ON #tmpRefund (IdTransfer, IdStatus, idReasonForCancel) --#1
    
		INSERT INTO #tmpRefund
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
				T.[DateOfTransfer],
				T.DateStatusChange,
				'MT' AS [Product],
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
				0 iscancel30,
				0 as [isModify30],
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
				IsActiveRealse = 0, 
				P.IdPaymentType,
				0 AS isModifyV2,
				T.Discount,
				T.IdPaymentMethod,
				cpm.PaymentMethod,
				(ISNULL(T.AmountInDollars, 0) + ISNULL(T.Fee, 0) + ISNULL(T.StateTax, 0) - ISNULL(T.Discount, 0)) TotalAmountPaid,
				T.IdGateway
			  FROM [dbo].[Transfer] T  WITH (NOLOCK)    
				 INNER JOIN #tmpRefundTransfer tmpT WITH (NOLOCK) ON tmpT.IdTransfer = T.IdTransfer 
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
				T.[DateOfTransfer],
				T.DateStatusChange,
				'MT' AS [Product],
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
				'' PayDate,
				'' PayDateReady,
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
				 INNER JOIN #tmpRefundTransferClosed tmpTC WITH (NOLOCK) ON tmpTC.IdTransferClosed = T.IdTransferClosed
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
	
		UPDATE #tmpRefund SET  
		   PayInfo = '{"Country":"'+isnull(ct.CountryName,tmp.SchemaName)+'", "City":"'+isnull(c.CityName,tmp.CityName)+'", "BranchName":"'+isnull(b.BranchName,tmp.BranchName)+'", "Address":"'+isnull(b.Address,'')+'", "idNumber":"'+isnull(BeneficiaryIdNumber,'')+'", "idType":"'+isnull(BeneficiaryIdType,'')+'", "DateOfPayment":"'+Convert(varchar,DateOfPayment,111)+' '+Convert(varchar,DateOfPayment,108)+'", "State":"'+isnull(s.StateName,'')+'" }'
		FROM #tmpRefund tmp 
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
			0 AS isModify30,
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
			A.[DateStatusChange],
			A.[Product],
			A.[Folio],
			CASE
				WHEN A.IdPaymentMethod = 2 AND A.IdStatus = 1 THEN 'Pending Payment'
				ELSE A.[StatusName]
			END StatusName,
			A.[DepositAccountNumber],
			A.[IdAgent],
			A.[ClaimCode],
			'0|0|0|0|0|0' AS Semaphore,
			NULL AS IdPreTransfer,
			A.[idcountry],
			A.[idcustomer],
			A.[IdStatus],
			A.[SSNRequired],
			0 AS HasComplianceFormat,
			ISNULL(COALESCE(', ', '') + CF.FileOfName, '') AS ComplianceFormats,
			A.[PayDate],
			A.[PayDateReady],
			A.[AccountTypeName],
			A.Fee,
			A.PayInfo,
			isnull(SF.Tax,0) AS StateFee,
			0 AS HasTicket,
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
			0 AS isModifyV2,
			A.Discount,
			A.IdPaymentMethod,
			A.PaymentMethod,
			A.TotalAmountPaid,
			--ASE WHEN A.IdStatus = 1 THEN 0 ELSE 1 END AllowPrintReceipt,
			0 AS AllowPrintReceipt,
			A.IdGateway
		FROM #tmpRefund A
			LEFT JOIN @PaymentTypesCannotModify ptm ON ptm.IdPaymentType = A.IdPaymentType
			LEFT JOIN TransferModify tm WITH(NOLOCK) ON tm.OldIdTransfer = A.IdTransfer AND tm.NewIdTransfer > 0
			LEFT JOIN Transfer told WITH(NOLOCK) ON told.IdTransfer = tm.NewIdTransfer
			LEFT JOIN TransferClosed tcold WITH(NOLOCK) ON tcold.IdTransferClosed = tm.NewIdTransfer
			LEFT JOIN StateFee SF ON SF.IdTransfer = A.IdTransfer	
			LEFT JOIN Tickets TK ON TK.IdTransaction = A.IdTransfer		
			LEFT JOIN CardVIP CV ON CV.IdCustomer = A.idCustomer AND CV.IdGenericStatus = 1
			LEFT JOIN (SELECT DISTINCT CF.[FileOfName], BRT.[IdTransfer]
				FROM [dbo].[BrokenRulesByTransfer] BRT WITH (NOLOCK)		
				JOIN [dbo].[ComplianceFormat] CF WITH (NOLOCK) ON BRT.[ComplianceFormatId] = CF.[ComplianceFormatId]
				WHERE BRT.ComplianceFormatId IS NOT NULL) CF ON  CF.IdTransfer = A.IdTransfer
		ORDER BY [DateOfTransfer] DESC

		DROP TABLE #tmpRefundTransfer
		DROP TABLE #tmpRefundTransferClosed
		DROP TABLE #tmpRefund

END TRY
BEGIN CATCH
	DECLARE @Message varchar(max) = ERROR_MESSAGE()
	DECLARE @ErrorLine varchar(20) = CONVERT(VARCHAR(20), ERROR_LINE())
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_FindTransfersRefunds', GETDATE(), 'Line: ' + @ErrorLine + '. ' + @Message)
END CATCH