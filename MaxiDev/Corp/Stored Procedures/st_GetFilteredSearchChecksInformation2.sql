CREATE PROCEDURE [Corp].[st_GetFilteredSearchChecksInformation2]
@FechaInicio DATETIME,
@FechaFin DATETIME,
@Status INT,
@IdAgent INT,
@IdCheckProcessorBank INT = null,

@Folio INT  = null,
@Issuer  NVARCHAR(MAX) = null,
@CustomerLastName NVARCHAR(MAX) = null,
@NumberCheck  NVARCHAR(MAX) = null,
@RoutingNumberCheck NVARCHAR(MAX) = null,
@AccountCheck  NVARCHAR(MAX) = null,
@OnlyNotIRDProcessed BIT,

@HasError BIT OUTPUT,
@Message NVARCHAR(MAX) OUTPUT

AS
/********************************************************************
<Author> ???</Author>
<app>Corporate </app>
<Description> Realiza busqueda de cheques desde Other products </Description>

<ChangeLog>
<log Date="18/07/2017" Author="fgonzalez"> Se agregan los campos IsOfacMultiple , MicrOriginal y MicrManual </log>
</ChangeLog>
<ChangeLog>
<log Date="10/08/2017" Author="dalmeida"> Se modifica el parametro Status para tomar los origin </log>
<log Date="24/03/2018" Author="jdarellano" Name="#1"> Se agrega "SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED".</log>
</ChangeLog>

*********************************************************************/
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;--#1

SET ARITHABORT ON;   

	DECLARE @ParametersXml VARCHAR(MAX)
	DECLARE @StartTime datetime = GETDATE()

	IF @Status = 0 SET @Status = NULL
	IF @IdAgent = 0 SET @IdAgent = NULL
	IF @IdCheckProcessorBank=0 SET @IdCheckProcessorBank=NULL

	/*--------------------------*/
	IF @Folio = 0 SET @Folio = NULL;

	SET @Issuer = RTRIM(LTRIM(@Issuer));
	IF @Issuer = '' SET @Issuer = null;

	SET @CustomerLastName = RTRIM(LTRIM(@CustomerLastName))
	IF  @CustomerLastName= '' SET @CustomerLastName = null;

	SET @NumberCheck = RTRIM(LTRIM(@NumberCheck));
	IF  @NumberCheck= '' SET @NumberCheck = null;

	SET @RoutingNumberCheck = RTRIM(LTRIM(@RoutingNumberCheck));
	IF @RoutingNumberCheck = '' SET @RoutingNumberCheck = NULL;

	SET @AccountCheck = RTRIM(LTRIM(@AccountCheck));
	IF @AccountCheck = '' SET @AccountCheck = NULL;
	/*--------------------------*/

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
	[IdentificationTypeDescription] NVARCHAR(MAX),
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
	CheckProcessorBank NVARCHAR(MAX),
	IsOfacMultiple BIT,
	MicrOriginal VARCHAR(200),
	MicrManual VARCHAR(200),
	IrdPrinted BIT
	--,[IdCustmer] INT
    )

	IF @Status IS NULL OR @Status IN (12,15,57,41,61,64) -- Deny List Hold (12), OFAC Hold (15), Endorse Hold (57), Duplicate Checks Hold (61)
	BEGIN
		INSERT INTO #TempChecks
			SELECT DISTINCT TOP 2001
				[C].[DateOfMovement] AS [DateOfMovement]
				, [C].[Name] AS [Name]
				, [C].[FirstLastName] AS [FirstLastName]
				, [C].[SecondLastName] AS [SecondLastName]
				, [C].[IssuerName] AS [IssuerName]
				, [C].[Account] AS [Account]
				, [C].[Amount] AS [Amount]
				, 'Verify Hold' as [Note]
				, [C].[IdIdentificationType] AS [IdentificationType]
				--, [C].[IdentificationType] AS IdentificationTypeDescription
				,CIT.Name AS IdentificationTypeDescription
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
				,ISNULL([C].[Fee],0) As [Fee]
				,ISNULL([C].[Comission],0) As [Comission]
				, [C].[IdCheck]
                ,ISNULL([U].[UserName],'') As [UserName]
				 ,[I].[PhoneNumber]
				 ,ISNULL(PB.Name,'') As CheckProcessorBank
				 ,CASE WHEN (select COUNT(1) from CheckHolds WITH(NOLOCK) where IdCheck = C.IdCheck AND IdStatus = 15 AND IsReleased = 1) >= 1 THEN 1 ELSE 0 END AS IsOfacMultiple,
				  C.MicrOriginal, 
				  C.MicrManual,
				  isnull(CRH.IrdPrinted, 0) AS IrdPrinted
				 --,[C].[IdCustomer]
			FROM
			[dbo].[Checks] AS [C] WITH (NOLOCK)
			INNER JOIN [dbo].CustomerIdentificationType AS CIT WITH (NOLOCK) ON C.IdIdentificationType = CIT.IdCustomerIdentificationType
			INNER JOIN [dbo].[Agent] AS [A] WITH (NOLOCK) ON [C].[IdAgent] = [A].[IdAgent]
			INNER JOIN [dbo].IssuerChecks AS [I] WITH (NOLOCK) ON [I].IdIssuer = [C].IdIssuer
			LEFT JOIN dbo.CheckProcessorBank AS PB WITH (NOLOCK) ON C.IdCheckProcessorBank=PB.IdCheckProcessorBank
			LEFT JOIN (
					SELECT [CH].[IdCheck]
					FROM [dbo].[CheckHolds] [CH] WITH (NOLOCK)
					WHERE @Status IS NOT NULL AND @Status != 41 AND [CH].[IdStatus] = @Status AND [CH].[IsReleased] IS NULL
				) [TCH] ON [TCH].[IdCheck] = [C].[IdCheck]
            LEFT JOIN [dbo].[Users] [U] WITH (NOLOCK) ON [C].[EnteredByIdUser] = [U].[IdUser]
            LEFT JOIN CheckRejectHistory AS CRH WITH(NOLOCK) ON CRH.IdCheck = C.IdCheck
			WHERE
			
				[A].[IdAgent] = ISNULL(@IdAgent, [A].[IdAgent])
				AND [C].[IdStatus] = 41 AND (@Status IS NULL OR @Status = 41 OR [TCH].[IdCheck] IS NOT NULL)

				AND CONVERT(DATE, [C].[DateOfMovement]) >= CONVERT(DATE, @FechaInicio)
				AND CONVERT(DATE, [C].[DateOfMovement]) < CONVERT(DATE, @FechaFin)
				AND (@IdCheckProcessorBank IS NULL or (C.IdCheckProcessorBank= @IdCheckProcessorBank ))

				AND [C].[IdCheck] = ISNULL(@Folio, [C].[IdCheck]) /*Folio*/

				--AND [C].[IssuerName] LIKE '%' + ISNULL(@Issuer, [C].[IssuerName]) + '%'
				--Se modifica la busqueda de issuer ya que los issuer que tienen corchetes en el nombre, no se pueden filtrar con like
				AND (@Issuer IS NULL  OR (@Issuer IS NOT NULL AND C.IssuerName LIKE '%' + @Issuer+'%'))

				AND [C].[FirstLastName] LIKE '%' + ISNULL(@CustomerLastName,[C].[FirstLastName]) + '%'
				AND [C].[CheckNumber] LIKE '%' + ISNULL(@NumberCheck, [C].[CheckNumber]) + '%'

				AND [C].[RoutingNumber] =ISNULL(@RoutingNumberCheck,[C].[RoutingNumber] ) /*NumeroDeRuta -> routingNumberCheck*/
				AND [C].[Account] = ISNULL(@AccountCheck, [C].[Account])	/*Cuenta -> accountCheck*/

	END
	IF @Status IS NULL OR @Status IN (1,20,21,22,30,31,40) -- Stand By (20), Pending Gateway Response (21), Cancelled (22), Paid (30), Rejected (31), Transfer Accepted (40)
	BEGIN
		INSERT INTO #TempChecks
			SELECT TOP 2001
				[C].[DateOfMovement] AS [DateOfMovement]
				, [C].[Name] AS [Name]
				, [C].[FirstLastName] AS [FirstLastName]
				, [C].[SecondLastName] AS [SecondLastName]
				, [C].[IssuerName] AS [IssuerName]
				, [C].[Account] AS [Account]
				, [C].[Amount] AS [Amount]
				, [S].[StatusName] as [Note]
				, [C].[IdIdentificationType] AS [IdentificationType]
				--, [C].[IdentificationType] AS IdentificationTypeDescription
				,CIT.Name AS IdentificationTypeDescription
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
				,ISNULL([C].[Fee],0) As [Fee]
				,ISNULL([C].[Comission],0) As [Comission]
				, [C].[IdCheck]
                ,isnull(u.UserName,'') As UserName
				, [I].[PhoneNumber]
				,ISNULL(PB.Name,'') As CheckProcessorBank
				,CASE WHEN (select COUNT(1) from CheckHolds WITH(NOLOCK) where IdCheck = C.IdCheck AND IdStatus = 15 AND IsReleased = 1) >= 1 THEN 1 ELSE 0 END AS IsOfacMultiple,
				  C.MicrOriginal, 
				  C.MicrManual,
				  isnull(CRH.IrdPrinted, 0) AS IrdPrinted
				--,[C].[IdCustomer]
			FROM
			[dbo].[Checks] AS [C] WITH (NOLOCK)
			INNER JOIN [dbo].CustomerIdentificationType AS CIT WITH (NOLOCK) ON C.IdIdentificationType = CIT.IdCustomerIdentificationType			
			INNER JOIN [dbo].[Agent] AS [A] WITH (NOLOCK) ON [C].[IdAgent] = [A].[IdAgent]
			INNER JOIN [dbo].IssuerChecks AS [I] WITH (NOLOCK) ON [I].IdIssuer = [C].IdIssuer
			LEFT JOIN dbo.CheckProcessorBank AS PB WITH (NOLOCK) ON C.IdCheckProcessorBank=PB.IdCheckProcessorBank			
			INNER JOIN [dbo].[Status] AS [S] WITH(NOLOCK) ON [C].[IdStatus] = [S].[IdStatus]
            left join users As u WITH(NOLOCK) on C.EnteredByIdUser=u.IdUser
            LEFT JOIN CheckRejectHistory AS CRH WITH(NOLOCK) ON CRH.IdCheck = C.IdCheck
			WHERE
				[A].[IdAgent] = ISNULL(nullif(@IdAgent,0), [A].[IdAgent])
				AND [C].[IdStatus] = ISNULL(@Status, [C].[IdStatus])
				AND [C].[IdStatus] != 41 -- Verify Hold

				AND CONVERT(DATE, [C].[DateOfMovement]) >= CONVERT(DATE, @FechaInicio)
				AND CONVERT(DATE, [C].[DateOfMovement]) < CONVERT(DATE, @FechaFin)
				AND (@IdCheckProcessorBank IS NULL or (C.IdCheckProcessorBank= @IdCheckProcessorBank ))

				AND [C].[IdCheck] = ISNULL(@Folio, [C].[IdCheck]) /*Folio*/

				
				--AND [C].[IssuerName] LIKE '%' + ISNULL(@Issuer, replace(replace([C].[IssuerName],']','%'),'[','%')) + '%'
				--Se modifica la busqueda de issuer ya que los issuer que tienen corchetes en el nombre, no se pueden filtrar con like
				AND (@Issuer IS NULL  OR (@Issuer IS NOT NULL AND C.IssuerName LIKE '%' + @Issuer+'%'))
			 
				AND [C].[FirstLastName] LIKE '%' + ISNULL(@CustomerLastName,[C].[FirstLastName]) + '%'
				AND [C].[CheckNumber] LIKE '%' + ISNULL(@NumberCheck, [C].[CheckNumber]) + '%'

				AND [C].[RoutingNumber] =ISNULL(@RoutingNumberCheck,[C].[RoutingNumber] ) /*NumeroDeRuta -> routingNumberCheck*/
				AND [C].[Account] = ISNULL(@AccountCheck, [C].[Account])	/*Cuenta -> accountCheck*/
	END

	DECLARE @Countrows INT
	SELECT @Countrows = COUNT(1) FROM #TempChecks
	IF @Countrows <= 2000
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
		IdentificationTypeDescription,
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
		[CheckProcessorBank],
		[IsOfacMultiple],
		[MicrOriginal],
		[MicrManual],
		[IrdPrinted]
		--[IdCustmer]
	FROM
	#TempChecks WITH(NOLOCK)
	WHERE ((@OnlyNotIRDProcessed = 1 AND IrdPrinted = 0) OR @OnlyNotIRDProcessed = 0)
	ORDER BY [DateOfMovement] DESC

	SET @HasError = 0
	SELECT @Message = ''

	END
	ELSE
	BEGIN
		SET @HasError = 1
		SELECT @Message = dbo.GetMessageFromLenguajeResorces (0,120) -- Error, Increase your filters, Result is too big to be displayed
	END

	/*SET @ParametersXml = CAST((SELECT *
	FROM (
	       SELECT FechaInicio = @FechaInicio,
	              FechaFin = @FechaFin,
	              [Status] = IIF(@Status IS NULL, 'NULL', CONVERT(VARCHAR, @Status)),
	              IdAgent = @IdAgent,
	              IdCheckProcessorBank = IIF(@IdCheckProcessorBank IS NULL, 'NULL', CONVERT(VARCHAR, @IdCheckProcessorBank)),
	              Folio = IIF(@Folio IS NULL, 'NULL', CONVERT(VARCHAR, @Folio)),
	              Issuer = IIF(@Issuer IS NULL, 'NULL', CONVERT(VARCHAR, @Issuer)),
	              CustomerLastName = IIF(@CustomerLastName IS NULL, 'NULL', CONVERT(VARCHAR, @CustomerLastName)),
	              NumberCheck = IIF(@NumberCheck IS NULL, 'NULL', CONVERT(VARCHAR, @NumberCheck)),
	              RoutingNumberCheck = IIF(@RoutingNumberCheck IS NULL, 'NULL', CONVERT(VARCHAR, @RoutingNumberCheck)),
	              AccountCheck = IIF(@AccountCheck IS NULL, 'NULL', CONVERT(VARCHAR, @AccountCheck)),
				  TimeExecute = DATEDIFF(SECOND, @StartTime, GETDATE())
	      ) as t
	       FOR XML PATH('Parameters'), ELEMENTS) AS VARCHAR(MAX))

	INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage, ExtraData) VALUES('st_GetFilteredSearchChecksInformation', GETDATE(), 'Validando tiempo de ejecución', @ParametersXml)
*/	
END




