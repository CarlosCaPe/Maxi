CREATE procedure [Balance].[st_AgentBalanceDetailByIdAgentBalanceService]
(              
    @IdAgent int,
    @IdAgentBalanceService int,
    @DateFrom datetime,
    @DateTo datetime
)    

/********************************************************************
<Author> ??? </Author>
<app> Corporative </app>
<Description>Gets AgentBalance Report(OtherProduct DataSet)</Description>

<ChangeLog>
<log Date="01/02/2018" Author="snevarez"> Fix:Ticket 611: Excluir Bonus de la seccion Deposits, Credits and Charges en el reporte AgentBlance (no aplicado a produccion) </log>
<log Date="08/05/2018" Author="jmmolina">Se agrega validacion para los cheques de tipo CHNFS, para que no presnte amount #1 (Aplicado en Stage)</log>
<log Date="30/05/2018" Author="azavala,">Merge entre cambio Sergio y Molina </log>
<log Date="15/02/2022" Author="jcsierra">Se contemplan debitos y creditos de TDD</log>
<log Date="07/05/2022" Author="saguilar">Se Agregan With (nolock) faltantes y se limita a un dia el Reporte</log>
<log Date="09/05/2022" Author="saguilar">Se limita a un dia el Reporte a 3 dias</log>
<log Date="11/05/2022" Author="saguilar">Se quita la limitante de dias para que se pueda consultar el rango de fechas seleccionado </log>
<log Date="20/06/2022" Author="jdarellano" Name="#2">Performance: se cambian variables tipo tabla por tablas temporales y se agregan esquemas.</log>
<log Date="11/11/2022" Author="jcsierra">Se incorpora @IdAgentBalanceService = 10 MoneyOrder</log>
</ChangeLog>
*********************************************************************/          
AS             

SET NOCOUNT ON;         
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

---------------------------------------------------------------------------------------------------------------------
--DECLARE @IdAgent int              
--DECLARE @IdAgentBalanceService int
--DECLARE @DateFrom datetime               
--DECLARE @DateTo datetime        
---------------------------------------------------------------------------------------------------------------------
--DECLARE @TypeM TABLE
CREATE TABLE #TypeM--#2
(
    TypeOfMovement NVARCHAR(MAX)
);

--DECLARE @Balance TABLE
CREATE TABLE #Balance--#2
(
	IdAgentBalance INT,
	TypeOfMovement NVARCHAR(MAX),
	DateOfMovement DATETIME,
	Reference int,
	[DESCRIPTION] NVARCHAR(MAX),
	Country NVARCHAR(MAX),
	Fee MONEY,
	Commission MONEY,
	FxFee MONEY,
	Amount MONEY,
	AmountForBalance MONEY,
	nsffee MONEY
);

SELECT @DateFrom = dbo.RemoveTimeFromDatetime(@DateFrom),@DateTo = dbo.RemoveTimeFromDatetime(@DateTo + 1);

---------------------------------------------------------------------------------------------------------------------
	--SET @IdAgent = 1244
	--SET @IdAgentBalanceService = 7
	--SET @DateFrom  = '2013-01-01'              
	--SET @DateTo = '2016-01-01'              
---------------------------------------------------------------------------------------------------------------------

/*
1,Money Transfers
2,Bill Payments
3,Long Distance
4,Top Ups
5,Deposits, Credits and Charges
6,Others
7,CH~
*/

---------------------------------------------------------------------------------------------------------------------
IF @IdAgentBalanceService = 1 
BEGIN
	INSERT INTO #TypeM--#2
	VALUES  ('CANC'),
			('REJ'),
			('CANCM'),
			('TRAN');
------------------------------------------------------
	INSERT INTO #Balance--#2
	SELECT
		IdAgentBalance,     
		CASE WHEN TypeOfMovement = 'CANC' AND OldIdTransfer IS NOT NULL THEN 'CANCM'
		ELSE TypeOfMovement END TypeOfMovement,
		DateOfMovement,
		CASE 
			WHEN ISNULL(Reference,'') = '' THEN CONVERT(varchar,IdAgentBalance)
			ELSE Reference
		END Reference,
		[Description],
		Country,
		CASE 
			WHEN DebitOrCredit = 'Debit' THEN (t.Fee - t.Discount)
			ELSE (t.Fee - t.Discount) * (-1) 
		END Fee,           
		Commission,      
		FxFee,                         
		CASE 
			WHEN DebitOrCredit = 'Debit' THEN t.AmountInDollars
			ELSE t.AmountInDollars * (-1)
		END Amount,
		CASE 
			WHEN DebitOrCredit = 'Debit' THEN Amount 
			ELSE Amount * (-1)
		END AmountForBalance,
		0.0 nsffee
	FROM dbo.AgentBalance AS b WITH (NOLOCK)
	INNER JOIN dbo.[Transfer] AS t WITH (NOLOCK) ON b.IdTransfer = t.idtransfer
	LEFT JOIN dbo.TransferModify AS m WITH (NOLOCK) ON t.idTransfer = m.OldIdTransfer
	WHERE b.IdAgent = @IdAgent              
	AND DateOfMovement >= @DateFrom AND DateOfMovement < @DateTo  
	--AND TypeOfMovement IN (SELECT TypeOfMovement FROM #TypeM)
	AND EXISTS (SELECT 1 FROM #TypeM AS M WHERE b.TypeOfMovement = M.TypeOfMovement)--#2
			
	UNION ALL

	SELECT
		IdAgentBalance,
		CASE WHEN TypeOfMovement = 'CANC' AND OldIdTransfer IS NOT NULL THEN 'CANCM'
		ELSE TypeOfMovement END TypeOfMovement,
		DateOfMovement,
		CASE
			WHEN ISNULL(Reference,'') = '' THEN CONVERT(varchar,IdAgentBalance)
			ELSE Reference
		END
		Reference,
		[Description],
		Country,
		CASE
			WHEN DebitOrCredit = 'Debit' THEN (t.Fee - t.Discount)
			ELSE (t.Fee - t.Discount) * (-1)
		END Fee,
		Commission,
		FxFee,
		CASE WHEN DebitOrCredit = 'Debit' THEN t.AmountInDollars ELSE t.AmountInDollars*(-1) END Amount,
		CASE WHEN DebitOrCredit = 'Debit' THEN Amount ELSE Amount * (-1) END AmountForBalance,
		0.0 nsffee
	FROM dbo.AgentBalance AS b WITH (NOLOCK)
	INNER JOIN dbo.TransferClosed AS t WITH (NOLOCK) ON b.IdTransfer = t.idtransferclosed
	LEFT JOIN dbo.TransferModify AS m WITH (NOLOCK) ON t.idtransferclosed = m.OldIdTransfer
	WHERE b.IdAgent = @IdAgent
	AND DateOfMovement >= @DateFrom AND DateOfMovement < @DateTo  
	--AND TypeOfMovement in (select TypeOfMovement from @TypeM)			
	AND EXISTS (SELECT 1 FROM #TypeM AS M WHERE b.TypeOfMovement = M.TypeOfMovement);--#2

	DELETE FROM #TypeM;--#1

	INSERT INTO #TypeM VALUES ('CGO');--#2

	INSERT INTO #Balance--#2
	SELECT    
		IdAgentBalance,
		'TRAN',
		DateOfMovement,
		CASE
			WHEN ISNULL(Reference,'') = '' THEN CONVERT(varchar,IdAgentBalance)
			ELSE Reference
		END
		Reference,
		[Description],
		Country,
		0 Fee,
		Commission,
		FxFee,
		CASE WHEN DebitOrCredit = 'Debit' THEN Amount ELSE Amount * (-1) END Amount,    
		CASE WHEN DebitOrCredit = 'Debit' THEN Amount ELSE Amount * (-1) END AmountForBalance,
		0.0 nsffee
    FROM dbo.AgentBalance AS b WITH (NOLOCK)
	WHERE b.IdAgent = @IdAgent
	AND DateOfMovement >= @DateFrom AND DateOfMovement < @DateTo 
	--AND TypeOfMovement IN (select TypeOfMovement from @TypeM) 
	AND b.Commission != 0
	AND EXISTS (SELECT 1 FROM #TypeM AS M WHERE b.TypeOfMovement = M.TypeOfMovement)--#2
END;

IF @IdAgentBalanceService IN (2,3,4)
BEGIN
	INSERT INTO #TypeM--#2
	SELECT typeofmovement
	FROM dbo.[RelationAgentBalanceServiceOtherProduct] AS r WITH (NOLOCK)
	INNER JOIN dbo.AgentBalanceHelper AS h WITH (NOLOCK) ON r.idotherproduct = h.idotherproduct 
	WHERE r.IdAgentBalanceService = @IdAgentBalanceService;

	INSERT INTO #Balance--#2
	SELECT
		IdAgentBalance,     
		TypeOfMovement,              
		DateOfMovement,              
		CASE 
			WHEN ISNULL(Reference,'') = '' THEN CONVERT(varchar,IdAgentBalance)
			ELSE Reference
		END
		Reference,
		[Description],
		--case 
		--    when b.TypeOfMovement in ('RBP','CRBP') then co.CountryCode 
		--    else b.Country
		--end            
		--Country,  
		b.country,
		CASE WHEN DebitOrCredit = 'Debit' THEN ISNULL(t.fee,ISNULL(P.FEE,0)) ELSE ISNULL(t.fee,ISNULL(P.FEE,0)) * (-1) END Fee,
		B.Commission,
		FxFee,
		CASE WHEN DebitOrCredit = 'Debit' THEN
			CASE WHEN b.IsMonthly = 1 THEN B.Amount - ISNULL(t.fee,ISNULL(P.Fee,0)) ELSE B.Amount + B.Commission END
			ELSE
			CASE WHEN b.IsMonthly = 1 THEN (B.Amount - ISNULL(t.fee,ISNULL(P.Fee,0))) * (-1) ELSE B.Amount * (-1) + B.Commission END
		END Amount,
		CASE WHEN DebitOrCredit = 'Debit' THEN B.Amount ELSE B.Amount * (-1) END AmountForBalance,
		0.0 nsffee
	FROM dbo.AgentBalance AS b WITH (NOLOCK)
	LEFT JOIN dbo.BillPaymentTransactions AS t WITH (NOLOCK) ON b.idtransfer = t.IdBillPayment AND b.TypeOfMovement IN ('BP','CBP')
	LEFT JOIN Operation.ProductTransfer AS P WITH (NOLOCK) ON b.idtransfer = P.IdProductTransfer AND b.TypeOfMovement IN ('RBP','CRBP')
	--left join Regalii.TransferR r on p.IdProductTransfer=r.IdProductTransfer
	--left join Country co on r.IdCountry=co.IdCountry    
	WHERE b.IdAgent = @IdAgent
	AND DateOfMovement >= @DateFrom AND DateOfMovement < @DateTo  
	--AND TypeOfMovement in  (select TypeOfMovement from @TypeM)  
	AND b.TypeOfMovement NOT IN ('FBP','FCBP')
	AND EXISTS (SELECT 1 FROM #TypeM AS M WHERE b.TypeOfMovement = M.TypeOfMovement);--#1
				      
	INSERT INTO #Balance--#2
	SELECT    
		IdAgentBalance,     
		TypeOfMovement,              
		DateOfMovement,              
		CASE 
			WHEN ISNULL(Reference,'') = '' THEN CONVERT(varchar,IdAgentBalance)
			ELSE Reference
		END
		Reference,              
		[Description],   
		b.country,					                   
			CASE WHEN DebitOrCredit = 'Debit' THEN ISNULL(f1.fee,ISNULL(P.FEE,0)) ELSE ISNULL(f1.fee,ISNULL(P.FEE,0)) * (-1) END Fee,                
		B.Commission,      
		FxFee,                          
		CASE WHEN DebitOrCredit = 'Debit' THEN
			CASE WHEN b.IsMonthly = 1 THEN B.Amount - ISNULL(f1.fee,ISNULL(P.Fee,0)) ELSE B.Amount + B.Commission END
			ELSE 
			CASE WHEN b.IsMonthly = 1 THEN (B.Amount - ISNULL(f1.fee,ISNULL(P.Fee,0))) * (-1) ELSE B.Amount * (-1) + B.Commission END
		END Amount,    
		CASE WHEN DebitOrCredit = 'Debit' THEN B.Amount ELSE B.Amount * (-1) END AmountForBalance,
		0.0 nsffee
	FROM dbo.AgentBalance AS b WITH (NOLOCK)
	LEFT JOIN BillPayment.TRansferR AS f1 WITH (NOLOCK) ON b.idtransfer = f1.IdProductTransfer AND b.TypeOfMovement IN ('FBP','FCBP')
	LEFT JOIN Operation.ProductTransfer AS P WITH (NOLOCK) ON b.idtransfer = P.IdProductTransfer AND b.TypeOfMovement IN ('FBP','FCBP')
	WHERE b.IdAgent = @IdAgent
	AND DateOfMovement >= @DateFrom AND DateOfMovement < @DateTo  
	--AND TypeOfMovement IN (SELECT TypeOfMovement FROM @TypeM)   
	AND b.TypeOfMovement IN ('FBP','FCBP')
	AND EXISTS (SELECT 1 FROM #TypeM AS M WHERE b.TypeOfMovement = M.TypeOfMovement);--#1
END;

IF @IdAgentBalanceService = 7
BEGIN
	INSERT INTO #TypeM--#2   
	SELECT typeofmovement 
	FROM dbo.[RelationAgentBalanceServiceOtherProduct] AS r WITH (NOLOCK) 
	INNER JOIN dbo.AgentBalanceHelper AS h WITH (NOLOCK) ON r.idotherproduct = h.idotherproduct 
	WHERE r.IdAgentBalanceService = @IdAgentBalanceService;

	INSERT INTO #TypeM--#2
	VALUES ('CHNFS');

	INSERT INTO #Balance--#2
	SELECT IdAgentBalance,     
		TypeOfMovement,              
		b.DateOfMovement,                  
		Reference,              
		[Description],              
		ISNULL(country,'') Country,  
		--------------------------------------------------------------------------------------------------
		CASE WHEN TypeOfMovement != 'CHNFS' THEN
			CASE 
				WHEN DebitOrCredit = 'Debit' THEN t.Fee * (-1)
				--
				WHEN TypeOfMovement = 'CH' THEN t.Fee
				WHEN TypeOfMovement = 'CHRTN' THEN t.Fee
				--
				ELSE t.Fee
			END					  
		ELSE 0 END Fee,               
	--------------------------------------------------------------------------------------------------			     
		0 Commission,
		CASE WHEN TypeOfMovement = 'CHNFS'
			THEN t.Comission
			ELSE 0
		END FxFee,   
		CASE WHEN TypeOfMovement != 'CHNFS' THEN --#1
			CASE WHEN DebitOrCredit = 'Debit' THEN t.Amount
			ELSE t.Amount * (-1)
			END
		ELSE 0 END Amount,    
		CASE WHEN DebitOrCredit = 'Debit' THEN B.Amount ELSE B.Amount * (-1) END AmountForBalance,
	--------------------------------------------------------------------------------------------------
		CASE WHEN TypeOfMovement = 'CHNFS' 
			THEN CONVERT(decimal(18,2),t.Comission) 					  
			ELSE 0.00 END nsffee ---- NSF Fee solo debe mostrar valor cuando el movimiento concepto es CHRTN
	--------------------------------------------------------------------------------------------------			     
	FROM dbo.AgentBalance AS b WITH (NOLOCK)
	LEFT JOIN dbo.Checks AS t WITH (NOLOCK) ON b.idtransfer = t.IdCheck --AND b.TypeOfMovement IN (SELECT TypeOfMovement FROM @TypeM)--#2
	WHERE b.IdAgent = @IdAgent
	AND b.DateOfMovement >= @DateFrom AND b.DateOfMovement < @DateTo
	--AND TypeOfMovement in (select TypeOfMovement from @TypeM) 
	AND EXISTS (SELECT 1 FROM #TypeM AS M WHERE b.TypeOfMovement = M.TypeOfMovement);
END;

IF @IdAgentBalanceService = 5
BEGIN
	INSERT INTO #TypeM--#2
	VALUES ('DEP'),
			('DCP');

	INSERT INTO #Balance--#2
	SELECT 
		b.IdAgentBalance,     
		TypeOfMovement,              
		DateOfMovement,              
		CASE 
			WHEN ISNULL(Reference,'') = '' THEN CONVERT(varchar,b.IdAgentBalance)
			ELSE Reference
		END Reference,              
		[Description],              
		Country,   
		0 Fee,               
		0 Commission,          
		0 FxFee,                         
		CASE WHEN (TypeOfMovement = 'DEP' OR TypeOfMovement = 'DCP') THEN b.Amount ELSE 0 END * CASE WHEN DebitOrCredit = 'Debit' THEN -1 ELSE 1 END Amount,    
		CASE WHEN DebitOrCredit = 'Debit' THEN b.Amount ELSE b.Amount * (-1) END AmountForBalance,
		0.0 nsffee
	FROM dbo.AgentBalance AS b WITH (NOLOCK)
	WHERE b.IdAgent = @IdAgent
	AND DateOfMovement >= @DateFrom AND DateOfMovement < @DateTo  
	--AND TypeOfMovement in (select TypeOfMovement from @TypeM)  
	AND EXISTS (SELECT 1 FROM #TypeM AS M WHERE b.TypeOfMovement = M.TypeOfMovement);--#2
    
    DELETE FROM #TypeM;--#2
    
	INSERT INTO #TypeM VALUES ('CGO');--#2

    INSERT INTO #Balance--#2
	SELECT
		IdAgentBalance,
		CASE WHEN DebitOrCredit = 'Debit' THEN 'CHG' ELSE 'CRED' END TypeOfMovement,
		DateOfMovement,
		CASE 
			WHEN ISNULL(Reference,'') = '' THEN CONVERT(varchar,IdAgentBalance)
			ELSE Reference
		END Reference,              
		[Description],              
		Country,   
		0 Fee,                   
    --case when TypeOfMovement='CGO' and b.commission=0 and isnull(o.IdOtherChargesMemo,0) in (6) Then b.Amount else 0 end * case when DebitOrCredit='Debit' Then 1 ELSE -1 END Commission,
    --case when TypeOfMovement='CGO' and b.commission=0 and isnull(o.IdOtherChargesMemo,0) not in (6) Then b.Amount else 0 end * case when DebitOrCredit='Debit' Then 1 ELSE -1 END FxFee,                         
		CASE WHEN DebitOrCredit = 'Credit' THEN Amount ELSE 0 END AS Commission,              
		CASE WHEN DebitOrCredit = 'Debit' THEN Amount ELSE 0 END AS FxFee, 
		0 Amount,    
		CASE WHEN DebitOrCredit = 'Debit' THEN Amount ELSE Amount * (-1) END AmountForBalance
		, 0.0 nsffee
	FROM dbo.AgentBalance AS B WITH (NOLOCK)
    --left join agentothercharge o with (nolock) on b.idagentbalance=o.idagentbalance                  
	WHERE IdAgent = @IdAgent              
	AND DateOfMovement >= @DateFrom AND DateOfMovement < @DateTo  
	--AND TypeOfMovement in  (select TypeOfMovement from @TypeM) 
	AND Commission = 0
	AND EXISTS (SELECT 1 FROM #TypeM AS M WHERE B.TypeOfMovement = M.TypeOfMovement);
END;

IF @IdAgentBalanceService = 0
BEGIN
	INSERT INTO #TypeM--#2
	/*select typeofmovement from agentbalancehelper with (nolock) where idotherproduct in(
	select idotherproducts from otherproducts with (nolock) where idotherproducts not in (
	select idotherproduct from [RelationAgentBalanceServiceOtherProduct] with (nolock)))*/
	SELECT TypeOfMovement FROM dbo.AgentBalanceHelper AS H WITH (NOLOCK) WHERE EXISTS (--#2
		SELECT 1 FROM dbo.OtherProducts AS O WITH (NOLOCK) WHERE H.IdOtherProduct = O.IdOtherProducts AND NOT EXISTS (
			SELECT 1 FROM dbo.[RelationAgentBalanceServiceOtherProduct] AS R WITH (NOLOCK) WHERE O.IdOtherProducts = R.IdOtherProduct
		)
	);

	INSERT INTO #Balance--#2
	SELECT 
		IdAgentBalance,
		TypeOfMovement,
		DateOfMovement,
		CASE 
			WHEN ISNULL(Reference,'') = '' THEN CONVERT(varchar,IdAgentBalance)
			ELSE Reference
		END Reference,
		[Description],
		Country,   
		0 Fee,           
		Commission,      
		FxFee,                         
		CASE WHEN DebitOrCredit = 'Debit' 
			THEN CASE WHEN b.IsMonthly = 1 THEN Amount ELSE Amount + Commission END
			ELSE CASE WHEN b.IsMonthly = 1 THEN Amount * (-1) ELSE Amount * (-1) + Commission END
		END Amount,    
		CASE WHEN DebitOrCredit = 'Debit' THEN Amount ELSE Amount * (-1) END AmountForBalance
		, 0.0 nsffee
	FROM dbo.AgentBalance AS b WITH (NOLOCK)
	WHERE IdAgent = @IdAgent              
	AND DateOfMovement >= @DateFrom AND DateOfMovement < @DateTo
	--AND TypeOfMovement in (select TypeOfMovement from @TypeM)
	AND EXISTS (SELECT 1 FROM #TypeM AS M WHERE b.TypeOfMovement = M.TypeOfMovement);
END;

IF @IdAgentBalanceService = 10
BEGIN
	INSERT INTO #TypeM--#2
	SELECT typeofmovement
	FROM dbo.[RelationAgentBalanceServiceOtherProduct] AS r WITH (NOLOCK)
	INNER JOIN dbo.AgentBalanceHelper AS h WITH (NOLOCK) ON r.idotherproduct = h.idotherproduct 
	WHERE r.IdAgentBalanceService = @IdAgentBalanceService;

	INSERT INTO #Balance--#2
	SELECT
		IdAgentBalance,     
		TypeOfMovement TypeOfMovement,
		DateOfMovement,
		CASE 
			WHEN ISNULL(Reference,'') = '' THEN CONVERT(varchar,IdAgentBalance)
			ELSE Reference
		END Reference,
		[Description],
		Country,
		CASE 
			WHEN DebitOrCredit = 'Debit' THEN (sr.FeeAmount)
			ELSE (sr.FeeAmount) * (-1) 
		END Fee,           
		Commission,      
		FxFee,                         
		CASE 
			WHEN DebitOrCredit = 'Debit' THEN sr.Amount
			ELSE sr.Amount * (-1)
		END Amount,
		CASE 
			WHEN DebitOrCredit = 'Debit' THEN sr.Amount 
			ELSE sr.Amount * (-1)
		END AmountForBalance,
		0.0 nsffee
	FROM dbo.AgentBalance AS b WITH (NOLOCK)
		INNER JOIN MoneyOrder.SaleRecord AS sr WITH (NOLOCK) ON b.IdTransfer = sr.IdSaleRecord
	WHERE 
		b.IdAgent = @IdAgent              
		AND DateOfMovement >= @DateFrom AND DateOfMovement < @DateTo  
		AND EXISTS (SELECT 1 FROM #TypeM AS M WHERE b.TypeOfMovement = M.TypeOfMovement)--#2
END;
---------------------------------------------------------------------------------------------------------------------

SELECT 
	IdAgentBalance,
	TypeOfMovement,
	DateOfMovement,
	Reference,
	[Description],
	Country,
	Fee,
	Commission,
	FxFee,
	Amount,
	AmountForBalance,
	nsffee, 
	0.0 valuefee 
FROM #Balance--#2 
ORDER BY DateOfMovement ASC, IdAgentBalance ASC;

