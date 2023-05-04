CREATE PROCEDURE [Corp].[st_GetReportTopUp_Operation]
(
    @BeginDate datetime = null,
    @EndDate datetime = null,
    @IdProvider int = null,
    @IdAgent int = null,    
    @StatusesPreselected XML,
    @Folio int =null,
    @IdLenguage int = null,
	@CustomerNumber nvarchar(max),
	@CellularNumber nvarchar(max),
    @FullResult bit = 0,
	@IdTransfer bigint = null,
    @HasError bit output,
    @Message nvarchar(max) output
)
AS

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description>This stored is used in Corp To get Report of Top-Up in [Seach Other Produts]</Description>

<ChangeLog>
<log Date="18/01/2017" Author="mdelgado">Add new filtered request. New Field "Transfer ID" [TransactionProviderID]</log>
</ChangeLog>

<ChangeLog>
<log Date="19/05/2017" Author="jdarellano">Se agrega filtrado por "CustomerNumber" y "CellularNumber"</log>
</ChangeLog>

<ChangeLog>
<log Date="28/10/2019" Author="adominguez">Se agrega StateCode"</log>
</ChangeLog>
*********************************************************************/

 --   DECLARE @BeginDate datetime = '20160101'
 --   DECLARE @EndDate datetime = '20170301'
 --   DECLARE @IdProvider int = null
 --   DECLARE @IdAgent int = null  
 --   DECLARE @StatusesPreselected XML = '<statuses><status id="21" /><status id="22" /><status id="30" /></statuses>'
	--DECLARE @Folio int = 123
 --   DECLARE @IdLenguage int = null
	--DECLARE @CustomerNumber nvarchar(max)
	--DECLARE @CellularNumber nvarchar(max)
 --   DECLARE @FullResult bit = 0
	--DECLARE @IdTransfer int = 226293693
 --   DECLARE @HasError bit = 0
 --   DECLARE @Message nvarchar(max)

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @tStatus TABLE
		  (    
		   id INT    
		  ) 

	DECLARE @DocHandle INT
	DECLARE @hasStatus BIT
	DECLARE @Tot  int = 0

	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @StatusesPreselected      
    
	INSERT INTO @tStatus(id)     
		SELECT id    
		FROM OPENXML (@DocHandle, '/statuses/status',1)     
		WITH (id int)    
    
	EXEC sp_xml_removedocument @DocHandle  

	IF @IdLenguage IS NULL 
		SET @IdLenguage=2  



	SET @BeginDate = dbo.RemoveTimeFromDatetime(@BeginDate)  
	SET @EndDate = dbo.RemoveTimeFromDatetime(@EndDate+1)  

	CREATE TABLE #Result
	(
		DateOfTransaction datetime,
		phonenumber nvarchar(max),
		folio bigint,
		transactionid bigint,
		ProductName nvarchar(max),
		WholeSalePrice money,
		RetailPrice money,
		agentcode nvarchar(max),
		agentname nvarchar(max),
		country nvarchar(max),    
		idstatus  int,
		carrier nvarchar(max), 
		status nvarchar(max),
		idprovider int,
		providername nvarchar(max),
		customerPhone NVARCHAR(max), 
		UserName nvarchar(max),
		AgentState nvarchar(max)
	)
	SET @Tot = 0
	SELECT @Tot = count(1)
	FROM operation.ProductTransfer t WITH(NOLOCK)
		join agent a WITH(NOLOCK) on t.idagent = a.idagent
		join dbo.[OtherProductStatus] s WITH(NOLOCK) on t.[IdStatus] = s.[IdStatus]
	WHERE t.IdAgentBalanceService = 4 
		AND T.DateOfCreation >= CASE WHEN @IdTransfer IS NULL THEN ISNULL(@BeginDate, T.DateOfCreation) ELSE T.DateOfCreation END
		AND T.DateOfCreation <= CASE WHEN @IdTransfer IS NULL THEN isnull(@EndDate,T.DateOfCreation) ELSE T.DateOfCreation END
		AND t.IdAgent = isnull(@IdAgent,t.Idagent)
		AND t.IdStatus in (select id from @tStatus)
		AND t.IdProductTransfer = isnull(@Folio,t.IdProductTransfer)
		AND t.IdProvider = isnull(@IdProvider,t.idprovider)
		AND t.TransactionProviderID = ISNULL(@IdTransfer,T.TransactionProviderID)
		AND t.IdProductTransfer in (
			SELECT IdProductTransfer FROM lunex.transferln ln where dbo.fnDeleteFormatPhoneNumber(ln.Phone) like '%'+isnull(@CustomerNumber,'')+'%' and dbo.fnDeleteFormatPhoneNumber(ln.TopupPhone) like '%'+isnull(@CellularNumber, '')+'%'
			UNION 
			SELECT IdProductTransfer FROM TransferTo.[TransferTTo] tt where dbo.fnDeleteFormatPhoneNumber(tt.[Msisdn]) like '%'+isnull(@CustomerNumber,'')+'%' and dbo.fnDeleteFormatPhoneNumber(tt.Destination_Msisdn) like '%'+isnull(@CellularNumber, '')+'%'
			)

	
	IF @Tot < 3001 OR @FullResult = 1
	BEGIN 

		INSERT INTO #Result 
			SELECT 
				t.DateOfCreation DateOfTransaction, 
				Destination_Msisdn phonenumber, 
				t.IdProductTransfer folio, 
				t.TransactionProviderID transactionid, 
				Product ProductName, 
				WholeSalePrice, 
				RetailPrice, 
				agentcode, 
				agentname, 
				country, 
				t.idstatus, 
				operator carrier, 
				StatusName status, 
				t.idprovider, 
				pr.providername, 
				tt.[Msisdn] as 'customerPhone',
				isnull(u.UserName,'') UserName,
				AgentState AgentState
			FROM operation.ProductTransfer t WITH(NOLOCK)
				JOIN TransferTo.[TransferTTo] tt WITH(NOLOCK) on t.IdProductTransfer=tt.IdProductTransfer and dbo.fnDeleteFormatPhoneNumber(tt.[Msisdn]) like '%'+isnull(@CustomerNumber,'')+'%' and dbo.fnDeleteFormatPhoneNumber(tt.Destination_Msisdn) like '%'+isnull(@CellularNumber,'')+'%' 
				JOIN agent a WITH(NOLOCK) on t.idagent = a.idagent
				JOIN dbo.status s WITH(NOLOCK) ON t.[IdStatus] = s.[IdStatus]
				JOIN providers pr WITH(NOLOCK) ON pr.idprovider = t.idprovider 
				LEFT JOIN users u WITH(NOLOCK) ON t.EnterByIdUser = u.IdUser
			WHERE 
				T.DateOfCreation >= CASE WHEN @IdTransfer IS NULL THEN ISNULL(@BeginDate, T.DateOfCreation) ELSE T.DateOfCreation END
				AND T.DateOfCreation <= CASE WHEN @IdTransfer IS NULL THEN isnull(@EndDate,T.DateOfCreation) ELSE T.DateOfCreation END
				AND t.TransactionProviderID = ISNULL(@IdTransfer, T.TransactionProviderID)
				AND t.IdAgent = isnull(@IdAgent, t.Idagent) 
				AND t.IdStatus in (select id from @tStatus) 
				AND t.IdProductTransfer = isnull(@Folio, t.IdProductTransfer) 
				AND t.idotherproduct = 7
				AND t.IdProvider=isnull(@IdProvider, t.idprovider)

		INSERT INTO #Result
			SELECT 
				t.DateOfCreation DateOfTransaction,
				TopUpNumber phonenumber,
				t.IdProductTransfer folio,
				t.TransactionProviderID transactionid,
				null ProductName,
				null WholeSalePrice,
				TopUpAmount RetailPrice,
				agentcode,
				agentname,
				cup.CountryName country,    
				t.idstatus,
				cp.CarrierName carrier, 
				StatusName status,
				t.idprovider,
				pr.providername,
				null as 'customerPhone',
				isnull(u.UserName,'') UserName,
				AgentState AgentState
			FROM operation.ProductTransfer t WITH(NOLOCK)
				join pureminutestopuptransaction tt WITH(NOLOCK) on t.IdProductTransfer=tt.IdProductTransfer
				join agent a WITH(NOLOCK) on t.idagent=a.idagent
				join dbo.status s WITH(NOLOCK) on t.[IdStatus]=s.[IdStatus]
				join CarrierPureMinutesTopUp cp WITH(NOLOCK) on tt.CarrierID=cp.IdCarrierPureMinutesTopUp
				join CountryPureMinutesTopUp cup WITH(NOLOCK) on tt.CountryID=cup.IdCountryPureMinutesTopUp
				join providers pr WITH(NOLOCK) on pr.idprovider=t.idprovider
				left join users u WITH(NOLOCK) on t.EnterByIdUser=u.IdUser
			WHERE 
				T.DateOfCreation >= CASE WHEN @IdTransfer IS NULL THEN ISNULL(@BeginDate, T.DateOfCreation) ELSE T.DateOfCreation END
				AND T.DateOfCreation <= CASE WHEN @IdTransfer IS NULL THEN isnull(@EndDate,T.DateOfCreation) ELSE T.DateOfCreation END
				AND t.TransactionProviderID = ISNULL(@IdTransfer,T.TransactionProviderID)
				and t.IdAgent=isnull(@IdAgent,t.Idagent)
				and t.IdStatus in (select id from @tStatus)
				and t.IdProductTransfer=isnull(@Folio,t.IdProductTransfer)
				and t.idotherproduct=6
				and t.IdProvider=isnull(@IdProvider,t.idprovider)

		INSERT INTO #Result
			SELECT 
				t.DateOfCreation DateOfTransaction,
				dbo.[fnFormatPhoneNumber](tt.TopupPhone) phonenumber,
				t.IdProductTransfer folio,
				t.TransactionProviderID transactionid,
				tt.skuname ProductName,
				null WholeSalePrice,
				tt.amount RetailPrice,
				agentcode,
				agentname,
				cup.CountryName country,    
				t.idstatus,
				cp.CarrierName carrier, 
				StatusName status,
				t.idprovider,
				pr.providername,
				tt.phone as 'customerPhone',
				isnull(u.UserName,'') UserName,
				AgentState AgentState
			FROM operation.ProductTransfer t WITH(NOLOCK)
				join lunex.TransferLN tt WITH(NOLOCK) on t.IdProductTransfer=tt.IdProductTransfer and dbo.fnDeleteFormatPhoneNumber(tt.phone) like '%'+isnull(@CustomerNumber,'')+'%' and dbo.fnDeleteFormatPhoneNumber(tt.TopupPhone) like '%'+isnull(@CellularNumber,'')+'%'
				join agent a WITH(NOLOCK) on t.idagent=a.idagent
				join dbo.status s WITH(NOLOCK) on t.[IdStatus]=s.[IdStatus]
				join lunex.Product p WITH(NOLOCK) on p.SKU=tt.SKU
				join Operation.Country cup WITH(NOLOCK) on p.IdCountry=cup.IdCountry
				join Operation.Carrier cp WITH(NOLOCK) on p.IdCarrier=cp.IdCarrier
				join providers pr WITH(NOLOCK) on pr.idprovider=t.idprovider
				left join users u WITH(NOLOCK) on t.EnterByIdUser=u.IdUser
			WHERE 
				T.DateOfCreation >= CASE WHEN @IdTransfer IS NULL THEN ISNULL(@BeginDate, T.DateOfCreation) ELSE T.DateOfCreation END
				AND T.DateOfCreation <= CASE WHEN @IdTransfer IS NULL THEN isnull(@EndDate,T.DateOfCreation) ELSE T.DateOfCreation END
				AND t.TransactionProviderID = ISNULL(CAST(@IdTransfer AS bigint),T.TransactionProviderID)
				and t.IdAgent=isnull(@IdAgent,t.Idagent)
				and t.IdStatus in (select id from @tStatus)
				and t.IdProductTransfer=isnull(@Folio,t.IdProductTransfer)
				and t.idotherproduct=9
				and t.IdProvider=isnull(@IdProvider,t.idprovider)

		INSERT INTO #Result
			SELECT 
					T.DateOfCreation [DateOfTransaction],
					dbo.[fnFormatPhoneNumber](tt.[Account_Number]) [PhoneNumber],
					t.IdProductTransfer [Folio],
					t.TransactionProviderID [TransactionId],
					TT.[BillerType] ProductName,
					NULL WholeSalePrice,
					TT.[Amount] [RetailPrice],
					[AgentCode],
					[AgentName],
					TT.[Country] country,    
					T.[IdStatus],
					TT.[Name] [Carrier],
					S.[StatusName] [Status],
					T.[IdProvider],
					PR.[ProviderName],
					TT.[CustomerCellPhoneNumber] [CustomerPhone],
					ISNULL(U.[UserName],'') [UserName],
					AgentState AgentState
				FROM [Operation].[ProductTransfer] T WITH(NOLOCK)
					JOIN [Regalii].[TransferR] TT WITH (NOLOCK) ON T.[IdProductTransfer]=TT.[IdProductTransfer] AND [dbo].[fnDeleteFormatPhoneNumber](TT.[Account_Number]) LIKE '%'+ISNULL(@CellularNumber,'')+'%'
					JOIN [dbo].[Agent] A WITH (NOLOCK) ON T.[IdAgent]=A.[IdAgent]
					JOIN [dbo].[Status] S WITH (NOLOCK) ON T.[IdStatus]=s.[IdStatus]
					JOIN [dbo].[Providers] PR WITH (NOLOCK) ON PR.[IdProvider]=T.[IdProvider]
					JOIN [dbo].[Users] [U] WITH (NOLOCK) ON [T].[EnterByIdUser] = [U].[IdUser]
				WHERE 
					T.DateOfCreation >= CASE WHEN @IdTransfer IS NULL THEN ISNULL(@BeginDate, T.DateOfCreation) ELSE T.DateOfCreation END
					AND T.DateOfCreation <= CASE WHEN @IdTransfer IS NULL THEN isnull(@EndDate,T.DateOfCreation) ELSE T.DateOfCreation END
					AND t.TransactionProviderID = ISNULL(@IdTransfer,T.TransactionProviderID)
					AND T.[IdAgent]=ISNULL(@IdAgent,t.Idagent)
					AND T.[IdStatus] IN (SELECT [Id] FROM @tStatus)
					AND T.[IdProductTransfer] = ISNULL(@Folio, T.[IdProductTransfer])
					AND T.[IdOtherProduct]=17 -- Regalii Top Up
					AND T.[IdProvider]=ISNULL(@IdProvider,T.[IdProvider])

	END

	IF @Tot > 3000 AND @FullResult = 0
	BEGIN
		SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHERROR'),@HasError=1
	END
	ELSE
	BEGIN
		SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHOK'),@HasError=0
	END

	SELECT
		DateOfTransaction,
		phonenumber,
		folio,
		transactionid,
		ProductName,
		WholeSalePrice,
		RetailPrice,
		agentcode,
		agentname,
		country,
		idstatus,
		carrier,
		status,
		idprovider,
		providername,
		customerPhone,
		UserName,
		AgentState
	FROM #Result
	where	
		replace(Replace(Replace(REPLACE (customerphone,'(',''),')',''),'-',''),' ','') like '%'+isnull(@CustomerNumber,'')+'%'--filter by "CustomerNumber"
		and	replace(Replace(Replace(REPLACE (phonenumber,'(',''),')',''),'-',''),' ','') like '%'+isnull(@CellularNumber,'')+'%'--filter by "CellularNumber"
	ORDER BY DateOfTransaction DESC


	DROP TABLE #Result

