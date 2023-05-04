CREATE PROCEDURE [Corp].[st_KYCAnalysisReport] (
             @DateFrom DATETIME,
             @DateTo DATETIME,
             @SearchType INT = 1,
             @Satatus INT= NULL,
             @Agent INT= NULL,
             @Gateway INT= NULL,
             @Country INT = NULL,
             @ClaimCode NVARCHAR (80)= NULL,
             @Folio INT= NULL,
             @Payer INT= NULL,
             @SenderLastName NVARCHAR (80)= NULL,
             @BeneficiaryLastName NVARCHAR (80)= NULL,
             @VIPCard NVARCHAR(20)= NULL,
             @Amount MONEY = 600
             ,@HasError BIT OUT
             ,@Message NVARCHAR(max) OUT
             ,@DateAgentOpenFrom datetime = null
             ,@DateAgentOpenTo datetime = null
)
AS
BEGIN


	--DECLARE @DateFrom DATETIME = '20160901'
	--DECLARE @DateTo DATETIME = '20160930'
	--DECLARE @SearchType INT = 1
	--DECLARE @Satatus INT= NULL
	--DECLARE @Agent INT= NULL
	--DECLARE @Gateway INT= NULL
	--DECLARE @Country INT = NULL
	--DECLARE @ClaimCode NVARCHAR (80)= NULL
	--DECLARE @Folio INT= NULL
	--DECLARE @Payer INT= NULL
	--DECLARE @SenderLastName NVARCHAR (80)= NULL
	--DECLARE @BeneficiaryLastName NVARCHAR (80)= NULL
	--DECLARE @VIPCard NVARCHAR(20)= NULL
	--DECLARE @Amount MONEY = 0
	--DECLARE @HasError BIT 
	--DECLARE @Message NVARCHAR(max) 
	--DECLARE @DateAgentOpenFrom datetime = NULL
	--DECLARE @DateAgentOpenTo datetime = NULL

	--SET NOCOUNT ON;
	--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SET @HasError = 0
	SET @Message = ''

	SELECT @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
	SELECT @DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)

	IF (@DateAgentOpenFrom) IS NOT NULL AND (@DateAgentOpenTo) IS NOT NULL 
	BEGIN
		SELECT @DateAgentOpenFrom=dbo.RemoveTimeFromDatetime(@DateAgentOpenFrom)
		SELECT @DateAgentOpenTo=dbo.RemoveTimeFromDatetime(@DateAgentOpenTo)
	END
	ELSE
	BEGIN
		SELECT @DateAgentOpenFrom=null
		SELECT @DateAgentOpenTo=null
	END

	DECLARE @q1 INT, @q2 INT

	IF (@SearchType = 1)
	BEGIN

		SELECT @q1=count(1) 
		FROM Transfer T (NOLOCK)
				 JOIN [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
				 JOIN [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
				 JOIN [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
				 JOIN [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
				 JOIN [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
			LEFT JOIN [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
			LEFT JOIN [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
			LEFT JOIN [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
			LEFT JOIN [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
			LEFT JOIN [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
			LEFT JOIN [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransfer AND TPI.IdTransferPayInfo = (SELECT MAX(tt.IdTransferPayInfo) FROM TransferPayInfo tt WHERE tt.IdTransfer =T.IdTransfer)
			LEFT JOIN branch d (NOLOCK) ON d.IdBranch= CASE WHEN tpi.idtransfer IS NOT NULL THEN tpi.idbranch ELSE 0 END
			LEFT JOIN City E With(Nolock) ON (E.IdCity=D.IdCity)
			LEFT JOIN State F With(Nolock) ON (F.IdState=E.IdState)
			LEFT JOIN payer p1  (NOLOCK) ON d.idpayer=p1.idpayer
			LEFT JOIN [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
			LEFT JOIN CardVIP CV (NOLOCK) ON CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1
		WHERE 
			T.IdStatus = ISNULL(@Satatus,t.idstatus) AND
			T.IdAgent = ISNULL(@Agent,t.idagent) AND
			CC.IdCountry = ISNULL(@Country, CC.IdCountry) AND
			T.ClaimCode = ISNULL(@ClaimCode,T.ClaimCode) AND
			T.Folio = ISNULL(@Folio,T.Folio) AND
			T.IdAgent = ISNULL(@Agent,T.IdAgent) AND
			T.IdPayer = ISNULL(@Payer,T.idpayer) AND
			T.CustomerFirstLastName like '%' + ISNULL(@SenderLastName,'') + '%' AND
			T.BeneficiaryFirstLastName like '%' + ISNULL(@BeneficiaryLastName,'') + '%' AND
			ISNULL(CV.CardNumber,'') like '%' + ISNULL(@VIPCard,'') + '%' AND
			T.AmountInDollars >= ISNULL(@Amount,T.AmountInDollars) AND
			T.IdGateway = ISNULL(@Gateway,T.Idgateway) AND 
			dbo.RemoveTimeFromDatetime(ISNULL(A.opendate,'')) >= dbo.RemoveTimeFromDatetime(ISNULL(@DateAgentOpenFrom,dbo.RemoveTimeFromDatetime(ISNULL(A.opendate,'')))) AND 
			dbo.RemoveTimeFromDatetime(A.opendate)<=dbo.RemoveTimeFromDatetime(ISNULL(@DateAgentOpenTo,dbo.RemoveTimeFromDatetime(ISNULL(A.opendate,'')))) AND
			T.DateOfTransfer>=@DateFrom AND 
			T.DateOfTransfer <= @DateTo        

		SELECT @q2 =count(1)
		FROM TransferCLosed T (NOLOCK)
				 JOIN [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
				 JOIN [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
				 JOIN [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
				 JOIN [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
				 JOIN [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
			LEFT JOIN [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
			LEFT JOIN [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
			LEFT JOIN [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
			LEFT JOIN [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
			LEFT JOIN [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
			LEFT JOIN [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransferclosed AND TPI.IdTransferPayInfo = (SELECT MAX(tt.IdTransferPayInfo) FROM TransferPayInfo tt WHERE tt.IdTransfer = T.IdTransferclosed)
			LEFT JOIN branch d  (NOLOCK) on d.IdBranch = CASE WHEN tpi.idtransfer IS NOT NULL THEN tpi.idbranch ELSE 0 END
			LEFT JOIN City E With(Nolock) on (E.IdCity = D.IdCity)
			LEFT JOIN State  F With(Nolock) on (F.IdState = E.IdState)
			LEFT JOIN payer p1  (NOLOCK)on d.idpayer = p1.idpayer
			LEFT JOIN [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
			LEFT JOIN CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1       
       WHERE 
			T.IdStatus = ISNULL(@Satatus,t.idstatus) AND
			T.IdAgent = ISNULL(@Agent,t.idagent) AND
			CC.IdCountry = ISNULL(@Country, CC.IdCountry) AND
			T.ClaimCode = ISNULL(@ClaimCode,T.ClaimCode) AND
			T.Folio = ISNULL(@Folio,T.Folio) AND
			T.IdAgent = ISNULL(@Agent,T.IdAgent) AND
			T.IdPayer = ISNULL(@Payer,T.idpayer) AND
			T.CustomerFirstLastName like '%' + ISNULL(@SenderLastName,'') + '%' AND
			T.BeneficiaryFirstLastName like '%' + ISNULL(@BeneficiaryLastName,'') + '%' AND
			ISNULL(CV.CardNumber,'') like '%' + ISNULL(@VIPCard,'') + '%' AND
			T.AmountInDollars >= ISNULL(@Amount,T.AmountInDollars) AND
			T.IdGateway = ISNULL(@Gateway,T.Idgateway) AND 
			dbo.RemoveTimeFromDatetime(ISNULL(A.opendate,'')) >= dbo.RemoveTimeFromDatetime(ISNULL(@DateAgentOpenFrom,dbo.RemoveTimeFromDatetime(ISNULL(A.opendate,'')))) AND 
			dbo.RemoveTimeFromDatetime(A.opendate)<=dbo.RemoveTimeFromDatetime(ISNULL(@DateAgentOpenTo,dbo.RemoveTimeFromDatetime(ISNULL(A.opendate,'')))) AND
			T.DateOfTransfer>=@DateFrom AND 
			T.DateOfTransfer <= @DateTo        

	END --IF (@SearchType = 1)
	ELSE
	BEGIN

		SELECT @q1 = COUNT(DISTINCT t.idtransfer)
			FROM Transfer T (NOLOCK)
				 JOIN [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
				 JOIN [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
				 JOIN [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
				 JOIN [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
				 JOIN [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
			LEFT JOIN [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
			LEFT JOIN [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
			LEFT JOIN [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
			LEFT JOIN [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
			LEFT JOIN [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
			LEFT JOIN [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransfer AND TPI.IdTransferPayInfo = (SELECT MAX(tt.IdTransferPayInfo) FROM TransferPayInfo tt WHERE tt.IdTransfer = T.IdTransfer)
			LEFT JOIN branch d  (NOLOCK) ON d.IdBranch = CASE WHEN tpi.idtransfer IS NOT NULL THEN tpi.idbranch ELSE 0 END
			LEFT JOIN City E With(Nolock) ON (E.IdCity = D.IdCity)
			LEFT JOIN State F With(Nolock) ON (F.IdState = E.IdState)
			LEFT JOIN payer p1  (NOLOCK) ON d.idpayer = p1.idpayer
			LEFT JOIN [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
			LEFT JOIN CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer AND CV.IdGenericStatus = 1       
       WHERE 
			T.IdStatus=isnull(@Satatus,t.idstatus) and
			T.IdAgent=isnull(@Agent,t.idagent) and
			T.ClaimCode=isnull(@ClaimCode,T.ClaimCode) and
			T.Folio=isnull(@Folio,T.Folio) and
			T.IdAgent=isnull(@Agent,T.IdAgent) and
			T.IdPayer=isnull(@Payer,T.idpayer) and
			T.CustomerFirstLastName like '%'+isnull(@SenderLastName,'')+'%' and
			T.BeneficiaryFirstLastName like '%'+isnull(@BeneficiaryLastName,'')+'%' and
			T.AmountInDollars>=isnull(@Amount,T.AmountInDollars) and
			T.IdGateway=isnull(@Gateway,T.Idgateway)  and 
			T.DateStatusChange>=@DateFrom and  
			T.DateStatusChange<=@DateTo and
			dbo.RemoveTimeFromDatetime(isnull(A.opendate,'')) >= dbo.RemoveTimeFromDatetime(isnull(@DateAgentOpenFrom,dbo.RemoveTimeFromDatetime(isnull(A.opendate,'')))) and 
			dbo.RemoveTimeFromDatetime(A.opendate) <= dbo.RemoveTimeFromDatetime(isnull(@DateAgentOpenTo,dbo.RemoveTimeFromDatetime(isnull(A.opendate,'')))) and
			isnull(CV.CardNumber,'') like '%'+isnull(@VIPCard,'')+'%' and
			CC.IdCountry = isnull(@Country, CC.IdCountry) 

		SELECT @q2 = count(1) 
		FROM TransferCLosed T (NOLOCK)
				 JOIN [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
				 JOIN [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
				 JOIN [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
				 JOIN [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
				 JOIN [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
			LEFT JOIN [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
			LEFT JOIN [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
			LEFT JOIN [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
			LEFT JOIN [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
			LEFT JOIN [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
			LEFT JOIN [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransferclosed and TPI.IdTransferPayInfo = (SELECT MAX(tt.IdTransferPayInfo) FROM TransferPayInfo tt WHERE tt.IdTransfer = T.IdTransferclosed)
			LEFT JOIN branch d  (NOLOCK) ON d.IdBranch = CASE WHEN tpi.idtransfer IS NOT NULL THEN tpi.idbranch ELSE 0 END
			LEFT JOIN City E With(Nolock) ON (E.IdCity = D.IdCity)
			LEFT JOIN State  F With(Nolock) ON (F.IdState = E.IdState)
			LEFT JOIN payer p1  (NOLOCK) ON d.idpayer = p1.idpayer
			LEFT JOIN [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
			LEFT JOIN CardVIP CV (NOLOCK) ON CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1       
		WHERE 
			T.IdStatus = ISNULL(@Satatus,t.idstatus) AND
			T.IdAgent = ISNULL(@Agent,t.idagent) AND
			CC.IdCountry = ISNULL(@Country, CC.IdCountry) AND
			T.ClaimCode = ISNULL(@ClaimCode,T.ClaimCode) AND
			T.Folio = ISNULL(@Folio,T.Folio) AND
			T.IdAgent = ISNULL(@Agent,T.IdAgent) AND
			T.IdPayer = ISNULL(@Payer,T.idpayer) AND
			T.CustomerFirstLastName LIKE '%' + ISNULL(@SenderLastName,'') + '%' AND
			T.BeneficiaryFirstLastName LIKE '%' + ISNULL(@BeneficiaryLastName,'') + '%' AND
			ISNULL(CV.CardNumber,'') LIKE '%' + ISNULL(@VIPCard,'') + '%' AND
			T.AmountInDollars> = ISNULL(@Amount,T.AmountInDollars) AND
			T.IdGateway = ISNULL(@Gateway,T.Idgateway)  and 
			dbo.RemoveTimeFromDatetime(ISNULL(A.opendate,'')) >= dbo.RemoveTimeFromDatetime(ISNULL(@DateAgentOpenFrom,dbo.RemoveTimeFromDatetime(ISNULL(A.opendate,'')))) AND
			dbo.RemoveTimeFromDatetime(A.opendate) <= dbo.RemoveTimeFromDatetime(ISNULL(@DateAgentOpenTo,dbo.RemoveTimeFromDatetime(ISNULL(A.opendate,'')))) AND
			T.DateStatusChange> = @DateFrom AND
			T.DateStatusChange <= @DateTo 

	END -- IF (@SearchType <> 1)
			
             
	IF (ISNULL(@q1,0) + ISNULL(@q2,0)) > 15000
	BEGIN
		SELECT @Message = dbo.GetMessageFromLenguajeResorces (0,34)                   
		SET @HasError=1
		RETURN
	END     
	
	PRINT ISNULL(@q1,0) + ISNULL(@q2,0)
             
	-----------------------COUNTS ends here


--- =========>>

	IF (@SearchType = 1)
	BEGIN
	WITH CTE_TRANS  AS (
		SELECT
			AmountRequiredToAskId AS AmountRequiredToAskId
			, AgentCode AS AgentCode
			, AgentZipcode AS AgentZipcode
			, T.Folio AS Folio
			, T.DateOfTransfer AS DateOfTransfer
			, T.AmountInDollars AS AmountInDollars
			, S.StatusName AS StatusName
			, T.DepositAccountNumber AS DepositAccountNumber
			, T.ClaimCode AS ClaimCode
			, T.IdCustomer AS IdCustomer
			, dbo.[fn_GetCustomerC](T.CustomerName)+dbo.[fn_GetCustomerC](T.CustomerFirstLastName)+dbo.[fn_GetCustomerC](T.CustomerSecondLastName) AS [String C]
						
			--, T.CustomerName AS CustomerName
			,CASE 
				WHEN LEN(ISNULL(T.CustomerName,'')) = 0 
				THEN CST.Name
				ELSE T.CustomerName
				END AS 'CustomerName'
			
			--, T.CustomerFirstLastName AS CustomerFirstLastName
			,CASE 
				WHEN LEN(ISNULL(T.CustomerFirstLastName,'')) = 0 
				THEN CST.FirstLastName
				ELSE T.CustomerFirstLastName
				END AS 'CustomerFirstLastName'

			--, T.CustomerSecondLastName AS CustomerSecondLastName
			,CASE 
				WHEN LEN(ISNULL(T.CustomerSecondLastName,'')) = 0 
				THEN CST.SecondLastName
				ELSE T.CustomerSecondLastName
				END AS 'CustomerSecondLastName'

			, T.CustomerAddress AS CustomerAddress
			, T.CustomerCity AS CustomerCity
			, T.CustomerState AS CustomerState
			, T.CustomerZipcode AS CustomerZipcode
			
			--, T.CustomerPhoneNumber AS CustomerPhoneNumber
			, CASE 
				WHEN LEN(ISNULL(CST.PhoneNumber,'')) > 0 
				THEN CST.PhoneNumber
				ELSE T.CustomerPhoneNumber
			  END AS 'CustomerPhoneNumber'

			--, T.CustomerCelullarNumber AS CustomerCelullarNumber
			, CASE 
				WHEN LEN(ISNULL(T.CustomerCelullarNumber,'')) = 0 
				THEN CST.CelullarNumber
				ELSE T.CustomerCelullarNumber
			  END AS 'CustomerCelullarNumber'

			, dbo.[fn_GetCustomerC](T.BeneficiaryName)+dbo.[fn_GetCustomerC](T.BeneficiaryFirstLastName)+dbo.[fn_GetCustomerC](T.BeneficiarySecondLastName) AS [String B]
			, ISNULL(T.BeneficiaryName,'') AS BeneficiaryName
			, ISNULL(T.BeneficiaryFirstLastName,'') AS BeneficiaryFirstLastName
			, ISNULL(T.BeneficiarySecondLastName,'') AS BeneficiarySecondLastName
			, ISNULL(T.BeneficiaryAddress,'') AS RecipientAddress
			, P.PayerName AS PayerName
			, T.IdBranch AS IdBranch
			, BRC.CityName AS CityName
			, BRS.StateName AS StateName
			, BRCo.CountryName AS CountryName
			, U.UserName AS UserName

			, CASE 
				WHEN CID.NAME IS NOT NULL 
				THEN ISNULL(CID.Name,'') 
				ELSE ISNULL(CIDc.Name, '')
				END  Name
	   
			,CASE 
				WHEN CID.IdCustomerIdentificationType IS NOT NULL 
				THEN 
					ISNULL(IDCo.CountryName,ISNULL(CST.Country , '')) 
				ELSE  ''
				END  IdentificationIdCountry

			, CASE 
				WHEN CID.NAME IS NOT NULL 
				THEN ISNULL(T.CustomerIdentificationNumber,'') 
				ELSE ISNULL(CST.IdentificationNumber,'')		 
				END IdentificationNumber
			
			--, ISNULL(T.CustomerSSNumber,'') AS SSNumber

			,
			CASE 
				WHEN LEN(ISNULL(T.CustomerSSNumber,'')) = 0  
				THEN ISNULL(CST.SSNumber,'') 
				ELSE ISNULL(T.CustomerSSNumber,'') 
				END SSNumber

			--, CASE 
			--	WHEN CID.NAME IS NOT NULL 
			--	THEN ISNULL(T.CustomerBornDate,'') 
			--	ELSE ISNULL(CST.BornDate,'') 
			--	END BornDate

			,CASE 
				WHEN LEN(ISNULL(CONVERT(VARCHAR(10),T.CustomerBornDate,112),'')) = 0  
				THEN CST.BornDate
				ELSE T.CustomerBornDate
				END BornDate

			--, CASE 
			--	WHEN CID.NAME IS NOT NULL 
			--	THEN ISNULL(T.CustomerOccupation,'') 
			--	ELSE ISNULL(CST.Occupation,'') 
			--	END Occupation

			,  CASE 
				WHEN LEN(ISNULL(T.CustomerOccupation,'')) = 0 
				THEN CST.Occupation
				ELSE T.CustomerOccupation
			  END AS 'Occupation'
			
			, CASE 
				WHEN t.idstatus=30 AND t.IdPaymentType in (1,4) 
				THEN CASE 
						WHEN d.idbranch is not null 
						THEN ISNULL(tpi.BranchCode,'') 
						ELSE '' 
					 END + ' ' + isnull(p1.payername,'') 
				ELSE '' 
				END BranchName    

			, CASE WHEN t.idstatus=30 AND t.IdPaymentType in (1,4) THEN TPI.DateOfPayment ELSE NULL END AS Date
			, CASE WHEN t.idstatus=30 AND t.IdPaymentType in (1,4) THEN isnull(e.CityName,'') ELSE '' END CityName1
			, CASE WHEN t.idstatus=30 AND t.IdPaymentType in (1,4) THEN isnull(f.StateName,'') ELSE '' END StateName1
			,isnull((select top 1 1 from transferdetail where idstatus in (9) and idtransfer=t.IdTransfer),0) KYCHold
			,isnull((select top 1 1 from transferdetail where idstatus in (12) and idtransfer=t.IdTransfer),0) DenyListHold
			,case
			when Exists (select top 1 1 from TransferHolds (nolock) where IdStatus=9 and IdTransfer=t.IdTransfer and IsReleased=0) then isnull(s2.StatusName,'')
			when Exists (select top 1 1 from TransferHolds (nolock) where IdStatus=12 and IdTransfer=t.IdTransfer and IsReleased=0) then isnull(s3.StatusName,'')
			else ''
			end        
			RejectedHold
			,isnull(z.CountyInfo,'') CountyInfo
			,cid.RequireSSN
			,cid.StateRequired
			,T.CustomerIdentificationIdState
		FROM Transfer T (NOLOCK)		
				 JOIN [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
				 JOIN [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
				 JOIN [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
				 JOIN [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
				 JOIN [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
			LEFT JOIN [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
			LEFT JOIN [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
			LEFT JOIN [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
			LEFT JOIN [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
			LEFT JOIN [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
			LEFT JOIN [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransfer and TPI.IdTransferPayInfo=(select max(tt.IdTransferPayInfo) from TransferPayInfo tt where tt.IdTransfer =T.IdTransfer)
			LEFT JOIN branch d (NOLOCK) on d.IdBranch= case when tpi.idtransfer is not null then tpi.idbranch else 0 end
			LEFT JOIN City E With(Nolock) on (E.IdCity=D.IdCity)
			LEFT JOIN State  F With(Nolock) on (F.IdState=E.IdState)
			LEFT JOIN payer p1 (NOLOCK) on d.idpayer=p1.idpayer
			LEFT JOIN [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType	   
			LEFT JOIN CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1
			LEFT JOIN status s2 (nolock) on 9=s2.IdStatus
			LEFT JOIN status s3 (nolock) on 12=s3.IdStatus
			LEFT JOIN
				(
					SELECT 
						SS.ZipCode,
						STUFF((
							SELECT '/' + c.CountyClassName 
							FROM RelationCountyCountyClass US
								join CountyClass c (NOLOCK) on us.IdCountyClass = c.IdCountyClass 
							WHERE US.IdCounty = SS.IdCounty
							ORDER BY c.CountyClassName 
							FOR XML PATH('')), 1, 1, '') CountyInfo
					FROM zipcode SS
					GROUP BY SS.ZipCode, SS.IdCounty    
				) z on AgentZipcode = z.ZipCode
			LEFT JOIN Customer CST (nolock) ON CST.IdCustomer = T.IdCustomer 
			LEFT JOIN [CustomerIdentificationType] CIDc (nolock) ON CIDc.IdCustomerIdentificationType = CST.IdCustomerIdentificationType -- cit IDTYPE y CUSTOMER
		WHERE 
			T.IdStatus=isnull(@Satatus,t.idstatus) and
			T.IdAgent=isnull(@Agent,t.idagent) and
			CC.IdCountry=isnull(@Country, CC.IdCountry) and
			T.ClaimCode=isnull(@ClaimCode,T.ClaimCode) and
			T.Folio=isnull(@Folio,T.Folio) and
			T.IdAgent=isnull(@Agent,T.IdAgent) and
			T.IdPayer=isnull(@Payer,T.idpayer) and
			T.CustomerFirstLastName like '%'+isnull(@SenderLastName,'')+'%' and
			T.BeneficiaryFirstLastName like '%'+isnull(@BeneficiaryLastName,'')+'%' and
			isnull(CV.CardNumber,'') like '%'+isnull(@VIPCard,'')+'%' and
			T.AmountInDollars>=isnull(@Amount,T.AmountInDollars) and
			T.IdGateway=isnull(@Gateway,T.Idgateway)  and 
			dbo.RemoveTimeFromDatetime(isnull(A.opendate,''))>=dbo.RemoveTimeFromDatetime(isnull(@DateAgentOpenFrom,dbo.RemoveTimeFromDatetime(isnull(A.opendate,'')))) and dbo.RemoveTimeFromDatetime(A.opendate)<=dbo.RemoveTimeFromDatetime(isnull(@DateAgentOpenTo,dbo.RemoveTimeFromDatetime(isnull(A.opendate,'')))) and
			T.DateOfTransfer>=@DateFrom and  T.DateOfTransfer<=@DateTo     

	UNION
	 
		SELECT
			AmountRequiredToAskId AS AmountRequiredToAskId
			, AgentCode AS AgentCode
			, AgentZipcode AS AgentZipcode
			, T.Folio AS Folio
			, T.DateOfTransfer AS DateOfTransfer
			, T.AmountInDollars AS AmountInDollars
			, S.StatusName AS StatusName
			, T.DepositAccountNumber AS DepositAccountNumber
			, T.ClaimCode AS ClaimCode
			, T.IdCustomer AS IdCustomer
			, dbo.[fn_GetCustomerC](T.CustomerName) + dbo.[fn_GetCustomerC](T.CustomerFirstLastName) + dbo.[fn_GetCustomerC](T.CustomerSecondLastName) AS [String C]
			
			--, T.CustomerName AS CustomerName
			,CASE 
				WHEN LEN(ISNULL(T.CustomerName,'')) = 0 
				THEN CST.Name
				ELSE T.CustomerName
				END AS 'CustomerName'
			
			--, T.CustomerFirstLastName AS CustomerFirstLastName
			,CASE 
				WHEN LEN(ISNULL(T.CustomerFirstLastName,'')) = 0 
				THEN CST.FirstLastName
				ELSE T.CustomerFirstLastName
				END AS 'CustomerFirstLastName'

			--, T.CustomerSecondLastName AS CustomerSecondLastName
			,CASE 
				WHEN LEN(ISNULL(T.CustomerSecondLastName,'')) = 0 
				THEN CST.SecondLastName
				ELSE T.CustomerSecondLastName
				END AS 'CustomerSecondLastName'

			, T.CustomerAddress AS CustomerAddress
			, T.CustomerCity AS CustomerCity
			, T.CustomerState AS CustomerState
			, T.CustomerZipcode AS CustomerZipcode
		
			--, T.CustomerPhoneNumber AS CustomerPhoneNumber
			, CASE 
				WHEN LEN(ISNULL(T.CustomerPhoneNumber,'')) = 0 
				THEN CST.PhoneNumber
				ELSE T.CustomerPhoneNumber
				END AS 'CustomerPhoneNumber'

			--, T.CustomerCelullarNumber AS CustomerCelullarNumber
			, CASE 
				WHEN LEN(ISNULL(T.CustomerCelullarNumber,'')) = 0 
				THEN CST.CelullarNumber
				ELSE T.CustomerCelullarNumber
				END AS 'CustomerCelullarNumber'

			, dbo.[fn_GetCustomerC](T.BeneficiaryName)+dbo.[fn_GetCustomerC](T.BeneficiaryFirstLastName)+dbo.[fn_GetCustomerC](T.BeneficiarySecondLastName) AS [String B]
			, ISNULL(T.BeneficiaryName,'') AS BeneficiaryName
			, ISNULL(T.BeneficiaryFirstLastName,'') AS BeneficiaryFirstLastName
			, ISNULL(T.BeneficiarySecondLastName,'') AS BeneficiarySecondLastName
			, ISNULL(T.BeneficiaryAddress,'') AS RecipientAddress
			, P.PayerName AS PayerName
			, T.IdBranch AS IdBranch
			, BRC.CityName AS CityName
			, BRS.StateName AS StateName
			, BRCo.CountryName AS CountryName
			, U.UserName AS UserName
			, CASE 
				WHEN CID.NAME IS NOT NULL 
				THEN ISNULL(CID.Name,'') 
				ELSE ISNULL(CIDc.Name, '')  
				END  Name
	   
			,CASE 
				WHEN CID.IdCustomerIdentificationType IS NOT NULL 
				THEN 
					ISNULL(IDCo.CountryName,ISNULL(CST.Country , '')) 
				ELSE  ''
				END  IdentificationIdCountry

			, CASE 
				WHEN CID.NAME IS NOT NULL
				THEN ISNULL(T.CustomerIdentificationNumber,'') 
				ELSE ISNULL(CST.IdentificationNumber,'')		 
				END IdentificationNumber
			
			--, ISNULL(T.CustomerSSNumber,'') AS SSNumber

			,CASE 
				WHEN LEN(ISNULL(T.CustomerSSNumber,'')) = 0  
				THEN ISNULL(CST.SSNumber,'') 
				ELSE ISNULL(T.CustomerSSNumber,'') 
				END SSNumber

			--, CASE 
			--	WHEN CID.NAME IS NOT NULL 
			--	THEN ISNULL(T.CustomerBornDate,'') 
			--	ELSE ISNULL(CST.BornDate,'') 
			--	END BornDate

			,CASE 
				WHEN LEN(ISNULL(CONVERT(VARCHAR(10),T.CustomerBornDate,112),'')) = 0  
				THEN CST.BornDate
				ELSE T.CustomerBornDate
				END BornDate

			--, CASE 
			--	WHEN CID.NAME IS NOT NULL 
			--	THEN ISNULL(T.CustomerOccupation,'') 
			--	ELSE ISNULL(CST.Occupation,'') 
			--	END Occupation

			,CASE 
				WHEN LEN(ISNULL(T.CustomerOccupation,'')) = 0 
				THEN CST.Occupation
				ELSE T.CustomerOccupation
				END AS 'Occupation'

			, CASE WHEN t.idstatus=30 AND t.IdPaymentType IN (1,4) THEN CASE WHEN d.idbranch IS NOT NULL THEN ISNULL(tpi.BranchCode,'') ELSE '' END   +' '+ISNULL(p1.payername,'') ELSE '' END BranchName    
			, CASE WHEN t.idstatus=30 AND t.IdPaymentType IN (1,4) THEN TPI.DateOfPayment ELSE NULL END AS Date
			, CASE WHEN t.idstatus=30 AND t.IdPaymentType IN (1,4) THEN isnull(e.CityName,'') ELSE '' END CityName1
			, CASE WHEN t.idstatus=30 AND t.IdPaymentType IN (1,4) THEN isnull(f.StateName,'') ELSE '' END StateName1
			,ISNULL((SELECT TOP 1 1 FROM transfercloseddetail WHERE idstatus in (9) and IdTransferClosed=t.IdTransferClosed),0) KYCHold
			,ISNULL((SELECT TOP 1 1 FROM transfercloseddetail WHERE idstatus in (12) and IdTransferClosed=t.IdTransferClosed),0) DenyListHold
			,CASE
				WHEN EXISTS (SELECT TOP 1 1 FROM TransferClosedHolds (NOLOCK) WHERE IdStatus=9 AND IdTransferClosed=t.IdTransferClosed AND IsReleased=0) THEN ISNULL(s2.StatusName,'')
				WHEN EXISTS (SELECT TOP 1 1 FROM TransferClosedHolds (NOLOCK) WHERE IdStatus=12 AND IdTransferClosed=t.IdTransferClosed AND IsReleased=0) THEN ISNULL(s3.StatusName,'')
			ELSE '' 
				END AS RejectedHold
			,ISNULL(z.CountyInfo,'') CountyInfo
			,cid.RequireSSN
			,cid.StateRequired
			,T.CustomerIdentificationIdState
		FROM TransferClosed T (NOLOCK)
			 JOIN [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
			 JOIN [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
			 JOIN [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
			 JOIN [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
			 JOIN [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
		LEFT JOIN [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransferclosed AND TPI.IdTransferPayInfo=(select max(tt.IdTransferPayInfo) from TransferPayInfo tt where tt.IdTransfer =T.IdTransferClosed)
		LEFT JOIN branch d (nolock) on d.IdBranch= case when tpi.idtransfer is not null then tpi.idbranch else 0 end
		LEFT JOIN City E With(Nolock) on (E.IdCity=D.IdCity)
		LEFT JOIN State  F With(Nolock) on (F.IdState=E.IdState)
		LEFT JOIN payer p1 (nolock) on d.idpayer=p1.idpayer
		LEFT JOIN [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
		LEFT JOIN [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
		LEFT JOIN [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
		LEFT JOIN [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
		LEFT JOIN [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
		LEFT JOIN [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
		LEFT JOIN CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1
		LEFT JOIN status s2 (nolock) on 9=s2.IdStatus 
		LEFT JOIN status s3 (nolock) on 12=s3.IdStatus
		LEFT JOIN (
					SELECT 
						SS.ZipCode,
						STUFF((SELECT '/' + c.CountyClassName 
					FROM RelationCountyCountyClass US
						JOIN CountyClass c (nolock) on us.IdCountyClass = c.IdCountyClass 
					WHERE US.IdCounty = SS.IdCounty
					ORDER BY c.CountyClassName 
					FOR XML PATH('')), 1, 1, '') CountyInfo
					FROM zipcode SS
					GROUP BY SS.ZipCode, SS.IdCounty    
				 ) z on AgentZipcode=z.ZipCode
		LEFT JOIN Customer CST (nolock) ON CST.IdCustomer = T.IdCustomer 
		LEFT JOIN [CustomerIdentificationType] CIDc (nolock) ON CIDc.IdCustomerIdentificationType = CST.IdCustomerIdentificationType 

		WHERE 
		T.IdStatus=isnull(@Satatus,t.idstatus) and
		T.IdAgent=isnull(@Agent,t.idagent) and
		CC.IdCountry=isnull(@Country, CC.IdCountry) and
		T.ClaimCode=isnull(@ClaimCode,T.ClaimCode) and
		T.Folio=isnull(@Folio,T.Folio) and
		T.IdAgent=isnull(@Agent,T.IdAgent) and
		T.IdPayer=isnull(@Payer,T.idpayer) and
		T.CustomerFirstLastName like '%'+isnull(@SenderLastName,'')+'%' and
		T.BeneficiaryFirstLastName like '%'+isnull(@BeneficiaryLastName,'')+'%' and
		isnull(CV.CardNumber,'') like '%'+isnull(@VIPCard,'')+'%' and
		T.AmountInDollars>=isnull(@Amount,T.AmountInDollars) and
		T.IdGateway=isnull(@Gateway,T.Idgateway)  and 
		dbo.RemoveTimeFromDatetime(isnull(A.opendate,''))>=dbo.RemoveTimeFromDatetime(isnull(@DateAgentOpenFrom,dbo.RemoveTimeFromDatetime(isnull(A.opendate,'')))) and dbo.RemoveTimeFromDatetime(A.opendate)<=dbo.RemoveTimeFromDatetime(isnull(@DateAgentOpenTo,dbo.RemoveTimeFromDatetime(isnull(A.opendate,'')))) and
		T.DateOfTransfer>=@DateFrom and  T.DateOfTransfer<=@DateTo 
	 )

	 SELECT
		 A.[AmountRequiredToAskId]
		,A.[AgentCode]
		,A.[AgentZipcode]
		,A.[Folio]
		,A.[DateOfTransfer]
		,A.[AmountInDollars]
		,A.[StatusName]
		,A.[DepositAccountNumber]
		,A.[ClaimCode]
		,A.[IdCustomer]
		,A.[String C]
		,A.[CustomerName]
		,A.[CustomerFirstLastName]
		,A.[CustomerSecondLastName]
		,A.[CustomerAddress]
		,A.[CustomerCity]
		,A.[CustomerState]
		,A.[CustomerZipcode]

		,CASE WHEN LEN(ISNULL(A.[CustomerPhoneNumber],'')) <> 0 THEN
			A.[CustomerPhoneNumber]
			ELSE
			( 
				SELECT TOP 1 ISNULL(CustomerPhoneNumber,'')
				FROM CTE_TRANS b
				WHERE IdCustomer = A.IdCustomer AND LEN(ISNULL(CustomerPhoneNumber,'')) > 0
				ORDER BY b.DateOfTransfer DESC 
			)
			END AS [CustomerPhoneNumber]

		,CASE WHEN LEN(ISNULL(A.[CustomerCelullarNumber],'')) <> 0 THEN
			A.[CustomerCelullarNumber]
			ELSE
			( 
				SELECT TOP 1 ISNULL([CustomerCelullarNumber],'')
				FROM CTE_TRANS b
				WHERE IdCustomer = A.IdCustomer AND LEN(ISNULL([CustomerCelullarNumber],'')) > 0
				ORDER BY b.DateOfTransfer DESC 
			)
			END AS [CustomerCelullarNumber]

		,A.[String B]
		,A.[BeneficiaryName]
		,A.[BeneficiaryFirstLastName]
		,A.[BeneficiarySecondLastName]

		,CASE WHEN LEN(ISNULL(A.[RecipientAddress],'')) <> 0 THEN
			A.[RecipientAddress]
			ELSE
			( 
				SELECT TOP 1 ISNULL([RecipientAddress],'')
				FROM CTE_TRANS b
				WHERE IdCustomer = A.IdCustomer AND LEN(ISNULL([RecipientAddress],'')) > 0
				ORDER BY b.DateOfTransfer DESC 
			)
			END AS [RecipientAddress]

		,A.[PayerName]
		,A.[IdBranch]
		,A.[CityName]

		--fix error estados sin mostrar
		--,CASE WHEN (LEN(ISNULL(A.Name,'')) = 0) OR (LEN(ISNULL(A.IdentificationNumber,'')) = 0) OR (LEN(ISNULL(A.StateName,'')) = 0) OR (LEN(ISNULL(CONVERT(VARCHAR(10),A.BornDate,112),'')) = 0)
		--	THEN '' ELSE A.[StateName] END AS [StateName] ---------------------------------------------------------------------------------------
		,A.[StateName]

		,A.[CountryName]
		,A.[UserName]
		,CASE WHEN (LEN(ISNULL(A.Name,'')) = 0) OR (LEN(ISNULL(A.IdentificationNumber,'')) = 0) OR (a.StateRequired = 1 AND ISNULL(A.CustomerIdentificationIdState, 0) = 0) OR (LEN(ISNULL(CONVERT(VARCHAR(10),A.BornDate,112),'')) = 0)
			THEN '' ELSE A.[Name] END AS [Name]   ---------------------------------------------------------------------------------------
		
		,CASE WHEN (LEN(ISNULL(A.Name,'')) = 0) OR (LEN(ISNULL(A.IdentificationNumber,'')) = 0) OR (a.StateRequired = 1 AND ISNULL(A.CustomerIdentificationIdState, 0) = 0) OR (LEN(ISNULL(CONVERT(VARCHAR(10),A.BornDate,112),'')) = 0)	
		 THEN ''
		 ELSE
			CASE WHEN LEN(ISNULL(A.[IdentificationIdCountry],'')) <> 0 THEN
				A.[IdentificationIdCountry]
				ELSE
				( 
					SELECT TOP 1 ISNULL([IdentificationIdCountry],'')
					FROM CTE_TRANS b
					WHERE IdCustomer = A.IdCustomer AND LEN(ISNULL([IdentificationIdCountry],'')) > 0
					ORDER BY b.DateOfTransfer DESC 
				)
			END 
		END
		AS [IdentificationIdCountry]

		,CASE WHEN (LEN(ISNULL(A.Name,'')) = 0) OR (LEN(ISNULL(A.IdentificationNumber,'')) = 0) OR (a.StateRequired = 1 AND ISNULL(A.CustomerIdentificationIdState, 0) = 0) OR (LEN(ISNULL(CONVERT(VARCHAR(10),A.BornDate,112),'')) = 0)
			THEN '' ELSE
				CASE WHEN LEN(ISNULL(A.[IdentificationNumber],'')) <> 0 THEN
				A.[IdentificationNumber]
				ELSE
				( 
					SELECT TOP 1 ISNULL([IdentificationNumber],'')
					FROM CTE_TRANS b
					WHERE IdCustomer = A.IdCustomer AND LEN(ISNULL([IdentificationNumber],'')) > 0
					ORDER BY b.DateOfTransfer DESC 
				)
				END 
			END AS [IdentificationNumber]		---------------------------------------------------------------------------------------

		,CASE WHEN (a.StateRequired = 1 AND (ISNULL(A.CustomerIdentificationIdState, 0) = 0)) OR (A.RequireSSN = 1 AND LEN(ISNULL(A.SSNumber,'')) = 0) THEN
			'' ELSE
					CASE WHEN LEN(ISNULL(A.[SSNumber],'')) <> 0 THEN
					A.[SSNumber]
					ELSE
					( 
						SELECT TOP 1 ISNULL([SSNumber],'')
						FROM CTE_TRANS b
						WHERE IdCustomer = A.IdCustomer AND LEN(ISNULL([SSNumber],'')) > 0
						ORDER BY b.DateOfTransfer DESC 
					)
					END
				END AS [SSNumber]
		,CASE WHEN (LEN(ISNULL(A.Name,'')) = 0) OR (LEN(ISNULL(A.IdentificationNumber,'')) = 0) OR (a.StateRequired = 1 AND ISNULL(A.CustomerIdentificationIdState, 0) = 0) OR (LEN(ISNULL(CONVERT(VARCHAR(10),A.BornDate,112),'')) = 0)
			THEN NULL ELSE A.[BornDate] END AS BornDate ---------------------------------------------------------------------------------------
		,CASE WHEN (LEN(ISNULL(A.Name,'')) = 0) OR (LEN(ISNULL(A.IdentificationNumber,'')) = 0) OR (a.StateRequired = 1 AND ISNULL(A.CustomerIdentificationIdState, 0) = 0) OR (LEN(ISNULL(CONVERT(VARCHAR(10),A.BornDate,112),'')) = 0)	
			THEN ''
			ELSE A.[Occupation]
		 END AS [Occupation]
		,A.[BranchName]
		,A.[Date]
		,A.[CityName1]
		,A.[StateName1]
		,A.[KYCHold]
		,A.[DenyListHold]
		,A.[RejectedHold]
		,A.[CountyInfo]
	 FROM CTE_TRANS A	 
	 ORDER BY A.DateOfTransfer 

	END
	ELSE
	BEGIN
		WITH CTE_TRANS  AS (
		SELECT
			AmountRequiredToAskId AS AmountRequiredToAskId
			, AgentCode AS AgentCode
			, AgentZipcode AS AgentZipcode
			, T.Folio AS Folio
			, T.DateOfTransfer AS DateOfTransfer
			, T.AmountInDollars AS AmountInDollars
			, S.StatusName AS StatusName
			, T.DepositAccountNumber AS DepositAccountNumber
			, T.ClaimCode AS ClaimCode
			, T.IdCustomer AS IdCustomer
			, dbo.[fn_GetCustomerC](T.CustomerName)+dbo.[fn_GetCustomerC](T.CustomerFirstLastName)+dbo.[fn_GetCustomerC](T.CustomerSecondLastName) AS [String C]
			
			--, T.CustomerName AS CustomerName
			,CASE 
				WHEN LEN(ISNULL(T.CustomerName,'')) = 0 
				THEN CST.Name
				ELSE T.CustomerName
				END AS 'CustomerName'
			
			--, T.CustomerFirstLastName AS CustomerFirstLastName
			,CASE 
				WHEN LEN(ISNULL(T.CustomerFirstLastName,'')) = 0 
				THEN CST.FirstLastName
				ELSE T.CustomerFirstLastName
				END AS 'CustomerFirstLastName'

			--, T.CustomerSecondLastName AS CustomerSecondLastName
			,CASE 
				WHEN LEN(ISNULL(T.CustomerSecondLastName,'')) = 0 
				THEN CST.SecondLastName
				ELSE T.CustomerSecondLastName
				END AS 'CustomerSecondLastName'

			, T.CustomerAddress AS CustomerAddress
			, T.CustomerCity AS CustomerCity
			, T.CustomerState AS CustomerState
			, T.CustomerZipcode AS CustomerZipcode
			--, T.CustomerPhoneNumber AS CustomerPhoneNumber
				, CASE 
				WHEN LEN(ISNULL(T.CustomerPhoneNumber,'')) = 0 
				THEN CST.PhoneNumber
				ELSE T.CustomerPhoneNumber
				END AS 'CustomerPhoneNumber'

			--, T.CustomerCelullarNumber AS CustomerCelullarNumber
			, CASE 
				WHEN LEN(ISNULL(T.CustomerCelullarNumber,'')) = 0 
				THEN CST.CelullarNumber
				ELSE T.CustomerCelullarNumber
				END AS 'CustomerCelullarNumber'

			, dbo.[fn_GetCustomerC](T.BeneficiaryName)+dbo.[fn_GetCustomerC](T.BeneficiaryFirstLastName)+dbo.[fn_GetCustomerC](T.BeneficiarySecondLastName) AS [String B]
			, ISNULL(T.BeneficiaryName,'') AS BeneficiaryName
			, ISNULL(T.BeneficiaryFirstLastName,'') AS BeneficiaryFirstLastName
			, ISNULL(T.BeneficiarySecondLastName,'') AS BeneficiarySecondLastName
			, ISNULL(T.BeneficiaryAddress,'') AS RecipientAddress
			, P.PayerName AS PayerName
			, T.IdBranch AS IdBranch
			, BRC.CityName AS CityName
			, BRS.StateName AS StateName
			, BRCo.CountryName AS CountryName
			, U.UserName AS UserName

			, CASE 
				WHEN CID.NAME IS NOT NULL 
				THEN ISNULL(CID.Name,'') 
				ELSE ISNULL(CIDc.Name, '') 
				END  Name
	   
			, CASE 
				WHEN CID.NAME IS NOT NULL 
				THEN ISNULL(IDCo.CountryName,'') 
				ELSE ISNULL(CST.Country , '')
				END  IdentificationIdCountry

			, CASE 
				WHEN CID.NAME IS NOT NULL 
				THEN ISNULL(T.CustomerIdentificationNumber,'') 
				ELSE ISNULL(CST.IdentificationNumber,'')		 
				END IdentificationNumber

			--, ISNULL(T.CustomerSSNumber,'') AS SSNumber

			,CASE 
				WHEN LEN(ISNULL(T.CustomerSSNumber,'')) = 0  
				THEN ISNULL(CST.SSNumber,'') 
				ELSE ISNULL(T.CustomerSSNumber,'') 
				END SSNumber

			--, CASE 
			--	WHEN CID.NAME IS NOT NULL 
			--	THEN ISNULL(T.CustomerBornDate,'') 
			--	ELSE ISNULL(CST.BornDate,'') 
			--	END BornDate

			,CASE 
				WHEN LEN(ISNULL(CONVERT(VARCHAR(10),T.CustomerBornDate,112),'')) = 0  
				THEN CST.BornDate
				ELSE T.CustomerBornDate
				END BornDate

			--, CASE 
				--	WHEN CID.NAME IS NOT NULL 
				--	THEN ISNULL(T.CustomerOccupation,'') 
				--	ELSE ISNULL(CST.Occupation,'') 
				--	END Occupation

			,  CASE 
				WHEN LEN(ISNULL(T.CustomerOccupation,'')) = 0 
				THEN CST.Occupation
				ELSE T.CustomerOccupation
				END AS 'Occupation'

			, CASE WHEN t.idstatus=30 AND t.IdPaymentType in (1,4) THEN CASE WHEN d.idbranch IS NOT NULL  THEN ISNULL(tpi.BranchCode,'') else '' end +' '+isnull(p1.payername,'') else '' end BranchName    
			, CASE WHEN t.idstatus=30 AND t.IdPaymentType in (1,4) THEN ISNULL(TPI.DateOfPayment,'') ELSE '' END AS Date
			, CASE WHEN t.idstatus=30 AND t.IdPaymentType in (1,4) THEN ISNULL(e.CityName,'') ELSE '' END CityName1
			, CASE WHEN t.idstatus=30 AND t.IdPaymentType in (1,4) THEN ISNULL(f.StateName,'') ELSE '' END StateName1
			,ISNULL((SELECT TOP 1 1 FROM transferdetail WHERE idstatus in (9) and idtransfer=t.IdTransfer),0) KYCHold
			,ISNULL((SELECT TOP 1 1 FROM transferdetail WHERE idstatus in (12) and idtransfer=t.IdTransfer),0) DenyListHold
			,CASE
			WHEN EXISTS(SELECT TOP 1 1 FROM TransferHolds (NOLOCK) WHERE IdStatus = 9 AND IdTransfer = t.IdTransfer AND IsReleased = 0) THEN ISNULL(s2.StatusName,'')
			WHEN EXISTS(SELECT TOP 1 1 FROM TransferHolds (NOLOCK) WHERE IdStatus = 12 AND IdTransfer = t.IdTransfer AND IsReleased = 0) THEN ISNULL(s3.StatusName,'')
			ELSE ''
			END RejectedHold
			,isnull(z.CountyInfo,'') CountyInfo
			,cid.RequireSSN
			,cid.StateRequired
			,T.CustomerIdentificationIdState
		FROM Transfer T (NOLOCK)
				 JOIN [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
				 JOIN [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
				 JOIN [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
				 JOIN [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
				 JOIN [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
			LEFT JOIN [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
			LEFT JOIN [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
			LEFT JOIN [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
			LEFT JOIN [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
			LEFT JOIN [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
			LEFT JOIN [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransfer AND TPI.IdTransferPayInfo=(select max(tt.IdTransferPayInfo) from TransferPayInfo tt where tt.IdTransfer =T.IdTransfer)
			LEFT JOIN branch d (nolock) on d.IdBranch= case when tpi.idtransfer is not null then tpi.idbranch else 0 end
			LEFT JOIN City E With(Nolock) on (E.IdCity=D.IdCity)
			LEFT JOIN State  F With(Nolock) on (F.IdState=E.IdState)
			LEFT JOIN payer p1 (nolock) on d.idpayer=p1.idpayer
			LEFT JOIN [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
			LEFT JOIN CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1
			LEFT JOIN status s2 (NOLOCK) on s2.IdStatus = 9
            LEFT JOIN status s3 (NOLOCK) on s3.IdStatus = 12
            LEFT JOIN
                    (
                       SELECT 
                       SS.ZipCode,
                       STUFF(
							   (
								SELECT '/' + c.CountyClassName 
								FROM RelationCountyCountyClass US
									JOIN CountyClass c (nolock) on us.IdCountyClass = c.IdCountyClass 
									WHERE US.IdCounty = SS.IdCounty
									ORDER BY c.CountyClassName 
									FOR XML PATH('')
								), 1, 1, ''
							) CountyInfo
							FROM zipcode SS
                        GROUP BY SS.ZipCode, SS.IdCounty    
                    ) z on AgentZipcode=z.ZipCode
			LEFT JOIN Customer CST (nolock) ON CST.IdCustomer = T.IdCustomer 
			LEFT JOIN [CustomerIdentificationType] CIDc (nolock) ON CIDc.IdCustomerIdentificationType = CST.IdCustomerIdentificationType
		WHERE 
			T.IdStatus=isnull(@Satatus,t.idstatus) and
			T.IdAgent=isnull(@Agent,t.idagent) and
			CC.IdCountry=isnull(@Country, CC.IdCountry) and
			T.ClaimCode=isnull(@ClaimCode,T.ClaimCode) and
			T.Folio=isnull(@Folio,T.Folio) and
			T.IdAgent=isnull(@Agent,T.IdAgent) and
			T.IdPayer=isnull(@Payer,T.idpayer) and
			T.CustomerFirstLastName like '%'+isnull(@SenderLastName,'')+'%' and
			T.BeneficiaryFirstLastName like '%'+isnull(@BeneficiaryLastName,'')+'%' and
			isnull(CV.CardNumber,'') like '%'+isnull(@VIPCard,'')+'%' and
			T.AmountInDollars>=isnull(@Amount,T.AmountInDollars) and
			T.IdGateway=isnull(@Gateway,T.Idgateway)  and 
			dbo.RemoveTimeFromDatetime(isnull(A.opendate,''))>=dbo.RemoveTimeFromDatetime(isnull(@DateAgentOpenFrom,'')) and dbo.RemoveTimeFromDatetime(A.opendate)<=dbo.RemoveTimeFromDatetime(isnull(@DateAgentOpenTo,'')) and
			T.DateStatusChange>=@DateFrom and  T.DateStatusChange<=@DateTo   
			           
    UNION 

		SELECT
			AmountRequiredToAskId AS AmountRequiredToAskId
			, AgentCode AS AgentCode
			, AgentZipcode AS AgentZipcode
			, T.Folio AS Folio
			, T.DateOfTransfer AS DateOfTransfer
			, T.AmountInDollars AS AmountInDollars
			, S.StatusName AS StatusName
			, T.DepositAccountNumber AS DepositAccountNumber
			, T.ClaimCode AS ClaimCode
			, T.IdCustomer AS IdCustomer
			, dbo.[fn_GetCustomerC](T.CustomerName)+dbo.[fn_GetCustomerC](T.CustomerFirstLastName)+dbo.[fn_GetCustomerC](T.CustomerSecondLastName) AS [String C]
			
			--, T.CustomerName AS CustomerName
			,CASE 
				WHEN LEN(ISNULL(T.CustomerName,'')) = 0 
				THEN CST.Name
				ELSE T.CustomerName
				END AS 'CustomerName'
			
			--, T.CustomerFirstLastName AS CustomerFirstLastName
			,CASE 
				WHEN LEN(ISNULL(T.CustomerFirstLastName,'')) = 0 
				THEN CST.FirstLastName
				ELSE T.CustomerFirstLastName
				END AS 'CustomerFirstLastName'

			--, T.CustomerSecondLastName AS CustomerSecondLastName
			,CASE 
				WHEN LEN(ISNULL(T.CustomerSecondLastName,'')) = 0 
				THEN CST.SecondLastName
				ELSE T.CustomerSecondLastName
				END AS 'CustomerSecondLastName'

			, T.CustomerAddress AS CustomerAddress
			, T.CustomerCity AS CustomerCity
			, T.CustomerState AS CustomerState
			, T.CustomerZipcode AS CustomerZipcode

			--, T.CustomerPhoneNumber AS CustomerPhoneNumber
				, CASE 
				WHEN LEN(ISNULL(T.CustomerPhoneNumber,'')) = 0 
				THEN CST.PhoneNumber
				ELSE T.CustomerPhoneNumber
				END AS 'CustomerPhoneNumber'

			--, T.CustomerCelullarNumber AS CustomerCelullarNumber
			, CASE 
				WHEN LEN(ISNULL(T.CustomerCelullarNumber,'')) = 0 
				THEN CST.CelullarNumber
				ELSE T.CustomerCelullarNumber
				END AS 'CustomerCelullarNumber'

			, dbo.[fn_GetCustomerC](T.BeneficiaryName)+dbo.[fn_GetCustomerC](T.BeneficiaryFirstLastName)+dbo.[fn_GetCustomerC](T.BeneficiarySecondLastName) AS [String B]
			, ISNULL(T.BeneficiaryName,'') AS BeneficiaryName
			, ISNULL(T.BeneficiaryFirstLastName,'') AS BeneficiaryFirstLastName
			, ISNULL(T.BeneficiarySecondLastName,'') AS BeneficiarySecondLastName
			, ISNULL(T.BeneficiaryAddress,'') AS RecipientAddress
			, P.PayerName AS PayerName
			, T.IdBranch AS IdBranch
			, BRC.CityName AS CityName
			, BRS.StateName AS StateName
			, BRCo.CountryName AS CountryName
			, U.UserName AS UserName

			, CASE 
					WHEN CID.NAME IS NOT NULL 
					THEN ISNULL(CID.Name,'') 
					ELSE ISNULL(CIDc.Name, '') 
				END  Name
	   
			, CASE 
					WHEN CID.NAME IS NOT NULL 
					THEN ISNULL(IDCo.CountryName,'') 
					ELSE ISNULL(CST.Country , '')
				END  IdentificationIdCountry

			, CASE 
					WHEN CID.NAME IS NOT NULL 
					THEN ISNULL(T.CustomerIdentificationNumber,'') 
					ELSE ISNULL(CST.IdentificationNumber,'')		 
				END IdentificationNumber

			--, ISNULL(T.CustomerSSNumber,'') AS SSNumber

			,CASE 
				WHEN LEN(ISNULL(T.CustomerSSNumber,'')) = 0  
				THEN ISNULL(CST.SSNumber,'') 
				ELSE ISNULL(T.CustomerSSNumber,'') 
				END SSNumber

			--, CASE 
			--	WHEN CID.NAME IS NOT NULL 
			--	THEN ISNULL(T.CustomerBornDate,'') 
			--	ELSE ISNULL(CST.BornDate,'') 
			--	END BornDate

			,CASE 
				WHEN LEN(ISNULL(CONVERT(VARCHAR(10),T.CustomerBornDate,112),'')) = 0  
				THEN CST.BornDate
				ELSE T.CustomerBornDate
				END BornDate
				
			--, CASE 
			--	WHEN CID.NAME IS NOT NULL 
			--	THEN ISNULL(T.CustomerOccupation,'') 
			--	ELSE ISNULL(CST.Occupation,'') 
			--	END Occupation

			,  CASE 
				WHEN LEN(ISNULL(T.CustomerOccupation,'')) = 0 
				THEN CST.Occupation
				ELSE T.CustomerOccupation
				END AS 'Occupation'			

			, CASE WHEN t.idstatus = 30 AND t.IdPaymentType IN (1,4) THEN CASE WHEN d.idbranch IS NOT NULL THEN ISNULL(tpi.BranchCode,'') ELSE '' END   +' '+ ISNULL(p1.payername,'') ELSE '' END BranchName    
			, CASE WHEN t.idstatus = 30 AND t.IdPaymentType IN (1,4) THEN ISNULL(TPI.DateOfPayment,'') else '' end AS Date
			, CASE WHEN t.idstatus = 30 AND t.IdPaymentType IN (1,4) THEN ISNULL(e.CityName,'') else '' end CityName1
			, CASE WHEN t.idstatus = 30 AND t.IdPaymentType IN (1,4) THEN ISNULL(f.StateName,'') else '' end StateName1
			,ISNULL((select top 1 1 from transfercloseddetail where idstatus in (9) and IdTransferClosed=t.IdTransferClosed),0) KYCHold
			,ISNULL((select top 1 1 from transfercloseddetail where idstatus in (12) and IdTransferClosed=t.IdTransferClosed),0) DenyListHold
			,CASE
				WHEN EXISTS (SELECT TOP 1 1 FROM TransferClosedHolds (NOLOCK) WHERE IdStatus = 9 AND IdTransferClosed = t.IdTransferClosed AND IsReleased=0) THEN ISNULL(s2.StatusName,'')
				WHEN EXISTS (SELECT TOP 1 1 FROM TransferClosedHolds (NOLOCK) WHERE IdStatus = 12 AND IdTransferClosed = t.IdTransferClosed AND IsReleased=0) THEN ISNULL(s3.StatusName,'')
			 ELSE ''
			 END RejectedHold
			,ISNULL(z.CountyInfo,'') CountyInfo
			,cid.RequireSSN
			,cid.StateRequired
			,T.CustomerIdentificationIdState
		FROM TransferClosed T (NOLOCK)
				 JOIN [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
				 JOIN [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
				 JOIN [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
				 JOIN [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
				 JOIN [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
			LEFT JOIN [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransferclosed and TPI.IdTransferPayInfo = (SELECT MAX(tt.IdTransferPayInfo) FROM TransferPayInfo tt WHERE tt.IdTransfer = T.IdTransferClosed)
			LEFT JOIN branch d (nolock) ON d.IdBranch= CASE WHEN tpi.idtransfer IS NOT NULL THEN tpi.idbranch ELSE 0 END
			LEFT JOIN City E With(Nolock) ON (E.IdCity=D.IdCity)
			LEFT JOIN State  F With(Nolock) ON (F.IdState=E.IdState)
			LEFT JOIN payer p1 (nolock) ON d.idpayer=p1.idpayer
			LEFT JOIN [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
			LEFT JOIN [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
			LEFT JOIN [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
			LEFT JOIN [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
			LEFT JOIN [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
			LEFT JOIN [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
			LEFT JOIN CardVIP CV (NOLOCK) ON CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1
			LEFT JOIN status s2 (nolock) ON 9=s2.IdStatus
            LEFT JOIN status s3 (nolock) ON 12=s3.IdStatus
            LEFT JOIN
                    (
                       SELECT 
                       SS.ZipCode,
                       STUFF((SELECT '/' + c.CountyClassName 
                              FROM RelationCountyCountyClass US
                              join CountyClass c (nolock) on us.IdCountyClass = c.IdCountyClass 
                              WHERE US.IdCounty = SS.IdCounty
                              ORDER BY c.CountyClassName 
                              FOR XML PATH('')), 1, 1, '') CountyInfo
                        FROM zipcode SS
                        GROUP BY SS.ZipCode, SS.IdCounty    
                    ) z on AgentZipcode=z.ZipCode
			LEFT JOIN Customer CST (nolock) ON CST.IdCustomer = T.IdCustomer 
			LEFT JOIN [CustomerIdentificationType] CIDc (nolock) ON CIDc.IdCustomerIdentificationType = CST.IdCustomerIdentificationType
		WHERE 
			T.IdStatus = isnull(@Satatus,t.idstatus) AND
			T.IdAgent = isnull(@Agent,t.idagent) AND
			CC.IdCountry = isnull(@Country, CC.IdCountry) AND
			T.ClaimCode = isnull(@ClaimCode,T.ClaimCode) AND
			T.Folio = isnull(@Folio,T.Folio) AND
			T.IdAgent = isnull(@Agent,T.IdAgent) AND
			T.IdPayer = isnull(@Payer,T.idpayer) AND
			T.CustomerFirstLastName like '%'+isnull(@SenderLastName,'')+'%' AND
			T.BeneficiaryFirstLastName like '%'+isnull(@BeneficiaryLastName,'')+'%' AND
			isnull(CV.CardNumber,'') like '%'+isnull(@VIPCard,'')+'%' AND
			T.AmountInDollars> = isnull(@Amount,T.AmountInDollars) AND
			T.IdGateway = isnull(@Gateway,T.Idgateway)  AND 
			dbo.RemoveTimeFromDatetime(isnull(A.opendate,''))> = dbo.RemoveTimeFromDatetime(isnull(@DateAgentOpenFrom,'')) AND 
			dbo.RemoveTimeFromDatetime(A.opendate)< = dbo.RemoveTimeFromDatetime(isnull(@DateAgentOpenTo,'')) AND
			T.DateStatusChange> = @DateFrom AND  
			T.DateStatusChange< = @DateTo 
			)

		 SELECT
		 A.[AmountRequiredToAskId]
		,A.[AgentCode]
		,A.[AgentZipcode]
		,A.[Folio]
		,A.[DateOfTransfer]
		,A.[AmountInDollars]
		,A.[StatusName]
		,A.[DepositAccountNumber]
		,A.[ClaimCode]
		,A.[IdCustomer]
		,A.[String C]
		,A.[CustomerName]
		,A.[CustomerFirstLastName]
		,A.[CustomerSecondLastName]
		,A.[CustomerAddress]
		,A.[CustomerCity]
		,A.[CustomerState]
		,A.[CustomerZipcode]

		,CASE WHEN LEN(ISNULL(A.[CustomerPhoneNumber],'')) <> 0 THEN
			A.[CustomerPhoneNumber]
			ELSE
			( 
				SELECT TOP 1 ISNULL(CustomerPhoneNumber,'')
				FROM CTE_TRANS b
				WHERE IdCustomer = A.IdCustomer AND LEN(ISNULL(CustomerPhoneNumber,'')) > 0
				ORDER BY b.DateOfTransfer DESC 
			)
			END AS [CustomerPhoneNumber]

		,CASE WHEN LEN(ISNULL(A.[CustomerCelullarNumber],'')) <> 0 THEN
			A.[CustomerCelullarNumber]
			ELSE
			( 
				SELECT TOP 1 ISNULL([CustomerCelullarNumber],'')
				FROM CTE_TRANS b
				WHERE IdCustomer = A.IdCustomer AND LEN(ISNULL([CustomerCelullarNumber],'')) > 0
				ORDER BY b.DateOfTransfer DESC 
			)
			END AS [CustomerCelullarNumber]

		,A.[String B]
		,A.[BeneficiaryName]
		,A.[BeneficiaryFirstLastName]
		,A.[BeneficiarySecondLastName]

		,CASE WHEN LEN(ISNULL(A.[RecipientAddress],'')) <> 0 THEN
			A.[RecipientAddress]
			ELSE
			( 
				SELECT TOP 1 ISNULL([RecipientAddress],'')
				FROM CTE_TRANS b
				WHERE IdCustomer = A.IdCustomer AND LEN(ISNULL([RecipientAddress],'')) > 0
				ORDER BY b.DateOfTransfer DESC 
			)
			END AS [RecipientAddress]

		,A.[PayerName]
		,A.[IdBranch]
		,A.[CityName]

		--fix error estados sin mostrar
		--,CASE WHEN (LEN(ISNULL(A.Name,'')) = 0) OR (LEN(ISNULL(A.IdentificationNumber,'')) = 0) OR (LEN(ISNULL(A.StateName,'')) = 0) OR (LEN(ISNULL(CONVERT(VARCHAR(10),A.BornDate,112),'')) = 0)
		--	THEN '' ELSE A.[StateName] END AS [StateName] ---------------------------------------------------------------------------------------
		,A.[StateName]

		,A.[CountryName]
		,A.[UserName]
		,CASE WHEN (LEN(ISNULL(A.Name,'')) = 0) OR (LEN(ISNULL(A.IdentificationNumber,'')) = 0) OR (a.StateRequired = 1 AND ISNULL(A.CustomerIdentificationIdState, 0) = 0) OR (LEN(ISNULL(CONVERT(VARCHAR(10),A.BornDate,112),'')) = 0)
			THEN '' ELSE A.[Name] END AS [Name]   ---------------------------------------------------------------------------------------
		
		,CASE WHEN (LEN(ISNULL(A.Name,'')) = 0) OR (LEN(ISNULL(A.IdentificationNumber,'')) = 0) OR (a.StateRequired = 1 AND ISNULL(A.CustomerIdentificationIdState, 0) = 0) OR (LEN(ISNULL(CONVERT(VARCHAR(10),A.BornDate,112),'')) = 0)	
		 THEN ''
		 ELSE
			CASE WHEN LEN(ISNULL(A.[IdentificationIdCountry],'')) <> 0 THEN
				A.[IdentificationIdCountry]
				ELSE
				( 
					SELECT TOP 1 ISNULL([IdentificationIdCountry],'')
					FROM CTE_TRANS b
					WHERE IdCustomer = A.IdCustomer AND LEN(ISNULL([IdentificationIdCountry],'')) > 0
					ORDER BY b.DateOfTransfer DESC 
				)
			END 
		END
		AS [IdentificationIdCountry]

		,CASE WHEN (LEN(ISNULL(A.Name,'')) = 0) OR (LEN(ISNULL(A.IdentificationNumber,'')) = 0) OR (a.StateRequired = 1 AND ISNULL(A.CustomerIdentificationIdState, 0) = 0) OR (LEN(ISNULL(CONVERT(VARCHAR(10),A.BornDate,112),'')) = 0)
			THEN '' ELSE
				CASE WHEN LEN(ISNULL(A.[IdentificationNumber],'')) <> 0 THEN
				A.[IdentificationNumber]
				ELSE
				( 
					SELECT TOP 1 ISNULL([IdentificationNumber],'')
					FROM CTE_TRANS b
					WHERE IdCustomer = A.IdCustomer AND LEN(ISNULL([IdentificationNumber],'')) > 0
					ORDER BY b.DateOfTransfer DESC 
				)
				END 
			END AS [IdentificationNumber]		---------------------------------------------------------------------------------------

		,CASE WHEN (a.StateRequired = 1 AND (ISNULL(A.CustomerIdentificationIdState, 0) = 0)) OR (A.RequireSSN = 1 AND LEN(ISNULL(A.SSNumber,'')) = 0) THEN
			'' ELSE
					CASE WHEN LEN(ISNULL(A.[SSNumber],'')) <> 0 THEN
					A.[SSNumber]
					ELSE
					( 
						SELECT TOP 1 ISNULL([SSNumber],'')
						FROM CTE_TRANS b
						WHERE IdCustomer = A.IdCustomer AND LEN(ISNULL([SSNumber],'')) > 0
						ORDER BY b.DateOfTransfer DESC 
					)
					END
				END AS [SSNumber]
		,CASE WHEN (LEN(ISNULL(A.Name,'')) = 0) OR (LEN(ISNULL(A.IdentificationNumber,'')) = 0) OR (a.StateRequired = 1 AND ISNULL(A.CustomerIdentificationIdState, 0) = 0) OR (LEN(ISNULL(CONVERT(VARCHAR(10),A.BornDate,112),'')) = 0)
			THEN NULL ELSE A.[BornDate] END AS BornDate ---------------------------------------------------------------------------------------
		,CASE WHEN (LEN(ISNULL(A.Name,'')) = 0) OR (LEN(ISNULL(A.IdentificationNumber,'')) = 0) OR (a.StateRequired = 1 AND ISNULL(A.CustomerIdentificationIdState, 0) = 0) OR (LEN(ISNULL(CONVERT(VARCHAR(10),A.BornDate,112),'')) = 0)	
			THEN ''
			ELSE A.[Occupation]
		 END AS [Occupation]
		,A.[BranchName]
		,A.[Date]
		,A.[CityName1]
		,A.[StateName1]
		,A.[KYCHold]
		,A.[DenyListHold]
		,A.[RejectedHold]
		,A.[CountyInfo]
	 FROM CTE_TRANS A	 
	 ORDER BY A.DateOfTransfer 
	END
END
