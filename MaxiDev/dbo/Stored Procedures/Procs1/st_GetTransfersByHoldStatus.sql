CREATE PROCEDURE [dbo].[st_GetTransfersByHoldStatus]
@IdStatus int,
@StringFilter NVARCHAR(MAX) = NULL,
@StateCode NVARCHAR(MAX) = NULL,
@YearFilter DATETIME = NULL
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="19/06/2017" Author="jmoreno"> S26 :: Replicar funcionalidad de Kyc Hold Sobres - [Cambios Realizados.] </log>
<log Date="19/06/2017" Author="mdelgado">S26 :: Replicar funcionalidad de Kyc Hold Sobres - Columna LastView para Status de GateWay info Required </log>
<log Date="20/06/2017" Author="snevarez">S26 :: Agrego columna para identificar identificaciones del cliente(HasAutomaticNotification) </log>
<log Date="19/01/2022" Author="jcsierra">Se cambia el funcionamiento para el status 73 PendingPayment</log>
</ChangeLog>
********************************************************************/
DECLARE @BeginDate DATETIME = NULL, @EndDate DATETIME = NULL


IF LTRIM(@StringFilter) = '' SET @StringFilter = NULL
IF LTRIM(@StateCode) = '' SET @StateCode = NULL

IF @YearFilter IS NOT NULL
BEGIN
	SET @YearFilter = [dbo].[RemoveTimeFromDatetime](@YearFilter)
	SET @BeginDate = DATEADD(DAY, -1, @YearFilter)
	SET @EndDate = DATEADD(YEAR, 1, @YearFilter)
END

--15 OFAC HOLD
If @IdStatus in (3,6,9,12,15,18) -- If IdStatus is Hold use the correspondent StatusName for that IdStatus and hard code it
Begin
       Select distinct top 1500 T.IdAgent,  A.AgentCode, A.AgentState, T.ClaimCode, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName,
	                 A.AgentName, T.DateOfTransfer, T.IdTransfer, T.Folio, P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName,
                     C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, T.ReviewReturned,
                     T.IdBeneficiary, T.IdCustomer, [dbo].[fun_GetLastReview](T.IdTransfer) as LastReview,
					 rt.IdDocumentTransfertStatus,
					 --(
					 --CASE 
					 --WHEN @IdStatus in (9,15, 12) AND (LC.IdUploadFile IS NOT NULL) then rt.IdDocumentTransfertStatus 
					 --ELSE null 
					 --END) as IdDocumentTransfertStatus -- New RMM
                     --,Convert(bit,case when LC.IdUploadFile is not null or LT.IdUploadFile is not null then 1 else 0 end) HasFiles,                     
			          case when @Idstatus = 15 then
			          (select count(1) from [TransferHolds]  Tho WITH(NOLOCK) WHERE Tho.IdTransfer = T.IdTransfer and T.IdStatus=41 and Tho.IsReleased = 1 and Tho.IdStatus = @IdStatus)
			          else 0 end releasedCount, t.IdGateway, gat.GatewayName
					  , T.[AgentNotificationSent]
					  ,T.FromStandByToKYC into #tmpdata
       From [Transfer] T with(nolock)
       inner join [TransferHolds] TH WITH(NOLOCK) ON T.IdTransfer = TH.IdTransfer
       inner join [Agent] A WITH(NOLOCK) ON T.IdAgent = A.IdAgent
       inner join [Customer] C WITH(NOLOCK) ON T.IdCustomer = C.IdCustomer
       inner join [Payer] P WITH(NOLOCK) ON T.IdPayer = P.IdPayer
       inner join [Status] S WITH(NOLOCK) ON TH.IdStatus = S.IdStatus
	   inner join [Gateway] gat WITH(NOLOCK) ON t.IdGateway = gat.IdGateway
       /*left join 
              (
                     select UF.IdReference, Max(UF.IdUploadFile) IdUploadFile
                     from UploadFiles UF with(nolock)
                           inner join DocumentTypes DT WITH(NOLOCK) ON DT.IdDocumentType=UF.IdDocumentType
                     WHERE UF.IdStatus=1 and DT.IdType=1
                     group by UF.IdReference
              )LC ON LC.IdReference=T.IdCustomer  
       left join 
              (
                     select UF.IdReference, Max(UF.IdUploadFile) IdUploadFile
                     from UploadFiles UF with(nolock)
                           inner join DocumentTypes DT WITH(NOLOCK) ON DT.IdDocumentType=UF.IdDocumentType
                     WHERE UF.IdStatus=1 and DT.IdType=4
                     group by UF.IdReference
              )LT ON LT.IdReference=T.IdTransfer
			  */
	left join RelationTransferDocumentStatus rt WITH(NOLOCK) ON rt.IdTransfer = t.IdTransfer AND rt.IsTransferReceipt = 0-- New RMM
       WHERE T.IdStatus = 41 and TH.IdStatus = @IdStatus and TH.IsReleased is null
       --ORDER BY T.DateOfTransfer desc

	    select UF.IdReference, Max(UF.IdUploadFile) IdUploadFile into #docs1
                     from UploadFiles UF with(nolock)
                           inner join DocumentTypes DT WITH(NOLOCK) ON DT.IdDocumentType=UF.IdDocumentType
                     WHERE UF.IdStatus=1 and DT.IdType=1 and uf.IdReference in (select IdCustomer from #tmpdata)
                     group by UF.IdReference

		 select UF.IdReference, Max(UF.IdUploadFile) IdUploadFile into #docs2
                     from UploadFiles UF with(nolock)
                           inner join DocumentTypes DT WITH(NOLOCK) ON DT.IdDocumentType=UF.IdDocumentType
                     WHERE UF.IdStatus=1 and DT.IdType=4 and uf.IdReference in (select idtransfer from #tmpdata)
                     group by UF.IdReference

		/*S26*/
		 select IdTransfer into #docs3              
					from TransferAutomaticNotification AS t
					WHERE t.IdTransfer in (select idtransfer from #tmpdata)
                     group by t.IdTransfer
		/*----*/

		CREATE CLUSTERED INDEX Idx1 ON #docs1(IdReference)
		CREATE CLUSTERED INDEX Idx2 ON #docs2(IdReference)

		select t.*, 
		 (
					 CASE 
					 WHEN @IdStatus in (9,15, 12) AND (LC.IdUploadFile IS NOT NULL) then t.IdDocumentTransfertStatus 
					 ELSE null 
					 END) as IdDocumentTransfertStatus -- New RMM
                     ,Convert(bit,case when LC.IdUploadFile is not null or LT.IdUploadFile is not null then 1 else 0 end) HasFiles
					 ,Convert(bit,case when id.IdTransfer is null then 0 else 1 end) AS HasAutomaticNotification /*S26*/
		from #tmpdata T
		left join #docs1 lc ON lc.IdReference=t.IdCustomer
		left join #docs2 lt ON lt.IdReference=t.IdTransfer
		left join #docs3 id ON t.IdTransfer=id.IdTransfer /*S26*/
		ORDER BY t.DateOfTransfer desc

End
ELSE IF (@IdStatus = 73)
Begin
	SELECT TOP 1500 T.IdAgent,  A.AgentCode, T.ClaimCode, A.AgentState, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName,
					A.AgentName, T.DateOfTransfer, T.IdTransfer, T.Folio, P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName,
					C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, T.ReviewReturned,
					T.IdBeneficiary, T.IdCustomer, 
					(CASE T.IdStatus WHEN 24 THEN [dbo].[fun_GetLastReview](T.IdTransfer) ELSE NULL END) as LastReview, 
					null as IdDocumentTransfertStatus
					,Convert(bit,0) HasFiles,
					0 releasedCount, t.IdGateway, gat.GatewayName
					, T.[AgentNotificationSent]
					,T.FromStandByToKYC
					,Convert(bit,0) HasAutomaticNotification
	From [Transfer] T with(nolock)
	inner join [Agent] A WITH(NOLOCK) ON T.IdAgent = A.IdAgent
	inner join [Customer] C WITH(NOLOCK) ON T.IdCustomer = C.IdCustomer
	inner join [Payer] P WITH(NOLOCK) ON T.IdPayer = P.IdPayer
	inner join [Status] S WITH(NOLOCK) ON T.IdStatus = S.IdStatus
	inner join [Gateway] gat WITH(NOLOCK) ON t.IdGateway = gat.IdGateway
	Where T.IdStatus = 1 AND T.IdPaymentMethod = 2
	ORDER BY T.DateOfTransfer desc
End
Else -- If IdStatus is NOT a Hold use a simple search by IdStatus
Begin
	-- New RMM
	if(@IdStatus = 1000)
	BEGIN
	   select top 1500 T.IdAgent,  A.AgentCode, A.AgentState, T.ClaimCode, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName, A.AgentName, T.DateOfTransfer, T.IdTransfer, T.Folio, 
	   				P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName, C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, 
					T.ReviewReturned, T.IdBeneficiary, T.IdCustomer, (CASE T.IdStatus WHEN 24 THEN [dbo].[fun_GetLastReview](T.IdTransfer) ELSE NULL END) as LastReview
					, 
					null as IdDocumentTransfertStatus, Convert(bit,0) HasFiles, 0 releasedCount, t.IdGateway, gat.GatewayName
					, T.[AgentNotificationSent]
					,T.FromStandByToKYC
					,Convert(bit,0) AS HasAutomaticNotification /*S26*/
	   from transfer t with(nolock)
	   join [GatewayPayerOnEdit] g WITH(NOLOCK) ON t.idgateway=g.idgateway and t.idpayer=isnull(g.idpayer,t.idpayer) and t.idpaymenttype=isnull(g.idpaymenttype,t.idpaymenttype) and g.idgenericstatus=1 
       inner join [Agent] A WITH(NOLOCK) ON T.IdAgent = A.IdAgent
       inner join [Customer] C WITH(NOLOCK) ON T.IdCustomer = C.IdCustomer
       inner join [Payer] P WITH(NOLOCK) ON T.IdPayer = P.IdPayer
       inner join [Status] S WITH(NOLOCK) ON T.IdStatus = S.IdStatus
	   inner join [Gateway] gat WITH(NOLOCK) ON t.IdGateway = gat.IdGateway
	   WHERE t.idstatus=23
	END
	ELSE
	BEGIN
	-- End New RMM
       IF @IdStatus = 27 -- UNCLAIMED HOLD
	   BEGIN
			IF @StringFilter IS NULL
				Select top 1500 T.IdAgent,  A.AgentCode, A.AgentState, T.ClaimCode, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName,
								A.AgentName, T.DateOfTransfer, T.IdTransfer, T.Folio, P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName,
								C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, T.ReviewReturned,
								T.IdBeneficiary, T.IdCustomer, (CASE T.IdStatus WHEN 24 THEN [dbo].[fun_GetLastReview](T.IdTransfer) ELSE NULL END) as LastReview, null as IdDocumentTransfertStatus
								,Convert(bit,0) HasFiles,
								0 releasedCount, t.IdGateway, gat.GatewayName
								, T.[AgentNotificationSent]
								,T.FromStandByToKYC
								,Convert(bit,0) AS HasAutomaticNotification /*S26*/
				From [Transfer] T with(nolock)
				inner join [Agent] A WITH(NOLOCK) ON T.IdAgent = A.IdAgent
				inner join [Customer] C WITH(NOLOCK) ON T.IdCustomer = C.IdCustomer
				inner join [Payer] P WITH(NOLOCK) ON T.IdPayer = P.IdPayer
				inner join [Status] S WITH(NOLOCK) ON T.IdStatus = S.IdStatus
				inner join [Gateway] gat WITH(NOLOCK) ON t.IdGateway = gat.IdGateway
				Where T.IdStatus = @IdStatus
				AND T.[DateOfTransfer] >= ISNULL(@BeginDate, T.[DateOfTransfer]) AND T.[DateOfTransfer] <= ISNULL(@EndDate, T.[DateOfTransfer])
				AND A.AgentState = ISNULL(@StateCode, A.AgentState)
				ORDER BY T.[DateOfTransfer] ASC
			ELSE
			BEGIN
				SET @StringFilter = '%' + @StringFilter + '%'
				Select top 1500 T.IdAgent,  A.AgentCode, A.AgentState, T.ClaimCode, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName,
								A.AgentName, T.DateOfTransfer, T.IdTransfer, T.Folio, P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName,
								C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, T.ReviewReturned,
								T.IdBeneficiary, T.IdCustomer, (CASE T.IdStatus WHEN 24 THEN [dbo].[fun_GetLastReview](T.IdTransfer) ELSE NULL END) as LastReview, null as IdDocumentTransfertStatus
								,Convert(bit,0) HasFiles,
								0 releasedCount, t.IdGateway, gat.GatewayName
								, T.[AgentNotificationSent]
								,T.FromStandByToKYC
								,Convert(bit,0) AS HasAutomaticNotification /*S26*/
				From [Transfer] T with(nolock)
				inner join [Agent] A WITH(NOLOCK) ON T.IdAgent = A.IdAgent
				inner join [Customer] C WITH(NOLOCK) ON T.IdCustomer = C.IdCustomer
				inner join [Payer] P WITH(NOLOCK) ON T.IdPayer = P.IdPayer
				inner join [Status] S WITH(NOLOCK) ON T.IdStatus = S.IdStatus
				inner join [Gateway] gat WITH(NOLOCK) ON t.IdGateway = gat.IdGateway
				Where T.IdStatus = @IdStatus
				AND T.[DateOfTransfer] >= ISNULL(@BeginDate, T.[DateOfTransfer]) AND T.[DateOfTransfer] <= ISNULL(@EndDate, T.[DateOfTransfer])
				AND A.AgentState = ISNULL(@StateCode, A.AgentState)
				AND (T.[ClaimCode] LIKE @StringFilter OR A.[AgentCode] LIKE @StringFilter OR A.[AgentName] LIKE @StringFilter)
				ORDER BY T.[DateOfTransfer] ASC
			END
		END
	   ELSE
	   IF @IdStatus = 24 -- RETURNED HOLD
	   BEGIN
		    Select top 1500 T.IdAgent,  A.AgentCode, T.ClaimCode, A.AgentState, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName,
			A.AgentName, T.DateOfTransfer, T.IdTransfer, T.Folio, P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName,
            C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, T.ReviewReturned,
            T.IdBeneficiary, T.IdCustomer, 
			[dbo].[fun_GetLastReview](T.IdTransfer) as LastReview,
			rt.IdDocumentTransfertStatus,
            --Convert(bit,case when LT.IdUploadFile is not null then 1 else 0 end) HasFiles,
            0 releasedCount, t.IdGateway, gat.GatewayName
			, T.[AgentNotificationSent]
			,T.FromStandByToKYC into #tmpdata24
		   From [Transfer] T with(nolock)
		   inner join [Agent] A WITH(NOLOCK) ON T.IdAgent = A.IdAgent
		   inner join [Customer] C WITH(NOLOCK) ON T.IdCustomer = C.IdCustomer
		   inner join [Payer] P WITH(NOLOCK) ON T.IdPayer = P.IdPayer
		   inner join [Status] S WITH(NOLOCK) ON T.IdStatus = S.IdStatus
		   inner join [Gateway] gat WITH(NOLOCK) ON t.IdGateway = gat.IdGateway
		   left join [RelationTransferDocumentStatus] rt WITH(NOLOCK) ON rt.IdTransfer = T.IdTransfer AND rt.IsTransferReceipt = 1
		   /*left join 
				  (
						 select UF.IdReference, Max(UF.IdUploadFile) IdUploadFile
						 from UploadFiles UF with(nolock)
							   inner join DocumentTypes DT WITH(NOLOCK) ON DT.IdDocumentType=UF.IdDocumentType
						 WHERE UF.IdStatus=1 and DT.IdDocumentType = 55
						 group by UF.IdReference
				  )LT ON LT.IdReference=T.IdTransfer	*/	  
		   WHERE T.IdStatus = @IdStatus
		   --ORDER BY T.DateOfTransfer desc	
		   
		   select UF.IdReference, Max(UF.IdUploadFile) IdUploadFile into #docs24
						 from UploadFiles UF with(nolock)
							   inner join DocumentTypes DT WITH(NOLOCK) ON DT.IdDocumentType=UF.IdDocumentType
						 WHERE UF.IdStatus=1 and DT.IdDocumentType = 55 and uf.IdReference in (select idtransfer from #tmpdata24)
						 group by UF.IdReference

				CREATE CLUSTERED INDEX Idx24 ON #docs24(IdReference)

				select 
					t.*
					, Convert(bit,case when LT.IdUploadFile is not null then 1 else 0 end) HasFiles
					, Convert(bit,0) AS HasAutomaticNotification /*S26*/
				from #tmpdata24 T		
				left join #docs24 lt ON lt.IdReference=t.IdTransfer
				ORDER BY t.DateOfTransfer desc
		   		
	   END
	   ELSE
	   BEGIN
	       	   	   
	    IF (@IdStatus = 29)
	    BEGIN 
					SELECT TOP 1500 T.IdAgent,  A.AgentCode, T.ClaimCode, A.AgentState, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName,
									A.AgentName, T.DateOfTransfer, T.IdTransfer, T.Folio, P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName,
									C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, T.ReviewReturned,
									T.IdBeneficiary, T.IdCustomer, 
									--(CASE T.IdStatus WHEN (24) THEN [dbo].[fun_GetLastReview](T.IdTransfer) ELSE NULL END) as LastReview, 
									[dbo].[fun_GetLastReview](T.IdTransfer) as LastReview,
									[IdDocumentTransfertStatus] =
							                                (CASE  @IdStatus
							                                  WHEN 29
							                                   THEN 
								                                  ( SELECT 
								                                     rt.IdDocumentTransfertStatus
								                                    FROM 
								                                     RelationTransferDocumentStatus rt WITH(NOLOCK) 
								                                    WHERE  
								                                     rt.IdTransfer =T.IdTransfer 
								                                     AND rt.IsTransferReceipt = 0
								                                   )					                                   
							                                    ELSE 
							                                     NULL
							                                   END					                                  					                                   					                                   
							                                 )						
									,CONVERT(BIT,0) HasFiles										 												
									,0 releasedCount, t.IdGateway, gat.GatewayName
									, T.[AgentNotificationSent]
									,T.FromStandByToKYC
									INTO #tmpdataGl2
					FROM [Transfer] T WITH(NOLOCK) 
					INNER JOIN [Agent] A WITH(NOLOCK) ON T.IdAgent = A.IdAgent
					INNER JOIN [Customer] C WITH(NOLOCK) ON T.IdCustomer = C.IdCustomer
					INNER JOIN [Payer] P WITH(NOLOCK) ON T.IdPayer = P.IdPayer
					INNER JOIN [Status] S WITH(NOLOCK) ON T.IdStatus = S.IdStatus
					INNER JOIN [Gateway] gat WITH(NOLOCK) ON t.IdGateway = gat.IdGateway
					WHERE T.IdStatus = @IdStatus
					ORDER BY T.DateOfTransfer DESC
					
				SELECT UF.IdReference, Max(UF.IdUploadFile) IdUploadFile INTO #docsGl2
		                     FROM UploadFiles UF WITH(NOLOCK)
		                           INNER JOIN DocumentTypes DT WITH(NOLOCK) ON DT.IdDocumentType=UF.IdDocumentType
		                     WHERE UF.IdStatus=1 and DT.IdType=1 and uf.IdReference in (select IdCustomer from #tmpdataGl2)
		                     GROUP BY UF.IdReference
		
				 SELECT UF.IdReference, MAX(UF.IdUploadFile) IdUploadFile INTO #docs2Gl2
		                     FROM UploadFiles UF WITH(NOLOCK)
		                           INNER JOIN DocumentTypes DT WITH(NOLOCK) ON DT.IdDocumentType=UF.IdDocumentType
		                     WHERE UF.IdStatus=1 and DT.IdType=4 AND uf.IdReference IN (SELECT idtransfer FROM #tmpdataGl2)
		                     GROUP BY UF.IdReference
				/*S26*/
				SELECT t.IdTransfer into #docsGl3              
						FROM TransferAutomaticNotification AS t
						WHERE t.IdTransfer in (select tmp12.idtransfer from #tmpdataGl2 tmp12)
						 GROUP BY t.IdTransfer
			 /*----*/

				CREATE CLUSTERED INDEX Idx1 ON #docsGl2(IdReference)
				CREATE CLUSTERED INDEX Idx2 ON #docs2Gl2(IdReference)
			
			
					
		   SELECT
		    gl2.IdAgent
		    , gl2.AgentCode
		    , gl2.ClaimCode
		    , gl2.AgentState
		    , gl2.CustomerName
		    , gl2.CustomerFirstLastName
		    , gl2.CustomerSecondLastName
		    , gl2.AgentName
		    , gl2.DateOfTransfer
		    , gl2.IdTransfer
		    , gl2.Folio
		    , gl2.PayerName
		    , gl2.AmountInDollars
		    , gl2.IdStatus
		    , gl2.StatusName
		    , gl2.CustomerPhysicalIdCopy
		    , gl2.ReviewDenyList
		    , gl2.ReviewOfac
		    , gl2.ReviewKyc
		    , gl2.ReviewGateway
		    , gl2.ReviewReturned
		    , gl2.IdBeneficiary
		    , gl2.IdCustomer 
				, gl2.LastReview 			
				, gl2.IdDocumentTransfertStatus		 
		    , CONVERT(BIT,CASE WHEN LC.IdUploadFile IS NOT NULL OR LT.IdUploadFile IS NOT NULL THEN 1 ELSE 0 END) HasFiles
				, gl2.releasedCount
				, gl2.IdGateway
				, gl2.GatewayName
				, gl2.AgentNotificationSent
		    , gl2.FromStandByToKYC
			,Convert(bit,case when id.IdTransfer is null then 0 else 1 end) AS HasAutomaticNotification /*S26*/
		   FROM #tmpdataGl2	 gl2	
				LEFT JOIN #docsGl2 lc ON lc.IdReference=gl2.IdCustomer
				LEFT JOIN #docs2Gl2 lt ON lt.IdReference=gl2.IdTransfer
				LEFT JOIN #docsGl3 id ON gl2.IdTransfer=id.IdTransfer /*S26*/
	 END
	 ELSE
	  BEGIN 
	   SELECT TOP 1500 T.IdAgent,  A.AgentCode, T.ClaimCode, A.AgentState, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName,
							A.AgentName, T.DateOfTransfer, T.IdTransfer, T.Folio, P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName,
							C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, T.ReviewReturned,
							T.IdBeneficiary, T.IdCustomer, 
							(CASE T.IdStatus WHEN 24 THEN [dbo].[fun_GetLastReview](T.IdTransfer) ELSE NULL END) as LastReview, 
							null as IdDocumentTransfertStatus
							,Convert(bit,0) HasFiles,
							0 releasedCount, t.IdGateway, gat.GatewayName
							, T.[AgentNotificationSent]
							,T.FromStandByToKYC
							,Convert(bit,0) HasAutomaticNotification
			From [Transfer] T with(nolock)
			inner join [Agent] A WITH(NOLOCK) ON T.IdAgent = A.IdAgent
			inner join [Customer] C WITH(NOLOCK) ON T.IdCustomer = C.IdCustomer
			inner join [Payer] P WITH(NOLOCK) ON T.IdPayer = P.IdPayer
			inner join [Status] S WITH(NOLOCK) ON T.IdStatus = S.IdStatus
			inner join [Gateway] gat WITH(NOLOCK) ON t.IdGateway = gat.IdGateway
			Where T.IdStatus = @IdStatus
			ORDER BY T.DateOfTransfer desc
	  end	 
		 			
	   END
	END
End







