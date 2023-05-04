CREATE PROCEDURE [dbo].[st_GetInquiryLetterInfo](@IdTicket INT)      
AS      
/********************************************************************
<Author> Lidia Ch </Author>
<app> RS </app>
<Description> Get Data for Inquiry Report </Description>
*********************************************************************/

SET NOCOUNT ON;

DECLARE @IdTransfer INT

SET @IdTransfer = (SELECT IdTransfer FROM [dbo].[FD_InquiryTicket] WITH(NOLOCK) WHERE Id=@IdTicket)

IF EXISTS (SELECT 1 FROM TransferClosed WITH(NOLOCK) WHERE IdTransferClosed=@IdTransfer)
BEGIN 

	SELECT                
	  fd.Id Folio,          
	  U.UserName,             
	  T.ClaimCode,         
	  T.CustomerName+' '+ T.CustomerFirstLastName+' '+T.CustomerSecondLastName CustomerFullName, 
	  ISNULL(C.[Email], '') CustomerEmail,
	  T.CustomerAddress,
	  T.CustomerCity, 
	  T.CustomerState, 
	  T.CustomerZipcode,
	  T.CustomerCountry
	  --'sample@gmail.com' CustomerEmail
	FROM TransferClosed T WITH(NOLOCK)
		LEFT JOIN [dbo].[ContactEmail] C ON C.IdReference=T.IdCustomer AND C.[IdContactEntity]=1 AND C.IsPrincipal=1
		LEFT JOIN [dbo].[FD_InquiryTicket] FD ON FD.IdTransfer=T.IdTransferClosed
		INNER JOIN Users U WITH(NOLOCK) ON U.IdUser = FD.EnterByIdUser 
	WHERE FD.Id = @IdTicket 
	
END
ELSE
BEGIN 
	SELECT                
	  fd.Id Folio,       
	  U.UserName,             
	  T.ClaimCode,         
	  T.CustomerName+' '+ T.CustomerFirstLastName+' '+T.CustomerSecondLastName CustomerFullName, 
	  ISNULL(C.[Email], '') CustomerEmail,
	  T.CustomerAddress,
	  T.CustomerCity, 
	  T.CustomerState, 
	  T.CustomerZipcode,
	  T.CustomerCountry
	  --'sample@gmail.com' CustomerEmail
	FROM Transfer T WITH(NOLOCK)
		LEFT JOIN [dbo].[ContactEmail] C ON C.IdReference=T.IdCustomer AND C.[IdContactEntity]=1 AND C.IsPrincipal=1
		LEFT JOIN [dbo].[FD_InquiryTicket] FD ON FD.IdTransfer=T.IdTransfer
		INNER JOIN Users U WITH(NOLOCK) ON U.IdUser = FD.EnterByIdUser     
		WHERE FD.Id = @IdTicket 
END


--select top 1 IdTransferClosed from TransferClosed 
--where IdStatus=30
--order by IdTransferClosed desc

--exec [st_GetInquiryLetterInfo] 48358552 48358301

--SELECT * FROM MAXI.DBO.Transfer
--WHERE IdTransfer=48358552

--SELECT * FROM ContactEmail
--WHERE IdReference=4959781
