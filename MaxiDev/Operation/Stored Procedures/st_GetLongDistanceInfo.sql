CREATE PROCEDURE [Operation].[st_GetLongDistanceInfo](
		@IdLanguaje INT = 1
		,@IdAgent INT = NULL
		,@DateFrom DATETIME --= '20140101'
		,@DateTo DATETIME --= '20140101'
		,@Folio INT= NULL
		,@IdStatus XML = NULL
        ,@CusPhone nvarchar(max) = null
		----------------------
		,@HasError BIT OUT
		,@Message VARCHAR(MAX) OUT
)
AS
BEGIN TRY
	--Configs
	SET NOCOUNT ON;


	--VarDeclarations
	DECLARE @TSTATUS TABLE(ID INT) 
	Declare @DocHandle int
	

	--VarSettings
	SET @HasError = 0
	SET @Message = 'Success'
	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @IdStatus
	-------------
	Select @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
    Select @DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)

	INSERT INTO @TSTATUS(ID)     
	SELECT id    
	FROM OPENXML (@DocHandle, '/statuses/status',1)     
	WITH (id INT)

	--Coding

	SELECT 
		PT.IdProductTransfer AS Folio
		,PT.DateOfCreation AS [TransactionDate]
		,PT.TransactionProviderID AS IdTransaction
		,dbo.[fnFormatPhoneNumber](LN.[Phone]) AS [CellularNumber]
		,PT.[Amount] AS [Amount],
        pt.IdOtherProduct		
	FROM 
		[Operation].[ProductTransfer] PT (NOLOCK)
			JOIN [Lunex].[TransferLN] LN (NOLOCK) ON LN.IdProductTransfer = pt.IdProductTransfer
			LEFT JOIN [Lunex].[Product] PR (NOLOCK) ON PR.SKU = LN.SKU
	WHERE PT.IdProvider = 3/*lunex*/
		and PT.IdOtherProduct = 10/*Lunex Long Distance'*/
		and PT.IdAgent = ISNULL(@IdAgent,pt.IdAgent)
		and PT.IdProductTransfer = ISNULL (@Folio,pt.IdProductTransfer)
		and PT.IdStatus IN(SELECT ID FROM @TSTATUS)--= ISNULL (@IdStatus,ln.IdStatus)
		and PT.DateOfCreation BETWEEN @DateFrom AND @DateTo
        and case when isnull(@CusPhone,'null')='null' then 1 else 0 end = 1
    
    union all
    
    SELECT 
		 PT.IdProductTransfer AS Folio
		,PT.DateOfCreation AS [TransactionDate]
		,PT.TransactionProviderID AS IdTransaction
		,LN.ReceiveAccountNumber AS [CellularNumber]
		,PT.[Amount] AS [Amount]
        ,pt.IdOtherProduct				
	FROM 
		[Operation].[ProductTransfer] PT (NOLOCK)
			JOIN pureminutestransaction LN (NOLOCK) ON LN.IdProductTransfer = pt.IdProductTransfer			
	WHERE PT.IdProvider = 4/*pureminutes*/
		and PT.IdOtherProduct = 5/*Pureminutes long distance'*/
        --and pt.Amount>0
		and PT.IdAgent = ISNULL(@IdAgent,pt.IdAgent)
		and PT.IdProductTransfer = ISNULL (@Folio,pt.IdProductTransfer)
		and PT.IdStatus IN(SELECT ID FROM @TSTATUS)--= ISNULL (@IdStatus,ln.IdStatus)
		and PT.DateOfCreation BETWEEN @DateFrom AND @DateTo        
        and ln.SenderPhoneNumber like '%'+isnull(@CusPhone,ln.SenderPhoneNumber)+'%'
	ORDER BY [TransactionDate]

End Try                                                                                            
Begin Catch
	SET @HasError = 1
	SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLanguaje,'MESSAGE07')
	Declare @ErrorMessage NVARCHAR(MAX)                                                                                             
	Select @ErrorMessage=ERROR_MESSAGE()                                             
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_GetTopUpsInfo',Getdate(),@ErrorMessage)                                                                                            
End Catch  

