-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-01-26
-- Description:	This stored is used for [dbo].[st_ReportSAR]
-- =============================================
CREATE PROCEDURE [dbo].[st_ReportBeneficiarySAR]
	   @BeneficiaryIds NVARCHAR(MAX),
	   @Begindate DATETIME,
	   @Enddate DATETIME,
	   @ResultSet INT
AS
BEGIN

	SET @Begindate = [dbo].[RemoveTimeFromDatetime] (@Begindate)
	SET @Enddate=[dbo].[RemoveTimeFromDatetime] (@Enddate + 1)

	--------------------------------
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	--------------------------------

	DECLARE @Ids TABLE ( [Id] INT )
	
	INSERT INTO @Ids ([Id]) (SELECT [item] FROM [dbo].[fnSplit] (@BeneficiaryIds,'-'))

	IF @ResultSet = 1	
	BEGIN
		;WITH ctCsDny AS (
							SELECT
								DLB.[IdBeneficiary],
								DLB.[DateInToList],
								DLB.[NoteInToList]
							FROM [dbo].[DenyListBeneficiary] DLB
							JOIN (
									SELECT MAX([IdDenyListBeneficiary]) [IdDenyListBeneficiary]
									FROM [dbo].[DenyListBeneficiary]
									GROUP BY [IdBeneficiary]
								) L ON DLB.[IdDenyListBeneficiary] = L.[IdDenyListBeneficiary]
							WHERE DLB.[IdBeneficiary] IN (SELECT [Id] FROM @Ids)
						 )

		, ctStatusSAR AS (
							SELECT
								[IdBeneficiary],
								MAX([DataLastChange]) [DataLastChange]
							FROM [dbo].[StatusBeneficiarySAR]
							WHERE [StatusSAR] = 1
								AND [IdBeneficiary] IN (SELECT [Id] FROM @Ids)
							GROUP BY [IdBeneficiary]
						)

		SELECT 
			BE.[IdBeneficiary] [Id],
			BE.[Name] +' '+ BE.[FirstLastName] + ' ' + BE.[SecondLastName] [Name],
			BE.[Address],
			BE.Country,
			BE.[State],
			BE.[City],
			ISNULL(IT.[Name],'') [IdentificationType],
			ISNULL(CONVERT(VARCHAR, BE.[IdBeneficiaryIdentificationType]), '') [IdentificationNumber],
			SR.[DataLastChange] [SARDate],
			ctCsDny.[DateInToList] [DenyDate],
			ISNULL(ctCsDny.[NoteInToList],'') [DenyStatus]
		FROM [dbo].[Beneficiary] BE
		LEFT JOIN [dbo].[BeneficiaryIdentificationType] IT ON BE.[IdBeneficiary] = IT.[IdBeneficiaryIdentificationType]
		LEFT JOIN ctStatusSAR SR ON BE.[IdBeneficiary] = SR.[IdBeneficiary] --ultimo y activado (1)
		LEFT JOIN ctCsDny ON ctCsDny.[IdBeneficiary] = BE.[IdBeneficiary]
		-------
		WHERE BE.IdBeneficiary IN (SELECT [Id] FROM @Ids)
		ORDER BY BE.IdBeneficiary

		RETURN

	END

-------------------------------

	SELECT
		[IdBeneficiary],
		[DateOfTransfer],
		[AgentCode],
		[Folio],
		[IdCustomer],
		[Country],
		[bFlName],
		[StateName],
		[StateNamePaid],
		[AmountInDollars],
		[IdStatus],
		[StatusName],
		[AgentName],
		[UserName],
		[PayerName],
		[RequireID],
		[PaymentType]
	INTO #TransfersInfo
	FROM (
			SELECT
				RT.[IdBeneficiary],
				RT.[DateOfTransfer] [DateOfTransfer],
				AG.[AgentCode],
				RT.[Folio],
				CT.[IdCustomer],
				AG.[AgentState] [Country],
				CT.[Name] +' '+ CT.[FirstLastName] + ' ' + CT.[SecondLastName] [bFlName],
				ISNULL(S.[StateName],'') [StateName],
				CASE WHEN RT.[IdStatus] = 30 THEN ISNULL(STE.[StateName],'') ELSE '' END [StateNamePaid],
				RT.[AmountInDollars],
				RT.[IdStatus],
				ST.[StatusName],
				AG.[AgentName],
				U.[UserName],
				PY.[PayerName],
				CASE WHEN ISNULL(BRBT.[IdTransfer],0) = 0 THEN 0 ELSE 1 END [RequireID],
				PT.[PaymentName] [PaymentType]
			FROM [dbo].[Transfer] RT
			INNER JOIN [dbo].[Agent] AG ON RT.[IdAgent] = AG.[IdAgent]
			INNER JOIN [dbo].[Customer] CT ON CT.[IdCustomer] = RT.[IdCustomer]
			INNER JOIN [dbo].[Users] U ON RT.[EnterByIdUser] = U.[IdUser]
			INNER JOIN [dbo].[PaymentType] PT ON PT.[IdPaymentType] = RT.[IdPaymentType]
			LEFT JOIN [dbo].[Branch] B ON RT.[IdBranch] = B.[IdBranch]
			LEFT JOIN [dbo].[City] C ON B.[IdCity] = C.[IdCity]
			LEFT JOIN [dbo].[State] S ON C.[IdState] = S.[IdState]
			LEFT JOIN
			(
				SELECT MAX([IdTransferPayInfo]) [IdTransferPayInfo], TPI.[IdTransfer]
				FROM [dbo].[TransferPayInfo] TPI
				GROUP BY TPI.[IdTransfer]
			)LTPI ON RT.[IdTransfer] = LTPI.[IdTransfer]
			LEFT JOIN [dbo].[TransferPayInfo] RPI ON LTPI.[IdTransferPayInfo] = RPI.[IdTransferPayInfo]
			LEFT JOIN [dbo].[Branch] BR ON RPI.[IdBranch] = BR.[IdBranch]
			LEFT JOIN [dbo].[City] CY ON CY.[IdCity] = BR.[IdCity]
			LEFT JOIN [dbo].[State] STE ON STE.[IdState] = CY.[IdState]
			LEFT JOIN [dbo].[Status] ST ON RT.[IdStatus] = ST.[IdStatus]
			LEFT JOIN [dbo].[Payer] PY ON RT.[IdPayer] = PY.[IdPayer]
			LEFT JOIN (
				SELECT
					[IdTransfer]
				FROM [dbo].[BrokenRulesByTransfer]
				WHERE [IdKYCAction] = 1
				GROUP BY [IdTransfer]
			) BRBT ON RT.[IdTransfer] = BRBT.[IdTransfer]

			WHERE RT.[IdBeneficiary] IN (SELECT [Id] FROM @Ids)
			AND RT.[DateOfTransfer] >= @Begindate
			AND RT.[DateOfTransfer] < @Enddate
			AND RT.[IdStatus] IN (1, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 41)
	 
		UNION ALL

			SELECT
				RT.[IdBeneficiary],
				RT.[DateOfTransfer] [DateOfTransfer],
				AG.[AgentCode],
				RT.[Folio],
				CT.[IdCustomer],
				AG.[AgentState] [Country],
				CT.[Name] +' '+ CT.[FirstLastName] + ' ' + CT.[SecondLastName] [bFlName],
				ISNULL(S.[StateName],'') [StateName],
				CASE WHEN RT.[IdStatus] = 30 THEN ISNULL(STE.[StateName],'') ELSE '' END [StateNamePaid],
				RT.[AmountInDollars],
				RT.[IdStatus],
				ST.[StatusName],
				AG.[AgentName],
				U.[UserName],
				PY.[PayerName],
				CASE WHEN ISNULL(BRBT.[IdTransfer],0) = 0 THEN 0 ELSE 1 END [RequireID],
				PT.[PaymentName] [PaymentType]
			FROM [dbo].[TransferClosed] RT
			INNER JOIN [dbo].[Agent] AG	ON RT.[IdAgent] = AG.[IdAgent]
			INNER JOIN [dbo].[Customer] CT ON CT.[IdCustomer] = RT.[IdCustomer]
			LEFT JOIN [dbo].[Branch] B ON RT.[IdBranch] = B.[IdBranch]
			LEFT JOIN [dbo].[City] C ON B.[IdCity] = C.[IdCity]
			LEFT JOIN [dbo].[State] S ON C.[IdState] = S.[IdState]
			LEFT JOIN
			(
				SELECT MAX([IdTransferPayInfo]) [IdTransferPayInfo], TPI.[IdTransfer]
				FROM [dbo].[TransferPayInfo] TPI
				GROUP BY TPI.[IdTransfer]
			)LTPI ON RT.[IdTransferClosed] = LTPI.[IdTransfer]
			LEFT JOIN [dbo].[TransferPayInfo] RPI ON LTPI.[IdTransferPayInfo] = RPI.[IdTransferPayInfo]
			LEFT JOIN [dbo].[Branch] BR ON RPI.[IdBranch] = BR.[IdBranch]
			LEFT JOIN [dbo].[City] CY ON CY.[IdCity] = BR.[IdCity]
			LEFT JOIN [dbo].[State] STE ON STE.[IdState] = CY.[IdState]
			LEFT JOIN [dbo].[Status] ST ON RT.[IdStatus] = ST.[IdStatus]
			LEFT JOIN [dbo].[Payer] PY ON RT.[IdPayer] = PY.[IdPayer]
			INNER JOIN [dbo].[Users] U ON RT.[EnterByIdUser] = U.[IdUser]
			JOIN [dbo].[PaymentType] PT ON PT.[IdPaymentType] = RT.[IdPaymentType]
			LEFT JOIN (
				SELECT
					[IdTransfer]
				FROM [dbo].[BrokenRulesByTransfer]
				WHERE [IdKYCAction] = 1
				GROUP BY [IdTransfer]
			) BRBT ON RT.[IdTransferClosed] = BRBT.[IdTransfer]

			WHERE RT.IdBeneficiary IN (SELECT [Id] FROM @Ids)
			AND RT.DateOfTransfer >= @Begindate
			AND RT.DateOfTransfer < @Enddate
			AND RT.IdStatus in (1, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 41)
			) T

	IF @ResultSet = 2	
	BEGIN
		SELECT 
			[IdBeneficiary] [IdEntity], [DateOfTransfer], [AgentCode], [Folio], [IdCustomer] [Id],
			[bFlName] [Name], [Country], [StateName] [State],
			[StateNamePaid], [AmountInDollars], [StatusName], [UserName], [PayerName], [RequireID], [PaymentType]
		FROM #TransfersInfo
		ORDER BY [DateOfTransfer] DESC

		RETURN

	END 

    IF @ResultSet = 3
	BEGIN
		SELECT [Status], ISNULL([AmountInDollars],0) [AmountInDollars]
		FROM(
			SELECT 1 [orderC],'Review' [Status], SUM([AmountInDollars]) [AmountInDollars] FROM #TransfersInfo WHERE [IdStatus] = 41
				UNION ALL
			SELECT 2 [orderC],'Paid' [Status], SUM([AmountInDollars]) [AmountInDollars] FROM #TransfersInfo WHERE [IdStatus] = 30
				UNION ALL
			SELECT 3 [orderC],'Cancel/Reject' [Status], SUM([AmountInDollars]) [AmountInDollars] FROM #TransfersInfo WHERE [IdStatus] IN (22,31)
		) T
	ORDER BY [orderC]

	END

END




