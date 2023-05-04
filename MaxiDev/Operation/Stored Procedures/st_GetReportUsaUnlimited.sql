CREATE PROCEDURE [Operation].[st_GetReportUsaUnlimited]
(
    @BeginDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @IdProvider INT = NULL,
    @IdAgent INT = NULL,    
    @StatusesPreselected XML,
    @Folio INT = NULL,
    @IdLenguage INT = NULL,
	@FullResult BIT = 0,
    @cellPhone NVARCHAR(MAX),
	@IdTransfer INT,
    @HasError BIT OUTPUT,
    @Message NVARCHAR(MAX) OUTPUT
)
AS
/********************************************************************
<Author>Jose Velarde</Author>
<app>MaxiCorp</app>
<Description>This stored is used in Corp To get Report of E-Gift in [Seach Other Produts]</Description>

<ChangeLog>
<log Date="18/01/2017" Author="mdelgado">Add new filtered request. New Field "Transfer ID" [TransactionProviderID]</log>
</ChangeLog>
*********************************************************************/
	-----------------------
	--DECLARE @BeginDate DATETIME = NULL
	--DECLARE @EndDate DATETIME = NULL
	--DECLARE @IdProvider INT = NULL
	--DECLARE @IdAgent INT = NULL  
	--DECLARE @StatusesPreselected XML = '<statuses><status id="21" /><status id="22" /><status id="30" /></statuses>'
	--DECLARE @Folio INT = NULL
	--DECLARE @IdLenguage INT = NULL
	--DECLARE @FullResult BIT = 0
	--DECLARE @cellPhone NVARCHAR(MAX)
	--DECLARE @IdTransfer BIGINT = 2015040923
	--DECLARE @tStatus TABLE ([Id] INT)
	--DECLARE @Message NVARCHAR(MAX)
	--DECLARE @HasError BIT
	-----------------------
	

	DECLARE @tStatus TABLE ([Id] INT)

	DECLARE @DocHandle INT
	DECLARE @hasStatus BIT
	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @StatusesPreselected
    
	INSERT INTO @tStatus(id)
	SELECT [id]
	FROM OPENXML (@DocHandle, '/statuses/status',1)
	WITH (id INT)
    
	EXEC sp_xml_removedocument @DocHandle

	IF @IdLenguage IS NULL
		SET @IdLenguage = 2

	DECLARE @Tot INT = 0

	SET @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)
	SET @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)

	CREATE TABLE #Result (
		[DateOfTransaction] DATETIME,
		[PhoneNumber] NVARCHAR(MAX),
		[Folio] BIGINT,
		[TransactionId] BIGINT,
		[ProductName] NVARCHAR(MAX),
		[Amount] MONEY,
		[AgentCode] NVARCHAR(MAX),
		[AgentName] NVARCHAR(MAX),  
		[IdStatus] INT,
		[Status] NVARCHAR(MAX),
		[IdProvider] INT,
		[ProviderName] NVARCHAR(MAX),
		[CellPhone] NVARCHAR(MAX),
		[UserName] NVARCHAR(MAX),
		[Country] NVARCHAR(MAX)
	)

	SELECT @Tot = COUNT(1)
	FROM [Operation].[ProductTransfer] T WITH (NOLOCK)
	JOIN [dbo].[agent] A WITH (NOLOCK) ON T.[IdAgent] = A.[IdAgent]
	JOIN [dbo].[OtherProductStatus] S WITH (NOLOCK) ON T.[IdStatus] = S.[IdStatus]
	WHERE T.[IdOtherProduct] IN (13,16)
		--AND T.[DateOfCreation] >= ISNULL(@BeginDate, T.[DateOfCreation]) AND T.[DateOfCreation] <= ISNULL(@EndDate, T.[DateOfCreation])
		AND T.DateOfCreation >= CASE WHEN @IdTransfer IS NULL THEN ISNULL(@BeginDate, T.DateOfCreation) ELSE T.DateOfCreation END --20170116
		AND T.DateOfCreation <= CASE WHEN @IdTransfer IS NULL THEN isnull(@EndDate,T.DateOfCreation) ELSE T.DateOfCreation END --20170116
		AND t.TransactionProviderID = ISNULL(@IdTransfer,T.TransactionProviderID) -- 20170116

		AND T.[IdAgent] = ISNULL(@IdAgent, T.[Idagent])
		AND T.[IdStatus] IN (SELECT [Id] FROM @tStatus)
		AND T.[IdProductTransfer] = ISNULL(@Folio, T.[IdProductTransfer])
		AND T.[IdProvider] = ISNULL(@IdProvider, T.[IdProvider])
		AND T.[IdProductTransfer] IN (SELECT [IdProductTransfer] FROM [Lunex].[TransferLN] WITH (NOLOCK) WHERE [Phone] LIKE '%'+ISNULL(@CellPhone,'')+'%')
    
	

	IF @Tot < 3001
	BEGIN 
		INSERT INTO #Result
			SELECT
				T.[DateOfCreation] [DateOfTransaction], [dbo].[fnFormatPhoneNumber](TT.[TopupPhone]) [PhoneNumber], T.[IdProductTransfer] [Folio],
				T.[TransactionProviderID] [Transactionid], tt.[SKUName] [ProductName], TT.[Amount], [AgentCode], [AgentName], T.[IdStatus], [StatusName] [Status],
				T.[IdProvider], PR.[ProviderName], TT.[Phone], ISNULL(U.[UserName],'') [UserName], CASE TT.[SKUType] WHEN 'Unlimited' THEN 'MEXICO' ELSE 'USA' END [Country]
			FROM [Operation].[ProductTransfer] T WITH (NOLOCK)
			JOIN [Lunex].[TransferLN] TT WITH (NOLOCK) ON T.[IdProductTransfer] = TT.[IdProductTransfer] AND TT.[Phone] LIKE '%'+ISNULL(@CellPhone, '')+'%'
			JOIN [dbo].[Agent] A WITH (NOLOCK) ON T.[IdAgent]=A.[IdAgent]
			JOIN [dbo].[Status] S WITH (NOLOCK) ON T.[IdStatus]=S.[IdStatus]
			JOIN [dbo].[Providers] PR WITH (NOLOCK) ON PR.[IdProvider]=T.[IdProvider]
			LEFT JOIN [dbo].[Users] U WITH (NOLOCK) ON T.[EnterByIdUser]=U.[IdUser]
			WHERE 
				--T.[DateOfCreation]>= ISNULL(@BeginDate,T.[DateOfCreation]) AND T.[DateOfCreation]<= ISNULL(@EndDate,T.[DateOfCreation])
				T.DateOfCreation >= CASE WHEN @IdTransfer IS NULL THEN ISNULL(@BeginDate, T.DateOfCreation) ELSE T.DateOfCreation END --20170116
				AND T.DateOfCreation <= CASE WHEN @IdTransfer IS NULL THEN isnull(@EndDate,T.DateOfCreation) ELSE T.DateOfCreation END --20170116
				AND t.TransactionProviderID = ISNULL(@IdTransfer,T.TransactionProviderID) -- 20170116
				AND T.[IdAgent]=ISNULL(@IdAgent,T.[IdAgent])
				AND T.[IdStatus] IN (SELECT [Id] FROM @tStatus)
				AND T.[IdProductTransfer]=ISNULL(@Folio,T.[IdProductTransfer])
				AND T.[IdOtherProduct] IN (13,16)
				AND T.[IdProvider]=ISNULL(@IdProvider,T.[IdProvider])
	END

	IF @Tot > 3000
	BEGIN
		IF @FullResult = 1
		BEGIN
			INSERT INTO #Result
				SELECT
					T.[DateOfCreation] [DateOfTransaction], [dbo].[fnFormatPhoneNumber](TT.[TopupPhone]) [PhoneNumber], T.[IdProductTransfer] Folio,
					T.[TransactionProviderID] [TransactionId], TT.[SKUName] [ProductName], TT.[Amount], [AgentCode], [AgentName], T.[IdStatus], [StatusName] [Status],
					T.[IdProvider], PR.[ProviderName], TT.[Phone], ISNULL(U.[UserName],'') [UserName], CASE TT.[SKUType] WHEN 'Unlimited' THEN 'MEXICO' ELSE 'USA' END [Country]
				FROM [Operation].[ProductTransfer] T WITH (NOLOCK)
				JOIN [Lunex].[TransferLN] TT ON T.[IdProductTransfer]=TT.[IdProductTransfer] AND TT.[Phone] LIKE '%'+ISNULL(@CellPhone, '')+'%'
				JOIN [dbo].[Agent] A WITH (NOLOCK) ON T.[IdAgent]=A.[IdAgent]
				JOIN [dbo].[Status] S WITH (NOLOCK) ON T.[IdStatus]=S.[IdStatus]
				JOIN [dbo].[Providers] PR WITH (NOLOCK) ON PR.[IdProvider]=T.[IdProvider]
				LEFT JOIN [dbo].[Users] U WITH (NOLOCK) ON T.[EnterByIdUser]=U.[IdUser]
				WHERE 
					--T.[DateOfCreation] >= ISNULL(@BeginDate,T.[DateOfCreation]) AND T.[DateOfCreation]<= ISNULL(@EndDate,T.[DateOfCreation])
					T.DateOfCreation >= CASE WHEN @IdTransfer IS NULL THEN ISNULL(@BeginDate, T.DateOfCreation) ELSE T.DateOfCreation END --20170116
					AND T.DateOfCreation <= CASE WHEN @IdTransfer IS NULL THEN isnull(@EndDate,T.DateOfCreation) ELSE T.DateOfCreation END --20170116
					AND t.TransactionProviderID = ISNULL(@IdTransfer,T.TransactionProviderID) -- 20170116
					AND T.[IdAgent]=ISNULL(@IdAgent,T.[IdAgent])
					AND T.[IdStatus] IN (SELECT [Id] FROM @tStatus)
					AND T.[IdProductTransfer]=ISNULL(@Folio,T.[IdProductTransfer])
					AND T.[IdOtherProduct] IN (13,16)
					AND T.[IdProvider]=ISNULL(@IdProvider,T.[IdProvider])
		END
		ELSE
		BEGIN
			SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHERROR'), @HasError=1
		END
	END
	ELSE
	BEGIN
		SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHOK'), @HasError=0
	END

	SELECT
		[DateOfTransaction]
		, [PhoneNumber]
		, [Folio]
		, [TransactionId]
		, [ProductName]
		, [Amount]
		, [AgentCode]
		, [AgentName]
		, [IdStatus]
		, [Status]
		, [IdProvider]
		, [ProviderName]
		, [CellPhone]
		, [UserName]
		, [Country]
	FROM #Result
	ORDER BY [DateOfTransaction] DESC;

	DROP TABLE #Result
