CREATE PROCEDURE [dbo].[st_GetSearchChecksInformation]
@FechaInicio DATETIME,
@FechaFin DATETIME,
@Status INT,
@IdAgent INT,
@IdCheckProcessorBank INT = null,
@HasError BIT OUTPUT,
@Message NVARCHAR(MAX) OUTPUT

AS
BEGIN

SET ARITHABORT ON;   

	IF @Status = 1 SET @Status = NULL
	IF @IdAgent = 0 SET @IdAgent = NULL
	IF @IdCheckProcessorBank=0 SET @IdCheckProcessorBank=NULL

	SET @FechaFin=DATEADD(dd, 1, @FechaFin)
	SELECT @FechaFin=dbo.RemoveTimeFromDatetime(@FechaFin)
	SELECT @FechaInicio=dbo.RemoveTimeFromDatetime(@FechaInicio)

	CREATE TABLE #TempChecks(
	[DateOfMovement] DATETIME,
	[Name] NVARCHAR(MAX),
	[FirstLastName] NVARCHAR(MAX),
	[SecondLastName] NVARCHAR(MAX),
	[IssuerName] NVARCHAR(MAX),
	[Account] NVARCHAR(MAX),
	[Amount] MONEY,
	[Note] NVARCHAR(MAX),
	[IdentificationType] INT,
	[CheckNumber] NVARCHAR(MAX),
	[Route] NVARCHAR(MAX),
	[Folio] INT,
	[IdAgent] INT,
	[AgentName] NVARCHAR(MAX),
	[AgentCode] NVARCHAR(MAX),
	[ClaimCheck] NVARCHAR(MAX),
	[IdentificationNumber] NVARCHAR(MAX),
	[IdentificationDateOfExpiration] DATETIME,
	[SSNumber] NVARCHAR(MAX),
	[DateOfBirth] DATETIME,
	[CountryBirthId] INT,
	[Ocupation] NVARCHAR(MAX),
	[IdCustomer] INT,
	[DateOfIssue] DATETIME,
	[Fee] MONEY,
	[Comission] MONEY,
	[IdCheck] INT,
    [UserName] NVARCHAR(MAX),
	[PhoneNumber] NVARCHAR(MAX),
	CheckProcessorBank NVARCHAR(MAX)
    )

	IF @Status IS NULL OR @Status IN (12,15,57,41,61,64) -- Deny List Hold (12), OFAC Hold (15), Endorse Hold (57), Duplicate Checks Hold (61)
	BEGIN
		INSERT INTO #TempChecks
			SELECT DISTINCT TOP 1500
				[C].[DateOfMovement] AS [DateOfMovement]
				, [C].[Name] AS [Name]
				, [C].[FirstLastName] AS [FirstLastName]
				, [C].[SecondLastName] AS [SecondLastName]
				, [C].[IssuerName] AS [IssuerName]
				, [C].[Account] AS [Account]
				, [C].[Amount] AS [Amount]
				, 'Verify Hold' as [Note]
				, [C].[IdIdentificationType] AS [IdentificationType]
				, [C].[CheckNumber] AS [CheckNumber]
				, [C].[RoutingNumber] AS [Route]
				, [C].[IdCheck] AS [Folio]
				, [A].[IdAgent] AS [IdAgent]
				, [A].[AgentName] AS [AgentName]
				, [A].[AgentCode] AS [AgentCode]
				, [C].[ClaimCheck] AS [ClaimCheck]
				, [C].[IdentificationNumber]
				, [C].[IdentificationDateOfExpiration]
				, [C].[SSNumber]
				, [C].[DateOfBirth]
				, [C].[CountryBirthId]
				, [C].[Ocupation]
				, [C].[IdCustomer]
				, [C].[DateOfIssue]
				,ISNULL([C].[Fee],0) [Fee]
				,ISNULL([C].[Comission],0) [Comission]
				, [C].[IdCheck]
                ,ISNULL([U].[UserName],'') [UserName]
				 ,[I].[PhoneNumber]
				 ,ISNULL(PB.Name,'') CheckProcessorBank
			FROM
			[dbo].[Checks] AS [C] WITH (NOLOCK)
			INNER JOIN [dbo].[Agent] AS [A] WITH (NOLOCK) ON [C].[IdAgent] = [A].[IdAgent]
			INNER JOIN [dbo].IssuerChecks AS [I] WITH (NOLOCK) ON [I].IdIssuer = [C].IdIssuer
			LEFT JOIN dbo.CheckProcessorBank AS PB WITH (NOLOCK) ON C.IdCheckProcessorBank=PB.IdCheckProcessorBank
			LEFT JOIN (
					SELECT [CH].[IdCheck]
					FROM [dbo].[CheckHolds] [CH] WITH (NOLOCK)
					WHERE @Status IS NOT NULL AND @Status != 41 AND [CH].[IdStatus] = @Status AND [CH].[IsReleased] IS NULL
				) [TCH] ON [TCH].[IdCheck] = [C].[IdCheck]
            LEFT JOIN [dbo].[Users] [U] WITH (NOLOCK) ON [C].[EnteredByIdUser] = [U].[IdUser]
			WHERE
				[A].[IdAgent] = ISNULL(@IdAgent, [A].[IdAgent])
				AND [C].[IdStatus] = 41 AND (@Status IS NULL OR @Status = 41 OR [TCH].[IdCheck] IS NOT NULL)
				AND CONVERT(DATE, [C].[DateOfMovement]) >= CONVERT(DATE, @FechaInicio)
				AND CONVERT(DATE, [C].[DateOfMovement]) < CONVERT(DATE, @FechaFin)
				AND (@IdCheckProcessorBank IS NULL or (C.IdCheckProcessorBank= @IdCheckProcessorBank ))
	END
	IF @Status IS NULL OR @Status IN (20,22,30,31,40,21) -- Stand By (20), Cancelled (22), Paid (30), Rejected (31), Transfer Accepted (40), Pending Gateway Response (21)
	BEGIN
		INSERT INTO #TempChecks
			SELECT TOP 1500
				[C].[DateOfMovement] AS [DateOfMovement]
				, [C].[Name] AS [Name]
				, [C].[FirstLastName] AS [FirstLastName]
				, [C].[SecondLastName] AS [SecondLastName]
				, [C].[IssuerName] AS [IssuerName]
				, [C].[Account] AS [Account]
				, [C].[Amount] AS [Amount]
				, [S].[StatusName] as [Note]
				, [C].[IdIdentificationType] AS [IdentificationType]
				, [C].[CheckNumber] AS [CheckNumber]
				, [C].[RoutingNumber] AS [Route]
				, [C].[IdCheck] AS [Folio]
				, [A].[IdAgent] AS [IdAgent]
				, [A].[AgentName] AS [AgentName]
				, [A].[AgentCode] AS [AgentCode]
				, [C].[ClaimCheck] AS [ClaimCheck]
				, [C].[IdentificationNumber]
				, [C].[IdentificationDateOfExpiration]
				, [C].[SSNumber]
				, [C].[DateOfBirth]
				, [C].[CountryBirthId]
				, [C].[Ocupation]
				, [C].[IdCustomer]
				, [C].[DateOfIssue]
				,ISNULL([C].[Fee],0) [Fee]
				,ISNULL([C].[Comission],0) [Comission]
				, [C].[IdCheck]
                ,isnull(u.UserName,'') UserName
				, [I].[PhoneNumber]
				,ISNULL(PB.Name,'') CheckProcessorBank
			FROM
			[dbo].[Checks] AS [C] WITH (NOLOCK)
			INNER JOIN [dbo].IssuerChecks AS [I] WITH (NOLOCK) ON [I].IdIssuer = [C].IdIssuer
			LEFT JOIN dbo.CheckProcessorBank AS PB WITH (NOLOCK) ON C.IdCheckProcessorBank=PB.IdCheckProcessorBank
			INNER JOIN [dbo].[Agent] AS [A] WITH (NOLOCK) ON [C].[IdAgent] = [A].[IdAgent]
			INNER JOIN [dbo].[Status] AS [S] ON [C].[IdStatus] = [S].[IdStatus]
            left join users u on C.EnteredByIdUser=u.IdUser
			WHERE
				[A].[IdAgent] = ISNULL(@IdAgent, [A].[IdAgent])
				AND [C].[IdStatus] = ISNULL(@Status, [C].[IdStatus])
				AND [C].[IdStatus] != 41 -- Verify Hold
				AND CONVERT(DATE, [C].[DateOfMovement]) >= CONVERT(DATE, @FechaInicio)
				AND CONVERT(DATE, [C].[DateOfMovement]) < CONVERT(DATE, @FechaFin)
				AND (@IdCheckProcessorBank IS NULL or (C.IdCheckProcessorBank= @IdCheckProcessorBank ))
	END

	DECLARE @Countrows INT
	SELECT @Countrows = COUNT(1) FROM #TempChecks
	IF @Countrows <= 10
	BEGIN

		SELECT
		[DateOfMovement],
		[Name],
		[FirstLastName],
		[SecondLastName],
		[IssuerName],
		[Account],
		[Amount],
		[Note],
		[IdentificationType],
		[CheckNumber],
		[Route],
		[Folio],
		[IdAgent],
		[AgentName],
		[AgentCode],
		[ClaimCheck],
		[IdentificationNumber],
		[IdentificationDateOfExpiration],
		[SSNumber],
		[DateOfBirth],
		[CountryBirthId],
		[Ocupation],
		[IdCustomer],
		[DateOfIssue],
		[Fee],
		[Comission],
		[IdCheck],
        [UserName],
		[PhoneNumber],
		CheckProcessorBank
	FROM
	#TempChecks
	ORDER BY [DateOfMovement] DESC

	SET @HasError = 0
	SELECT @Message = ''

	END
	ELSE
	BEGIN
		SET @HasError = 1
		SELECT @Message = dbo.GetMessageFromLenguajeResorces (0,34) -- Error, Increase your filters, Result is too big to be displayed
	END

END

