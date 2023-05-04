
CREATE PROCEDURE [dbo].[st_getBeneficiaryHistoryByFullName](@FullName VARCHAR(200), @idBeneficiary INT = 0)
AS 
/********************************************************************
<Author>Fabian Gonzalez</Author>
<app>Agent </app>
<Description>Obtiene historico de envios de un Beneficiario con un determinado nombre </Description>

<ChangeLog>
<log Date="19/07/2017" Author="Fgonzalez">Creacion</log>
<log Date="11/08/2017" Author="Fgonzalez">Se cambia ciudad y estado por Cliente y Pagador</log>
<log Date="20/07/2018" Author="jmmolina">Se quita el forzado del indice ixDateOfTransfer #1</log>
</ChangeLog>

*********************************************************************/
BEGIN 
	DECLARE @MatchingCustomers TABLE (idBeneficiary INT)
	
	INSERT INTO @MatchingCustomers
	SELECT idBeneficiary FROM Beneficiary WHERE FullName LIKE replace(@FullName,' ','')
	
	IF @idBeneficiary > 0 BEGIN 
	INSERT INTO @MatchingCustomers VALUES (@idBeneficiary)
	END 
	
	SELECT 
	tr.IdAgent, 
	AgentCity=isnull(CustomerName,'')+' '+isnull(CustomerFirstLastName,'')+' '+isnull(CustomerSecondLastName,''),
	AgentState= p.PayerName,
	'TRAN' AS [Type],
	AmountInDollars,DateOfTransfer,
	tr.Folio
	--FROM Transfer tr WITH (Nolock, INDEX(ixDateOfTransfer))  #1
	FROM [dbo].[Transfer] tr WITH (Nolock) 
	JOIN Payer p WITH (Nolock) ON p.idPayer= tr.idPayer
	JOIN Agent ag WITH (nolock) ON ag.IdAgent = tr.IdAgent
	WHERE 1 = 1
	  AND idBeneficiary IN (SELECT idBeneficiary FROM @MatchingCustomers) 
	  AND DateOfTransfer >= dateadd(day,-30,getdate()) 
	  AND IdStatus not in (22,31)
	UNION	
	SELECT 
	tr.IdAgent, 
	AgentCity=isnull(CustomerName,'')+' '+isnull(CustomerFirstLastName,'')+' '+isnull(CustomerSecondLastName,''),
	AgentState= p.PayerName,
	'TRAN' AS [Type],
	AmountInDollars,DateOfTransfer,
	tr.Folio
	--FROM TransferClosed tr WITH (Nolock, INDEX(ixDateOfTransfer)) #1 
	FROM [dbo].[TransferClosed] tr WITH (Nolock)  
	JOIN Payer p WITH (Nolock) ON p.idPayer= tr.idPayer
	JOIN Agent ag WITH (nolock) ON ag.IdAgent = tr.IdAgent
	WHERE 1 = 1
	  AND DateOfTransfer >= dateadd(day,-30,getdate())
	  AND idBeneficiary IN (SELECT idBeneficiary FROM @MatchingCustomers) 
	  AND IdStatus not in (22,31)
	ORDER BY  DateOfTransfer DESC 

END 




