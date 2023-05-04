CREATE procedure [dbo].[st_GetTransfersByHoldStatusV3]
@IdStatus int,
@StringFilter NVARCHAR(MAX) = NULL,
@StateCode NVARCHAR(MAX) = NULL,
@YearFilter DATETIME = NULL
as

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
		
	  Select distinct T.IdTransfer, T.IdCustomer
	  into #TempTransactions
	  From [Transfer] T with(nolock)
       inner join [TransferHolds] TH with(nolock) on T.IdTransfer = TH.IdTransfer
	     Where T.IdStatus = 41 and TH.IdStatus = @IdStatus and TH.IsReleased is null


       Select distinct top 1500 T.IdAgent,  A.AgentCode, A.AgentState, T.ClaimCode, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName,
                     A.AgentName, T.DateOfTransfer, T.IdTransfer, T.Folio, P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName,
                     C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, T.ReviewReturned,
                     T.IdBeneficiary, T.IdCustomer, LL.LastReview as LastReview,
					 --(case @IdStatus when 9 then rt.IdDocumentTransfertStatus else null end) as IdDocumentTransfertStatus -- New RMM
					 (case when @IdStatus in (9,15, 12) then rt.IdDocumentTransfertStatus else null end) as IdDocumentTransfertStatus -- New RMM
                     ,Convert(bit,case when LC.IdUploadFile is not null or LT.IdUploadFile is not null then 1 else 0 end) HasFiles,                     
			         ISNULL(LR.releasedCount,0) releasedCount, t.IdGateway, gat.GatewayName
       From [Transfer] T with(nolock)
       inner join [TransferHolds] TH with(nolock) on T.IdTransfer = TH.IdTransfer
       inner join [Agent] A with(nolock) on T.IdAgent = A.IdAgent
       inner join [Customer] C with(nolock) on T.IdCustomer = C.IdCustomer
       inner join [Payer] P with(nolock) on T.IdPayer = P.IdPayer
       inner join [Status] S with(nolock) on TH.IdStatus = S.IdStatus
	   inner join [Gateway] gat with(nolock) on t.IdGateway = gat.IdGateway
       left join 
              (
                     select UF.IdReference, Max(UF.IdUploadFile) IdUploadFile
                     from UploadFiles UF with(nolock)
						   inner join #TempTransactions T on UF.IdReference=T.IdCustomer	
                           inner join DocumentTypes DT with(nolock) on DT.IdDocumentType=UF.IdDocumentType
                     where UF.IdStatus=1 and DT.IdType=1
                     group by UF.IdReference
              )LC on LC.IdReference=T.IdCustomer  
       left join 
              (
                     select UF.IdReference, Max(UF.IdUploadFile) IdUploadFile
                     from UploadFiles UF with(nolock)
						   inner join #TempTransactions T on UF.IdReference=T.IdTransfer
                           inner join DocumentTypes DT with(nolock) on DT.IdDocumentType=UF.IdDocumentType
                     where UF.IdStatus=1 and DT.IdType=4
                     group by UF.IdReference
              )LT on LT.IdReference=T.IdTransfer
		left join
				(
					SELECT A.IdTransfer, MAX(Isnull(B.EnterDate,A.DateOfMovement)) LastReview
					FROM TransferDetail A with(nolock)  
						inner join #TempTransactions T on A.IdTransfer=T.IdTransfer                      
						Left Join TransferNote B with(nolock) on (A.IdTransferDetail=B.IdTransferDetail)                          
					group by A.IdTransfer
				)LL on LL.IdTransfer=T.IdTransfer
		left join 
				(
					select Tho.IdTransfer,  count(1)  releasedCount
					from [TransferHolds]  Tho with(nolock) 
						inner join #TempTransactions T on Tho.IdTransfer=T.IdTransfer  
					where @Idstatus = 15 and Tho.IsReleased = 1 and Tho.IdStatus = @IdStatus
					group by tho.IdTransfer
				)LR on LR.IdTransfer=T.IdTransfer
	left join RelationTransferDocumentStatus rt with(nolock) on rt.IdTransfer = t.IdTransfer -- New RMM
       Where T.IdStatus = 41 and TH.IdStatus = @IdStatus and TH.IsReleased is null
       Order by T.DateOfTransfer desc
End
Else -- If IdStatus is NOT a Hold use a simple search by IdStatus
Begin
	-- New RMM
	if(@IdStatus = 1000)
	BEGIN
	   select top 1500 T.IdAgent,  A.AgentCode, A.AgentState, T.ClaimCode, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName, A.AgentName, T.DateOfTransfer, T.IdTransfer, T.Folio, 
					P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName, C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, 
					T.ReviewReturned, T.IdBeneficiary, T.IdCustomer, (CASE T.IdStatus WHEN 24 THEN [dbo].[fun_GetLastReview](T.IdTransfer) ELSE NULL END) as LastReview, 
					null as IdDocumentTransfertStatus, Convert(bit,0) HasFiles, 0 releasedCount, t.IdGateway, gat.GatewayName
	   from transfer t with(nolock)
	   join [GatewayPayerOnEdit] g with(nolock) on t.idgateway=g.idgateway and t.idpayer=isnull(g.idpayer,t.idpayer) and t.idpaymenttype=isnull(g.idpaymenttype,t.idpaymenttype) and g.idgenericstatus=1 
       inner join [Agent] A with(nolock) on T.IdAgent = A.IdAgent
       inner join [Customer] C with(nolock) on T.IdCustomer = C.IdCustomer
       inner join [Payer] P with(nolock) on T.IdPayer = P.IdPayer
       inner join [Status] S with(nolock) on T.IdStatus = S.IdStatus
	   inner join [Gateway] gat with(nolock) on t.IdGateway = gat.IdGateway
	   where t.idstatus=23
	END
	ELSE
	BEGIN
	-- End New RMM
       IF @IdStatus = 27 -- UNCLAIMED HOLD
	   BEGIN
			IF @StringFilter IS NULL
				Select T.IdAgent,  A.AgentCode, A.AgentState, T.ClaimCode, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName,
								A.AgentName, T.DateOfTransfer, T.IdTransfer, T.Folio, P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName,
								C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, T.ReviewReturned,
								T.IdBeneficiary, T.IdCustomer, (CASE T.IdStatus WHEN 24 THEN [dbo].[fun_GetLastReview](T.IdTransfer) ELSE NULL END) as LastReview, null as IdDocumentTransfertStatus
								,Convert(bit,0) HasFiles,
								0 releasedCount, t.IdGateway, gat.GatewayName
				From [Transfer] T with(nolock)
				inner join [Agent] A with(nolock) on T.IdAgent = A.IdAgent
				inner join [Customer] C with(nolock) on T.IdCustomer = C.IdCustomer
				inner join [Payer] P with(nolock) on T.IdPayer = P.IdPayer
				inner join [Status] S with(nolock) on T.IdStatus = S.IdStatus
				inner join [Gateway] gat with(nolock) on t.IdGateway = gat.IdGateway
				Where T.IdStatus = @IdStatus
				AND T.[DateOfTransfer] >= ISNULL(@BeginDate, T.[DateOfTransfer]) AND T.[DateOfTransfer] <= ISNULL(@EndDate, T.[DateOfTransfer])
				AND A.AgentState = ISNULL(@StateCode, A.AgentState)
				ORDER BY T.[DateOfTransfer] ASC
			ELSE
			BEGIN
				SET @StringFilter = '%' + @StringFilter + '%'
				Select T.IdAgent,  A.AgentCode, A.AgentState, T.ClaimCode, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName,
								A.AgentName, T.DateOfTransfer, T.IdTransfer, T.Folio, P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName,
								C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, T.ReviewReturned,
								T.IdBeneficiary, T.IdCustomer, (CASE T.IdStatus WHEN 24 THEN [dbo].[fun_GetLastReview](T.IdTransfer) ELSE NULL END) as LastReview, null as IdDocumentTransfertStatus
								,Convert(bit,0) HasFiles,
								0 releasedCount, t.IdGateway, gat.GatewayName
				From [Transfer] T with(nolock)
				inner join [Agent] A with(nolock) on T.IdAgent = A.IdAgent
				inner join [Customer] C with(nolock) on T.IdCustomer = C.IdCustomer
				inner join [Payer] P with(nolock) on T.IdPayer = P.IdPayer
				inner join [Status] S with(nolock) on T.IdStatus = S.IdStatus
				inner join [Gateway] gat with(nolock) on t.IdGateway = gat.IdGateway
				Where T.IdStatus = @IdStatus
				AND T.[DateOfTransfer] >= ISNULL(@BeginDate, T.[DateOfTransfer]) AND T.[DateOfTransfer] <= ISNULL(@EndDate, T.[DateOfTransfer])
				AND A.AgentState = ISNULL(@StateCode, A.AgentState)
				AND (T.[ClaimCode] LIKE @StringFilter OR A.[AgentCode] LIKE @StringFilter OR A.[AgentName] LIKE @StringFilter)
				ORDER BY T.[DateOfTransfer] ASC
			END
		END
	   ELSE
	   Select top 1500 T.IdAgent,  A.AgentCode, T.ClaimCode, A.AgentState, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName,
                     A.AgentName, T.DateOfTransfer, T.IdTransfer, T.Folio, P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName,
                     C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, T.ReviewReturned,
                     T.IdBeneficiary, T.IdCustomer, (CASE T.IdStatus WHEN 24 THEN [dbo].[fun_GetLastReview](T.IdTransfer) ELSE NULL END) as LastReview, null as IdDocumentTransfertStatus
                     ,Convert(bit,0) HasFiles,
                     0 releasedCount, t.IdGateway, gat.GatewayName
       From [Transfer] T with(nolock)
       inner join [Agent] A with(nolock) on T.IdAgent = A.IdAgent
       inner join [Customer] C with(nolock) on T.IdCustomer = C.IdCustomer
       inner join [Payer] P with(nolock) on T.IdPayer = P.IdPayer
       inner join [Status] S with(nolock) on T.IdStatus = S.IdStatus
	   inner join [Gateway] gat with(nolock) on t.IdGateway = gat.IdGateway
       Where T.IdStatus = @IdStatus
       Order by T.DateOfTransfer desc
	END
End

