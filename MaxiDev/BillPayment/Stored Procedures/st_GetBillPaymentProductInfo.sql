/********************************************************************
<Author>amoreno</Author>
<app>New Agent</app>
<Description>Obtener Biller By IdProductTransfer </Description>

<ChangeLog>

<log Date="15/06/2018" Author="amoreno">Creation</log>
<log Date="12/02/2019" Author="azavala">se agrega IdAggregator a la consulta saliente - Ref: 12022019_azavala</log>
</ChangeLog>
*********************************************************************/
CREATE PROCEDURE  [BillPayment].[st_GetBillPaymentProductInfo]

	-- Add the parameters for the stored procedure here
	@IdProductTransfer INT,
	@DateOfPayment DATETIME OUTPUT,
	@Amount MONEY OUTPUT,
	@AccountNumber NVARCHAR(MAX) OUTPUT,
	@Biller NVARCHAR(MAX) OUTPUT,
	@StatusId INT OUTPUT,
	@StatusName NVARCHAR(MAX) OUTPUT,
	@AgentId INT OUTPUT,
	@AgentName NVARCHAR(MAX) OUTPUT,
	@TrackingNumber NVARCHAR(MAX) OUTPUT,
	@Fee MONEY OUTPUT,
	@ProviderFee MONEY OUTPUT,
	@AgentCommission MONEY OUTPUT,
	@CorporateCommission MONEY OUTPUT,
	@CustomerName NVARCHAR(MAX) OUTPUT,
	@CustomerLastName NVARCHAR(MAX) OUTPUT,
	@CustomerSecondLastName NVARCHAR(MAX) OUTPUT,
	--@CustomerAddress NVARCHAR(MAX) OUTPUT,
	--@CustomerZipCode NVARCHAR(MAX) OUTPUT,
	--@CustomerCity NVARCHAR(MAX) OUTPUT,
	--@CustomerState NVARCHAR(MAX) OUTPUT,
	@CustomerPhone NVARCHAR(MAX) OUTPUT,
	--@CustomerIdType NVARCHAR(MAX) OUTPUT,
	--@CustomerSSN NVARCHAR(MAX) OUTPUT,
	--@CustomerBornDate DATETIME OUTPUT,
	--@Occupation NVARCHAR(MAX) OUTPUT,
	@ProviderName NVARCHAR(MAX) OUTPUT,
	@Country NVARCHAR(MAX) OUTPUT,
	@RefExRate MONEY OUTPUT,
	@NameOnAccount NVARCHAR(MAX) OUTPUT,
	@RequireNameOnAccount BIT OUTPUT,
	@CurrencyName NVARCHAR(MAX) OUTPUT,
	@AmountMN MONEY OUTPUT,
	@AgentCode NVARCHAR(MAX) OUTPUT,
	@CanCancel bit OUTPUT,
	@IdAggregator int OUTPUT --12022019_azavala
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @IdTransferR BIGINT
	declare @TimeNow datetime
	
	 
set @TimeNow= getdate() 
 

	SELECT
		@IdTransferR = [TR].[IdTransferR]
		, @DateOfPayment = [TR].[DateOfCreation]
		, @Amount = [TR].[Amount]
		,@AccountNumber = [TR].[Account_Number]
		, @Biller = [B].[Name]
		, @StatusId = [TR].[IdStatus]
		, @StatusName = [S].[StatusName]
		, @AgentId = [A].[IdAgent]
		, @AgentName = ([A].[AgentCode] + ' ' + [A].[AgentName])
		, @TrackingNumber = [TR].[TraceNumber]
		, @Fee = [TR].[Fee]
		, @ProviderFee = [TR].[TransactionFee]
		, @AgentCommission = [TR].[AgentCommission]
		, @CorporateCommission = [TR].[CorpCommission]
		, @CustomerName = [TR].[CustomerName]
		, @CustomerLastName = [TR].[CustomerFirstLastName]
		, @CustomerSecondLastName = [TR].[CustomerSecondLastName]
		--, @CustomerAddress = [C].[Address]
		--, @CustomerZipCode = [C].[Zipcode]
		--, @CustomerCity = [C].[City]
		--, @CustomerState = [C].[State]
		, @CustomerPhone = (SELECT [dbo].[fnFormatPhoneNumber]([TR].[CustomerCellPhoneNumber]))
		--, @CustomerIdType = ISNULL(IT.Name,'')
		--, @CustomerSSN = ISNULL([C].[SSNumber],'')
		--, @CustomerBornDate = [C].[BornDate]
		--, @Occupation = ISNULL([C].[Occupation],'')
		, @ProviderName = (select Name from BillPayment.Aggregator WITH (NOLOCK) where  IdAggregator = B.IdAggregator)
		, @RefExRate = [TR].[ExRate]
		, @NameOnAccount = [TR].[Name_On_Account]
		, @RequireNameOnAccount = [TR].[RequiresNameOnAccount]
		, @CurrencyName = [TR].[CurrencyName]
		, @AmountMN = [TR].[AmountInMN]
		, @AgentCode = [A].[AgentCode]
		, @CanCancel =
				      (case  
				        when ([B].IdAggregator=1 and dateadd(minute,-(case
												when [B].Relationship = 'Non Contracted' then 10
										  		when [B].Relationship = 'Authorized' then 30 end), @TimeNow) > ([TR].DateOfCreation)) then 0
						when [B].IdAggregator=5 then [B].CancelAllowed --12022019_azavala
				        else 1
				        end)
		, @IdAggregator = [B].IdAggregator --12022019_azavala
	FROM [BillPayment].[TransferR] [TR] WITH (NOLOCK)
	JOIN [BillPayment].[Billers] [B] WITH (NOLOCK) ON [TR].[IdBiller] = [B].[IdBiller]
	JOIN [dbo].[Status] [S] WITH (NOLOCK) ON [TR].[IdStatus] = [S].[IdStatus]
	JOIN [dbo].[Agent] [A] WITH (NOLOCK) ON [TR].[IdAgent] = [A].[IdAgent]
	--JOIN [dbo].[Customer] [C] WITH (NOLOCK) ON [TR].[IdCustomer] = [C].[IdCustomer]
	--LEFT JOIN [dbo].[CustomerIdentificationType] IT WITH (NOLOCK) ON [C].[IdCustomerIdentificationType] = [IT].[IdCustomerIdentificationType]
	WHERE
		[TR].[IdProductTransfer] = @IdProductTransfer

	SELECT [N].[IdNote], [N].[Note], [U].[UserName]
	FROM [Regalii].[Notes] [N] WITH (NOLOCK)
	JOIN [dbo].[Users] [U] WITH (NOLOCK) ON [N].[IdUser] = [u].[IdUser]
	WHERE [IdTransferR] = @IdTransferR
	ORDER BY [N].[DateOfCreation] ASC

END

