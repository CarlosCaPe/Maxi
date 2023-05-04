
CREATE procedure [dbo].[st_GetOtherProductProfitV2]
    @From datetime ,
    @hasta datetime ,
    @IdAgentBalanceService int = null, 
    /*
    2  Bill Payments
    3  Long Distance
    4  Top Ups	
    6  Others
       7      Checks /*2016-Ago-19*/
    */
    @IdProvider int = null,
    /*
    1  Softgate
    2  TransferTo
    3  Lunex
    4  PureMinutes
    5   Regalii
    6  Others
    */
    @State varchar(10) 
    
    
    	
	/********************************************************************
<Author> ??? </Author>
<app> Corporative </app>
<Description>Get TRansfer Other Products</Description>

<ChangeLog>

<log Date="24/09/2018" Author="amoreno,">Se agrega el filtro de Fidelity</log>
<log Date="04/02/2019" Author="azavala,">Se agrega el filtro de FiServ y se agregan filtros para obtencion de movimientos en balance para cuando sea FiServ o Fidelity - REF: 04022019_azavala</log>
<log Date="04/23/2019" Author="jdarellano" Name="#1">Se agrega filtro para solución a ticket 1843.</log>
<log Date="07/01/2019" Author="jgomez" Name="#1">se agrega left join, y se modifica para que muestre costumer fee para agencias de tipo branch -- CR - M00230</log>
</ChangeLog>
*********************************************************************/ 
as

/*NOTA: Agregar las columas nuevas en el procedimiento st_GetOtherProductProfitV2 al st_ReportProfitVCountry*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

/* 2012-02-15 HMG  Cambio con nueva logica*/
set @hasta = dateadd(day,1,@hasta)

SET @State =RTRIM(LTRIM(@State)) 
IF (@State='')
       SET @State = null

declare @Products table
(
    IdOtherProduct Int
)

if @IdAgentBalanceService is null
begin
    insert into @Products
    select IdOtherProduct from [RelationAgentBalanceServiceOtherProduct] with (nolock)
        Where IdOtherProduct!=15 /*2015-Sep-21 : 15    Checks*/
    union all    
    select idotherproducts from otherproducts with (nolock) 
        where idotherproducts not in (select idotherproduct from [RelationAgentBalanceServiceOtherProduct] with (nolock))
                and IdOtherProducts!=3
end

if @IdAgentBalanceService in (2,3,4)
begin
    insert into @Products
    select IdOtherProduct from [RelationAgentBalanceServiceOtherProduct] where IdAgentBalanceService=@IdAgentBalanceService
end

if @IdAgentBalanceService = 6
begin
    insert into @Products
    select idotherproducts from otherproducts with (nolock) where idotherproducts not in (
    select idotherproduct from [RelationAgentBalanceServiceOtherProduct] with (nolock)) and IdOtherProducts!=3
end

/*2015-Ago-19*/
/*-----------*/
if @IdAgentBalanceService in (7)
begin
    insert into @Products
    select IdOtherProduct from [RelationAgentBalanceServiceOtherProduct] where IdAgentBalanceService=@IdAgentBalanceService
end
/*-----------*/

if @IdProvider=1 --Softgate
begin 
    delete from @Products where IdOtherProduct not in (1)
end

if @IdProvider=2 --TransferTo
begin
    delete from @Products where IdOtherProduct not in (7)
end

if @IdProvider=3 --Lunex
begin
    delete from @Products where IdOtherProduct not in (9,10,11,12,13,16)
end

if @IdProvider=4 --PureMinutes
begin
    delete from @Products where IdOtherProduct not in (5,6)
end

if @IdProvider=5 --Regalii
begin
    delete from @Products where IdOtherProduct not in (14,17)
end

if @IdProvider=6 --Others
begin
    delete from @Products where IdOtherProduct not in (2,4,8)
end



if @IdProvider=8 --Others
begin
    delete from @Products where IdOtherProduct not in (18)
end

/*01 - 04022019_azavala */
if @IdProvider=9 --Others
begin
    delete from @Products where IdOtherProduct not in (19)
end
/*01 - 04022019_azavala */

--delete from @Products WHERE IdOtherProduct=15
/*2016-Ago-19*/
/*-----------*/
if (@IdAgentBalanceService IS NOT NULL) AND (@IdAgentBalanceService <> 7)
begin
       delete from @Products WHERE IdOtherProduct=15
end
/*-----------*/


/*Get Other Product*/
/*-----------------*/
--Declare @OtherProductProfit table
CREATE TABLE #OtherProductProfit
(
       IdAgent Int,
	   IdAgentType int,
       AgentName NVARCHAR(250),
       AgentCode NVARCHAR(25),
       Total Money default(0),
       CancelsTotal Money default(0),
       TotalNet Money default(0),
       Amount Money default(0),
       CGS Money default(0),
       Fee Money default(0),
       FeeM Money default(0),
       FeeR Money default(0),
       ProviderComm Money default(0),
       CorpCommission Money default(0),
       AgentCommMonthly Money default(0),
       AgentCommRetain Money default(0),
       FX Money default(0),

       CheckFees Money default(0),

       ReturnedFee Money default(0),

       TransactionFee Money default(0),
       CustomerFee Money default(0),
	   ProccessingFee Money default (0),

       ScannerFee Money default(0)
);


--;WITH CTE_PROFIT AS 
--(

/*02 - 04022019_azavala*/
if(@IdProvider is null or @IdProvider not in (8,9))
	BEGIN
		if(@IdProvider is null)--#1
			delete from @Products where IdOtherProduct = 19

		--delete from @Products where IdOtherProduct not in (19)
		INSERT INTO #OtherProductProfit
		select t0.idAgent, t0.IdAgentType, AgentName, AgentCode, 
			sum (case when t3.allowcount = 1 then 1 else 0 end) as Total,
			sum (case when t3.allowcount = 0 then 1 else 0 end) as CancelsTotal,
			sum (case when t3.allowcount = 1 then 1 else -1 end) as TotalNet,

			sum(case 
						when t1.IsMonthly = 0 and t3.idOtherProduct IN (7,17) then t2.TotalAmount+t1.Commission
						else  t2.TotalAmount 
					end
					) as Amount,
			sum(case 
						when t1.IsMonthly = 0 and t3.idOtherProduct IN (7) then t2.CGS+t1.Commission 
						else t2.CGS 
					end
					) as CGS,

			--sum (t2.Fee) as Fee,
			sum (case when t3.IdOtherProduct<>15 then (t2.Fee) else 0 end) as Fee, /*2016-Ago-19*/

			/*Dos nuevas Columnas agregadas Jose*/
			sum (case when t1.IsMonthly = 1  then t2.Fee else 0 end )  as FeeM,
			sum (case when t1.IsMonthly = 0  then t2.Fee else 0 end )  as FeeR,
			/***********************************/
			sum (t2.ProviderFee) as ProviderComm, 
			sum (case
						when t3.idOtherProduct=14 then (t2.TotalAmount-t2.fee-t2.CGS)+t2.Fee-t1.Commission-t2.ProviderFee
						--when t3.idOtherProduct=15 then c0.Comission
						else t2.CorpCommission
					end
					) as CorpCommission,
			--sum (case when t3.IdOtherProduct=1 then t2.Fee-t1.Commission-t2.ProviderFee else t2.CorpCommission end) as CorpCommission2,
			sum (case when t1.IsMonthly = 1 then t1.Commission else 0 end) as AgentCommMonthly,
			sum (case when t1.IsMonthly = 0 then t1.Commission else 0 end) as AgentCommRetain,
			sum (case
						when t3.idOtherProduct=14 then t2.TotalAmount-t2.fee-t2.CGS
						else 0
					end
					) FX
					,sum (case when t3.IdOtherProduct=15 then t2.Fee else 0 end) as CheckFees /*2016-Ago-19 *//*2016-Sep-14:Scanner Fee(sf.Amount)*/
			, 0 AS ReturnedFee
			, 0 AS TransactionFee
			, 0 AS CustomerFee
			, 0 AS ProccessingFee
			, 0 AS ScannerFee
		from Agent t0 WITH(NOLOCK) 
		join AgentBalance t1 WITH(NOLOCK)  on t0.idAgent = t1.idAgent
		join AgentBalanceDetail t2 WITH(NOLOCK)  on t1.IdAgentBalance = t2.IdAgentBalance
		join profitHelper t3 WITH(NOLOCK)  on (t1.typeofMovement = t3.typeofmovement) and (t3.idOtherProduct in (select idOtherProduct from @Products) )
		--left join Checks AS c0 on c0.IdAgent = t0.IdAgent And t1.IdTransfer = c0.IdCheck
		where (t1.DateOfMovement >= @from and t1.DateOfMovement < @hasta) AND (@State is null or t0.AgentState=@State)
		group by t0.idAgent, t0.IdAgentType, AgentName, AgentCode
	END
ELSE
	BEGIN
		INSERT INTO #OtherProductProfit
		select t0.idAgent, t0.IdAgentType, AgentName, AgentCode, 
			sum (case when t3.allowcount = 1 then 1 else 0 end) as Total,
			sum (case when t3.allowcount = 0 then 1 else 0 end) as CancelsTotal,
			sum (case when t3.allowcount = 1 then 1 else -1 end) as TotalNet,

			sum(case 
						when t1.IsMonthly = 0 and t3.idOtherProduct IN (7,17) then t2.TotalAmount+t1.Commission
						else  t2.TotalAmount 
					end
					) as Amount,
			sum(case 
						when t1.IsMonthly = 0 and t3.idOtherProduct IN (7) then t2.CGS+t1.Commission 
						else t2.CGS 
					end
					) as CGS,

			--sum (t2.Fee) as Fee,
			sum (case when t3.IdOtherProduct<>15 then (t2.Fee) else 0 end) as Fee, /*2016-Ago-19*/

			/*Dos nuevas Columnas agregadas Jose*/
			sum (case when t1.IsMonthly = 1  then t2.Fee else 0 end )  as FeeM,
			sum (case when t1.IsMonthly = 0  then t2.Fee else 0 end )  as FeeR,
			/***********************************/
			sum (t2.ProviderFee) as ProviderComm, 
			sum (case
						when t3.idOtherProduct=14 then (t2.TotalAmount-t2.fee-t2.CGS)+t2.Fee-t1.Commission-t2.ProviderFee
						--when t3.idOtherProduct=15 then c0.Comission
						else t2.CorpCommission
					end
					) as CorpCommission,
			--sum (case when t3.IdOtherProduct=1 then t2.Fee-t1.Commission-t2.ProviderFee else t2.CorpCommission end) as CorpCommission2,
			sum (case when t1.IsMonthly = 1 then t1.Commission else 0 end) as AgentCommMonthly,
			sum (case when t1.IsMonthly = 0 then t1.Commission else 0 end) as AgentCommRetain,
			sum (case
						when t3.idOtherProduct=14 then t2.TotalAmount-t2.fee-t2.CGS
						else 0
					end
					) FX
					,sum (case when t3.IdOtherProduct=15 then t2.Fee else 0 end) as CheckFees /*2016-Ago-19 *//*2016-Sep-14:Scanner Fee(sf.Amount)*/
			, 0 AS ReturnedFee
			, 0 AS TransactionFee
			, 0 AS CustomerFee
			, 0 AS ProccessingFee
			, 0 AS ScannerFee
		from Agent t0 WITH(NOLOCK) 
		join AgentBalance t1 WITH(NOLOCK)  on t0.idAgent = t1.idAgent
		join AgentBalanceDetail t2 WITH(NOLOCK)  on t1.IdAgentBalance = t2.IdAgentBalance
		join profitHelper t3 WITH(NOLOCK)  on (t1.typeofMovement = t3.typeofmovement) and (t3.idOtherProduct in (select idOtherProduct from @Products) )
		join [BillPayment].[TransferR] TR with(nolock) on TR.IdProductTransfer=t1.Reference
		join [BillPayment].[Billers] B with(nolock) on TR.IdBiller=B.IdBiller
		--left join Checks AS c0 on c0.IdAgent = t0.IdAgent And t1.IdTransfer = c0.IdCheck
		where (t1.DateOfMovement >= @from and t1.DateOfMovement < @hasta) AND (@State is null or t0.AgentState=@State) and B.IdAggregator=(select IdAggregator from [BillPayment].[Aggregator] with(nolock) where IdOtherProducts in (select idOtherProduct from @Products))
		group by t0.idAgent, t0.IdAgentType, AgentName, AgentCode
		
	END
	/*02 - 04022019_azavala*/
	CREATE NONCLUSTERED INDEX IX_OtherProductProfit_IdAgent ON #OtherProductProfit (IdAgent)
/*)INSERT INTO @OtherProductProfit
       SELECT
       CT.idAgent
       , CT.AgentName
       , CT.AgentCode
       , CT.Total
       , CT.CancelsTotal
       , CT.TotalNet
       , CT.Amount
       , CT.CGS
       , CT.Fee
       , CT.FeeM
       , CT.FeeR
       , CT.ProviderComm
       , CT.CorpCommission
       , CT.AgentCommMonthly
       , CT.AgentCommRetain
       , CT.FX
       , CT.CheckFees      

       , 0 AS ReturnedFee
       , 0 AS TransactionFee
       , 0 AS CustomerFee
       , 0 AS ScannerFee
FROM CTE_PROFIT AS CT;*/

/*2016-Sep-14 : Scanner Fee*/
/*-------------------------*/
if (@IdAgentBalanceService = 7)
BEGIN
       /*-------------------------*/
       --AgentBalance[Description]: Deferred Balance Fee - Scanner Fee
       --AgentOtherCharge[Notes]:Scanner Fee
       /*-------------------------*/
	    Declare @Scanner table
       (
			Id [int] IDENTITY(1,1) NOT NULL,
            IdAgent Int,
            ScannerFee Money default(0)
       );

		INSERT INTO @Scanner
			SELECT 
                    AB.IdAgent   
                    --,SUM(AB.Amount) AS ScannerFee
					,SUM( case when DebitOrCredit='Credit' then -1 else 1 end*  AB.Amount) AS ScannerFee
            FROM AgentBalance AS AB WITH(NOLOCK) 
                    INNER JOIN  AgentOtherCharge AS AOC WITH(NOLOCK) 
					ON AB.IdAgent = AOC.IdAgent						
						AND AB.IdAgentBalance = AOC.IdAgentBalance  
						AND (AB.DateOfMovement >= @from and AB.DateOfMovement < @hasta)	
			WHERE AOC.IdOtherChargesMemo = 29 /*11 -> 29:IdOtherChargesMemo - Scanner Fee*/
            GROUP BY AB.IdAgent;

		UPDATE op
			SET
				ScannerFee = ISNULL(f.ScannerFee,0)
			--FROM @OtherProductProfit As op
			FROM #OtherProductProfit As op
				INNER JOIN @Scanner AS f
					ON op.IdAgent = f.IdAgent;

		DELETE F 
			FROM @Scanner AS F 
				--INNER JOIN @OtherProductProfit As op
				INNER JOIN #OtherProductProfit As op
					ON op.IdAgent = f.IdAgent;

		--INSERT @OtherProductProfit (IdAgent,ScannerFee)
		INSERT #OtherProductProfit (IdAgent,ScannerFee)
			SELECT 
				s.IdAgent,
				ISNULL(s.ScannerFee,0)
			FROM @Scanner AS s
				INNER JOIN Agent AS A WITH(NOLOCK) 
					ON s.IdAgent = A.IdAgent
			WHERE (@State is null or A.AgentState=@State);

       /*------------------------------*/
       /* TransactionFee, CustomerFee, ProccessingFee*/
       /*------------------------------*/
       Declare @Fees table
       (
			Id [int] IDENTITY(1,1) NOT NULL,
            IdAgent Int,
            Commission Money default(0),
            TransactionFee Money default(0),
            CustomerFee Money default(0),
			ProccessingFee mONEY DEFAULT(0)
       );

		--INSERT INTO @Fees
  --           SELECT 
  --                  C.IdAgent,
  --                  SUM(C.Comission) AS Commission                 
  --                  ,SUM(CASE WHEN AB.TypeOfMovement = 'CH' THEN C.TransactionFee ELSE (-1*C.TransactionFee) END) AS TransactionFee
  --                  ,SUM(CASE WHEN AB.TypeOfMovement = 'CH' THEN C.CustomerFee ELSE (-1*C.CustomerFee) END) AS CustomerFee
  --           FROM Checks AS C WITH(NOLOCK) 
  --                  INNER JOIN AgentBalance AS AB WITH(NOLOCK) 
  --                         ON C.IdCheck = AB.IdTransfer AND AB.TypeOfMovement in ('CH','CHRTN','CHNFS') /*'CHNFS'*/
  --                  WHERE (C.DateOfMovement >= @from and C.DateOfMovement < @hasta)
  --           GROUP BY C.IdAgent;
       

--IdStatus	StatusName
--20	Stand By
--22	Cancelled
--30	Paid
--31	Rejected
--21	Pending Gateway Response
--40	Transfer Accepted
	   /*INSERT INTO @Fees
             SELECT 
                    C.IdAgent,
                    SUM(C.Comission) AS Commission                 
                   --,SUM(CASE WHEN C.IdStatus in (20,30) THEN C.TransactionFee ELSE (-1*C.TransactionFee) END) AS TransactionFee

				    ,SUM(CASE WHEN C.IdStatus in (20,21,30) 
								THEN ISNULL(C.TransactionFee,C.Fee) 
								ELSE (-1 * ISNULL(C.TransactionFee,C.Fee)) END) AS TransactionFee

                    ,SUM(CASE WHEN C.IdStatus in (20,30) THEN C.CustomerFee ELSE (-1*C.CustomerFee) END) AS CustomerFee
             FROM Checks AS C WITH(NOLOCK) 
					INNER JOIN CheckDetails CD ON C.IdCheck = CD.IdCheck
             WHERE (C.DateOfMovement >= @from and C.DateOfMovement < @hasta)
						AND CD.IdStatus = 20
						AND C.IdStatus not in (22,31)
             GROUP BY C.IdAgent;*/
       
	   INSERT INTO @Fees
             SELECT 
                    C.IdAgent,
                    SUM(C.Comission) AS Commission
				    /*,SUM(CASE WHEN C.IdStatus in (20,21,30)
								THEN ISNULL(C.TransactionFee,C.Fee) 
								ELSE CASE WHEN ab.TypeOfMovement NOT IN ('CHNFS', 'CH') THEN ISNULL(C.TransactionFee,C.Fee) ELSE 0 END END) AS TransactionFee*/
					,SUM(case when TypeOfMovement!='CHNFS' then
							case 
							     when DebitOrCredit='Debit' then C.TransactionFee*(-1) 
								 when TypeOfMovement='CH'  then C.TransactionFee   
								 when TypeOfMovement='CHRTN' then C.TransactionFee
								 else C.TransactionFee  
							 end					  
							else 0 end) AS TransactionFee
                    ,SUM(CC.VERIFICATIONFEE) AS CustomerFee
					,SUM(CASE WHEN C.IdStatus in (20,30) THEN C.CustomerFee ELSE (-1*C.CustomerFee) END) AS ProccessingFee
             FROM Checks AS C WITH(NOLOCK)
			INNER JOIN dbo.AgentBalance AS ab WITH(NOLOCK) ON ab.IdTransfer = c.IdCheck AND ab.IdAgent = c.IdAgent
			LEFT JOIN CC_AccVerifByAg CC WITH(NOLOCK) ON CC.IDAGENT = C.IDAGENT and cc.Idcheck = c.IdCheck--M00230 
             WHERE (ab.DateOfMovement >= @from and ab.DateOfMovement < @hasta)
			   AND C.IdStatus not in (22)
			   AND ab.TypeOfMovement LIKE 'CH%'
			   AND EXISTS(SELECT 1 FROM CheckDetails CD WHERE C.IdCheck = CD.IdCheck AND CD.IdStatus = 20)
             GROUP BY C.IdAgent;  


		UPDATE op
			SET
				op.TransactionFee = ISNULL(f.TransactionFee,0)
				,op.CustomerFee = ISNULL(f.CustomerFee,0)
				, op.ProccessingFee = ISNULL(f.ProccessingFee,0)
			--FROM @OtherProductProfit As op
			FROM #OtherProductProfit As op
				INNER JOIN @Fees AS f
					ON op.IdAgent = f.IdAgent;

		DELETE F 
			FROM @Fees AS F 
				--INNER JOIN @OtherProductProfit As op
				INNER JOIN #OtherProductProfit As op
					ON op.IdAgent = f.IdAgent;

		--INSERT INTO @OtherProductProfit
		INSERT INTO #OtherProductProfit
				(IdAgent,TransactionFee,CustomerFee, ProccessingFee)
			SELECT
                f.IdAgent
                ,ISNULL(f.TransactionFee,0)
                ,ISNULL(f.CustomerFee,0)
				,ISNULL(f.ProccessingFee,0)
			FROM @Fees AS f
				INNER JOIN Agent AS A WITH(NOLOCK) 
					ON f.IdAgent = A.IdAgent
			WHERE (@State is null or A.AgentState=@State);;

       /*-------------------------*/
       /*ReturnedFee -> Commission*/
       /*-------------------------*/
	   /*
       ;WITH CTE_ReturnedFee AS 
       (
             SELECT 
                    ABC.IdAgent
                    ,SUM(ABC.Amount) AS ReturnedFee
             FROM agentbalance AS ABC WITH(NOLOCK)
                    INNER JOIN @OtherProductProfit AS op ON ABC.IdAgent = op.IdAgent
                           AND ABC.TypeOfMovement = 'CHNFS'
             WHERE 
                    (ABC.DateOfMovement >= @from AND ABC.DateOfMovement < @hasta)
             GROUP BY ABC.IdAgent
       )UPDATE op 
             SET
                    op.ReturnedFee = CTE.ReturnedFee
             FROM @OtherProductProfit AS op
                    INNER JOIN CTE_ReturnedFee AS CTE ON op.IdAgent = CTE.IdAgent;
			*/
       UPDATE op 
             SET
                    op.ReturnedFee = CTE.ReturnedFee
             --FROM @OtherProductProfit AS op
			 FROM #OtherProductProfit AS op
                    INNER JOIN (
								 SELECT 
										ABC.IdAgent
										,SUM(ABC.Amount) AS ReturnedFee
								 FROM agentbalance AS ABC WITH(NOLOCK)
										--INNER JOIN @OtherProductProfit AS op ON ABC.IdAgent = op.IdAgent
										INNER JOIN #OtherProductProfit AS op ON ABC.IdAgent = op.IdAgent
											   AND ABC.TypeOfMovement = 'CHNFS'
								 WHERE 
										(ABC.DateOfMovement >= @from AND ABC.DateOfMovement < @hasta)
								 GROUP BY ABC.IdAgent
					) AS CTE ON op.IdAgent = CTE.IdAgent;

		/*-------------------------*/
		/*-------------------------*/
		UPDATE op
		SET
			 op.AgentName = a.AgentName
             ,op.AgentCode = a.AgentCode
		 --FROM @OtherProductProfit as op
		 FROM #OtherProductProfit as op
			LEFT JOIN Agent AS a WITH(NOLOCK) 
				ON op.IdAgent = a.IdAgent
			WHERE (op.AgentName IS NULL OR  op.AgentCode IS NULL);
		/*-------------------------*/

END
/*-------------------------*/

SELECT
       idAgent
       , AgentName
       , AgentCode
       , Total
       , CancelsTotal
       , TotalNet
       , Amount
       , CGS
       , Fee
       , FeeM
       , FeeR
       , ProviderComm
       , CorpCommission
       , AgentCommMonthly
       , AgentCommRetain
       , FX
       , CheckFees  

       , ReturnedFee
       , TransactionFee
       , CustomerFee 
	   ,case when IdAgentType = 1  then 0 else ProccessingFee end ProccessingFee --M00230
       , ScannerFee
--FROM @OtherProductProfit;
FROM #OtherProductProfit
ORDER BY AgentCode;

DROP TABLE #OtherProductProfit