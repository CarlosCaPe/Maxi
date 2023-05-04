--drop procedure [WellsFargo].[st_GetUserAccount]

create procedure [WellsFargo].[st_GetAgentAccount]
(
    @IdAgent int
)
as

SELECT IdAgentAccount,Alias,FirstName,LastName,ZipCode,Street,City,State,Country,PhoneNUmber,DBO.[fnDecryptData](AccountNumberData) AccountNumber,DBO.[fnDecryptData](RoutingNumberData) RoutingNumber,AccountType,Email,IdAgentAccount,BankName FROM  [WellsFargo].[AgentAccount] where idgenericstatus=1 and IdAgent=@IdAgent order by Alias