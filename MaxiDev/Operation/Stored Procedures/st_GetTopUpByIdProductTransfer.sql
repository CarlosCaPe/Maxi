CREATE PROCEDURE [Operation].[st_GetTopUpByIdProductTransfer]
(    
    @IdProductTransfer BIGINT = NULL
)
AS

/********************************************************************
<AuthorFrancisco Lara</Author>
<app>MaxiCorp</app>
<Description>Returns TopUp detail / Used in BackOffice-BillPayment -> Search Other Products</Description>

<ChangeLog>
<log Date="23/05/2017" Author="acontreras">Add new row output Field [Entity] </log>
</ChangeLog>

Author:		 Dario Almeida
Create date: 2017-05-30
Description: Returns Fee for Lunex products
*********************************************************************/



	DECLARE @IdOtherProduct INT

	SELECT @IdOtherProduct= [IdOtherProduct] FROM [Operation].[ProductTransfer] WITH (NOLOCK) WHERE [IdProductTransfer]=@IdProductTransfer
	
	IF @IdOtherProduct=7	-- TransferTo Top Up
	BEGIN
		SELECT
			PT.[DateOfCreation] [DateOfTransaction],
			T.[Destination_Msisdn] [PhoneNumber],
			PT.[IdProductTransfer] [Folio],
			PT.TransactionProviderID transactionid,
			T.[Product] [ProductName],
			T.[WholeSalePrice],
			T.[RetailPrice],
			PT.[AgentCommission],
			PT.[CorpCommission],
			T.[OriginCurrency] [ReceivedCurrency],
			T.[DestinationCurrency] [RechargedCurrency],
			A.[agentcode],
			A.[AgentName],
			T.[Country],
			T.[Operator] [Carrier],
			PT.[IdStatus],
			S.[StatusName] [Status],
			T.[IdAgent],
			T.[Msisdn],
			T.[LocalInfoAmount],
			T.[LocalInfoCurrency],
			T.[pinBased],
			T.[pinValidity],
			T.[pinCode],
			T.[pinIvr],
			T.[pinSerial],
			T.[pinValue],
			T.[pinOption1],
			T.[pinOption2],
			T.[pinOption3],
			T.[LocalInfoValue],
			PT.[IdProvider],
			PR.[ProviderName],
			PT.[IdOtherProduct],
			0.0 [Discount] --- Siempre se regresa cero, es una salida solo para lunex
			,[U].[UserName]
			,'' AS Entity
			, 0 AS Fee
		FROM [Operation].[ProductTransfer] PT WITH (NOLOCK)
		JOIN [TransFerTo].[TransferTTo] T WITH (NOLOCK) ON PT.[IdProductTransfer]=T.[IdProductTransfer]
		JOIN [dbo].[Agent] A WITH (NOLOCK) ON T.[IdAgent]=A.[IdAgent]
		JOIN [dbo].[Status] S WITH (NOLOCK) ON PT.[IdStatus]=S.[IdStatus]
		JOIN [dbo].[Providers] PR WITH (NOLOCK) ON PR.[IdProvider]=PT.[IdProvider]
		JOIN [dbo].[Users] [U] WITH (NOLOCK) ON [PT].[EnterByIdUser] = [U].[IdUser]
		WHERE PT.[IdProductTransfer]=ISNULL(@IdProductTransfer, PT.[IdProductTransfer]) AND PT.[IdOtherProduct]= @IdOtherProduct
	END

	IF @IdOtherProduct=6	-- Top Up
	BEGIN
		SELECT
			PT.[DateOfCreation] [DateOfTransaction],
			T.[TopUpNumber] [PhoneNumber],
			PT.[IdProductTransfer] [Folio],
			PT.[TransactionProviderID] [TransactionId],
			NULL [ProductName],
			NULL [WholeSalePrice],
			T.[TopUpAmount] [RetailPrice],
			PT.[AgentCommission],
			PT.[CorpCommission],
			T.[ReceiverCurrency] [ReceivedCurrency],
			T.[RechargeCurrency] [RechargedCurrency],
			[AgentCode],
			A.[AgentName],
			CUP.[CountryName] [Country],
			CP.[CarrierName] [Carrier],
			PT.[IdStatus],
			S.[StatusName] [Status],
			T.[IdAgent],
			NULL [Msisdn],
			NULL [LocalInfoAmount],
			NULL [LocalInfoCurrency],
			NULL [pinBased],
			NULL [pinValidity],
			NULL [pinCode],
			NULL [pinIvr],
			NULL [pinSerial],
			NULL [pinValue],
			NULL [pinOption1],
			NULL [pinOption2],
			NULL [pinOption3],
			NULL [LocalInfoValue],
			PT.[IdProvider],
			PR.[ProviderName],
			PT.[IdOtherProduct],
			0.0 [Discount] --- Siempre se regresa cero, es una salida solo para lunex
			, [U].[UserName]
			,'' AS Entity
			, 0 AS Fee
		FROM [Operation].[ProductTransfer] PT WITH (NOLOCK)
		JOIN [dbo].[PureMinutesTopUpTransaction] T WITH (NOLOCK) ON PT.[IdProductTransfer]=T.[IdProductTransfer]
		JOIN [dbo].[Agent] A WITH (NOLOCK) ON T.[IdAgent]=A.[IdAgent]
		JOIN [dbo].[Status] S WITH (NOLOCK) ON PT.[IdStatus]=s.[IdStatus]
		JOIN [dbo].[CarrierPureMinutesTopUp] CP WITH (NOLOCK) ON T.[CarrierID]=CP.[IdCarrierPureMinutesTopUp]
		JOIN [dbo].[CountryPureMinutesTopUp] CUP WITH (NOLOCK) ON T.[CountryID]=CUP.[IdCountryPureMinutesTopUp]
		JOIN [dbo].[Providers] PR WITH (NOLOCK) ON PR.[IdProvider]=PT.[IdProvider]
		JOIN [dbo].[Users] [U] WITH (NOLOCK) ON [PT].[EnterByIdUser] = [U].[IdUser]
		WHERE PT.[IdProductTransfer]=ISNULL(@IdProductTransfer,PT.[IdProductTransfer]) AND PT.[IdOtherProduct]= @IdOtherProduct
	END

	IF @IdOtherProduct=9	-- Lunex Top Up
	BEGIN
		SELECT
			PT.[DateOfCreation] [DateOfTransaction],
			T.[TopupPhone] [PhoneNumber],
			PT.[IdProductTransfer] [Folio],
			PT.[TransactionProviderID] [TransactionId],
			T.[SKUName] [ProductName],
			NULL [WholeSalePrice],
			T.[Amount] [RetailPrice],
			PT.[AgentCommission],
			PT.[CorpCommission],
			'USD' [ReceivedCurrency],
			'USD' [RechargedCurrency],
			A.[AgentCode],
			A.[AgentName],
			CUP.[CountryName] [Country],
			CP.[CarrierName] [Carrier],
			PT.[IdStatus],
			S.[StatusName] [Status],
			T.[IdAgent],
			T.[Phone] [Msisdn], -- US Customer Phone
			T.[ReceivedValue] [LocalInfoAmount],
			--T.[ReceivedCurrency] [LocalInfoCurrency],
			T.AmountInMN [LocalInfoCurrency],
			NULL [PinBased],
			NULL [PinValidity],
			NULL [PinCode],
			NULL [PinIvr],
			NULL [PinSerial],
			T.[Pin] [PinValue],
			NULL [PinOption1],
			NULL [PinOption2],
			NULL [PinOption3],
			T.[ReceivedValue] [LocalInfoValue],
			PT.[IdProvider],
			PR.[ProviderName],
			PT.[IdOtherProduct],
			case
			when ISNULL(PT.Fee, 0)=0 then
				T.[D1Discount] 
			else	
				bd.fee-bd.ProviderFee
			end
			[Discount] -- Se regresa el discount 1, con el que se calcula las comisiones
			, [U].[UserName]						
			,(SELECT TOP 1 Entity FROM lunex.TransferLN WITH (NOLOCK) where EnterByIdUser = PT.EnterByIdUser) AS Entity
			,ISNULL(PT.Fee, 0) AS Fee
		FROM [Operation].[ProductTransfer] PT WITH (NOLOCK)
		JOIN [Lunex].[TransferLN] T WITH (NOLOCK) ON PT.[IdProductTransfer]=T.[IdProductTransfer]
		JOIN [dbo].[Agent] A WITH (NOLOCK) ON T.[IdAgent]=A.[IdAgent]
		JOIN [dbo].[Status] S WITH (NOLOCK) ON PT.[IdStatus]=S.[IdStatus]
		JOIN [Lunex].[Product] P WITH (NOLOCK) ON P.[SKU]=T.[SKU]
		JOIN [Operation].[Country] CUP WITH (NOLOCK) ON P.[IdCountry]=CUP.[IdCountry]
		JOIN [Operation].[Carrier] CP WITH (NOLOCK) ON P.[IdCarrier]=CP.[IdCarrier]
		JOIN [dbo].[Providers] PR WITH (NOLOCK) ON PR.[IdProvider]=PT.[IdProvider]
		JOIN [dbo].[Users] [U] WITH (NOLOCK) ON [PT].[EnterByIdUser] = [U].[IdUser]
		join AgentBalance b WITH (NOLOCK) on b.TypeOfMovement='LTTU' and b.IdTransfer=pt.IdProductTransfer
		join AgentBalanceDetail bd WITH (NOLOCK) on bd.IdAgentBalance=b.IdAgentBalance
		WHERE PT.[IdProductTransfer]=ISNULL(@IdProductTransfer,PT.[IdProductTransfer]) AND PT.[IdOtherProduct]= @IdOtherProduct
	END

	IF @IdOtherProduct=17	-- Regalii Top Up
	BEGIN
		SELECT
			PT.[DateOfCreation] [DateOfTransaction],
			T.[Account_Number] [PhoneNumber],
			PT.[IdProductTransfer] [Folio],
			PT.[TransactionProviderID] [TransactionId],
			C.CountryName + ' - ' +T.Name [ProductName],
			NULL [WholeSalePrice],
			T.[Amount] [RetailPrice],
			PT.[AgentCommission],
			PT.[CorpCommission],
			'USD' [ReceivedCurrency],
			'USD' [RechargedCurrency],
			A.[AgentCode],
			A.[AgentName],
			C.CountryName [Country],
			T.[Name] [Carrier],
			PT.[IdStatus],
			S.[StatusName] [Status],
			T.[IdAgent],
			T.[CustomerCellPhoneNumber] [Msisdn], -- US Customer Phone
			T.[AmountInMN] [LocalInfoAmount],
			T.[LocalCurrency] [LocalInfoCurrency],
			NULL [PinBased],
			NULL [PinValidity],
			NULL [PinCode],
			NULL [PinIvr],
			NULL [PinSerial],
			NULL [PinValue],
			NULL [PinOption1],
			NULL [PinOption2],
			NULL [PinOption3],
			T.[AmountInMN] [LocalInfoValue],
			PT.[IdProvider],
			PR.[ProviderName],
			PT.[IdOtherProduct],
			0.0 [Discount] --- Siempre se regresa cero, es una salida solo para lunex
			, [U].[UserName]
			,C.*
			,'' AS Entity
			, 0 AS Fee
		FROM [Operation].[ProductTransfer] PT WITH (NOLOCK)
		JOIN [Regalii].[TransferR] T WITH (NOLOCK) ON PT.[IdProductTransfer]=T.[IdProductTransfer]
		left join dbo.Country C (NOLOCK) on C.idCountry=T.idCountry
		JOIN [dbo].[Agent] A WITH (NOLOCK) ON T.[IdAgent]=A.[IdAgent]
		JOIN [dbo].[Status] S WITH (NOLOCK) ON PT.[IdStatus]=S.[IdStatus]
		JOIN [dbo].[Providers] PR WITH (NOLOCK) ON PR.[IdProvider]=PT.[IdProvider]
		JOIN [dbo].[Users] [U] WITH (NOLOCK) ON [PT].[EnterByIdUser] = [U].[IdUser]
		WHERE PT.[IdProductTransfer]=ISNULL(@IdProductTransfer,PT.[IdProductTransfer]) AND PT.[IdOtherProduct]= @IdOtherProduct
	END
