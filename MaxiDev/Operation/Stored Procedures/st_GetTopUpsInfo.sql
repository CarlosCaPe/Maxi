-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,
-- Description:	<Description,
-- =============================================
CREATE PROCEDURE [Operation].[st_GetTopUpsInfo](
		@IdLanguaje INT = 1
		,@IdAgent INT = NULL
		,@DateFrom DATETIME --= '20140101'
		,@DateTo DATETIME --= '20140101'
		,@Folio INT= NULL
		,@IdStatus XML = NULL
        ,@CusPhone nvarchar(max)
        ,@BenPhone nvarchar(max)
		----------------------
		,@HasError BIT OUT
		,@Message VARCHAR(MAX) OUT
)
AS
BEGIN TRY
	--Configs
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	--set @IdStatus ='<statuses>
	--				  <status id="30" />
	--				  <status id="22" />
	--				</statuses>'


	--VarDeclarations
	DECLARE @TSTATUS TABLE(ID INT) 
	Declare @DocHandle int       
	

	--VarSettings
	SET @HasError = 0
	SET @Message = 'Success'

	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @IdStatus
	Select @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
    Select @DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)

	INSERT INTO @TSTATUS(ID)     
	SELECT id    
	FROM OPENXML (@DocHandle, '/statuses/status',1)     
	WITH (id INT) 

    SELECT 
		PT.IdProductTransfer AS Folio
		,PT.DateOfCreation AS [TransactionDate]
		,LN.TopUpNumber AS [CellularNumber]
		,PT.[Amount] AS [Amount]
		,ISNULL(c.carriername,'') AS [Operator]
        ,ISNULL(cu.countryname,'') AS Country
		,PT.TransactionProviderID AS IdTransaction
	FROM 
		[Operation].[ProductTransfer] PT (NOLOCK)
			JOIN pureminutestopuptransaction LN (NOLOCK) ON LN.IdProductTransfer = pt.IdProductTransfer		
            left join carrierpureminutestopup c (NOLOCK) on ln.carrierid=c.IdCarrierPureMinutesTopUp
           left join countrypureminutestopup cu (NOLOCK) on c.IdCountryPureMinutesTopUp=cu.IdCountryPureMinutesTopUp
	WHERE PT.IdProvider = 4/*lunex*/
		and PT.IdOtherProduct = 6/*tou up'*/ 
		and PT.IdAgent = ISNULL(@IdAgent,PT.IdAgent)
		and PT.IdProductTransfer = ISNULL (@Folio,pt.IdProductTransfer)
		and PT.IdStatus  IN (SELECT ID FROM @TSTATUS)--ISNULL (@IdStatus,ln.IdStatus)
		and PT.DateOfCreation BETWEEN @DateFrom AND @DateTo	        
        and ln.TopUpNumber like '%'+isnull(@BenPhone,ln.TopUpNumber)+'%'        
        and case when isnull(@CusPhone,'null')='null' then 1 else 0 end = 1
	
    union all

    SELECT 
		PT.IdProductTransfer AS Folio
		,PT.DateOfCreation AS [TransactionDate]
		,LN.[Destination_Msisdn] AS [CellularNumber]
		,PT.[Amount] AS [Amount]
		,[Operator]
        ,Country
		,PT.TransactionProviderID AS IdTransaction        
	FROM 
		[Operation].[ProductTransfer] PT (NOLOCK)
		JOIN TransFerTo.TransferTTo LN (NOLOCK) ON LN.IdProductTransfer = pt.IdProductTransfer			         
	WHERE PT.IdProvider = 2/*lunex*/
		and PT.IdOtherProduct = 7/*tou up'*/
		and PT.IdAgent = ISNULL(@IdAgent,PT.IdAgent)
		and PT.IdProductTransfer = ISNULL (@Folio,pt.IdProductTransfer)
		and PT.IdStatus  IN (SELECT ID FROM @TSTATUS)--ISNULL (@IdStatus,ln.IdStatus)
		and PT.DateOfCreation BETWEEN @DateFrom AND @DateTo		
        and ln.Destination_Msisdn like '%'+isnull(@BenPhone,ln.Destination_Msisdn)+'%'
        and ln.Msisdn like '%'+isnull(@cusPhone,ln.Msisdn)+'%'

	union all

	SELECT 
		PT.IdProductTransfer AS Folio
		,PT.DateOfCreation AS [TransactionDate]
		,dbo.[fnFormatPhoneNumber](LN.[TopupPhone]) AS [CellularNumber]
		,PT.[Amount] AS [Amount]
		,ISNULL(c.CarrierName,'') AS [Operator]
        ,ISNULL(cu.countryname,'') AS Country
		,PT.TransactionProviderID AS IdTransaction
	FROM 
		[Operation].[ProductTransfer] PT (NOLOCK)
			JOIN [Lunex].[TransferLN] LN (NOLOCK) ON LN.IdProductTransfer = pt.IdProductTransfer
			LEFT JOIN [Lunex].[Product] PR (NOLOCK) ON PR.SKU = LN.SKU
            left join operation.Carrier c on c.IdCarrier=pr.IdCarrier
            left join operation.country cu on cu.IdCountry=pr.IdCountry
	WHERE PT.IdProvider = 3/*lunex*/
		and PT.IdOtherProduct = 9/*tou up'*/
		and PT.IdAgent = ISNULL(@IdAgent,PT.IdAgent)
		and PT.IdProductTransfer = ISNULL (@Folio,pt.IdProductTransfer)
		and PT.IdStatus  IN (SELECT ID FROM @TSTATUS)--ISNULL (@IdStatus,ln.IdStatus)
		and PT.DateOfCreation BETWEEN @DateFrom AND @DateTo        
        and ln.TopupPhone like '%'+isnull(@BenPhone,ln.TopupPhone)+'%'
        and case when isnull(@CusPhone,'null')='null' then 1 else 0 end = 1

	UNION ALL

	SELECT 
		PT.IdProductTransfer AS Folio
		,PT.DateOfCreation AS [TransactionDate]
		,dbo.[fnFormatPhoneNumber](RT.[Account_Number]) AS [CellularNumber]
		,PT.[Amount] AS [Amount]
		,ISNULL(RT.[Name],'') AS [Operator]
        ,ISNULL(RT.[Country],'') AS Country
		,PT.TransactionProviderID AS IdTransaction
	FROM 
		[Operation].[ProductTransfer] PT (NOLOCK)
		JOIN [Regalii].[TransferR] RT (NOLOCK) ON PT.[IdProductTransfer] = RT.[IdProductTransfer]
	WHERE PT.IdProvider = 5/*Regalii*/
		AND PT.IdOtherProduct = 17/*Regalii TopUp*/
		AND PT.IdAgent = ISNULL(@IdAgent,PT.IdAgent)
		AND PT.IdProductTransfer = ISNULL (@Folio,pt.IdProductTransfer)
		AND PT.IdStatus  IN (SELECT ID FROM @TSTATUS)--ISNULL (@IdStatus,ln.IdStatus)
		AND PT.DateOfCreation BETWEEN @DateFrom AND @DateTo        
        AND RT.[Account_Number] like '%'+isnull(@BenPhone,RT.[Account_Number])+'%'
        AND CASE WHEN ISNULL(@CusPhone,'null')='null' THEN 1 ELSE 0 END = 1
	ORDER BY [TransactionDate]

End Try                                                                                            
Begin Catch
	SET @HasError = 1
	SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLanguaje,'MESSAGE07')
	Declare @ErrorMessage NVARCHAR(MAX)                                                                                             
	Select @ErrorMessage=ERROR_MESSAGE()                                             
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_GetTopUpsInfo',Getdate(),@ErrorMessage)                                                                                            
End Catch  

--USE [MaxiDev]
--GO

--DECLARE	@return_value int,
--		@HasError bit,
--		@Message varchar(max)

--EXEC	@return_value = [dbo].[st_GetTopUpsInfo]
--		@IdLanguaje = 1,
--		@IdAgent = 1254,
--		@DateFrom = N'2015-02-16',
--		--@DateFrom = N'2015-02-16 20:08:44.773',
--		@DateTo = N'2015-02-17',
--		@Folio = 10089,
--		@IdStatus = 30,
--		@HasError = @HasError OUTPUT,
--		@Message = @Message OUTPUT

--SELECT	@HasError as N'@HasError',
--		@Message as N'@Message'
--GO
