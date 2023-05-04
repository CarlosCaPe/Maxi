/********************************************************************
<Author>Francisco Lara</Author>
<app>Maxi Host Manager Service</app>
<Description>Return a call-usa Lunex product // This stored is used in BAckOffice-BillPayment (Call-USA detail)  </Description>

<ChangeLog>
<log Date="08/01/2016" Author="flara"> Creación </log>
<log Date="08/08/2017" Author="Mhinojo"> Alter </log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [Operation].[st_GetUsaUnlimitedDetailbyIdProductTransfer]
(
    @IdProductTransfer BIGINT
)
AS
	DECLARE @IdOtherProduct INT

	SELECT @IdOtherProduct=[IdOtherProduct] FROM [Operation].[ProductTransfer] WITH (NOLOCK) WHERE [IdProductTransfer]=@IdProductTransfer

	IF @IdOtherProduct=13 OR @IdOtherProduct=16
	BEGIN
		SELECT
			T.[IdProductTransfer],
			T.[EnterByIdUser],
			U.[UserName] [UserName],
			T.[IdAgent],
			T.[TransactionProviderDate],
			T.[DateOfStatusChange],
			[dbo].[fnFormatPhoneNumber](PIV.[Phone]) [Phone],
			PIV.[TopupPhone],
			T.[Amount] [Amount],
			T.[AgentCommission],
			T.[CorpCommission],
			T.[IdStatus],
			PIV.[LNStatus] [LastReturnCode],
			T.[EnterByIdUser],
			ISNULL(U.[UserLogin],'') [UserName],
			T.[EnterByIdUserCancel],
			ISNULL(U2.[Userlogin],'') [UserNameCancel],
			T.[TransactionProviderCancelDate],
			T.[TransactionProviderID],
			S.[StatusName],
			A.[Agentcode]+' '+A.[AgentName] [SelectedAgent],
			T.[IdProvider],
			PR.[ProviderName],
			T.[IdOtherProduct],
			PIV.[ExpirationDate],
			PIV.[D1Discount] [Discount],
			CASE PIV.[SKUType] WHEN 'Unlimited' THEN 'MEXICO' ELSE 'USA' END [Country]
			,PIV.AccessNumber
		FROM [Operation].[ProductTransfer] T WITH (NOLOCK)
		INNER JOIN [dbo].[Agent] A WITH (NOLOCK) ON A.[IdAgent] = T.[IdAgent]
		INNER JOIN [dbo].[Users] U WITH (NOLOCK) ON U.[IdUser]= T.[EnterByIdUser]
		LEFT JOIN [dbo].[Users] U2 WITH (NOLOCK) ON T.[EnterByIdUserCancel]=U2.[IdUser]     
		INNER JOIN [Lunex].[TransferLN] PIV WITH (NOLOCK) ON PIV.[IdProductTransfer]=T.[IdProductTransfer]
		INNER JOIN [dbo].[Status] S WITH (NOLOCK) ON T.[IdStatus]=S.[IdStatus]
		INNER JOIN [dbo].[Providers] PR WITH (NOLOCK) ON PR.[IdProvider]=T.[IdProvider]
		WHERE T.[IdProductTransfer]=@IdProductTransfer
	END
