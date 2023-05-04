
CREATE PROCEDURE [dbo].[st_getCustomerHistoryByFullName](@FullName VARCHAR(200), @idCustomer INT = 0)
AS 
/********************************************************************
<Author>Fabian Gonzalez</Author>
<app>Agent </app>
<Description>Obtiene historico de envios de un Cliente con un determinado nombre </Description>

<ChangeLog>
<log Date="19/07/2017" Author="Fgonzalez">Creacion</log>
<log Date="11/08/2017" Author="Fgonzalez">Se cambia ciudad y estado por beneficiario y Pagador</log>
<log Date="04/04/2018" Author="jdarellano" Name="#1">Se quita filtro por múltiple "Customer".</log>
</ChangeLog>

*********************************************************************/
BEGIN 
	DECLARE @MatchingCustomers TABLE (idCustomer INT)
	
	--INSERT INTO @MatchingCustomers
	--SELECT IdCustomer FROM Customer WHERE FullName LIKE replace(@FullName,' ','')--#1
	
	
	IF @idCustomer > 0 BEGIN 
	INSERT INTO @MatchingCustomers VALUES (@idCustomer)
	END 
	
	SELECT tr.IdAgent, 
	AgentCity=isnull(BeneficiaryName,'')+' '+isnull(BeneficiaryFirstLastName,'')+' '+isnull(BeneficiarySecondLastName,''),
	AgentState= p.PayerName,
	'TRAN' AS Type,AmountInDollars,DateOfTransfer,
	tr.Folio
	FROM Transfer tr WITH (Nolock) 
	JOIN Payer p with (nolock)
	ON p.idPayer= tr.idPayer
	JOIN Agent ag WITH (nolock)
	ON ag.IdAgent = tr.IdAgent
	--WHERE IdCustomer IN (SELECT IdCustomer FROM @MatchingCustomers)--#1
	WHERE IdCustomer = @idCustomer
	AND DateOfTransfer >= dateadd(day,-30,getdate()) and IdStatus not in (22,31)
	UNION	
	SELECT tr.IdAgent, 
	AgentCity=isnull(BeneficiaryName,'')+' '+isnull(BeneficiaryFirstLastName,'')+' '+isnull(BeneficiarySecondLastName,''),
	AgentState= p.PayerName,
	'TRAN' AS Type,AmountInDollars,DateOfTransfer,tr.Folio
	FROM TransferClosed tr WITH (Nolock) 
	JOIN Payer p with (nolock)
	ON p.idPayer= tr.idPayer
	JOIN Agent ag WITH (nolock)
	ON ag.IdAgent = tr.IdAgent
	WHERE DateOfTransfer >= dateadd(day,-30,getdate())
	--AND IdCustomer IN (SELECT IdCustomer FROM @MatchingCustomers) and IdStatus not in (22,31)--#1
	AND IdCustomer = @idCustomer and IdStatus not in (22,31)
	
	/*UNION 
	SELECT ag.IdAgent, ag.AgentCity,AgentState,'CHECK',Amount,DateOfMovement,IdCheck FROM Checks ch with (nolock) 
	JOIN Agent ag WITH (nolock)
	ON ag.IdAgent = ch.IdAgent
	WHERE IdCustomer IN (SELECT IdCustomer FROM @MatchingCustomers) 
	AND DateOfMovement >= dateadd(day,-30,getdate()) and IdStatus not in (31)*/
	ORDER BY DateOfTransfer DESC 
END 



