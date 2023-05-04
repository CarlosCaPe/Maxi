CREATE PROCEDURE [Corp].[st_GetReportLongDistance_Operation]
(
    @DateFrom datetime,
    @DateTo datetime,
    @IdProvider int = null,
    @IdStatus int = null,
    @IdAgent int = null,
    @Folio int = null,
    @IsCancel bit,
    @IdLenguage int = null,
    @FullResult BIT = 0,
    @CellPhone varchar(max),
    @IdTransfer bigint = null,
    @ProductCode varchar(max) = null, /*S41*/
    @HasError bit output,
    @Message nvarchar(max) output
)
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description>This stored is used in Corp To get Report of Long Distance in [Seach Other Produts]</Description>

<ChangeLog>
<log Date="18/01/2017" Author="mdelgado">Add new filtered request. New Field "Transfer ID" [TransactionProviderID]</log>
<log Date="29/09/2017" Author="snevarez">S41:Add new filtered request. New Field "Product Code" [ProductCode]</log>
</ChangeLog>
*********************************************************************/

       -----
       SET ARITHABORT ON;     
       SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
       -----

       IF @IdLenguage is null 
              SET @IdLenguage=2  

       DECLARE @Tot  INT = 0

       SET @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
       SET @DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)

       DECLARE @CellPhoneWithFormat VARCHAR(MAX)

       IF LEN(@CellPhone) = 10
       BEGIN 
              SET @CellPhoneWithFormat = '('+SUBSTRING(@CellPhone, 0, 4)+') '+ SUBSTRING(@CellPhone, 4, 3)+ '-'+ SUBSTRING(@CellPhone, 7, 4)
       END
       ELSE
       BEGIN
              SET @CellPhoneWithFormat = @CellPhone
       END

       -------------------------------------
       SET @CellPhone = isnull(@CellPhone,'')
       SET @CellPhoneWithFormat = isnull(@CellPhoneWithFormat,'')
       -------------------------------------

	   CREATE TABLE #Result
	   (
		  IdProductTransfer bigint,
		  AgentCode nvarchar(max),
		  AgentName nvarchar(max),
		  Folio int,
		  Amount money,
		  Date datetime,
		  Customer nvarchar(max),
		  TransactionProviderID nvarchar(max),
		  STATUS nvarchar(max),
		  ProviderName nvarchar(max),
		  CellPhone nvarchar(max),
		  UserName nvarchar(max)
		  ,ProductName nvarchar(max)
	   )


       IF @IsCancel = 1 
       BEGIN 
              SELECT @Tot = count(1) 
              FROM operation.producttransfer t WITH(NOLOCK)
                     JOIN Agent a WITH(NOLOCK) ON a.IdAgent = t.IdAgent
                     LEFT JOIN Users u WITH(NOLOCK) ON u.IdUser = t.enterbyiduser
                     LEFT JOIN Users u2 WITH(NOLOCK) ON u2.IdUser = t.enterbyidusercancel
                     JOIN status PS WITH(NOLOCK) ON ps.Idstatus=t.idstatus
              WHERE 
                     t.idotherproduct = 5 
                     AND t.idstatus != 1
                     AND t.amount > 0
                     --and ( t.DateOfCreation >= @DateFrom and t.DateOfCreation < @DateTo )  --20170116 :: Se desactiva para considerar el "TransactionProviderID"
                     
                     AND T.DateOfCreation >= CASE WHEN @IdTransfer IS NULL THEN ISNULL(@DateFrom, T.DateOfCreation) ELSE T.DateOfCreation END --20170116
                     AND T.DateOfCreation <= CASE WHEN @IdTransfer IS NULL THEN isnull(@DateTo,T.DateOfCreation) ELSE T.DateOfCreation END --20170116
                     AND t.TransactionProviderID = ISNULL(@IdTransfer,T.TransactionProviderID) -- 20170116

                  AND t.idstatus = isnull(@IdStatus, t.idstatus) 
                     AND t.Idproducttransfer = isnull(@Folio, t.Idproducttransfer)
                  AND a.IdAgent = isnull(@IdAgent, a.IdAgent) 
                  AND IdProvider = isnull(@IdProvider, IdProvider)
                  --------------
                     AND DATEDIFF(MINUTE, t.DateOfCreation, getdate()) < 1440
                     --------------

              IF @Tot < 3001 OR @FullResult = 1
              BEGIN
                     INSERT INTO #Result 
                           SELECT t.IdProductTransfer, 
                                  a.AgentCode,
                                  t.Idproducttransfer Folio,
                                  t.amount Amount,
                                  t.DateOfCreation Date,
                                  Isnull(pm.SenderName,'') +' '+ Isnull(pm.SenderFirstLastName,'') +' '+ Isnull(pm.SenderSecondLastName,'') Customer,
                                  t.TransactionProviderID,
                                  Ps.StatusName STATUS,
                                  Providername ,
                                  isnull(u.UserName,'') UserName

						    ,'' AS ProductName /*S41*/

                           FROM operation.producttransfer t WITH(NOLOCK)
                                  JOIN Agent a WITH(NOLOCK) ON a.IdAgent=t.IdAgent
                                  LEFT JOIN Users u WITH(NOLOCK) ON u.IdUser= t.enterbyiduser
                                  LEFT JOIN Users u2 WITH(NOLOCK) ON u2.IdUser= t.enterbyidusercancel
                                  JOIN status PS WITH(NOLOCK) ON ps.idstatus=t.idstatus
                                  JOIN pureminutestransaction pm WITH(NOLOCK) ON pm.Idproducttransfer=t.Idproducttransfer
                                  JOIN providers p WITH(NOLOCK) ON t.idprovider=p.idprovider
                           WHERE 
                                  t.idotherproduct=5 
                                  --and (t.DateOfCreation>=@DateFrom and t.DateOfCreation<@DateTo) 
                                                
                                  AND T.DateOfCreation >= CASE WHEN @IdTransfer IS NULL THEN ISNULL(@DateFrom, T.DateOfCreation) ELSE T.DateOfCreation END --20170116
                                  AND T.DateOfCreation <= CASE WHEN @IdTransfer IS NULL THEN isnull(@DateTo,T.DateOfCreation) ELSE T.DateOfCreation END --20170116
                                  AND t.TransactionProviderID = ISNULL(@IdTransfer,T.TransactionProviderID) -- 20170116
                                             
                                  AND t.idstatus = ISNULL(@IdStatus,t.idstatus) and t.idstatus not in (1)
                                  AND t.Idproducttransfer = ISNULL(@Folio,t.Idproducttransfer)
                                  AND a.IdAgent = ISNULL(@IdAgent,a.IdAgent) 
                                  AND t.amount > 0 
                                  AND t.IdProvider = isnull(@IdProvider,t.IdProvider)
                                  AND DATEDIFF(MINUTE, t.DateOfCreation, GETDATE()) < 1440
              END
       END

       ELSE
       BEGIN
              SELECT @Tot = count(1) 
              FROM operation.producttransfer t WITH(NOLOCK) 
                     JOIN Agent a WITH(NOLOCK) ON a.IdAgent = t.IdAgent
                     LEFT JOIN Users u WITH(NOLOCK) ON u.IdUser = t.enterbyiduser
                     LEFT JOIN Users u2 WITH(NOLOCK) ON u2.IdUser = t.enterbyidusercancel
                     JOIN status PS WITH(NOLOCK) ON ps.idstatus = t.idstatus
                     
              WHERE 
                     t.idotherproduct  in (5, 10)
                     --and (t.DateOfCreation >= @DateFrom and t.DateOfCreation < @DateTo)
                                         
                     AND T.DateOfCreation >= CASE WHEN @IdTransfer IS NULL THEN ISNULL(@DateFrom, T.DateOfCreation) ELSE T.DateOfCreation END --20170116
                     AND T.DateOfCreation <= CASE WHEN @IdTransfer IS NULL THEN isnull(@DateTo,T.DateOfCreation) ELSE T.DateOfCreation END --20170116
                     AND t.TransactionProviderID = ISNULL(@IdTransfer,T.TransactionProviderID) -- 20170116

                     AND t.idstatus = isnull(@IdStatus, t.idstatus) and t.idstatus not in (1)
                     AND t.Idproducttransfer = isnull(@Folio, t.Idproducttransfer)
                     AND IdProvider = isnull(@IdProvider, IdProvider)
                     AND a.IdAgent = isnull(@IdAgent, a.IdAgent)
                     AND t.IdProductTransfer IN ( 
                                                                     SELECT IdProductTransfer 
                                                                     FROM lunex.transferln WITH(NOLOCK)
                                                                     WHERE Phone like @CellPhone
                                                                     UNION 
                                                                     SELECT IdProductTransfer 
                                                                     FROM pureminutestransaction WITH(NOLOCK)
                                                                     WHERE SenderPhoneNumber like '%' + @CellPhoneWithFormat + '%'
                                                                     )

              IF @Tot < 3001 OR @FullResult=1
              BEGIN


				INSERT INTO #Result
                           SELECT 
                                  t.IdProductTransfer,
                                  a.AgentCode,
                                  a.AgentName,
                                  t.Idproducttransfer Folio,
                                  t.amount Amount,
                                  t.DateOfCreation Date,
                                  Isnull(pm.SenderName,'') +' '+ Isnull(pm.SenderFirstLastName,'') +' '+ Isnull(pm.SenderSecondLastName,'') Customer,
                                  t.TransactionProviderID,
                                  Ps.StatusName STATUS,
                                  providername, 
                                  pm.ReceiveAccountNumber AS 'CellPhone',
                                  isnull(u.UserName,'') UserName

						    ,'' AS ProductName /*S41*/

                           FROM operation.producttransfer t WITH(NOLOCK)
                                  JOIN Agent a WITH(NOLOCK) ON a.IdAgent=t.IdAgent
                                  LEFT JOIN Users u WITH(NOLOCK) ON u.IdUser= t.enterbyiduser
                                  LEFT JOIN Users u2 WITH(NOLOCK) ON u2.IdUser= t.enterbyidusercancel
                                  JOIN status PS WITH(NOLOCK) ON ps.idstatus=t.idstatus
                                  JOIN pureminutestransaction pm WITH(NOLOCK) ON pm.Idproducttransfer=t.Idproducttransfer and pm.ReceiveAccountNumber like '%'+@CellPhoneWithFormat+'%'
                                  JOIN providers p WITH(NOLOCK) ON t.idprovider=p.idprovider
                           WHERE 
                                  t.idotherproduct = 5 
                                  --and (t.DateOfCreation>=@DateFrom and t.DateOfCreation<@DateTo) 

                                  AND T.DateOfCreation >= CASE WHEN @IdTransfer IS NULL THEN ISNULL(@DateFrom, T.DateOfCreation) ELSE T.DateOfCreation END --20170116
                                  AND T.DateOfCreation <= CASE WHEN @IdTransfer IS NULL THEN isnull(@DateTo,T.DateOfCreation) ELSE T.DateOfCreation END --20170116
                                  AND t.TransactionProviderID = ISNULL(@IdTransfer,T.TransactionProviderID) -- 20170116

                                  AND t.idstatus=isnull(@IdStatus,t.idstatus) and t.idstatus not in (1)
                                  AND t.Idproducttransfer=isnull(@Folio,t.Idproducttransfer)
                                  AND t.IdProvider = isnull(@IdProvider,t.IdProvider)
                                  AND a.IdAgent=isnull(@IdAgent,a.IdAgent);


				/*S41 - BEGIN*/

				IF(@IdProvider=3)
				BEGIN

				    DECLARE @Products TABLE
				    (
					   Id INT IDENTITY(1,1),
					   IdProvider INT,
					   Sku NVARCHAR(150),
					   Product  NVARCHAR(150),
					   Alias  NVARCHAR(150)
				    )

				    INSERT INTO @Products (IdProvider,Sku,Product, Alias)
					   Select 
						  Distinct 
							 pt.IdProvider
							 ,lp.SKU
							 ,lp.Product
							 ,(CASE lp.SKU WHEN '1090' THEN lp.Product ELSE 'Pinless/Long Distance' END) AS Alias
					   From operation.ProductTransfer AS pt WITH(NOLOCK) 
						  Inner Join lunex.transferln tln WITH(NOLOCK) ON pt.Idproducttransfer = tln.IdProductTransfer
						  Inner Join lunex.Product AS lp WITH(NOLOCK) ON tln.SKU = lp.SKU
					   Where IdProvider = isnull(@IdProvider,pt.IdProvider);


				    INSERT INTO #Result
						 SELECT 
							   t.IdProductTransfer,
							   a.AgentCode,
							   a.AgentName,
							   t.Idproducttransfer Folio,
							   t.amount Amount,
							   t.DateOfCreation Date,
							   pm.SenderName Customer,
							   t.TransactionProviderID,
							   Ps.StatusName STATUS,
							   providername,
							   pm.Phone AS 'CellPhone',
							   isnull(u.UserName,'') UserName

							   ,ISNULL(tmp.Alias,'') AS ProductName /*S41*/

						 FROM operation.producttransfer t WITH(NOLOCK)
							   JOIN Agent a WITH(NOLOCK) ON a.IdAgent = t.IdAgent
							   LEFT JOIN Users u WITH(NOLOCK) ON u.IdUser = t.enterbyiduser
							   LEFT JOIN Users u2 WITH(NOLOCK) ON u2.IdUser = t.enterbyidusercancel
							   JOIN status PS WITH(NOLOCK) ON ps.idstatus = t.idstatus
							   JOIN lunex.transferln pm WITH(NOLOCK) ON pm.Idproducttransfer = t.Idproducttransfer and pm.Phone like '%'+@CellPhone+'%'
							   JOIN providers p WITH(NOLOCK) ON t.idprovider = p.idprovider

							   LEFT JOIN @Products AS tmp ON pm.SKU = tmp.SKU /*S41*/
						 WHERE
							   t.idotherproduct = 10

							   AND T.DateOfCreation >= CASE WHEN @IdTransfer IS NULL THEN ISNULL(@DateFrom, T.DateOfCreation) ELSE T.DateOfCreation END --20170116
							   AND T.DateOfCreation <= CASE WHEN @IdTransfer IS NULL THEN isnull(@DateTo,T.DateOfCreation) ELSE T.DateOfCreation END --20170116
							   AND t.TransactionProviderID = ISNULL(@IdTransfer,T.TransactionProviderID) -- 20170116

							   AND t.idstatus = isnull(@IdStatus, t.idstatus) and t.idstatus not in (1)
							   AND t.Idproducttransfer = isnull(@Folio, t.Idproducttransfer)
							   AND t.IdProvider = isnull(@IdProvider, t.IdProvider)
							   AND a.IdAgent = isnull(@IdAgent, a.IdAgent);

				    IF @ProductCode  = '0001'
				    BEGIN
					   --DELETE FROM #Result WHERE ProductName = 'GuateLLama';
					   DELETE FROM #Result WHERE ProductName = 'GuateLLama' OR ISNULL(ProductName,'') = '';
				    END

				    IF @ProductCode  = '1090'
				    BEGIN
					   DELETE FROM #Result WHERE ProductName != 'GuateLLama';
				    END

				END
				ELSE
				BEGIN
					INSERT INTO #Result
						 SELECT 
							   t.IdProductTransfer,
							   a.AgentCode,
							   a.AgentName,
							   t.Idproducttransfer Folio,
							   t.amount Amount,
							   t.DateOfCreation Date,
							   pm.SenderName Customer,
							   t.TransactionProviderID,
							   Ps.StatusName STATUS,
							   providername,
							   pm.Phone AS 'CellPhone',
							   isnull(u.UserName,'') UserName

							  ,'' AS ProductName /*S41*/

						 FROM operation.producttransfer t WITH(NOLOCK)
							   JOIN Agent a WITH(NOLOCK) ON a.IdAgent = t.IdAgent
							   LEFT JOIN Users u WITH(NOLOCK) ON u.IdUser = t.enterbyiduser
							   LEFT JOIN Users u2 WITH(NOLOCK) ON u2.IdUser = t.enterbyidusercancel
							   JOIN status PS WITH(NOLOCK) ON ps.idstatus = t.idstatus
							   JOIN lunex.transferln pm WITH(NOLOCK) ON pm.Idproducttransfer = t.Idproducttransfer and pm.Phone like '%'+@CellPhone+'%'
							   JOIN providers p WITH(NOLOCK) ON t.idprovider = p.idprovider
						 WHERE
							   t.idotherproduct = 10
							   --and (t.DateOfCreation >= @DateFrom and t.DateOfCreation < @DateTo) 
                                            
							   AND T.DateOfCreation >= CASE WHEN @IdTransfer IS NULL THEN ISNULL(@DateFrom, T.DateOfCreation) ELSE T.DateOfCreation END --20170116
							   AND T.DateOfCreation <= CASE WHEN @IdTransfer IS NULL THEN isnull(@DateTo,T.DateOfCreation) ELSE T.DateOfCreation END --20170116
							   AND t.TransactionProviderID = ISNULL(@IdTransfer,T.TransactionProviderID) -- 20170116

							   AND t.idstatus = isnull(@IdStatus, t.idstatus) and t.idstatus not in (1)
							   AND t.Idproducttransfer = isnull(@Folio, t.Idproducttransfer)
							   AND t.IdProvider = isnull(@IdProvider, t.IdProvider)
							   AND a.IdAgent = isnull(@IdAgent, a.IdAgent);
				END
				/*S41 - END*/  

              END
       END


       IF @Tot > 3000 AND @FullResult = 0
	   BEGIN
              SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHERROR'),@HasError = 1;
	   END
       ELSE
	   BEGIN
              SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHOK'),@HasError = 0;
	   END


       SELECT 
		 IdProductTransfer
		 , AgentCode
		 , AgentName
		 , Folio
		 , Amount
		 , Date
		 , Customer
		 , TransactionProviderID
		 , STATUS
		 , ProviderName
		 , CellPhone
		 , UserName
		 , ProductName /*S41*/
       FROM #Result
       ORDER BY [Date] DESC;

       DROP TABLE #Result;
