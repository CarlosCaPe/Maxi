CREATE PROCEDURE [dbo].[st_GetInquiryLetterResolution](@IdTransfer INT)      
AS      
/********************************************************************
<Author> Lidia Ch </Author>
<app> RS </app>
<Description> Get Data for Inquiry Report Resolution: Error & No Error </Description>

<ChangeLog>
<log Date="09/02/2023" Author="cagarcia">BM-522 Se agrega campo 'ClaimReasonENG' </log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

declare @IdtransferT int 

SET @IdtransferT = (SELECT IdTransfer FROM [FD_InquiryTicket] WITH(NOLOCK) WHERE Id=@IdTransfer)


IF EXISTS (SELECT 1 FROM TransferClosed WITH(NOLOCK) WHERE IdTransferClosed=@IdTransferT)
BEGIN 

	SELECT 
		fd.CreateDate InquiryDate,
		fd.Id InquiryCase,
		fd.InquiryReason ClaimReason,   
		fd.InquiryReasonENG 'ClaimReasonENG',             
		T.Folio,       
		U.UserName,             
		T.ClaimCode,
		T.DateOfTransfer,
		T.AmountInDollars,
		A.AgentCity,
		T.PayerName,
		A.AgentState,
		T.CustomerName+' '+ T.CustomerFirstLastName+' '+T.CustomerSecondLastName CustomerFullName, 
		T.BeneficiaryName+' '+ T.BeneficiaryFirstLastName+' '+T.BeneficiarySecondLastName BeneficiaryFullName, 
		BR.Address + ' '+ BR.zipcode LocationAddress,
		st.StateName LocationState, 
		T.CountryName LocationCity,
		ISNULL(fd.CustomerEmail, '') CustomerEmail,
		T.CustomerAddress,
	    T.CustomerCity, 
	    T.CustomerState, 
		T.CustomerZipcode,
		T.CustomerCountry,
		A.AgentFax
	FROM TransferClosed T WITH(NOLOCK)
		LEFT JOIN [dbo].[FD_InquiryTicket] FD WITH(NOLOCK) ON FD.IdTransfer=T.IdTransferClosed
		INNER JOIN Agent A WITH(NOLOCK) ON A.IdAgent=T.IdAgent
		--LEFT JOIN [dbo].[ContactEmail] C ON C.IdReference=T.IdCustomer AND C.[IdContactEntity]=1 AND C.IsPrincipal=1
		INNER JOIN Users U WITH(NOLOCK) ON U.IdUser = FD.EnterByIdUser     
		INNER JOIN Branch BR WITH(NOLOCK) ON BR.IdBranch=T.IdBranch
		INNER JOIN City CT WITH(NOLOCK) ON CT.IdCity=BR.IdCity
		INNER JOIN State ST WITH(NOLOCK) ON ST.IdState=CT.IdState
	WHERE fd.Id = @IdTransfer 
	
END
else IF EXISTS (SELECT 1 FROM Transfer WITH(NOLOCK) WHERE IdTransfer=@IdTransferT)
BEGIN 

	SELECT 
		fd.CreateDate InquiryDate,
		fd.Id InquiryCase,
		fd.InquiryReason ClaimReason,
		fd.InquiryReasonENG 'ClaimReasonENG',             
		T.Folio,       
		U.UserName,             
		T.ClaimCode,
		T.DateOfTransfer,
		T.AmountInDollars,
		A.AgentCity,
		PY.PayerName,
		A.AgentState,
		T.CustomerName+' '+ T.CustomerFirstLastName+' '+T.CustomerSecondLastName CustomerFullName, 
		T.BeneficiaryName+' '+ T.BeneficiaryFirstLastName+' '+T.BeneficiarySecondLastName BeneficiaryFullName, 
		BR.Address + ' '+ BR.zipcode LocationAddress,
		st.StateName LocationState, 
		CY.CountryName LocationCity,
		ISNULL(fd.CustomerEmail, '') CustomerEmail,
		T.CustomerAddress,
	    T.CustomerCity, 
	    T.CustomerState, 
		T.CustomerZipcode,
		T.CustomerCountry,
		A.AgentFax
	FROM Transfer T WITH(NOLOCK)
		INNER JOIN Agent A WITH(NOLOCK) ON A.IdAgent=T.IdAgent
		LEFT JOIN [dbo].[FD_InquiryTicket] FD WITH(NOLOCK) ON FD.IdTransfer=T.IdTransfer
		--LEFT JOIN [dbo].[ContactEmail] C ON C.IdReference=T.IdCustomer AND C.[IdContactEntity]=1 AND C.IsPrincipal=1
		INNER JOIN Users U WITH(NOLOCK) ON U.IdUser = FD.EnterByIdUser     
		INNER JOIN Branch BR WITH(NOLOCK) ON BR.IdBranch=T.IdBranch
		INNER JOIN City CT WITH(NOLOCK) ON CT.IdCity=BR.IdCity
		INNER JOIN State ST WITH(NOLOCK) ON ST.IdState=CT.IdState
		INNER JOIN Payer PY WITH(NOLOCK) ON PY.IdPayer=T.IdPayer
		INNER JOIN CountryCurrency CC WITH(NOLOCK) ON CC.IdCountryCurrency=T.IdCountryCurrency
		INNER JOIN Country CY WITH(NOLOCK) ON CY.IdCountry=CC.IdCountry
	WHERE fd.Id = @IdTransfer 
	
END

--exec [st_GetInquiryLetterResolution] 99

--select * from [FD_InquiryTicket]
