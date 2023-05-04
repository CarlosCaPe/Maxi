CREATE PROCEDURE [dbo].[st_KYCAnalysisReport2] (
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
)
AS
BEGIN
       SET NOCOUNT ON;

       SET @HasError =0
       SET @Message = ''
       -------

       Select @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
       Select @DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)


       -----------------------COUNTS

                           DECLARE @q4 NVARCHAR(MAX) = 'SELECT
                                        COUNT (1)VAL
                                  FROM Transfer T (NOLOCK)
                                        join TransferDetail CD (NOLOCK) on (CD.IdTransfer=T.IdTransfer)   
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
                                               left join [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
                                        left join CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1
                                        WHERE T.IdStatus = ISNULL('+ISNULL(CONVERT(VARCHAR,@Satatus),'NULL')+',T.IdStatus)
                                               AND T.IdAgent = ISNULL('+ISNULL(CONVERT(VARCHAR,@Agent),'NULL')+',T.IdAgent)
                                               AND CC.IdCountry = ISNULL('+ISNULL(CONVERT(VARCHAR,@Country),'NULL')+',CC.IdCountry)
                                               AND T.ClaimCode = ISNULL('+ISNULL(''''+CONVERT(VARCHAR,@ClaimCode)+'''','NULL')+',T.ClaimCode)
                                               AND T.Folio = ISNULL('+ISNULL(CONVERT(VARCHAR,@Folio),'NULL')+',T.Folio)
                                               AND T.IdPayer = ISNULL('+ISNULL(CONVERT(VARCHAR,@Payer),'NULL')+',T.IdPayer)
                                               AND T.CustomerFirstLastName = ISNULL('+ISNULL(''''+CONVERT(VARCHAR,@SenderLastName)+'''','NULL')+',T.CustomerFirstLastName)
                                               AND T.BeneficiaryFirstLastName = ISNULL('+ISNULL(''''+CONVERT(VARCHAR,@BeneficiaryLastName)+'''','NULL')+',T.BeneficiaryFirstLastName)'+
                                               ISNULL('AND (CV.CardNumber is null or CV.CardNumber = '''+@VIPCard+''' )','')+'
                                               AND T.AmountInDollars >= ISNULL('+ISNULL(CONVERT(VARCHAR,@Amount),'NULL')+',T.AmountInDollars)
                                               AND T.IdGateway = ISNULL('+ISNULL(CONVERT(VARCHAR,@Gateway),'NULL')+',T.IdGateway)
                                               '

                                               IF (@SearchType = 1 AND ISNULL(@DateFrom,'') != '' AND ISNULL(@DateTo,'') != '')
                                               BEGIN
                                                      set @q4 = @q4 + ' AND T.DateOfTransfer BETWEEN '+ISNULL(''''+CONVERT(VARCHAR,@DateFrom)+'''','NULL')+' and '+ISNULL(''''+CONVERT(VARCHAR,@DateTo)+'''','NULL')
                                               END
                                               ELSE
                                               IF (@SearchType = 0 AND ISNULL(@DateFrom,'') != '' AND ISNULL(@DateTo,'') != '')
                                               BEGIN
                                                      set @q4 = @q4 + ' AND CD.DateOfMovement BETWEEN '+ISNULL(''''+CONVERT(VARCHAR,@DateFrom)+'''','NULL')+' and '+ISNULL(''''+CONVERT(VARCHAR,@DateTo)+'''','NULL')
                                               END

                                               DECLARE @q5 NVARCHAR(MAX) = '
                                                      
                                               
                                               '
                                               DECLARE @q6 NVARCHAR(MAX) = 'SELECT
                                                      COUNT (1) VAL FROM TransferClosed T (NOLOCK)
                                                      Join TransferClosedDetail CD (NOLOCK) on (CD.IdTransferClosed=T.IdTransferClosed)  
                                                      join [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
                                                      join [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
                                                      join [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
                                                      join [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
                                                      join [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
                                                      left join [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransferclosed
                                                            and TPI.IdTransferPayInfo=(select max(tt.IdTransferPayInfo) from TransferPayInfo tt where tt.IdTransfer =T.IdTransferClosed)
                                                      left join [Branch] BR (NOLOCK) ON BR.IdBranch = T.IdBranch
                                                      left join [City] BRC (NOLOCK) ON BRC.IdCity = BR.IdCity
                                                      left join [State] BRS (NOLOCK) ON BRS.IdState = BRC.IdState
                                                      left join [Country] BRCo (NOLOCK) ON BRCo.IdCountry = BRS.IdCountry
                                                      left join [Country] IDCo (NOLOCK) ON IDCo.IdCountry = T.CustomerIdentificationIdCountry
                                                      left join [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
                                                      left join CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1
                                                      WHERE T.IdStatus = ISNULL('+ISNULL(CONVERT(VARCHAR,@Satatus),'NULL')+',T.IdStatus)
                                                            AND T.IdAgent = ISNULL('+ISNULL(CONVERT(VARCHAR,@Agent),'NULL')+',T.IdAgent)
                                               AND CC.IdCountry = ISNULL('+ISNULL(CONVERT(VARCHAR,@Country),'NULL')+',CC.IdCountry)
                                               AND T.ClaimCode = ISNULL('+ISNULL(''''+CONVERT(VARCHAR,@ClaimCode)+'''','NULL')+',T.ClaimCode)
                                               AND T.Folio = ISNULL('+ISNULL(CONVERT(VARCHAR,@Folio),'NULL')+',T.Folio)
                                               AND T.IdPayer = ISNULL('+ISNULL(CONVERT(VARCHAR,@Payer),'NULL')+',T.IdPayer)
                                               AND T.CustomerFirstLastName = ISNULL('+ISNULL(''''+CONVERT(VARCHAR,@SenderLastName)+'''','NULL')+',T.CustomerFirstLastName)
                                               AND T.BeneficiaryFirstLastName = ISNULL('+ISNULL(''''+CONVERT(VARCHAR,@BeneficiaryLastName)+'''','NULL')+',T.BeneficiaryFirstLastName)'+
                                               ISNULL('AND (CV.CardNumber is null or CV.CardNumber = '''+@VIPCard+''' )','')
                                               +'
                                               AND T.AmountInDollars >= ISNULL('+ISNULL(CONVERT(VARCHAR,@Amount),'NULL')+',T.AmountInDollars)
                                               AND T.IdGateway = ISNULL('+ISNULL(CONVERT(VARCHAR,@Gateway),'NULL')+',T.IdGateway)
                                        '

                                        IF (@SearchType = 1 AND ISNULL(@DateFrom,'') != '' AND ISNULL(@DateTo,'') != '')
                                               BEGIN
                                                      set @q6 = @q6 + ' AND T.DateOfTransfer BETWEEN '+ISNULL(''''+CONVERT(VARCHAR,@DateFrom)+'''','NULL')+' and '+ISNULL(''''+CONVERT(VARCHAR,@DateTo)+'''','NULL')
                                               END
                                               ELSE
                                               IF (@SearchType = 0 AND ISNULL(@DateFrom,'') != '' AND ISNULL(@DateTo,'') != '')
                                               BEGIN
                                                      set @q6 = @q6 + ' AND CD.DateOfMovement BETWEEN '+ISNULL(''''+CONVERT(VARCHAR,@DateFrom)+'''','NULL')+' and '+ISNULL(''''+CONVERT(VARCHAR,@DateTo)+'''','NULL')
                                               END

/*
             DECLARE @TC table ([Count] INT) 
             INSERT INTO @TC EXEC(@q4)
             ---select SUM([Count]) from @TC
             IF (select SUM([Count]) from @TC) > 10000
             BEGIN
                    SELECT @Message =dbo.GetMessageFromLenguajeResorces (0,34)                   
                    SET @HasError=1
                    RETURN
             END
             INSERT INTO @TC EXEC(@q6)
             ---select SUM([Count]) from @TC
             
             IF (select SUM([Count]) from @TC) > 10000
             BEGIN
                    SELECT @Message =dbo.GetMessageFromLenguajeResorces (0,34)                   
                    SET @HasError=1
                    RETURN
             END
*/
             
             
       -----------------------COUNTS ends here







    DECLARE @q NVARCHAR(MAX) = 'SELECT
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
       , REPLACE(T.CustomerName+T.CustomerFirstLastName+T.CustomerSecondLastName,'' '','''') AS [String C]
       , T.CustomerName AS CustomerName
       , T.CustomerFirstLastName AS CustomerFirstLastName
       , T.CustomerSecondLastName AS CustomerSecondLastName
       , T.CustomerAddress AS CustomerAddress
       , T.CustomerCity AS CustomerCity
       , T.CustomerState AS CustomerState
       , T.CustomerZipcode AS CustomerZipcode
       , T.CustomerPhoneNumber AS CustomerPhoneNumber
       , T.CustomerCelullarNumber AS CustomerCelullarNumber
       , REPLACE(T.BeneficiaryName+T.BeneficiaryFirstLastName+T.BeneficiarySecondLastName,'' '','''') AS [String B]
       , ISNULL(T.BeneficiaryName,'''') AS BeneficiaryName
       , ISNULL(T.BeneficiaryFirstLastName,'''') AS BeneficiaryFirstLastName
       , ISNULL(T.BeneficiarySecondLastName,'''') AS BeneficiarySecondLastName
       , ISNULL(T.BeneficiaryAddress,'''') AS RecipientAddress
       , P.PayerName AS PayerName
       , T.IdBranch AS IdBranch
       , BRC.CityName AS CityName
       , BRS.StateName AS StateName
       , BRCo.CountryName AS CountryName
       , U.UserName AS UserName
       , ISNULL(CID.Name,'''') AS Name
       , ISNULL(IDCo.CountryName,'''') AS IdentificationIdCountry
       , ISNULL(T.CustomerIdentificationNumber,'''') AS IdentificationNumber
       , ISNULL(T.CustomerSSNumber,'''') AS SSNumber
       , ISNULL(T.CustomerBornDate,'''') AS BornDate
       , ISNULL(T.CustomerOccupation,'''') AS Occupation
	    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then case when d.idbranch is not null then ISNULL(tpi.BranchCode,'''') else '''' end +'' ''+isnull(p1.payername,'''') else '''' end BranchName    
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then ISNULL(TPI.DateOfPayment,'''') else '''' end AS Date
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(e.CityName,'''') else '''' end CityName1
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(f.StateName,'''') else '''' end StateName1
FROM Transfer T (NOLOCK)
       join TransferDetail CD (NOLOCK) on (CD.IdTransfer=T.IdTransfer)   
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
	   left join branch d on d.IdBranch= case when tpi.idtransfer is not null then [dbo].[funGetIdBranch] (tpi.BranchCode,t.IdGateway,t.IdPayer) else 0 end
	   left Join City E With(Nolock) on (E.IdCity=D.IdCity)
       left Join State  F With(Nolock) on (F.IdState=E.IdState)
	   left join payer p1 on d.idpayer=p1.idpayer
       left join [CustomerIdentificationType] CID (NOLOCK) ON CID.IdCustomerIdentificationType = T.CustomerIdCustomerIdentificationType
       left join CardVIP CV (NOLOCK) on CV.IdCustomer = T.IdCustomer and CV.IdGenericStatus = 1
       WHERE 1=1 and 
             '
             
			 declare @q7 nvarchar(max)=''
			 if @Satatus is not null
					set @q7=@q7+ ' T.IdStatus='+CONVERT(VARCHAR,@Satatus)+' and'

					if @Agent is not null
					set @q7=@q7+ ' T.IdAgent='+CONVERT(VARCHAR,@Agent)+' and'

					if @Country is not null
					set @q7=@q7+ ' CC.IdCountry='+CONVERT(VARCHAR,@Country)+' and'

					if @ClaimCode is not null
					set @q7=@q7+ ' T.ClaimCode='''+@ClaimCode+''' and'

					if @Folio is not null
					set @q7=@q7+ ' T.Folio='+CONVERT(VARCHAR,@Folio)+' and'

					if @Agent is not null
					set @q7=@q7+ ' T.IdAgent='+CONVERT(VARCHAR,@Agent)+' and'

					if @Payer is not null
					set @q7=@q7+ ' T.IdPayer='+CONVERT(VARCHAR,@Payer)+' and'

					if @SenderLastName is not null
					set @q7=@q7+ ' T.CustomerFirstLastName like''%'+CONVERT(VARCHAR,@SenderLastName)+'%'' and'

					if @BeneficiaryLastName is not null
					set @q7=@q7+ ' T.BeneficiaryFirstLastName like''%'+CONVERT(VARCHAR,@BeneficiaryLastName)+'%'' and'

					if @VIPCard is not null
					set @q7=@q7+ ' CV.CardNumber like''%'+CONVERT(VARCHAR,@VIPCard)+'%'' and'

					if @Amount is not null
					set @q7=@q7+ ' T.AmountInDollars>='+CONVERT(VARCHAR,@Amount)+' and'

					if @Gateway is not null
					set @q7=@q7+ ' T.IdGateway>='+CONVERT(VARCHAR,@Gateway)+' and' 

             

             IF (@SearchType = 1 AND ISNULL(@DateFrom,'') != '' AND ISNULL(@DateTo,'') != '')
             BEGIN
                    set @q7 = @q7 + '  T.DateOfTransfer BETWEEN '+ISNULL(''''+CONVERT(VARCHAR,@DateFrom)+'''','NULL')+' and '+ISNULL(''''+CONVERT(VARCHAR,@DateTo)+'''','NULL')
             END
             ELSE
             IF (@SearchType = 0 AND ISNULL(@DateFrom,'') != '' AND ISNULL(@DateTo,'') != '')
             BEGIN
                    set @q7 = @q7 + '  CD.DateOfMovement BETWEEN '+ISNULL(''''+CONVERT(VARCHAR,@DateFrom)+'''','NULL')+' and '+ISNULL(''''+CONVERT(VARCHAR,@DateTo)+'''','NULL')
             END

             DECLARE @q2 NVARCHAR(MAX) = '
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
                    , REPLACE(T.CustomerName+T.CustomerFirstLastName+T.CustomerSecondLastName,'' '','''') AS [String C]
                    , T.CustomerName AS CustomerName
                    , T.CustomerFirstLastName AS CustomerFirstLastName
                    , T.CustomerSecondLastName AS CustomerSecondLastName
                    , T.CustomerAddress AS CustomerAddress
                    , T.CustomerCity AS CustomerCity
                    , T.CustomerState AS CustomerState
                    , T.CustomerZipcode AS CustomerZipcode
                    , T.CustomerPhoneNumber AS CustomerPhoneNumber
                    , T.CustomerCelullarNumber AS CustomerCelullarNumber
                    , REPLACE(T.BeneficiaryName+T.BeneficiaryFirstLastName+T.BeneficiarySecondLastName,'' '','''') AS [String B]
                    , ISNULL(T.BeneficiaryName,'''') AS BeneficiaryName
                    , ISNULL(T.BeneficiaryFirstLastName,'''') AS BeneficiaryFirstLastName
                    , ISNULL(T.BeneficiarySecondLastName,'''') AS BeneficiarySecondLastName
                    , ISNULL(T.BeneficiaryAddress,'''') AS RecipientAddress
                    , P.PayerName AS PayerName
                    , T.IdBranch AS IdBranch
                    , BRC.CityName AS CityName
                    , BRS.StateName AS StateName
                    , BRCo.CountryName AS CountryName
                    , U.UserName AS UserName
                    , ISNULL(CID.Name,'''') AS Name
                    , ISNULL(IDCo.CountryName,'''') AS IdentificationIdCountry
                    , ISNULL(T.CustomerIdentificationNumber,'''') AS IdentificationNumber
                    , ISNULL(T.CustomerSSNumber,'''') AS SSNumber
                    , ISNULL(T.CustomerBornDate,'''') AS BornDate
                    , ISNULL(T.CustomerOccupation,'''') AS Occupation
					, case when t.idstatus=30 AND t.IdPaymentType in (1,4) then   case when d.idbranch is not null then ISNULL(tpi.BranchCode,'''') else '''' end   +'' ''+isnull(p1.payername,'''') else '''' end BranchName    
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then ISNULL(TPI.DateOfPayment,'''') else '''' end AS Date
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(e.CityName,'''') else '''' end CityName1
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(f.StateName,'''') else '''' end StateName1
             'DECLARE @q3 NVARCHAR(MAX) = 'FROM TransferClosed T (NOLOCK)
                    Join TransferClosedDetail CD (NOLOCK) on (CD.IdTransferClosed=T.IdTransferClosed)  
                    join [Agent] A (NOLOCK) ON A.IdAgent = T.IdAgent
                    join [Payer] P (NOLOCK) ON P.IdPayer = T.IdPayer
                    join [Users] U (NOLOCK) ON U.IdUser = T.EnterByIdUser
                    join [Status] S (NOLOCK) ON S.IdStatus = T.IdStatus
                    join [CountryCurrency] CC (NOLOCK) ON CC.IdCountryCurrency = T.IdCountryCurrency
                    left join [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransferclosed
                           and TPI.IdTransferPayInfo=(select max(tt.IdTransferPayInfo) from TransferPayInfo tt where tt.IdTransfer =T.IdTransferClosed)
                    left join branch d on d.IdBranch= case when tpi.idtransfer is not null then [dbo].[funGetIdBranch] (tpi.BranchCode,t.IdGateway,t.IdPayer) else 0 end
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
                    WHERE 1=1 and '
					
					
					if @Satatus is not null
					set @q3=@q3+ ' T.IdStatus='+CONVERT(VARCHAR,@Satatus)+' and'

					if @Agent is not null
					set @q3=@q3+ ' T.IdAgent='+CONVERT(VARCHAR,@Agent)+' and'

					if @Country is not null
					set @q3=@q3+ ' CC.IdCountry='+CONVERT(VARCHAR,@Country)+' and'

					if @ClaimCode is not null
					set @q3=@q3+ ' T.ClaimCode='''+@ClaimCode+''' and'

					if @Folio is not null
					set @q3=@q3+ ' T.Folio='+CONVERT(VARCHAR,@Folio)+' and'

					if @Agent is not null
					set @q3=@q3+ ' T.IdAgent='+CONVERT(VARCHAR,@Agent)+' and'

					if @Payer is not null
					set @q3=@q3+ ' T.IdPayer='+CONVERT(VARCHAR,@Payer)+' and'

					if @SenderLastName is not null
					set @q3=@q3+ ' T.CustomerFirstLastName like''%'+CONVERT(VARCHAR,@SenderLastName)+'%'' and'

					if @BeneficiaryLastName is not null
					set @q3=@q3+ ' T.BeneficiaryFirstLastName like''%'+CONVERT(VARCHAR,@BeneficiaryLastName)+'%'' and'

					if @VIPCard is not null
					set @q3=@q3+ ' CV.CardNumber like''%'+CONVERT(VARCHAR,@VIPCard)+'%'' and'

					if @Amount is not null
					set @q3=@q3+ ' T.AmountInDollars>='+CONVERT(VARCHAR,@Amount)+' and'

					if @Gateway is not null
					set @q3=@q3+ ' T.IdGateway>='+CONVERT(VARCHAR,@Gateway)+' and'
					

       IF (@SearchType = 1 AND ISNULL(@DateFrom,'') != '' AND ISNULL(@DateTo,'') != '')
             BEGIN
                    set @q3 = @q3 + ' T.DateOfTransfer BETWEEN '+ISNULL(''''+CONVERT(VARCHAR,@DateFrom)+'''','NULL')+' and '+ISNULL(''''+CONVERT(VARCHAR,@DateTo)+'''','NULL')
             END
             ELSE
             IF (@SearchType = 0 AND ISNULL(@DateFrom,'') != '' AND ISNULL(@DateTo,'') != '')
             BEGIN
                    set @q3 = @q3 + ' CD.DateOfMovement BETWEEN '+ISNULL(''''+CONVERT(VARCHAR,@DateFrom)+'''','NULL')+' and '+ISNULL(''''+CONVERT(VARCHAR,@DateTo)+'''','NULL')
             END

       EXEC(@q+@q7+@q2+@q3)
             --SELECT (@q)
             --SELECT @q2
             select (@q+@q7+@q2+@q3)
			
			
		
             --PRINT (@q+@q2)
END
