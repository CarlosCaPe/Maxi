CREATE PROCEDURE [dbo].[st_AgenciesUnderAmountLimit_SBQ]
as
/********************************************************************
<Author></Author>
<app></app>
<Description>Obtiene agencias candidatas a reduccion de credito</Description>

<ChangeLog>
<log Date="19/07/2018" Author="snevarez"> CO_003_SuggestCreditLimit </log>
<log Date="26/07/2018" Author="jmmolina"> CO_003_SuggestCreditLimit: Se quito el ciclo por agente #1 </log>
</ChangeLog>
*********************************************************************/
Begin try

SET NOCOUNT ON;

	DECLARE @DaysBack int = 61;
	DECLARE @IdAgentCollectType int = 4

    DECLARE @Agents TABLE 
    (
	   Id INT IDENTITY(1,1),
	   IdAgent INT,
	   AgentCode Varchar(50),
	   AgentName Varchar(250),
	   BalanceActual MONEY,
	   CreditActual MONEY,
	   IdAgentStatus INT,
	   IdAgentClass INT,
	   AgentClass Varchar(50),

	   DateOfDeposit DateTime,
	   DateFrom datetime, /*Prueba mike*/
	   Production MONEY, /*Balance Max*/    
	   Percentage DECIMAL(10,2) DEFAULT(0),
	   Margin MONEY DEFAULT(0),
	   Suggest MONEY DEFAULT(0),
	   Review BIT DEFAULT(0)
    );

    /*Obtiene informacion de las agencias*/
    INSERT INTO @Agents (IdAgent,AgentCode,AgentName,BalanceActual,CreditActual,IdAgentClass,AgentClass,IdAgentStatus,DateOfDeposit, DateFrom,Percentage)
	   SELECT 
		  A.IdAgent
		  ,A.AgentCode
		  ,A.AgentName
		  ,isnull(ACB.balance,0) AS BalanceActual
		  ,isnull(A.creditamount,0) AS CreditActual	   
		  ,A.IdAgentClass
		  ,AC.Name AS AgentClass  
		  ,A.idAgentStatus AS IdAgentStatus

		  ,GETDATE() AS DateOfDeposit
		  , CONVERT(DATETIME, CAST(DATEADD(day, -@DaysBack, GETDATE()) AS DATE)) As DateFrom /*Prueba mike*/
		  ,(CONVERT(DECIMAL, AC.ClassPercent)/CONVERT(DECIMAL, 100)) AS Percentage
	   FROM Agent AS A With(NoLock)
		  Inner Join AgentClass AS AC With(NoLock) On A.IdAgentClass = AC.IdAgentClass
		  Inner Join AgentCurrentBalance AS ACB With(NoLock) On A.IdAgent = ACB.IdAgent
	   WHERE A.IdAgentStatus NOT IN (2, 6, 5); /*Disabled(2),Collections(5),Write Off(6)*/

   
	
    DECLARE @SystemIdUser INT;
    SELECT @SystemIdUser=dbo.GetGlobalAttributeByName('SystemUserID');


			/*	SELECT t.IdAgent, CreditActual, t.DateFrom, DateOfDeposit = t.DateOfMovement, t.Production, Margin = ROUND((Production * Percentage), 0), Suggest = ROUND((Production * Percentage) + Production, 0)
				FROM (
					SELECT DISTINCT t.IdAgent, CreditActual, Percentage, t.DateFrom, t.DateOfMovement, Production = ISNULL(MAX(ab.Balance) OVER (PARTITION BY t.idagent), 0)
					FROM (
						   SELECT DISTINCT a.IdAgent, a.CreditActual, Percentage, 
										   DateOfMovement = CONVERT(DATETIME, CAST(CASE WHEN ab.IdAgent IS NULL OR ad.IdAgentDeposit IS NULL THEN GETDATE() ELSE MAX(ab.DateOfMovement) OVER (PARTITION BY a.IdAgent) END AS DATE)),
										   DateFrom = CONVERT(DATETIME, DATEADD(DAY, -@DaysBack, CAST(CASE WHEN ab.IdAgent IS NULL OR ad.IdAgentDeposit IS NULL THEN GETDATE() ELSE MAX(ab.DateOfMovement) OVER (PARTITION BY a.IdAgent) END AS DATE))),
										   RANK() OVER(PARTITION BY a.IdAgent ORDER BY ab.DateOfMovement DESC) AS Rnk
						   FROM @Agents As a
						   LEFT OUTER JOIN AgentBalance AS ab WITH(NOLOCK) ON a.IdAgent = ab.IdAgent AND ab.DateOfMovement BETWEEN a.DateFrom AND a.DateOfDeposit
						   LEFT OUTER JOIN AgentDeposit As ad WITH(NOLOCK) ON ad.IdAgentCollectType = @IdAgentCollectType AND ab.IdAgentBalance = ad.IdAgentBalance
						   WHERE 1 = 1
					) As t
					LEFT OUTER JOIN dbo.AgentBalance As ab ON t.IdAgent = ab.IdAgent AND ab.DateOfMovement BETWEEN t.DateFrom AND t.DateOfMovement
					WHERE Rnk = 1
				) As t
				WHERE 1 = 1
				AND (Production * Percentage) + Production > 0*/

    MERGE soporte.AgentCreditSuggest_SBQ AS TARGET
	   USING (	   
				SELECT t.IdAgent, CreditActual, t.DateFrom, DateOfDeposit = t.DateOfMovement, t.Production, Margin = ROUND((Production * Percentage), 0), Suggest = ROUND((Production * Percentage) + Production, 0) --#1
				FROM (
					SELECT DISTINCT t.IdAgent, CreditActual, Percentage, t.DateFrom, t.DateOfMovement, Production = ISNULL(MAX(ab.Balance) OVER (PARTITION BY t.idagent), 0)
					FROM (
						   SELECT DISTINCT a.IdAgent, a.CreditActual, Percentage, 
										   DateOfMovement = CONVERT(DATETIME, CAST(CASE WHEN ab.IdAgent IS NULL OR ad.IdAgentDeposit IS NULL THEN GETDATE() ELSE MAX(ab.DateOfMovement) OVER (PARTITION BY a.IdAgent) END AS DATE)),
										   DateFrom = CONVERT(DATETIME, DATEADD(DAY, -@DaysBack, CAST(CASE WHEN ab.IdAgent IS NULL OR ad.IdAgentDeposit IS NULL THEN GETDATE() ELSE MAX(ab.DateOfMovement) OVER (PARTITION BY a.IdAgent) END AS DATE))),
										   RANK() OVER(PARTITION BY a.IdAgent ORDER BY ab.DateOfMovement DESC) AS Rnk
						   FROM @Agents As a
						   LEFT OUTER JOIN AgentBalance AS ab WITH(NOLOCK) ON a.IdAgent = ab.IdAgent AND ab.DateOfMovement BETWEEN a.DateFrom AND a.DateOfDeposit
						   LEFT OUTER JOIN AgentDeposit As ad WITH(NOLOCK) ON ad.IdAgentCollectType = @IdAgentCollectType AND ab.IdAgentBalance = ad.IdAgentBalance
						   WHERE 1 = 1
					) As t
					LEFT OUTER JOIN dbo.AgentBalance As ab ON t.IdAgent = ab.IdAgent AND ab.DateOfMovement BETWEEN t.DateFrom AND t.DateOfMovement
					WHERE Rnk = 1
				) As t
				WHERE 1 = 1
	   ) AS SOURCE 
		  ON (TARGET.IdAgent = SOURCE.IdAgent)
			 WHEN MATCHED AND SOURCE.Suggest < SOURCE.CreditActual AND SOURCE.Suggest>0 THEN 
				UPDATE 
				SET 
				    TARGET.CreditLimit = SOURCE.CreditActual, 
				    TARGET.Margin = SOURCE.Margin,
				    TARGET.Suggested = SOURCE.Suggest,
				    TARGET.IsApproved = IIF(TARGET.CreditLimit <> SOURCE.CreditActual AND TARGET.IsApproved = 1, 0, TARGET.IsApproved),
				    TARGET.DateOfLastChange = GETDATE()
			 WHEN NOT MATCHED BY TARGET AND SOURCE.Suggest < SOURCE.CreditActual AND SOURCE.Suggest>0 THEN 
				INSERT (IdAgent, CreditLimit, Margin, Suggested, IsApproved, CreationDate, EnterByIdUser, Coments) 
				    VALUES (SOURCE.IdAgent, SOURCE.CreditActual, SOURCE.Margin, SOURCE.Suggest, NULL, GETDATE(),@SystemIdUser, '');
			 /*OUTPUT $action, 
				    DELETED.IdAgent AS IdAgent, 
				    DELETED.CreditLimit AS CreditLimit, 
				    DELETED.Margin AS Margin, 
				    INSERTED.Suggested AS Suggested, 
				    INSERTED.IsApproved AS IsApproved, 
				    INSERTED.DateOfLastChange AS DateOfLastChange; */

End Try
begin catch
    Declare @ErrorMessage nvarchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into Soporte.InfoLogForStoreProcedure (StoreProcedure,InfoDate,InfoMessage)Values('dbo.st_AgenciesUnderAmountLimit_SBQ',Getdate(),@ErrorMessage);
End Catch