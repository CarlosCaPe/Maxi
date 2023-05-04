CREATE PROCEDURE [dbo].[st_ReportCustomerSAR]
   @CustomerIds 	NVARCHAR(MAX),
   @Begindate 		DATETIME,
   @Enddate 		DATETIME,
   @ResultSet 		INT,
   @IdProductType	INT
AS

/********************************************************************
<Author>Francisco Lara</Author>
<app>---</app>
<CreateDate>2016-01-26</CreateDate>
<Description>This stored is used for [dbo].[st_ReportSAR]</Description>

<ChangeLog>
<log Date="05/04/2018" Author="jdarellano" Name="#1">Se modifica filtro por estatus para que tome en cuenta todos.</log>
<log Date="07/05/2018" Author="jdarellano" Name="#2">Se modifica filtro para extraer clientes activos en "Deny List".</log>
<log Date="04/29/2022" Author="cagarcia">MP1007 - Se agrega parametro @IdProductType para buscar por diferente tipo de producto</log>
</ChangeLog>
*********************************************************************/

BEGIN 

	--------------------------------
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON
	--------------------------------
	
	SET @Begindate = dbo.RemoveTimeFromDatetime(@Begindate)
	SET @Enddate = dbo.RemoveTimeFromDatetime(@Enddate)+1

	DECLARE @Ids TABLE ( [Id] INT )

	INSERT INTO @Ids ([Id]) (SELECT [item] FROM [dbo].[fnSplit] (@CustomerIds,'-'))


	IF @ResultSet = 1	
	BEGIN
		WITH ctCsDny AS (
						SELECT
							DLC.[IdCustomer],
							DLC.[DateInToList],
							DLC.[NoteInToList]
						FROM [dbo].[DenyListCustomer] DLC WITH(NOLOCK)
						JOIN (
								SELECT MAX([IdDenyListCustomer]) IdDenyListCustomer
								FROM [dbo].[DenyListCustomer] WITH(NOLOCK)
								WHERE IdGenericStatus=1--#2
								GROUP BY [IdCustomer]
							 ) L ON DLC.[IdDenyListCustomer] = L.[IdDenyListCustomer]
						WHERE DLC.[IdCustomer] IN (SELECT [Id] FROM @Ids)

						 )
		, ctStatusSAR AS (
						SELECT
							[IdCustomer],
							MAX([DataLastChange]) [DataLastChange]
						FROM [dbo].[StatusCustomerSAR] WITH(NOLOCK)
						WHERE [StatusSAR] = 1
							AND [IdCustomer] IN (SELECT [Id] FROM @Ids)
						GROUP BY [IdCustomer]
						)
	
		SELECT
			C.[IdCustomer] ID,                 
			REPLACE(C.[Name] + ' ' + C.[FirstLastName] + ' ' + C.[SecondLastName], '.' , '') [Name],
			C.[Address],
			ISNULL(C.[Country], '') [Country],
			ISNULL(C.[State], '') [State],
			C.[City] [City],
			ISNULL(CI.[Name], '') [IdentificationType],
			C.[IdentificationNumber],
			SR.[DataLastChange] [SARDate],
			ctCsDny.[DateInToList] [DenyDate],
			ISNULL(ctCsDny.[NoteInToList],'') [DenyStatus]
						
		FROM [dbo].[Customer] C WITH(NOLOCK)
		LEFT JOIN [dbo].[CustomerIdentificationType] CI WITH(NOLOCK) ON C.[IdCustomerIdentificationType] = CI.[IdCustomerIdentificationType]
		LEFT JOIN ctCsDny ON ctCsDny.[IdCustomer] = C.[IdCustomer]
		LEFT JOIN ctStatusSAR SR ON C.[IdCustomer] = SR.[IdCustomer]
		
		WHERE
		C.[IdCustomer] IN (SELECT [Id] FROM @Ids)
		ORDER BY C.[IdCustomer]

		RETURN

	END



	SELECT
		[IdCustomer],
		[DateOfTransfer],
		[AgentCode],
		Folio,
		[IdBeneficiary],
		[Beneficiaryname],
		[Country],
		[StateName],
		[StateNamePaid],
		[AmountInDollars],
		[IdStatus],
		[StatusName],
		[UserName],
		[PayerName],
		[RequireID],
		[PaymentType]
	INTO #TransfersInfo
	FROM (
		SELECT
			T.[IdCustomer],
			T.[DateOfTransfer],
			A.[AgentCode],
			t.Folio,
			T.[IdBeneficiary],
			LTRIM(ISNULL([BeneficiaryName],'') + ' ' + ISNULL([BeneficiaryFirstLastName],'') + ' ' + ISNULL([BeneficiarySecondLastName],'')) [Beneficiaryname],
			ISNULL(CO.[CountryName],'') [Country],
			ISNULL(S.[StateName],'') [StateName],
			CASE WHEN T.[IdStatus] = 30 THEN ISNULL(SP.[StateName],'') ELSE '' END [StateNamePaid],
			T.[AmountInDollars],
			T.[IdStatus],
			ST.[StatusName],
			U.[UserName],
			P.[PayerName],
			CASE WHEN ISNULL(BRBT.[IdTransfer],0) = 0 THEN 0 ELSE 1 END [RequireID],
			PT.[PaymentName] [PaymentType]
		FROM [dbo].[Transfer] T WITH(NOLOCK) 
		JOIN [dbo].[Agent] A WITH(NOLOCK) ON A.[IdAgent] = T.[IdAgent]
		LEFT JOIN [dbo].[CountryCurrency] CC WITH(NOLOCK) ON T.[IdCountryCurrency] = CC.[IdCountryCurrency]
		LEFT JOIN [dbo].[Country] CO WITH(NOLOCK) ON CC.[IdCountry] = CO.[IdCountry]
		LEFT JOIN [dbo].[Branch] B WITH(NOLOCK) ON T.[IdBranch] = B.[IdBranch]
		LEFT JOIN [dbo].[City] C WITH(NOLOCK) ON B.[IdCity] = C.[IdCity]
		LEFT JOIN [dbo].[State] S WITH(NOLOCK) ON C.[IdState] = S.[IdState]
		LEFT JOIN
		(
			SELECT MAX([IdTransferPayInfo]) [IdTransferPayInfo], TPI.[IdTransfer]
			FROM [dbo].[TransferPayInfo] TPI WITH(NOLOCK)
			GROUP BY TPI.[IdTransfer]
		)LTPI ON T.[IdTransfer] = LTPI.[IdTransfer]
		LEFT JOIN TransferPayInfo  tpi WITH(NOLOCK) ON LTPI.IdTransferPayInfo = tpi.IdTransferPayInfo
		LEFT JOIN [dbo].[Branch] BP WITH(NOLOCK) ON TPI.[IdBranch] = BP.[IdBranch]
		LEFT JOIN [dbo].[City] CP WITH(NOLOCK) ON BP.[IdCity] = CP.[IdCity]
		LEFT JOIN [dbo].[State] SP WITH(NOLOCK) ON CP.[IdState] = SP.[IdState]
		JOIN [dbo].[Status] ST WITH(NOLOCK) ON T.[IdStatus] = ST.[IdStatus]
		JOIN [dbo].[Users] U WITH(NOLOCK) ON T.[EnterByIdUser] = U.[IdUser]
		JOIN [dbo].[Payer] P WITH(NOLOCK) ON T.[IdPayer] = P.[IdPayer]
        JOIN [dbo].[PaymentType] PT WITH(NOLOCK) ON PT.[IdPaymentType] = T.[IdPaymentType]
		LEFT JOIN (
				SELECT
					[IdTransfer]
				FROM [dbo].[BrokenRulesByTransfer] WITH(NOLOCK)
				WHERE [IdKYCAction] = 1
				GROUP BY [IdTransfer]
			) BRBT ON T.[IdTransfer] = BRBT.[IdTransfer]
		WHERE
			[IdCustomer] IN (SELECT [Id] FROM @Ids)
			AND [DateOfTransfer] >= @Begindate AND [DateOfTransfer] < @Enddate
			--AND T.[IdStatus] IN (1, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 41)--#1
		
		UNION ALL

		SELECT
			T.[IdCustomer],
			T.[DateOfTransfer] [DateOfTransfer],
			A.[AgentCode],
			T.[Folio],
			[IdBeneficiary],
			REPLACE([BeneficiaryName] + ' ' + [BeneficiaryFirstLastName] + ' ' + [BeneficiarySecondLastName], '.', '') [Beneficiaryname],
			ISNULL(CO.[CountryName],'') [CountryName],
			ISNULL(S.[StateName],'') [StateName],
			CASE WHEN T.[IdStatus] = 30 THEN ISNULL(SP.[StateName], '') ELSE '' END [StateNamePaid],
			[AmountInDollars],
			T.[IdStatus],
			ST.[StatusName],
			U.[UserName],
			P.[PayerName],
			CASE WHEN ISNULL(BRBT.[IdTransfer],0) = 0 THEN 0 ELSE 1 END [RequireID],
			PT.[PaymentName] [PaymentType]
		FROM 
			[dbo].[Transferclosed] T WITH(NOLOCK)
		JOIN [dbo].[Agent] A WITH(NOLOCK) ON A.[IdAgent] = T.[IdAgent]
		LEFT JOIN [dbo].[CountryCurrency] CC WITH(NOLOCK) ON T.[IdCountryCurrency] = CC.[IdCountryCurrency]
		LEFT JOIN [dbo].[Country] CO WITH(NOLOCK) ON CC.[IdCountry] = CO.[IdCountry]
		LEFT JOIN
			[dbo].[Branch] B WITH(NOLOCK) ON T.[IdBranch] = B.[IdBranch]
		LEFT JOIN [dbo].[City] C WITH(NOLOCK) ON B.[IdCity] = C.[IdCity]
		LEFT JOIN [dbo].[State] S WITH(NOLOCK) ON C.[IdState] = S.[IdState]
		LEFT JOIN
		(
			SELECT MAX([IdTransferPayInfo]) [IdTransferPayInfo], TPI.[IdTransfer]
			FROM [dbo].[TransferPayInfo] TPI WITH(NOLOCK)
			GROUP BY TPI.[IdTransfer]
		)LTPI ON T.[IdTransferClosed] = LTPI.[IdTransfer]
		LEFT JOIN [dbo].[TransferPayInfo] TPI WITH(NOLOCK) ON LTPI.[IdTransferPayInfo] = TPI.[IdTransferPayInfo]
		LEFT JOIN [dbo].[Branch] BP WITH(NOLOCK) ON TPI.[IdBranch] = BP.[IdBranch]
		LEFT JOIN [dbo].[City] CP WITH(NOLOCK) ON BP.[IdCity] = CP.[IdCity]
		LEFT JOIN [dbo].[State] SP WITH(NOLOCK) ON CP.[IdState] = SP.[IdState]
		JOIN [dbo].[Status] ST WITH(NOLOCK) ON T.[IdStatus] = ST.[IdStatus]
		JOIN [dbo].[Users] U WITH(NOLOCK) ON T.[EnterByIdUser] = U.[IdUser]
		JOIN [dbo].[Payer] P WITH(NOLOCK) ON T.[IdPayer] = P.[IdPayer]
		JOIN [dbo].[PaymentType] PT WITH(NOLOCK) ON PT.[IdPaymentType] = T.[IdPaymentType]
		LEFT JOIN (
				SELECT
					[IdTransfer]
				FROM [dbo].[BrokenRulesByTransfer] WITH(NOLOCK)
				WHERE [IdKYCAction] = 1
				GROUP BY [IdTransfer]
			) BRBT ON T.[IdTransferClosed] = BRBT.[IdTransfer]

		WHERE
			[IdCustomer] IN (SELECT [Id] FROM @Ids)
			AND [DateOfTransfer] >= @Begindate AND [DateOfTransfer] < @Enddate
			--AND T.[IdStatus] IN (1, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 41)--#1
		) T
		OPTION(RECOMPILE)
		
		
		SELECT *
		INTO #BPInfo
		FROM
		(
		SELECT BP.IdCustomer, 
			BP.DateOfCreation AS 'DateOfTransfer', 
			A.AgentCode, 
			BP.IdProductTransfer AS 'Folio', 
			NULL AS  IdBeneficiary, 
			'BP' AS 'Beneficiaryname',			
			C.CountryName AS 'Country',
			'' AS 'StateName',
			'' AS 'StateNamePaid',
			Amount AS 'AmountInDollars',
			ST.StatusName,
			U.UserName,
			'PayerName' AS 'PayerName', 
			0 AS 'RequireID',
			'' AS 'PaymentType',
			BP.IdStatus 
		FROM Regalii.TransferR BP WITH(NOLOCK) INNER JOIN
			[dbo].Agent A WITH(NOLOCK) ON A.IdAgent = BP.IdAgent INNER JOIN
			Country C WITH(NOLOCK) ON C.IdCountry = BP.IdCountry INNER JOIN
			Status ST WITH(NOLOCK) ON ST.IdStatus = BP.IdStatus INNER JOIN
			Users U WITH(NOLOCK) ON U.IdUser = BP.EnterByIdUser
		WHERE BP.IdCustomer IN (SELECT [Id] FROM @Ids)
			AND BP.DateOfCreation >= @Begindate AND BP.DateOfCreation < @Enddate
		UNION
		SELECT BP.IdCustomer, 
			BP.DateOfCreation AS 'DateOfTransfer', 
			A.AgentCode, 
			BP.IdProductTransfer AS 'Folio', 
			NULL AS  IdBeneficiary, 
			'BP' AS 'Beneficiaryname',			
			C.CountryName AS 'Country',
			'' AS 'StateName',
			'' AS 'StateNamePaid',
			Amount AS 'AmountInDollars',
			ST.StatusName,
			U.UserName,
			'PayerName' AS 'PayerName', 
			0 AS 'RequireID',
			'' AS 'PaymentType',
			BP.IdStatus
		FROM BillPayment.TransferR BP WITH(NOLOCK) INNER JOIN
			[dbo].Agent A WITH(NOLOCK) ON A.IdAgent = BP.IdAgent INNER JOIN
			Country C WITH(NOLOCK) ON C.IdCountry = BP.IdCountry INNER JOIN
			Status ST WITH(NOLOCK) ON ST.IdStatus = BP.IdStatus INNER JOIN
			Users U WITH(NOLOCK) ON U.IdUser = BP.EnterByIdUser
		WHERE BP.IdCustomer IN (SELECT [Id] FROM @Ids)
			AND BP.DateOfCreation >= @Begindate AND BP.DateOfCreation < @Enddate
		) A
		

	IF @ResultSet = 2	
	BEGIN
	
		IF @IdProductType = 0 -- MT + BP
		BEGIN
			SELECT [IdCustomer] [IdEntity], [DateOfTransfer], [AgentCode], [Folio], [IdBeneficiary] [Id],
				[Beneficiaryname] [Name], [Country] [Country], [StateName] [State],
				[StateNamePaid], [AmountInDollars], [StatusName], [UserName], [PayerName], [RequireID], [PaymentType]
			FROM #TransfersInfo			
			UNION ALL
			SELECT IdCustomer AS 'IdEntity', DateOfTransfer, AgentCode, Folio, IdBeneficiary AS 'Id',
				BeneficiaryName AS 'Name', Country, StateName AS 'State', StateNamePaid, AmountInDollars,
				StatusName, UserName, PayerName, RequireID, PaymentType
			FROM #BPInfo
			ORDER BY DateOfTransfer DESC
		END
		ELSE
		BEGIN
			IF @IdProductType = 1 -- MT
			BEGIN
				
				SELECT [IdCustomer] [IdEntity], [DateOfTransfer], [AgentCode], [Folio], [IdBeneficiary] [Id],
					[Beneficiaryname] [Name], [Country] [Country], [StateName] [State],
					[StateNamePaid], [AmountInDollars], [StatusName], [UserName], [PayerName], [RequireID], [PaymentType]
				FROM #TransfersInfo
				ORDER BY [DateOfTransfer] DESC
			END
			ELSE
			IF @IdProductType = 2 -- BP
			BEGIN
				
				SELECT IdCustomer AS 'IdEntity', DateOfTransfer, AgentCode, Folio, IdBeneficiary AS 'Id',
					BeneficiaryName AS 'Name', Country, StateName AS 'State', StateNamePaid, AmountInDollars,
					StatusName, UserName, PayerName, RequireID, PaymentType
				FROM #BPInfo
			END 
		END
				
    END

	IF @ResultSet = 3	
	BEGIN
	
		IF @IdProductType = 1 -- MP
		BEGIN
			DELETE #BPInfo
		END
		ELSE
		IF @IdProductType = 2 -- BP
		BEGIN
			DELETE #TransfersInfo
		END 
		

		SELECT [Status], sum(ISNULL([AmountInDollars],0)) [AmountInDollars] FROM(
		SELECT 1 [orderC], 'Review' [Status], SUM([AmountInDollars]) [AmountInDollars] FROM #TransfersInfo WHERE [IdStatus] = 41
		UNION ALL
		select 2 [orderC], 'Paid' [Status], SUM([AmountInDollars]) [AmountInDollars] FROM #TransfersInfo WHERE [IdStatus] = 30
		UNION ALL
		SELECT 3 [orderC], 'Cancel/Reject' [Status], SUM([AmountInDollars]) [AmountInDollars] FROM #TransfersInfo WHERE [IdStatus] IN (22,31)
		UNION ALL 
		SELECT 1 [orderC], 'Review' [Status], SUM([AmountInDollars]) [AmountInDollars] FROM #BPInfo WHERE [IdStatus] = 41
		UNION ALL
		select 2 [orderC], 'Paid' [Status], SUM([AmountInDollars]) [AmountInDollars] FROM #BPInfo WHERE [IdStatus] = 30
		UNION ALL
		SELECT 3 [orderC], 'Cancel/Reject' [Status], SUM([AmountInDollars]) [AmountInDollars] FROM #BPInfo WHERE [IdStatus] IN (22,31)
		) T
		GROUP BY [orderC], [Status]
		ORDER BY [orderC], [Status]

    END 

	
END
