--drop procedure [WellsFargo].[st_GetLastTransferWFEcheckByAgent]
create procedure [WellsFargo].[st_GetLastTransferWFEcheckByUser]
(
    @IdUser int
)
as

SELECT top 1 Token,w.FirstName,w.LastName,w.ZipCode,w.Street,w.City,w.State,w.Country,w.PhoneNUmber,DBO.[fnDecryptData](w.AccountNumberData) AccountNumber,DBO.[fnDecryptData](w.RoutingNumberData) RoutingNumber,w.AccountType,isnull(w.Email,'') Email,w.IdAgentAccount,isnull(w.BankName,'') BankName,isnull(w.Alias,'') Alias 
FROM  [WellsFargo].[TransferWFEcheck] w
join [WellsFargo].AgentAccount a on w.IdAgentAccount=a.IdAgentAccount and a.IdGenericStatus=1
where w.enterbyiduser=@IdUser order by w.DateOfCreation desc