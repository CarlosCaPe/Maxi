CREATE PROCEDURE [dbo].[st_AgenciesUnderAmountLimit]
as
/********************************************************************
<Author></Author>
<app></app>
<Description>Obtiene agencias candidatas a reduccion de credito</Description>

<ChangeLog>
<log Date="19/07/2018" Author="snevarez"> CO_003_SuggestCreditLimit </log>
</ChangeLog>
*********************************************************************/
Begin try

SET NOCOUNT ON;

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
	   Production MONEY, /*Balance Max*/    
	   Percentage DECIMAL(10,2) DEFAULT(0),
	   Margin MONEY DEFAULT(0),
	   Suggest MONEY DEFAULT(0),
	   Review BIT DEFAULT(0)
    );

    /*Obtiene informacion de las agencias*/
    INSERT INTO @Agents (IdAgent,AgentCode,AgentName,BalanceActual,CreditActual,IdAgentClass,AgentClass,IdAgentStatus,DateOfDeposit,Percentage)
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

		  ,AC.ClassPercent AS Percentage
	   FROM Agent AS A With(NoLock)
		  Inner Join AgentClass AS AC With(NoLock) On A.IdAgentClass = AC.IdAgentClass
		  Inner Join AgentCurrentBalance AS ACB With(NoLock) On A.IdAgent = ACB.IdAgent
	   WHERE A.IdAgentStatus NOT IN (2, 6, 5); /*Disabled(2),Collections(5),Write Off(6)*/

    /*Se busca los valores Production(Balance Maximo),Margin y Suggest para cada agencia*/
    WHILE EXISTS(SELECT 1 FROM @Agents WHERE Review = 0)
    BEGIN

	   DECLARE @IdAgent int 
	   DECLARE @DateTo datetime;
	   DECLARE @DateFrom datetime;

	   DECLARE @DaysBack int = 61;
	   DECLARE @IdAgentCollectType int = 4 /*MaxiBackOffice.Sl.Collection.Payments.Views -> No Codified Deposit*/

	   DECLARE @Percentage DECIMAL(12,2)
	   DECLARE @Production MONEY;
	   DECLARE @Margin MONEY;
	   DECLARE @Suggest MONEY;

	   SELECT TOP 1 
		  @IdAgent = IdAgent
		  ,@DateTo = DateOfDeposit
		  ,@Percentage = (Percentage/100)
	   FROM @Agents 
		  WHERE Review = 0;

	   /*Se busca la fecha del ultimo pago(deposito)*/
	   SET @DateFrom = dbo.RemoveTimeFromDatetime(DATEDIFF(day, @DaysBack, @DateTo));
	   ;with cte_deposit as 
	   (
		  Select    
			 AB.DateOfMovement
			 ,AB.Amount
			 ,rank() over (order by AB.DateOfMovement desc) rnk
		  From AgentBalance AS AB With(NoLock)
			 Inner Join [dbo].[AgentDeposit] AS AD With(NoLock) On AB.IdAgentBalance = AD.[IdAgentBalance]
		  Where AB.IdAgent = @IdAgent
			 AND AD.IdAgentCollectType =  @IdAgentCollectType
			 AND AB.DateOfMovement >= @DateFrom
			 AND AB.DateOfMovement < @DateTo
	   )Select 
			 @DateTo = ISNULL(DateOfMovement,GETDATE())
		  From cte_deposit Where rnk = 1;

	   SET @DateFrom = dbo.RemoveTimeFromDatetime(DATEDIFF(day, @DaysBack, @DateTo));

	   /*Se busca balance de cierre maximo (por dia)*/
	   Select	   
		  @Production = MAX(Balance)
		  --rank() over (partition by dbo.RemoveTimeFromDatetime(DateOfMovement) order by DateOfMovement desc) rnk
	   From AgentBalance With(NoLock)
		  Where IdAgent = @IdAgent
			 AND DateOfMovement >= @DateFrom
			 AND DateOfMovement < @DateTo
   
	   /*Margin = Produccion * Porcentaje de Clase*/
	   SET @Margin = ROUND(ISNULL(@Production,0) * ISNULL(@Percentage,0),0)

	   /*Suggested Credit Limit = Produccion + Margin*/
	   SET @Suggest = ROUND(ISNULL(@Margin,0) + ISNULL(@Production,0),0)

	   UPDATE @Agents
	   SET 
		  DateOfDeposit = @DateTo
		  ,Production = @Production
		  ,Margin = @Margin
		  ,Suggest = @Suggest
		  ,Review = 1
	   WHERE IdAgent = @IdAgent;

    END

    DECLARE @SystemIdUser INT;
    SELECT @SystemIdUser=dbo.GetGlobalAttributeByName('SystemUserID');

    MERGE dbo.AgentCreditSuggest AS TARGET
	   USING @Agents AS SOURCE 
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
				    VALUES (SOURCE.IdAgent, SOURCE.CreditActual, SOURCE.Margin, SOURCE.Suggest, NULL, GETDATE(),@SystemIdUser, '')
			 OUTPUT $action, 
				    DELETED.IdAgent AS IdAgent, 
				    DELETED.CreditLimit AS CreditLimit, 
				    DELETED.Margin AS Margin, 
				    INSERTED.Suggested AS Suggested, 
				    INSERTED.IsApproved AS IsApproved, 
				    INSERTED.DateOfLastChange AS DateOfLastChange; 

End Try
begin catch
    Declare @ErrorMessage nvarchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into Soporte.InfoLogForStoreProcedure (StoreProcedure,InfoDate,InfoMessage)Values('dbo.st_AgenciesUnderAmountLimit',Getdate(),@ErrorMessage);
End Catch