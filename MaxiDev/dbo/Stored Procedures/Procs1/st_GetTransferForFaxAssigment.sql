CREATE PROCEDURE [dbo].[st_GetTransferForFaxAssigment]
(  
    @SearchParameter varchar(max), 
    @IdentificationType INT
)  
AS

	/********************************************************************
	<Author>Known't</Author>
	<app>MaxiCorp</app>
	<Description>Fax Assignment Seach Transfer</Description>

	<ChangeLog>
	<log Date="23/03/2017" Author="mdelgado">s14_17 :: Add Transfer with status in GateWay pending response or Unclaimed Hold only search by Identification Type = 1 </log>
	</ChangeLog>
	********************************************************************/

IF (@IdentificationType=0)
BEGIN
 
	IF (LEN(@SearchParameter) != 0)
	BEGIN
		SELECT  
			T.IdAgent,
			A.AgentCode, 
			T.ClaimCode,
			T.CustomerName +' '+ T.CustomerFirstLastName + ' ' + T.CustomerSecondLastName as CustomerName, 
			T.BeneficiaryName +' '+  T.BeneficiaryFirstLastName +' '+ T.BeneficiarySecondLastName as BeneficiaryName,
			A.AgentName,
			T.DateOfTransfer,
			T.DateStatusChange,
			T.IdTransfer,
			T.Folio,
			P.PayerName,
			PT.PaymentName as PaymentTypeName,
			T.AmountInDollars,
			T.IdStatus,
			S.StatusName,
			G.GateWayName,
			T.AmountInMN,
			CO.CountryName,
			CU.CurrencyName,
			T.IdCustomer from [transfer] T (nolock)
			JOIN Agent A (nolock) on T.IdAgent=A.IdAgent
			JOIN CountryCurrency CC (nolock) on CC.IdCountryCurrency=T.IdCountryCurrency
			JOIN Country CO (nolock) on CC.IdCountry=CO.IdCountry
			JOIN Currency CU (nolock) on CC.IdCurrency=CU.IdCurrency
			JOIN PaymentType PT (nolock) on T.IdPaymentType=PT.IdPaymentType
			JOIN Payer P (nolock) on T.IdPayer=P.IdPayer
			JOIN [Status] S (nolock) on T.IdStatus=S.IdStatus
			JOIN Gateway G (nolock) on T.IdGateway=G.IdGateway
			LEFT JOIN TransferHolds H (nolock) on T.IdTransfer=H.IdTransfer AND H.IsReleased IS NULL AND H.IdStatus = 3			
		    where (T.IdStatus=24 or T.IdStatus=41) and ((SUBSTRING( T.ClaimCode , (len(T.ClaimCode ) - 3) , len(T.ClaimCode )) = @SearchParameter OR @SearchParameter =T.ClaimCode) OR T.Folio like '%'+ @SearchParameter +'%'  OR A.AgentName like  '%'+@SearchParameter+'%' OR A.AgentCode like '%'+@SearchParameter+'%')			
			order by DateOfTransfer desc
	END
	ELSE 
	BEGIN
		select 
			T.IdAgent,
			A.AgentCode, 
			T.ClaimCode,
			T.CustomerName +' '+ T.CustomerFirstLastName + ' ' + T.CustomerSecondLastName as CustomerName, 
			T.BeneficiaryName +' '+  T.BeneficiaryFirstLastName +' '+ T.BeneficiarySecondLastName as BeneficiaryName,
			A.AgentName,
			T.DateOfTransfer,
			T.DateStatusChange,
			T.IdTransfer,
			T.Folio,
			P.PayerName,
			PT.PaymentName as PaymentTypeName,
			T.AmountInDollars,
			T.IdStatus,
			S.StatusName,
			G.GateWayName,
			T.AmountInMN,
			CO.CountryName,
			CU.CurrencyName,
			T.IdCustomer from [transfer] T (nolock)
			JOIN Agent A (nolock) on T.IdAgent=A.IdAgent
			JOIN CountryCurrency CC (nolock) on CC.IdCountryCurrency=T.IdCountryCurrency
			JOIN Country CO (nolock) on CC.IdCountry=CO.IdCountry
			JOIN Currency CU (nolock) on CC.IdCurrency=CU.IdCurrency
			JOIN PaymentType PT (nolock) on T.IdPaymentType=PT.IdPaymentType
			JOIN Payer P (nolock) on T.IdPayer=P.IdPayer
			JOIN [Status] S (nolock) on T.IdStatus=S.IdStatus
			JOIN Gateway G (nolock) on T.IdGateway=G.IdGateway
			LEFT JOIN TransferHolds H (nolock) on T.IdTransfer=H.IdTransfer AND H.IsReleased IS NULL AND H.IdStatus = 3
			where T.IdStatus=41 AND ( T.ClaimCode like '%'+@SearchParameter+'%' OR T.Folio like '%'+ @SearchParameter +'%'  OR A.AgentName like  '%'+@SearchParameter+'%' OR A.AgentCode like '%'+@SearchParameter+'%')
		    --where T.IdStatus  IN (24,41,21,27) --s14
			order by DateOfTransfer desc

	END
END

If ( @IdentificationType = 1 )
BEGIN 
--		select 
--			C.IdCustomer,
--			T.IdAgent,
--			T.AgentCode, 
--			T.ClaimCode,
--			T.CustomerName, 
--			T.BeneficiaryName,
--			T.AgentName,
--			T.DateOfTransfer,
--			T.DateStatusChange,
--			T.IdTransfer,
--			T.Folio,
--			T.PayerName,
--			T.PaymentTypeName,
--			T.AmountInDollars,
--			T.IdStatus,
--			T.StatusName,
--			T.GateWayName,
--			T.AmountInMN,
--			T.CountryName,
--			T.CurrencyName
--			From Customer C
--			CROSS APPLY
--			(
--				Select top 1 
--				T.IdAgent,
--				A.AgentCode, 
--				T.ClaimCode,
--				T.CustomerName +' '+ T.CustomerFirstLastName + ' ' + T.CustomerSecondLastName as CustomerName, 
--				T.BeneficiaryName +' '+  T.BeneficiaryFirstLastName +' '+ T.BeneficiarySecondLastName as BeneficiaryName,
--				A.AgentName,
--				T.DateOfTransfer,
--				T.DateStatusChange,
--				T.IdTransfer,
--				T.Folio,
--				P.PayerName,
--				PT.PaymentName as PaymentTypeName,
--				T.AmountInDollars,
--				T.IdStatus,
--				S.StatusName,
--				G.GateWayName,
--				T.AmountInMN,
--				CO.CountryName,
--				CU.CurrencyName,
--				T.IdCustomer 
--				from transfer T 
--				JOIN Agent A on T.IdAgent = A.IdAgent
--				JOIN CountryCurrency CC on CC.IdCountryCurrency=T.IdCountryCurrency
--				JOIN Country CO on CC.IdCountry=CO.IdCountry
--				JOIN Currency CU on CC.IdCurrency=CU.IdCurrency
--				JOIN PaymentType PT on T.IdPaymentType=PT.IdPaymentType
--				JOIN Payer P on T.IdPayer=P.IdPayer
--				JOIN Status S on T.IdStatus=S.IdStatus
--				JOIN Gateway G on T.IdGateway=G.IdGateway
--				--where (C.IdCustomer = T.IdCustomer) and (T.IdStatus=41 OR T.IdStatus=24)
--				where (C.IdCustomer = T.IdCustomer) and T.IdStatus  IN (41,24,27,29) --s14 solo para identification (checked)
--			) T 
--			Where T.CustomerName like '%'+@SearchParameter+'%'
--			order by T.DateOfTransfer desc

			SELECT
				C.IdCustomer,
				T.IdAgent,
				T.AgentCode, 
				T.ClaimCode,
				T.CustomerName, 
				T.BeneficiaryName,
				T.AgentName,
				T.DateOfTransfer,
				T.DateStatusChange,
				T.IdTransfer,
				T.Folio,
				T.PayerName,
				T.PaymentTypeName,
				T.AmountInDollars,
				T.IdStatus,
				T.StatusName,
				T.GateWayName,
				T.AmountInMN,
				T.CountryName,
				T.CurrencyName
			FROM Customer C (nolock)
			INNER JOIN
				(
					SELECT
					T.IdAgent,
					A.AgentCode, 
					T.ClaimCode,
					T.CustomerName +' '+ T.CustomerFirstLastName + ' ' + T.CustomerSecondLastName as CustomerName, 
					T.BeneficiaryName +' '+  T.BeneficiaryFirstLastName +' '+ T.BeneficiarySecondLastName as BeneficiaryName,
					A.AgentName,
					T.DateOfTransfer,
					T.DateStatusChange,
					T.IdTransfer,
					T.Folio,
					P.PayerName,
					PT.PaymentName as PaymentTypeName,
					T.AmountInDollars,
					T.IdStatus,
					S.StatusName,
					G.GateWayName,
					T.AmountInMN,
					CO.CountryName,
					CU.CurrencyName,
					T.IdCustomer 
					FROM [transfer] T (nolock)
						 INNER JOIN Agent A (nolock) on T.IdAgent = A.IdAgent
						 INNER JOIN CountryCurrency CC (nolock) on CC.IdCountryCurrency=T.IdCountryCurrency
						 INNER JOIN Country CO (nolock) on CC.IdCountry=CO.IdCountry
						 INNER JOIN Currency CU (nolock) on CC.IdCurrency=CU.IdCurrency
						 INNER JOIN PaymentType PT (nolock) on T.IdPaymentType=PT.IdPaymentType
						 INNER JOIN Payer P (nolock) on T.IdPayer=P.IdPayer
						 INNER JOIN Status S (nolock) on T.IdStatus=S.IdStatus
						 INNER JOIN Gateway G (nolock) on T.IdGateway=G.IdGateway					
					WHERE T.IdStatus  IN (41,24,27,29)
				) T  ON T.IdCustomer = C.IdCustomer
			WHERE T.CustomerName like '%'+@SearchParameter+'%' AND T.IdStatus  IN (41,24,27,29)
			ORDER BY T.DateOfTransfer DESC
END

If (@IdentificationType=2)
BEGIN 
    select 
			T.IdAgent,
			A.AgentCode, 
			T.ClaimCode,
			T.CustomerName +' '+ T.CustomerFirstLastName + ' ' + T.CustomerSecondLastName as CustomerName, 
			T.BeneficiaryName +' '+  T.BeneficiaryFirstLastName +' '+ T.BeneficiarySecondLastName as BeneficiaryName,
			A.AgentName,
			T.DateOfTransfer,
			T.DateStatusChange,
			T.IdTransfer,
			T.Folio,
			P.PayerName,
			PT.PaymentName as PaymentTypeName,
			T.AmountInDollars,
			T.IdStatus,
			S.StatusName,
			G.GateWayName,
			T.AmountInMN,
			CO.CountryName,
			CU.CurrencyName,
			T.IdCustomer from [transfer] T (nolock)
			JOIN Agent A (nolock) on T.IdAgent=A.IdAgent
			JOIN CountryCurrency CC (nolock) on CC.IdCountryCurrency=T.IdCountryCurrency
			JOIN Country CO (nolock) on CC.IdCountry=CO.IdCountry
			JOIN Currency CU (nolock) on CC.IdCurrency=CU.IdCurrency
			JOIN PaymentType PT (nolock) on T.IdPaymentType=PT.IdPaymentType
			JOIN Payer P (nolock) on T.IdPayer=P.IdPayer
			JOIN [Status] S (nolock) on T.IdStatus=S.IdStatus
			JOIN Gateway G (nolock) on T.IdGateway=G.IdGateway			
			where T.IdStatus=41 AND ( T.ClaimCode like '%'+@SearchParameter+'%' OR T.Folio like '%'+ @SearchParameter +'%'  OR A.AgentName like  '%'+@SearchParameter+'%' OR A.AgentCode like '%'+@SearchParameter+'%')
END

If (@IdentificationType=3)
BEGIN 
    select 
			T.IdAgent,
			A.AgentCode, 
			T.ClaimCode,
			T.CustomerName +' '+ T.CustomerFirstLastName + ' ' + T.CustomerSecondLastName as CustomerName, 
			T.BeneficiaryName +' '+  T.BeneficiaryFirstLastName +' '+ T.BeneficiarySecondLastName as BeneficiaryName,
			A.AgentName,
			T.DateOfTransfer,
			T.DateStatusChange,
			T.IdTransfer,
			T.Folio,
			P.PayerName,
			PT.PaymentName as PaymentTypeName,
			T.AmountInDollars,
			T.IdStatus,
			S.StatusName,
			G.GateWayName,
			T.AmountInMN,
			CO.CountryName,
			CU.CurrencyName,
			T.IdCustomer from [transfer] T (nolock)
			JOIN Agent A (nolock) on T.IdAgent=A.IdAgent
			JOIN CountryCurrency CC (nolock) on CC.IdCountryCurrency=T.IdCountryCurrency
			JOIN Country CO (nolock) on CC.IdCountry=CO.IdCountry
			JOIN Currency CU (nolock) on CC.IdCurrency=CU.IdCurrency
			JOIN PaymentType PT (nolock) on T.IdPaymentType=PT.IdPaymentType
			JOIN Payer P (nolock) on T.IdPayer=P.IdPayer
			JOIN Status S (nolock) on T.IdStatus=S.IdStatus
			JOIN Gateway G (nolock) on T.IdGateway=G.IdGateway
			JOIN (
				SELECT BR.[IdTransfer]
				FROM [dbo].[BrokenRulesByTransfer] BR (NOLOCK)
				JOIN [dbo].[ComplianceFormat] CF (NOLOCK) ON BR.[ComplianceFormatId] = CF.[ComplianceFormatId]
				WHERE LTRIM(ISNULL(CF.[FileOfName],'')) != ''
				GROUP BY BR.[IdTransfer]
			) BRT ON T.[IdTransfer] = BRT.[IdTransfer]
			where T.IdStatus=41 AND ( T.ClaimCode like '%'+@SearchParameter+'%' OR T.Folio like '%'+ @SearchParameter +'%'  OR A.AgentName like  '%'+@SearchParameter+'%' OR A.AgentCode like '%'+@SearchParameter+'%')
END
