--exec sp_helptext st_FindTransfersTobeCancelled


CREATE PROCEDURE [dbo].[st_FindTransfersTobeCancelled]  
	@StatusesPreselected XML,        
	@BeginDate datetime ,        
	@EndDate datetime,        
	@IdAgent int,        
	@Customer nvarchar(max),        
	@Beneficiary nvarchar(max),        
	@TransferFolio int,        
	@IdCurrency int,         
	@IdPayer int,  
	@IsMonoAgent BIT = 0  
AS        
/********************************************************************
<Author></Author>
<app>MaxiAgente</app>
<Description>Busqueda de Transferencias</Description>

<ChangeLog>
<log Date="12/13/2016" Author="mdelgado">Se agrego informacion de la ultima notificacion recibida de la transferencia buscada si es que la tiene.</log>
</ChangeLog>
*********************************************************************/


	--DECLARE @StatusesPreselected XML
	--DECLARE @BeginDate datetime = '02/24/2016'
	--DECLARE @EndDate datetime = '02/25/2046'
	--DECLARE @IdAgent int = 1240
	--DECLARE @Customer nvarchar(max)
	--DECLARE @Beneficiary nvarchar(max)
	--DECLARE @TransferFolio int = 61950
	--DECLARE @IdCurrency int       
	--DECLARE @IdPayer int
	--DECLARE @IsMonoAgent BIT = 0  
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
	  
	DECLARE @DateOfTransfer DATETIME = NULL  
	IF @IsMonoAgent = 1 AND @TransferFolio > 0  
	BEGIN  
	 SET @DateOfTransfer = DATEADD(MONTH,-1,GETDATE()) -- Mono Agent can get transfers from 1 month ago only  
	 SELECT @DateOfTransfer = [dbo].[RemoveTimeFromDatetime](@DateOfTransfer)  
	END  
	  
	DECLARE @IdUserSystem int =(select Value from GlobalAttributes where Name = 'SystemUserID')  
	  
	IF @BeginDate is not null  
		Select @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)  
	  
	IF @EndDate is not null  
		SELECT @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)  
	        
	DECLARE   @IdStatus INT
	SET @IdStatus=Null     
	        
	DECLARE @IdGenericStatusEnable int        
	SET @IdGenericStatusEnable =1        
	DECLARE @AllParametersNulls bit        
	SET @AllParametersNulls =0        
	IF (@Customer is null and @Beneficiary is null and @IdStatus is null and @TransferFolio is null and @IdCurrency is null and @IdCurrency is null and @IdPayer is null)        
	BEGIN        
	 SET @AllParametersNulls =1        
	END        
	        
	DECLARE @tStatus TABLE
		  (        
		   id INT        
		  )        
	        
	DECLARE @DocHandle INT
	DECLARE @hasStatus BIT
	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @StatusesPreselected          
	        
	INSERT INTO @tStatus(id)         
	SELECT id        
	FROM OPENXML (@DocHandle, '/statuses/status',1)         
	WITH (id int)        
	        
	EXEC sp_xml_removedocument @DocHandle        
	        
	IF EXISTS(SELECT 1 FROM @tStatus)        
	 BEGIN        
	  SET @hasStatus=1        
	 END        
	ELSE        
	 BEGIN        
	  SET @hasStatus=0        
	 END         
	  
	------------------------------------ Find in Transfer or (Transfer and TransferClosed) -------------------------  
	DECLARE  @QuickSearch BIT
	SET @QuickSearch=1      
	  
	 IF EXISTS(SELECT 1 FROM @tStatus WHERE id in (31,30,22))  
	 SET @QuickSearch=0  
	   
	 ------------------------------------ End -----------------------------------------------------------------------
	  
	IF @QuickSearch = 1 AND @hasStatus = 1
	BEGIN  
        
		SELECT DISTINCT  
			T.IdTransfer,        
			T.CustomerName,        
			T.CustomerFirstLastName,        
			T.CustomerSecondLastName,        
			T.CustomerZipcode,        
			T.CustomerCity,        
			T.CustomerState,        
			T.CustomerAddress,        
			T.CustomerPhoneNumber,        
			T.CustomerCelullarNumber,        
			T.BeneficiaryName,        
			T.BeneficiaryFirstLastName,        
			T.BeneficiarySecondLastName,        
			T.BeneficiaryCountry,        
			T.BeneficiaryZipcode,        
			T.BeneficiaryState,        
			T.BeneficiaryCity,        
			T.BeneficiaryAddress,        
			T.BeneficiaryPhoneNumber,        
			T.BeneficiaryCelularNumber,
			CASE        
				WHEN T.IdAgentSchema IS NOT NULL THEN A.SchemaName        
				WHEN T.IdCountryCurrency IS NOT NULL THEN A1.SchemaName          
			END SchemaName,--Nullable        
			P.PaymentName,        
			Py.PayerName,        
			Br.BranchName,--Nullable        
			Ci.CityName,--Nullable        
			S.StateName,--Nullable        
			T.ExRate,        
			--T.CorporateCommission+ T.AgentCommission Commission,        
			T.Fee Commission,    
			T.AmountInDollars,        
			T.AmountInMN,        
			--T.CorporateCommission+ T.AgentCommission+T.AmountInDollars Total,        
			T.Fee+T.AmountInDollars Total,  
			T.DateOfTransfer,        
			T.Folio,        
			St.StatusName,        
			T.DepositAccountNumber,        
			T.IdAgent,  
			T.ClaimCode,  
			-- dbo.fun_GetTransferHoldSemaphore(T.IdTransfer) as Semaphore,           
			CASE   
			WHEN TH1.IdStatus = 3  THEN 'S,G' --Signature Hold  
			ELSE '' END  
				+ '|' +  	
				CASE   
				WHEN TH1.IdStatus = 6  THEN 'A,B' --AR Hold  
				ELSE '' END  
				+ '|' +  
				CASE   
				WHEN TH1.IdStatus = 9  THEN 'K,R' --KYC Hold  
				ELSE '' END  
				+ '|' +  
				CASE   
				WHEN TH1.IdStatus = 12  THEN 'D,R' --Deny List Hold  
				ELSE '' END  
				+ '|' +  
				CASE   
				WHEN TH1.IdStatus = 15  THEN 'O,R' --OFAC Hold  
				ELSE '' END
				+ '|' +  
				CASE   
				WHEN TH1.IdStatus = 18  THEN 'DP,T' --OFAC Hold  
				ELSE '' END
			AS Semaphore,  
			cc.idcountry,  
			isnull(TN.Note, isnull(RC.Reason, '')) as Reason,  
			CASE   
				WHEN t.idstatus = 31 then T.AmountInDollars+T.Fee + Isnull(SF.Tax,0)
				WHEN DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange)<=30 then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0)                   
				WHEN TNR.IdTransfer is not null then T.AmountInDollars+T.Fee + Isnull(SF.Tax,0)         
			ELSE
				CASE (rc.returnallcomission)   
					WHEN 1 then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0)   
				ELSE T.AmountInDollars                
				END
			END  
			AS Accredited,  
			isnull(RC.ReasonEn, '') as ReasonEn,  
			TN.EnterDate as ReasonDate  
			, AT.[AccountTypeName]  
			,Hold.EnterDate
			,ISNULL(Hold.RawMessage,'') AS RawMessage,
			T.Discount,
			cpm.PaymentMethod,
			(T.AmountInDollars + T.Fee + ISNULL(T.StateTax, 0) - T.Discount) TotalAmountPaid,
			CASE WHEN T.IdStatus = 1 THEN 0 ELSE 1 END AllowPrintReceipt
			FROM [dbo].[Transfer] T WITH (NOLOCK)    
			JOIN PaymentMethod cpm WITH(NOLOCK) ON cpm.IdPaymentMethod = ISNULL(T.IdPaymentMethod, 1)
			LEFT JOIN [dbo].[TransferHolds] TH1  on T.IdTransfer = TH1.IdTransfer and TH1.IdStatus = 3 and TH1.IsReleased is null and T.IdStatus = 41   
			LEFT JOIN [dbo].[TransferHolds] TH2  on T.IdTransfer = TH2.IdTransfer and TH2.IdStatus in (9) and TH2.IsReleased is null and T.IdStatus = 41   
			LEFT JOIN [dbo].[TransferHolds] TH3  on T.IdTransfer = TH3.IdTransfer and TH3.IdStatus in (12) and TH3.IsReleased is null and T.IdStatus = 41   
			LEFT JOIN [dbo].[TransferHolds] TH4  on T.IdTransfer = TH4.IdTransfer and TH4.IdStatus in (15) and TH4.IsReleased is null and T.IdStatus = 41   
			LEFT JOIN [dbo].[TransferHolds] TH5  on T.IdTransfer = TH5.IdTransfer and TH5.IdStatus in (6) and TH5.IsReleased is null and T.IdStatus = 41     
			LEFT JOIN [dbo].[AgentSchema] A  on A.IdAgentSchema=T.IdAgentSchema        
			LEFT JOIN
						(        
						 SELECT A.IdCountryCurrency, MIN(A.IdAgentSchema) IdAgentSchema         
						 FROM AgentSchema A          
						 WHERE A.IdGenericStatus = @IdGenericStatusEnable        
						 GROUP BY A.IdCountryCurrency        
						)AC ON AC.IdCountryCurrency = T.IdCountryCurrency        
			LEFT JOIN AgentSchema A1  on A1.IdAgentSchema = AC.IdAgentSchema        
			INNER JOIN PaymentType P  on P.IdPaymentType = T.IdPaymentType        
			INNER JOIN Payer Py  on Py.IdPayer = T.IdPayer        
			INNER JOIN CountryCurrency CC  on CC.IdCountryCurrency =T.IdCountryCurrency        
			LEFT JOIN dbo.Branch Br  on Br.IdBranch =T.IdBranch        
			LEFT JOIN dbo.City Ci  on Ci.IdCity = Br.IdCity         
			LEFT JOIN dbo.State S  on S.IdState = Ci.IdState         
			INNER JOIN Status St  on St.IdStatus = T.IdStatus
			LEFT JOIN transferdetail TD WITH(NOLOCK) on TD.idtransfer = T.idtransfer and TD.idstatus = 31   
			LEFT JOIN transfernote TN WITH(NOLOCK) on TN.idtransferdetail = TD.idtransferdetail and TN.IdUser != @IdUserSystem  
			LEFT JOIN reasonforcancel RC on RC.idreasonforcancel = T.idreasonforcancel  
			LEFT JOIN TransferNotAllowedResend TNR on TNR.IdTransfer = T.IdTransfer   
			LEFT JOIN StateFee SF on SF.IdTransfer = T.IdTransfer  
			LEFT JOIN [dbo].[AccountType] AT WITH (NOLOCK) ON AT.[AccountTypeId] = T.[AccountTypeId]
			LEFT JOIN 
						(
							SELECT TD.IdTransfer,TN.EnterDate, MSG.RAWMESSAGE, TN.IdTransferNote, TNN.IdGenericStatus
							FROM TRANSFERDETAIL TD WITH(NOLOCK)
							LEFT JOIN TRANSFERNOTE TN ON TN.IdTransferDetail = TD.IdTransferDetail AND
											TN.EnterDate = 
												(
													SELECT ISNULL(MAX(EnterDate),GETDATE() ) 
													FROM TRANSFERNOTE tu 
													INNER JOIN TRANSFERNOTENOTIFICATION TNN ON TNN.IdTransferNote = tu.IdTransferNote 
													WHERE tu.IdTransferDetail = TD.IdTransferDetail  AND TNN.IdGenericStatus = 1
												)
							INNER JOIN TRANSFERNOTENOTIFICATION TNN ON TNN.IdTransferNote = TN.IdTransferNote 
							INNER JOIN MSG.MESSAGES MSG ON MSG.IdMessage = TNN.IdMessage							
						) AS Hold ON Hold.IdTransfer = T.IdTransfer AND hold.IdGenericStatus = 1
		WHERE
			T.[DateOfTransfer] >= ISNULL(@DateOfTransfer,T.[DateOfTransfer]) AND
			T.IdAgent =@IdAgent and T.DateStatusChange>= isnull(@BeginDate,T.DateStatusChange) and T.DateStatusChange<= isnull(@EndDate,T.DateStatusChange) AND
			(@hasStatus = 0 OR (T.IdStatus in (select id from @tStatus) ) ) AND
			(
				@AllParametersNulls = 1 OR
				( 
					T.IdStatus= @IdStatus   or        
					T.Folio = @TransferFolio or        
					CC.IdCurrency = @IdCurrency or        
					T.IdPayer = @IdPayer or        
					(
						@Customer is not null and 
						(
							T.CustomerName = @Customer or 
							T.CustomerFirstLastName = @Customer or 
							T.CustomerSecondLastName = @Customer
						)
					) or        
					(
						@Beneficiary is not null and 
						(
							T.BeneficiaryName = @Beneficiary or 
							T.BeneficiaryFirstLastName = @Beneficiary or 
							T.BeneficiarySecondLastName = @Beneficiary
						)
					)        
				)        
			)  
		ORDER BY DateOfTransfer DESC
	
	END
	ELSE
	BEGIN
	
		SELECT DISTINCT   
			T.IdTransfer,        
			T.CustomerName,        
			T.CustomerFirstLastName,        
			T.CustomerSecondLastName,        
			T.CustomerZipcode,        
			T.CustomerCity,        
			T.CustomerState,        
			T.CustomerAddress,        
			T.CustomerPhoneNumber,        
			T.CustomerCelullarNumber,        
			T.BeneficiaryName,        
			T.BeneficiaryFirstLastName,        
			T.BeneficiarySecondLastName,        
			T.BeneficiaryCountry,        
			T.BeneficiaryZipcode,        
			T.BeneficiaryState,        
			T.BeneficiaryCity,        
			T.BeneficiaryAddress,        
			T.BeneficiaryPhoneNumber,        
			T.BeneficiaryCelularNumber,        
			CASE        
				WHEN T.IdAgentSchema IS NOT NULL THEN A.SchemaName        
				WHEN T.IdCountryCurrency IS NOT NULL THEN A1.SchemaName          
			END SchemaName,--Nullable        
			P.PaymentName,        
			Py.PayerName,        
			Br.BranchName,--Nullable        
			Ci.CityName,--Nullable        
			S.StateName,--Nullable        
			T.ExRate,        
			--T.CorporateCommission+ T.AgentCommission Commission,        
			T.Fee Commission,    
			T.AmountInDollars,        
			T.AmountInMN,        
			--T.CorporateCommission+ T.AgentCommission+T.AmountInDollars Total,        
			T.Fee+T.AmountInDollars Total,  
			T.DateOfTransfer,        
			T.Folio,        
			St.StatusName,        
			T.DepositAccountNumber,        
			T.IdAgent,  
			T.ClaimCode,  
			--dbo.fun_GetTransferHoldSemaphore(T.IdTransfer) as Semaphore           
			CASE   
				WHEN TH1.IdStatus =3  THEN 'S,G' --Signature Hold  
				ELSE '' END
				+ '|' +  
				CASE   
				WHEN TH1.IdStatus =6  THEN 'A,B' --AR Hold  
				ELSE '' END
				+ '|' +    
				CASE   
				WHEN TH1.IdStatus =9  THEN 'K,R' --KYC Hold  
				ELSE '' END
				+ '|' +    
				CASE   
				WHEN TH1.IdStatus =12  THEN 'D,R' --Deny List Hold  
				ELSE '' END
				+ '|' +    
				CASE   
				WHEN TH1.IdStatus =15  THEN 'O,R' --OFAC Hold  
				ELSE '' END
				+ '|' +   
				CASE   
				WHEN TH1.IdStatus =18  THEN 'DP,T' --OFAC Hold  
				ELSE '' END  
			AS Semaphore,  
			cc.idcountry,  
			ISNULL(TN.Note, isnull(RC.Reason, '')) as Reason,  
			CASE   
				WHEN t.idstatus = 31 then T.AmountInDollars+T.Fee + Isnull(SF.Tax,0)  
				WHEN DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange)<=30 then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0)                   
				WHEN TNR.IdTransfer is not null then T.AmountInDollars+T.Fee + Isnull(SF.Tax,0)         
			ELSE
				CASE(rc.returnallcomission)   
					WHEN 1 then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0)   
				ELSE T.AmountInDollars                
				END
			END  
			AS Accredited,  
			ISNULL(RC.ReasonEn, '') as ReasonEn,  
			TN.EnterDate as ReasonDate,
			AT.[AccountTypeName]  
			,Hold.EnterDate
			,ISNULL(Hold.RawMessage,'') AS RawMessage,
			T.Discount,
			cpm.PaymentMethod,
			(T.AmountInDollars + T.Fee + ISNULL(SF.Tax, 0) - T.Discount) TotalAmountPaid,
			CASE WHEN T.IdStatus = 1 THEN 0 ELSE 1 END AllowPrintReceipt
		FROM [dbo].[Transfer] T     
			JOIN PaymentMethod cpm WITH(NOLOCK) ON cpm.IdPaymentMethod = ISNULL(T.IdPaymentMethod, 1)
			LEFT JOIN [TransferHolds] TH1 on T.IdTransfer = TH1.IdTransfer and TH1.IdStatus =3 and TH1.IsReleased is null and T.IdStatus = 41   
			LEFT JOIN [TransferHolds] TH2 on T.IdTransfer = TH2.IdTransfer and TH2.IdStatus in (9) and TH2.IsReleased is null and T.IdStatus = 41   
			LEFT JOIN [TransferHolds] TH3 on T.IdTransfer = TH3.IdTransfer and TH3.IdStatus in (12) and TH3.IsReleased is null and T.IdStatus = 41   
			LEFT JOIN [TransferHolds] TH4 on T.IdTransfer = TH4.IdTransfer and TH4.IdStatus in (15) and TH4.IsReleased is null and T.IdStatus = 41   
			LEFT JOIN [TransferHolds] TH5  on T.IdTransfer = TH5.IdTransfer and TH5.IdStatus in (6) and TH5.IsReleased is null and T.IdStatus = 41     
			LEFT JOIN AgentSchema A on A.IdAgentSchema=T.IdAgentSchema        
			LEFT JOIN 
						(        
							SELECT A.IdCountryCurrency, MIN(A.IdAgentSchema) IdAgentSchema         
							FROM AgentSchema A          
							WHERE A.IdGenericStatus = @IdGenericStatusEnable        
							GROUP BY A.IdCountryCurrency        
						) AC on AC.IdCountryCurrency =T.IdCountryCurrency        
			LEFT JOIN AgentSchema A1  on A1.IdAgentSchema=AC.IdAgentSchema        
			INNER JOIN PaymentType P  on P.IdPaymentType= T.IdPaymentType        
			INNER JOIN Payer Py on Py.IdPayer =T.IdPayer        
			INNER JOIN CountryCurrency CC on CC.IdCountryCurrency =T.IdCountryCurrency        
			LEFT JOIN dbo.Branch Br on Br.IdBranch =T.IdBranch        
			LEFT JOIN dbo.City Ci on Ci.IdCity =Br.IdCity         
			LEFT JOIN dbo.State S on S.IdState = Ci.IdState         
			INNER JOIN Status St on St.IdStatus = T.IdStatus
			LEFT JOIN transferdetail TD WITH(NOLOCK) on TD.idtransfer = T.idtransfer and TD.idstatus = 31  
			LEFT JOIN transfernote TN WITH(NOLOCK) on TN.idtransferdetail = TD.idtransferdetail and TN.IdUser != @IdUserSystem  
			LEFT JOIN reasonforcancel RC on RC.idreasonforcancel = T.idreasonforcancel  
			LEFT JOIN TransferNotAllowedResend TNR on TNR.IdTransfer =T.IdTransfer  
			LEFT JOIN StateFee SF on SF.IdTransfer=T.IdTransfer  
			LEFT JOIN [dbo].[AccountType] AT WITH (NOLOCK) ON AT.[AccountTypeId] = T.[AccountTypeId]  
			LEFT JOIN
						(
							SELECT TD.IdTransfer,TN.EnterDate, MSG.RAWMESSAGE, TN.IdTransferNote, TNN.IdGenericStatus
							FROM TRANSFERDETAIL TD WITH(NOLOCK)
							LEFT JOIN TRANSFERNOTE TN ON TN.IdTransferDetail = TD.IdTransferDetail AND
											TN.EnterDate = 
												(
													SELECT ISNULL(MAX(EnterDate),GETDATE() ) 
													FROM TRANSFERNOTE tu 
													INNER JOIN TRANSFERNOTENOTIFICATION TNN ON TNN.IdTransferNote = tu.IdTransferNote 
													WHERE tu.IdTransferDetail = TD.IdTransferDetail  AND TNN.IdGenericStatus = 1
												)
							INNER JOIN TRANSFERNOTENOTIFICATION TNN ON TNN.IdTransferNote = TN.IdTransferNote 
							INNER JOIN MSG.MESSAGES MSG ON MSG.IdMessage = TNN.IdMessage							
						) AS Hold ON Hold.IdTransfer = T.IdTransfer AND hold.IdGenericStatus = 1
		WHERE
			T.[DateOfTransfer] >= ISNULL(@DateOfTransfer,T.[DateOfTransfer]) AND  
			T.IdAgent =@IdAgent and T.DateStatusChange>= isnull(@BeginDate,T.DateStatusChange) and T.DateStatusChange<= isnull(@EndDate,T.DateStatusChange) and         
			(
				@hasStatus = 0 or 
				(T.IdStatus in (select id from @tStatus) )  
			) AND
			(
				@AllParametersNulls = 1 or        
				( 
					T.IdStatus = @IdStatus or        
					T.Folio = @TransferFolio or        
					CC.IdCurrency = @IdCurrency or        
					T.IdPayer = @IdPayer or        
					(
						@Customer is not null and 
						(
							T.CustomerName = @Customer or 
							T.CustomerFirstLastName = @Customer or 
							T.CustomerSecondLastName = @Customer
						)
					) or        
					(
						@Beneficiary is not null and 
						(
							T.BeneficiaryName = @Beneficiary or 
							T.BeneficiaryFirstLastName = @Beneficiary or 
							T.BeneficiarySecondLastName = @Beneficiary
						)
					)        
				)        
			)
	               
		UNION
	        
			SELECT DISTINCT   
				T.IdTransferClosed IdTransfer,        
				T.CustomerName,        
				T.CustomerFirstLastName,        
				T.CustomerSecondLastName,        
				T.CustomerZipcode,        
				T.CustomerCity,        
				T.CustomerState,        
				T.CustomerAddress,        
				T.CustomerPhoneNumber,        
				T.CustomerCelullarNumber,        
				T.BeneficiaryName,        
				T.BeneficiaryFirstLastName,        
				T.BeneficiarySecondLastName,        
				T.BeneficiaryCountry,        
				T.BeneficiaryZipcode,        
				T.BeneficiaryState,        
				T.BeneficiaryCity,        
				T.BeneficiaryAddress,        
				T.BeneficiaryPhoneNumber,        
				T.BeneficiaryCelularNumber,        
				CASE        
					WHEN T.IdAgentSchema IS NOT NULL THEN T.SchemaName        
					WHEN T.IdCountryCurrency IS NOT NULL THEN A1.SchemaName          
				END SchemaName,--Nullable        
				T.PaymentTypeName,        
				T.PayerName,        
				Br.BranchName,--Nullable        
				Ci.CityName,--Nullable        
				S.StateName,--Nullable        
				T.ExRate,        
				--T.CorporateCommission+ T.AgentCommission Commission,   
				T.Fee Commission,         
				T.AmountInDollars,        
				T.AmountInMN,        
				--T.CorporateCommission+ T.AgentCommission+T.AmountInDollars Total,        
				T.Fee+T.AmountInDollars Total,  
				T.DateOfTransfer,        
				T.Folio,        
				T.StatusName,         
				T.DepositAccountNumber,        
				T.IdAgent,  
				T.ClaimCode,  
				'0|0|0|0|0|0' as Semaphore,     
				T.idcountry,  
				isnull(TN.Note, isnull(RC.Reason, '')) as Reason,  
				CASE   
					WHEN t.idstatus = 31 then T.AmountInDollars+T.Fee + Isnull(SF.Tax,0)  
					WHEN DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange)<=30 then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0)                   
					WHEN TNR.IdTransfer is not null then T.AmountInDollars+T.Fee + Isnull(SF.Tax,0)         
				ELSE              
					CASE (rc.returnallcomission)   
						WHEN 1 THEN  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0)   
					ELSE T.AmountInDollars                
					END  
				END  
				AS Accredited,  
				ISNULL(RC.ReasonEn, '') as ReasonEn,  
				TN.EnterDate as ReasonDate,
				AT.[AccountTypeName]
				,Hold.EnterDate
				,ISNULL(Hold.RawMessage,'') AS RawMessage,
				T.Discount,
				cpm.PaymentMethod,
				(T.AmountInDollars + T.Fee + ISNULL(SF.Tax, 0) - T.Discount) TotalAmountPaid,
				CASE WHEN T.IdStatus = 1 THEN 0 ELSE 1 END AllowPrintReceipt
			FROM [dbo].TransferClosed T     
				JOIN PaymentMethod cpm WITH(NOLOCK) ON cpm.IdPaymentMethod = ISNULL(T.IdPaymentMethod, 1)
				LEFT JOIN         
						(        
							SELECT A.IdCountryCurrency, MIN(A.IdAgentSchema) IdAgentSchema         
							FROM AgentSchema A         
							WHERE A.IdGenericStatus = @IdGenericStatusEnable        
							GROUP BY A.IdCountryCurrency        
						)AC ON AC.IdCountryCurrency = T.IdCountryCurrency        
				LEFT JOIN AgentSchema A1 on A1.IdAgentSchema = AC.IdAgentSchema        
				LEFT JOIN dbo.Branch Br on Br.IdBranch = T.IdBranch        
				LEFT JOIN dbo.City Ci on Ci.IdCity = Br.IdCity         
				LEFT JOIN dbo.State S on Ci.IdState = S.IdState
				LEFT JOIN TransferClosedDetail TD on TD.IdTransferClosed = T.IdTransferClosed and TD.idstatus = 31  
				LEFT JOIN TransferClosedNote TN on TN.IdTransferClosedDetail = TD.IdTransferClosedDetail and TN.IdUser != @IdUserSystem  
				LEFT JOIN reasonforcancel RC on RC.idreasonforcancel = T.idreasonforcancel  
				LEFT JOIN TransferNotAllowedResend TNR on TNR.IdTransfer =T.IdTransferClosed  
				LEFT JOIN StateFee SF on SF.IdTransfer=T.IdTransferClosed  
				LEFT JOIN [dbo].[AccountType] AT WITH (NOLOCK) ON AT.[AccountTypeId] = T.[AccountTypeId]  
				LEFT JOIN 
						(
							SELECT TD.IdTransfer,TN.EnterDate, MSG.RAWMESSAGE, TN.IdTransferNote, TNN.IdGenericStatus
							FROM TRANSFERDETAIL TD WITH(NOLOCK)
							LEFT JOIN TRANSFERNOTE TN ON TN.IdTransferDetail = TD.IdTransferDetail AND
											TN.EnterDate = 
												(
													SELECT ISNULL(MAX(EnterDate),GETDATE() ) 
													FROM TRANSFERNOTE tu 
													INNER JOIN TRANSFERNOTENOTIFICATION TNN ON TNN.IdTransferNote = tu.IdTransferNote 
													WHERE tu.IdTransferDetail = TD.IdTransferDetail  AND TNN.IdGenericStatus = 1
												)
							INNER JOIN TRANSFERNOTENOTIFICATION TNN ON TNN.IdTransferNote = TN.IdTransferNote 
							INNER JOIN MSG.MESSAGES MSG ON MSG.IdMessage = TNN.IdMessage							
						) AS Hold ON Hold.IdTransfer = T.IdTransferClosed AND hold.IdGenericStatus = 1
	  
			WHERE  
				T.[DateOfTransfer] >= ISNULL(@DateOfTransfer,T.[DateOfTransfer]) AND  
				T.IdAgent = @IdAgent AND 
				T.DateStatusChange >= isnull(@BeginDate,T.DateStatusChange) AND
				T.DateStatusChange <= isnull(@EndDate,T.DateStatusChange) AND         
				(
					@hasStatus = 0 OR 
					(T.IdStatus IN (SELECT id FROM @tStatus) )
				) AND        
				(
					@AllParametersNulls = 1 OR
					( 
						T.IdStatus= @IdStatus OR
						T.Folio = @TransferFolio OR
						T.IdCurrency = @IdCurrency OR
						T.IdPayer = @IdPayer or        
						(
							@Customer IS NOT NULL AND 
							(
								T.CustomerName = @Customer OR 
								T.CustomerFirstLastName = @Customer OR
								T.CustomerSecondLastName = @Customer
							)
						) OR
						(
							@Beneficiary IS NOT NULL AND 
							(
								T.BeneficiaryName = @Beneficiary OR 
								T.BeneficiaryFirstLastName = @Beneficiary OR
								T.BeneficiarySecondLastName = @Beneficiary
							)
						)        
					)        
				)        
			ORDER BY DateOfTransfer DESC
	END
