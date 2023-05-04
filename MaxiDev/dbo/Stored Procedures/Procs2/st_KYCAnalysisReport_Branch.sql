CREATE PROCEDURE [dbo].[st_KYCAnalysisReport_Branch] (
             @DateFrom DATETIME,
             @DateTo DATETIME,
             @SearchType INT = 1,
             @Satatus INT= NULL,
             @Agent INT= NULL,
             @Gateway INT= NULL,
             @Country INT = NULL,
			 @BranchIdState INT = NULL,
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
       SET NOCOUNT ON;
	   SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

       SET @HasError =0
       SET @Message = ''
       -------

       Select @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
       Select @DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)

       if (@DateAgentOpenFrom) is not null and (@DateAgentOpenTo) is not null 
       begin
        Select @DateAgentOpenFrom=dbo.RemoveTimeFromDatetime(@DateAgentOpenFrom)
        Select @DateAgentOpenTo=dbo.RemoveTimeFromDatetime(@DateAgentOpenTo)
       end
       else
       begin
        Select @DateAgentOpenFrom=null
        Select @DateAgentOpenTo=null
       end


	   declare @q1 int, @q2 int

	   IF (@SearchType = 1)
	   begin
	   
       SELECT
			@q1=count(1) 
       FROM 
			Transfer T (NOLOCK)
       --join TransferDetail CD (NOLOCK) on (CD.IdTransfer=T.IdTransfer)   
       join [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
       join [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
       join [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
       join [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
       join [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
       left join [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
       left join [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
       left join [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
       left join [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
       left join [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
       left join [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransfer and TPI.IdTransferPayInfo=(select max(tt.IdTransferPayInfo) from TransferPayInfo tt where tt.IdTransfer =T.IdTransfer)
	   left join branch d  (NOLOCK) on d.IdBranch= case when tpi.idtransfer is not null then tpi.idbranch else 0 end
	   left Join City E With(Nolock) on (E.IdCity=D.IdCity)
       left Join State  F With(Nolock) on (F.IdState=E.IdState)
	   left join payer p1  (NOLOCK)on d.idpayer=p1.idpayer
       left join [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
       left join CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1       
       WHERE 
			T.IdStatus=isnull(@Satatus,t.idstatus) and
			T.IdAgent=isnull(@Agent,t.idagent) and
			CC.IdCountry=isnull(@Country, CC.IdCountry) and
			BRS.IdState=isnull(@BranchIdState, BRS.IdState) and
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



			SELECT
			@q2 =count(1)
       FROM 
			TransferCLosed T (NOLOCK)
       --join TransferDetail CD (NOLOCK) on (CD.IdTransfer=T.IdTransfer)   
       join [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
       join [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
       join [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
       join [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
       join [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
       left join [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
       left join [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
       left join [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
       left join [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
       left join [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
       left join [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransferclosed and TPI.IdTransferPayInfo=(select max(tt.IdTransferPayInfo) from TransferPayInfo tt where tt.IdTransfer =T.IdTransferclosed)
	   left join branch d  (NOLOCK) on d.IdBranch= case when tpi.idtransfer is not null then tpi.idbranch else 0 end
	   left Join City E With(Nolock) on (E.IdCity=D.IdCity)
       left Join State  F With(Nolock) on (F.IdState=E.IdState)
	   left join payer p1  (NOLOCK)on d.idpayer=p1.idpayer
       left join [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
       left join CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1       
       WHERE 
			T.IdStatus=isnull(@Satatus,t.idstatus) and
			T.IdAgent=isnull(@Agent,t.idagent) and
			CC.IdCountry=isnull(@Country, CC.IdCountry) and
			BRS.IdState=isnull(@BranchIdState, BRS.IdState) and
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


       end
	   else
	   begin
			SELECT
			@q1 = count(distinct t.idtransfer)
       FROM 
			Transfer T (NOLOCK)
       --join TransferDetail CD (NOLOCK) on (CD.IdTransfer=T.IdTransfer)   
       join [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
       join [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
       join [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
       join [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
       join [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
       left join [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
       left join [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
       left join [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
       left join [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
       left join [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
       left join [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransfer and TPI.IdTransferPayInfo=(select max(tt.IdTransferPayInfo) from TransferPayInfo tt where tt.IdTransfer =T.IdTransfer)
	   left join branch d  (NOLOCK) on d.IdBranch= case when tpi.idtransfer is not null then tpi.idbranch else 0 end
	   left Join City E With(Nolock) on (E.IdCity=D.IdCity)
       left Join State  F With(Nolock) on (F.IdState=E.IdState)
	   left join payer p1  (NOLOCK)on d.idpayer=p1.idpayer
       left join [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
       left join CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1       
       WHERE 
			T.IdStatus=isnull(@Satatus,t.idstatus) and
			T.IdAgent=isnull(@Agent,t.idagent) and
			CC.IdCountry=isnull(@Country, CC.IdCountry) and
			BRS.IdState=isnull(@BranchIdState, BRS.IdState) and
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
			T.DateStatusChange>=@DateFrom and  T.DateStatusChange<=@DateTo 


		SELECT
			@q2 = count(1) 
       FROM 
			TransferCLosed T (NOLOCK)
       --join TransferDetail CD (NOLOCK) on (CD.IdTransfer=T.IdTransfer)   
       join [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
       join [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
       join [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
       join [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
       join [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
       left join [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
       left join [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
       left join [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
       left join [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
       left join [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
       left join [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransferclosed and TPI.IdTransferPayInfo=(select max(tt.IdTransferPayInfo) from TransferPayInfo tt where tt.IdTransfer =T.IdTransferclosed)
	   left join branch d  (NOLOCK) on d.IdBranch= case when tpi.idtransfer is not null then tpi.idbranch else 0 end
	   left Join City E With(Nolock) on (E.IdCity=D.IdCity)
       left Join State  F With(Nolock) on (F.IdState=E.IdState)
	   left join payer p1  (NOLOCK)on d.idpayer=p1.idpayer
       left join [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
       left join CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1       
       WHERE 
			T.IdStatus=isnull(@Satatus,t.idstatus) and
			T.IdAgent=isnull(@Agent,t.idagent) and
			CC.IdCountry=isnull(@Country, CC.IdCountry) and
			BRS.IdState=isnull(@BranchIdState, BRS.IdState) and
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
			T.DateStatusChange>=@DateFrom and  T.DateStatusChange<=@DateTo 
	   end
			
             
             IF (isnull(@q1,0)+ISNULL(@q2,0)) > 15000
             BEGIN
                    SELECT @Message =dbo.GetMessageFromLenguajeResorces (0,34)                   
                    SET @HasError=1
                    RETURN
             END     


			 print isnull(@q1,0)+ISNULL(@q2,0)
             
       -----------------------COUNTS ends here




   IF (@SearchType = 1)
	   begin


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
       , T.CustomerName AS CustomerName
       , T.CustomerFirstLastName AS CustomerFirstLastName
       , T.CustomerSecondLastName AS CustomerSecondLastName
       , T.CustomerAddress AS CustomerAddress
       , T.CustomerCity AS CustomerCity
       , T.CustomerState AS CustomerState
       , T.CustomerZipcode AS CustomerZipcode
       , T.CustomerPhoneNumber AS CustomerPhoneNumber
       , T.CustomerCelullarNumber AS CustomerCelullarNumber
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
       --
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
       --
	   , ISNULL(T.CustomerSSNumber,'') AS SSNumber
       --------
	   , CASE 
		      WHEN CID.NAME IS NOT NULL 
			  THEN ISNULL(T.CustomerBornDate,'') 
			  ELSE ISNULL(CST.BornDate,'') 
		 END BornDate
       , CASE 
		      WHEN CID.NAME IS NOT NULL 
			  THEN ISNULL(T.CustomerOccupation,'') 
			  ELSE ISNULL(CST.Occupation,'') 
	   END Occupation

	   --------
	    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then case when d.idbranch is not null then ISNULL(tpi.BranchCode,'') else '' end +' '+isnull(p1.payername,'') else '' end BranchName    
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then ISNULL(TPI.DateOfPayment,'') else '' end AS Date
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(e.CityName,'') else '' end CityName1
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(f.StateName,'') else '' end StateName1
	   ,isnull((select top 1 1 from transferdetail where idstatus in (9) and idtransfer=t.IdTransfer),0) KYCHold
                    ,isnull((select top 1 1 from transferdetail where idstatus in (12) and idtransfer=t.IdTransfer),0) DenyListHold
                    ,case
                    when Exists (select top 1 1 from TransferHolds (nolock) where IdStatus=9 and IdTransfer=t.IdTransfer and IsReleased=0) then isnull(s2.StatusName,'')
                    when Exists (select top 1 1 from TransferHolds (nolock) where IdStatus=12 and IdTransfer=t.IdTransfer and IsReleased=0) then isnull(s3.StatusName,'')
                    else ''
                    end        
                    RejectedHold
                    ,isnull(z.CountyInfo,'') CountyInfo
FROM Transfer T (NOLOCK)
       --join TransferDetail CD (NOLOCK) on (CD.IdTransfer=T.IdTransfer)   
       join [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
       join [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
       join [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
       join [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
       join [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
       left join [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
       left join [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
       left join [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
       left join [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
       left join [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
       left join [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransfer
             and TPI.IdTransferPayInfo=(select max(tt.IdTransferPayInfo) from TransferPayInfo tt where tt.IdTransfer =T.IdTransfer)
	   left join branch d on d.IdBranch= case when tpi.idtransfer is not null then tpi.idbranch else 0 end
	   left Join City E With(Nolock) on (E.IdCity=D.IdCity)
       left Join State  F With(Nolock) on (F.IdState=E.IdState)
	   left join payer p1 on d.idpayer=p1.idpayer
       left join [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType	   
       left join CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1
	    left join 
            status s2 (nolock) on 9=s2.IdStatus
       left join 
            status s3 (nolock) on 12=s3.IdStatus
       left join
        (
           SELECT 
           SS.ZipCode,
           STUFF((SELECT '/' + c.CountyClassName 
                  FROM RelationCountyCountyClass US
                  join CountyClass c on us.IdCountyClass = c.IdCountyClass 
                  WHERE US.IdCounty = SS.IdCounty
                  ORDER BY c.CountyClassName 
                  FOR XML PATH('')), 1, 1, '') CountyInfo
            FROM zipcode SS
            GROUP BY SS.ZipCode, SS.IdCounty    
        ) z on AgentZipcode=z.ZipCode
	  --
	  LEFT JOIN Customer CST
	    ON CST.IdCustomer = T.IdCustomer 
      LEFT JOIN [CustomerIdentificationType] CIDc 
	    ON CIDc.IdCustomerIdentificationType = CST.IdCustomerIdentificationType
	  -- 
      WHERE 
			T.IdStatus=isnull(@Satatus,t.idstatus) and
			T.IdAgent=isnull(@Agent,t.idagent) and
			CC.IdCountry=isnull(@Country, CC.IdCountry) and
			BRS.IdState=isnull(@BranchIdState, BRS.IdState) and
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
                    , dbo.[fn_GetCustomerC](T.CustomerName)+dbo.[fn_GetCustomerC](T.CustomerFirstLastName)+dbo.[fn_GetCustomerC](T.CustomerSecondLastName) AS [String C]
                    , T.CustomerName AS CustomerName
                    , T.CustomerFirstLastName AS CustomerFirstLastName
                    , T.CustomerSecondLastName AS CustomerSecondLastName
                    , T.CustomerAddress AS CustomerAddress
                    , T.CustomerCity AS CustomerCity
                    , T.CustomerState AS CustomerState
                    , T.CustomerZipcode AS CustomerZipcode
                    , T.CustomerPhoneNumber AS CustomerPhoneNumber
                    , T.CustomerCelullarNumber AS CustomerCelullarNumber
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
                    ---------------------
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
				   --
				   , ISNULL(T.CustomerSSNumber,'') AS SSNumber
				   --------
				   , CASE 
						  WHEN CID.NAME IS NOT NULL 
						  THEN ISNULL(T.CustomerBornDate,'') 
						  ELSE ISNULL(CST.BornDate,'') 
					 END BornDate
				   , CASE 
						  WHEN CID.NAME IS NOT NULL 
						  THEN ISNULL(T.CustomerOccupation,'') 
						  ELSE ISNULL(CST.Occupation,'') 
				   END Occupation
					---------------------
					, case when t.idstatus=30 AND t.IdPaymentType in (1,4) then   case when d.idbranch is not null then ISNULL(tpi.BranchCode,'') else '' end   +' '+isnull(p1.payername,'') else '' end BranchName    
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then ISNULL(TPI.DateOfPayment,'') else '' end AS Date
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(e.CityName,'') else '' end CityName1
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(f.StateName,'') else '' end StateName1
					,isnull((select top 1 1 from transfercloseddetail where idstatus in (9) and IdTransferClosed=t.IdTransferClosed),0) KYCHold
                    ,isnull((select top 1 1 from transfercloseddetail where idstatus in (12) and IdTransferClosed=t.IdTransferClosed),0) DenyListHold
                    ,case
                    when Exists (select top 1 1 from TransferClosedHolds (nolock) where IdStatus=9 and IdTransferClosed=t.IdTransferClosed and IsReleased=0) then isnull(s2.StatusName,'')
                    when Exists (select top 1 1 from TransferClosedHolds (nolock) where IdStatus=12 and IdTransferClosed=t.IdTransferClosed and IsReleased=0) then isnull(s3.StatusName,'')
                    else ''
                    end        
                    RejectedHold
                    ,isnull(z.CountyInfo,'') CountyInfo
             FROM TransferClosed T (NOLOCK)
                    --Join TransferClosedDetail CD (NOLOCK) on (CD.IdTransferClosed=T.IdTransferClosed)  
                    join [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
                    join [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
                    join [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
                    join [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
                    join [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
                    left join [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransferclosed
                           and TPI.IdTransferPayInfo=(select max(tt.IdTransferPayInfo) from TransferPayInfo tt where tt.IdTransfer =T.IdTransferClosed)
                    left join branch d on d.IdBranch= case when tpi.idtransfer is not null then tpi.idbranch else 0 end
					left Join City E With(Nolock) on (E.IdCity=D.IdCity)
					left Join State  F With(Nolock) on (F.IdState=E.IdState)
					left join payer p1 on d.idpayer=p1.idpayer
					left join [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
                    left join [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
                    left join [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
                    left join [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
                    left join [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
                    left join [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
                    left join CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1
					left join 
                        status s2 (nolock) on 9=s2.IdStatus
                    left join 
                        status s3 (nolock) on 12=s3.IdStatus
                    left join
                    (
                       SELECT 
                       SS.ZipCode,
                       STUFF((SELECT '/' + c.CountyClassName 
                              FROM RelationCountyCountyClass US
                              join CountyClass c on us.IdCountyClass = c.IdCountyClass 
                              WHERE US.IdCounty = SS.IdCounty
                              ORDER BY c.CountyClassName 
                              FOR XML PATH('')), 1, 1, '') CountyInfo
                        FROM zipcode SS
                        GROUP BY SS.ZipCode, SS.IdCounty    
                    ) z on AgentZipcode=z.ZipCode
	  
			--
			  LEFT JOIN Customer CST
				ON CST.IdCustomer = T.IdCustomer 
              LEFT JOIN [CustomerIdentificationType] CIDc 
				ON CIDc.IdCustomerIdentificationType = CST.IdCustomerIdentificationType 
			--

                    WHERE 
			T.IdStatus=isnull(@Satatus,t.idstatus) and
			T.IdAgent=isnull(@Agent,t.idagent) and
			CC.IdCountry=isnull(@Country, CC.IdCountry) and
			BRS.IdState=isnull(@BranchIdState, BRS.IdState) and
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
	end
	else
	   begin


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
       , T.CustomerName AS CustomerName
       , T.CustomerFirstLastName AS CustomerFirstLastName
       , T.CustomerSecondLastName AS CustomerSecondLastName
       , T.CustomerAddress AS CustomerAddress
       , T.CustomerCity AS CustomerCity
       , T.CustomerState AS CustomerState
       , T.CustomerZipcode AS CustomerZipcode
       , T.CustomerPhoneNumber AS CustomerPhoneNumber
       , T.CustomerCelullarNumber AS CustomerCelullarNumber
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
		---------------------
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
				   --
				   , ISNULL(T.CustomerSSNumber,'') AS SSNumber
				   --------
				   , CASE 
						  WHEN CID.NAME IS NOT NULL 
						  THEN ISNULL(T.CustomerBornDate,'') 
						  ELSE ISNULL(CST.BornDate,'') 
					 END BornDate
				   , CASE 
						  WHEN CID.NAME IS NOT NULL 
						  THEN ISNULL(T.CustomerOccupation,'') 
						  ELSE ISNULL(CST.Occupation,'') 
				   END Occupation
					---------------------
	    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then case when d.idbranch is not null then ISNULL(tpi.BranchCode,'') else '' end +' '+isnull(p1.payername,'') else '' end BranchName    
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then ISNULL(TPI.DateOfPayment,'') else '' end AS Date
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(e.CityName,'') else '' end CityName1
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(f.StateName,'') else '' end StateName1
		,isnull((select top 1 1 from transferdetail where idstatus in (9) and idtransfer=t.IdTransfer),0) KYCHold
                    ,isnull((select top 1 1 from transferdetail where idstatus in (12) and idtransfer=t.IdTransfer),0) DenyListHold
                    ,case
                    when Exists (select top 1 1 from TransferHolds (nolock) where IdStatus=9 and IdTransfer=t.IdTransfer and IsReleased=0) then isnull(s2.StatusName,'')
                    when Exists (select top 1 1 from TransferHolds (nolock) where IdStatus=12 and IdTransfer=t.IdTransfer and IsReleased=0) then isnull(s3.StatusName,'')
                    else ''
                    end        
                    RejectedHold
                    ,isnull(z.CountyInfo,'') CountyInfo
FROM Transfer T (NOLOCK)
       --join TransferDetail CD (NOLOCK) on (CD.IdTransfer=T.IdTransfer)   
       join [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
       join [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
       join [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
       join [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
       join [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
       left join [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
       left join [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
       left join [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
       left join [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
       left join [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
       left join [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransfer
             and TPI.IdTransferPayInfo=(select max(tt.IdTransferPayInfo) from TransferPayInfo tt where tt.IdTransfer =T.IdTransfer)
	   left join branch d on d.IdBranch= case when tpi.idtransfer is not null then tpi.idbranch else 0 end
	   left Join City E With(Nolock) on (E.IdCity=D.IdCity)
       left Join State  F With(Nolock) on (F.IdState=E.IdState)
	   left join payer p1 on d.idpayer=p1.idpayer
       left join [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
       left join CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1
	   left join 
                        status s2 (nolock) on 9=s2.IdStatus
                    left join 
                        status s3 (nolock) on 12=s3.IdStatus
                    left join
                    (
                       SELECT 
                       SS.ZipCode,
                       STUFF((SELECT '/' + c.CountyClassName 
                              FROM RelationCountyCountyClass US
                              join CountyClass c on us.IdCountyClass = c.IdCountyClass 
                              WHERE US.IdCounty = SS.IdCounty
                              ORDER BY c.CountyClassName 
                              FOR XML PATH('')), 1, 1, '') CountyInfo
                        FROM zipcode SS
                        GROUP BY SS.ZipCode, SS.IdCounty    
                    ) z on AgentZipcode=z.ZipCode
		--
		LEFT JOIN Customer CST
		ON CST.IdCustomer = T.IdCustomer 
		LEFT JOIN [CustomerIdentificationType] CIDc 
	    ON CIDc.IdCustomerIdentificationType = CST.IdCustomerIdentificationType
		--	

      WHERE 
			T.IdStatus=isnull(@Satatus,t.idstatus) and
			T.IdAgent=isnull(@Agent,t.idagent) and
			CC.IdCountry=isnull(@Country, CC.IdCountry) and
			BRS.IdState=isnull(@BranchIdState, BRS.IdState) and
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
                    , T.CustomerName AS CustomerName
                    , T.CustomerFirstLastName AS CustomerFirstLastName
                    , T.CustomerSecondLastName AS CustomerSecondLastName
                    , T.CustomerAddress AS CustomerAddress
                    , T.CustomerCity AS CustomerCity
                    , T.CustomerState AS CustomerState
                    , T.CustomerZipcode AS CustomerZipcode
                    , T.CustomerPhoneNumber AS CustomerPhoneNumber
                    , T.CustomerCelullarNumber AS CustomerCelullarNumber
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
					---------------------
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
				   --
				   , ISNULL(T.CustomerSSNumber,'') AS SSNumber
				   --------
				   , CASE 
						  WHEN CID.NAME IS NOT NULL 
						  THEN ISNULL(T.CustomerBornDate,'') 
						  ELSE ISNULL(CST.BornDate,'') 
					 END BornDate
				   , CASE 
						  WHEN CID.NAME IS NOT NULL 
						  THEN ISNULL(T.CustomerOccupation,'') 
						  ELSE ISNULL(CST.Occupation,'') 
				   END Occupation
				   ---------------------
					, case when t.idstatus=30 AND t.IdPaymentType in (1,4) then   case when d.idbranch is not null then ISNULL(tpi.BranchCode,'') else '' end   +' '+isnull(p1.payername,'') else '' end BranchName    
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then ISNULL(TPI.DateOfPayment,'') else '' end AS Date
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(e.CityName,'') else '' end CityName1
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(f.StateName,'') else '' end StateName1
					,isnull((select top 1 1 from transfercloseddetail where idstatus in (9) and IdTransferClosed=t.IdTransferClosed),0) KYCHold
                    ,isnull((select top 1 1 from transfercloseddetail where idstatus in (12) and IdTransferClosed=t.IdTransferClosed),0) DenyListHold
                    ,case
                    when Exists (select top 1 1 from TransferClosedHolds (nolock) where IdStatus=9 and IdTransferClosed=t.IdTransferClosed and IsReleased=0) then isnull(s2.StatusName,'')
                    when Exists (select top 1 1 from TransferClosedHolds (nolock) where IdStatus=12 and IdTransferClosed=t.IdTransferClosed and IsReleased=0) then isnull(s3.StatusName,'')
                    else ''
                    end        
                    RejectedHold
                    ,isnull(z.CountyInfo,'') CountyInfo
             FROM TransferClosed T (NOLOCK)
                    --Join TransferClosedDetail CD (NOLOCK) on (CD.IdTransferClosed=T.IdTransferClosed)  
                    join [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
                    join [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
                    join [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
                    join [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
                    join [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
                    left join [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransferclosed
                           and TPI.IdTransferPayInfo=(select max(tt.IdTransferPayInfo) from TransferPayInfo tt where tt.IdTransfer =T.IdTransferClosed)
                    left join branch d on d.IdBranch= case when tpi.idtransfer is not null then tpi.idbranch else 0 end
					left Join City E With(Nolock) on (E.IdCity=D.IdCity)
					left Join State  F With(Nolock) on (F.IdState=E.IdState)
					left join payer p1 on d.idpayer=p1.idpayer
					left join [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
                    left join [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
                    left join [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
                    left join [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
                    left join [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
                    left join [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
                    left join CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1
					left join 
                        status s2 (nolock) on 9=s2.IdStatus
                    left join 
                        status s3 (nolock) on 12=s3.IdStatus
                    left join
                    (
                       SELECT 
                       SS.ZipCode,
                       STUFF((SELECT '/' + c.CountyClassName 
                              FROM RelationCountyCountyClass US
                              join CountyClass c on us.IdCountyClass = c.IdCountyClass 
                              WHERE US.IdCounty = SS.IdCounty
                              ORDER BY c.CountyClassName 
                              FOR XML PATH('')), 1, 1, '') CountyInfo
                        FROM zipcode SS
                        GROUP BY SS.ZipCode, SS.IdCounty    
                    ) z on AgentZipcode=z.ZipCode

			--
				LEFT JOIN Customer CST
				ON CST.IdCustomer = T.IdCustomer 
				LEFT JOIN [CustomerIdentificationType] CIDc 
				ON CIDc.IdCustomerIdentificationType = CST.IdCustomerIdentificationType
			--	

                    WHERE 
			T.IdStatus=isnull(@Satatus,t.idstatus) and
			T.IdAgent=isnull(@Agent,t.idagent) and
			CC.IdCountry=isnull(@Country, CC.IdCountry) and
			BRS.IdState=isnull(@BranchIdState, BRS.IdState) and
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
	end
END



