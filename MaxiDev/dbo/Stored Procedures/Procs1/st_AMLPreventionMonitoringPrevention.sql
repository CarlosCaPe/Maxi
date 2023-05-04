CREATE PROCEDURE [dbo].[st_AMLPreventionMonitoringPrevention]
AS
BEGIN
SET NOCOUNT ON;

DECLARE @Date DATETIME 
DECLARE @DateFrom DATETIME 
DECLARE @N INT

SET @N=1
SET @Date=GETDATE()
SET @DateFrom=DATEADD(MI,-180,@Date)

SELECT @Date, @DateFrom

CREATE TABLE #Agents 
(
       IdAgent INT,
       IdCountry INT,
       IdParameter INT,
       Ponderation INT,
       Qualification INT
)

--Get Transactions with new beneficiaries
;WITH cte AS (
       SELECT IdAgent,CC.IdCountry, COUNT(DISTINCT B.IdBeneficiary) Ben
       FROM 
              Transfer T
             JOIN  CountryCurrency CC ON CC.IdCountryCurrency=T.IdCountryCurrency
             JOIN  Beneficiary B ON T.IdBeneficiary=B.IdBeneficiary
       WHERE DateOfTransfer BETWEEN @DateFrom AND @Date 
             AND CONVERT(DATE, B.CREATEDATE) = CONVERT(DATE,@DATE)
       GROUP BY IdAgent, CC.IdCountry
)
SELECT *
FROM cte

--240,259,267
-- Transactions to Risk State
;WITH det AS
(
       SELECT  IdAgent, CC.idcountry, COUNT(DISTINCT IdTransfer) CC
       FROM 
              Transfer t
             JOIN  CountryCurrency CC ON CC.IdCountryCurrency=T.IdCountryCurrency
             JOIN  Branch br ON br.IdBranch=t.IdBranch
             JOIN  City cy ON cy.IdCity=br.IdCity
       WHERE DateOfTransfer BETWEEN @DateFrom AND @Date AND CY.IdState IN (240,259,267)
       GROUP BY T.IdAgent, CC.IdCountry
)
SELECT IdAgent, COUNT(*) cc
FROM det 
GROUP BY IdAgent

-- Cancelled Transactions
;WITH det AS
(
       SELECT  IdAgent, CC.IdCountry, COUNT(DISTINCT IdTransfer) CC
       FROM  Transfer t
       JOIN  CountryCurrency CC ON CC.IdCountryCurrency=T.IdCountryCurrency
       WHERE DateOfTransfer BETWEEN @DateFrom AND @Date
       AND IdStatus IN (22,26)
       GROUP BY t.IdAgent,cc.IdCountry
)
SELECT IdAgent
FROM det 

--Suspicious Amount
;WITH det AS
(
       SELECT  
             IdAgent,
             cc.idCountry,
             COUNT(DISTINCT IdTransfer) CC
       FROM  Transfer t
       JOIN  CountryCurrency CC ON CC.IdCountryCurrency=T.IdCountryCurrency 
       WHERE AmountInDollars BETWEEN 300 AND 801 
       AND DateOfTransfer BETWEEN @DateFrom AND @Date
       GROUP BY IdAgent, cc.IdCountry
)
SELECT *
FROM det 
             
-- Payed less than 10 min
;WITH tInfo AS(
             SELECT
                    t.IdAgent,
                    cc.IdCountry,
                    COUNT(DISTINCT T.IdTransfer) CC
             FROM  Transfer T
             JOIN  CountryCurrency CC ON CC.IdCountryCurrency=T.IdCountryCurrency
             JOIN 
             (
                    SELECT IdTransfer, MAX(IdTransferDetail) IdTransferDetail 
                    FROM  TransferDetail 
                    WHERE IdStatus=30 AND DateOfMovement BETWEEN @DateFrom AND @Date
                    GROUP BY IdTransfer) Pay ON Pay.IdTransfer=T.IdTransfer
             INNER JOIN  TransferDetail P ON p.IdTransferDetail=PAY.IdTransferDetail
             WHERE t.DateOfTransfer BETWEEN @DateFrom AND @Date
             AND DATEDIFF(MI,T.DateOfTransfer, P.DateOfMovement)<=10
             AND IdPaymentType NOT IN (2) 
             GROUP BY T.IdAgent, cc.IdCountry
             HAVING COUNT(DISTINCT T.IdTransfer)>@N
             )
             SELECT *
             FROM tInfo


       -- Cobradas en diferente estado 
       ;with PayedDifLocation AS(
             SELECT 
             T.IdAgent, 
             cc.IdCountry,
             COUNT(DISTINCT t.IdTransfer ) CC
       FROM 
              Transfer T
             JOIN  CountryCurrency CC ON CC.IdCountryCurrency=T.IdCountryCurrency
             LEFT JOIN 
                          (SELECT IdTransfer, MAX(IdTransferPayInfo) IdTransferPayInfo from  TransferPayInfo 
                          GROUP BY Idtransfer ) Pay ON Pay.Idtransfer=T.IdTransfer
             LEFT JOIN  TransferPayInfo PayInfo ON PAY.IdTransferPayInfo=PayInfo.IdTransferPayInfo
             LEFT JOIN  Branch BR ON BR.IdBranch=T.IdBranch
             LEFT JOIN  City CT ON CT.IdCity=BR.IdCity
             LEFT JOIN  Branch BRP ON BRP.IdBranch=PayInfo.IdBranch
             LEFT JOIN  City CTP ON CTP.IdCity=BRP.IdCity
       WHERE T.IdPaymentType NOT IN (2,3) AND IdStatus=30
       AND (CT.IdState <> CTP.IdState)  
       AND DateOfTransfer BETWEEN @DateFrom AND @Date
       GROUP BY T.IdAgent,CC.IdCountry
       )
       SELECT * FROM PayedDifLocation

END
