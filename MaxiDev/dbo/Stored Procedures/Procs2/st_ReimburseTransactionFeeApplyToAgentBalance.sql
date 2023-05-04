CREATE PROCEDURE [dbo].[st_ReimburseTransactionFeeApplyToAgentBalance]
	@CurrentMonth BIT = 0
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

/*
     Cambio  Devp         Fecha            Nota:
**-----------------------------------------------------------------------------------------
      1      MHinojo       25/04/2017     Creación.
      2      Jmoreno       28/04/2017     Se agrega parametro para  correr el ajusto del Mes en curso.
																				  Se valida si ya se guardo el Reimburse para que cuando se ejecute varias veces el USP no guarde repetidos.      

  
*/

BEGIN TRY





--{#2

declare
 @Notes nvarchar(50)
 , @Month int
set 
 @Notes = 'Reimburse Transaction Fee'
 
set 
  @Month = -1 
 
	if (@CurrentMonth=1) 
	 begin 
		set 
		 @Month=0
	 end
	
 --}#2
 
 

DECLARE @NumChecks AS INT, @CurrentDate AS DATETIME, @ErrorMessage NVARCHAR(MAX), @HasError bit = 0;
SET @CurrentDate = GETDATE();
DECLARE @AgentsTemp AS TABLE (IdAgent INT , NumChecks INT , ReimburseTransactionFee MONEY, Goal INT);
WITH cte  (IdAgent, NumChecks, ReimburseTransactionFee, Goal)
AS
(
SELECT        
C.IdAgent, COUNT(*) AS NumChecks, (ISNULL(SUM(ISNULL(C.TransactionFee, 0)), 0) +  ISNULL(SUM(ISNULL(C.ValidationFee, 0)), 0)) AS ReimburseTransactionFee
, ISNULL((SELECT TOP 1 Goal FROM AgentReimburseConfig with(nolock) WHERE Statusactive = 1 AND IdAgent = C.IdAgent), 0) AS Goal
FROM            
Checks C with(nolock)
WHERE        
MONTH(C.DateOfMovement) = MONTH(DATEADD(MONTH, @Month, @CurrentDate)) AND YEAR(C.DateOfMovement) = YEAR(DATEADD(MONTH, @Month, @CurrentDate)) --#2
GROUP BY C.IdAgent
)
INSERT INTO @AgentsTemp
SELECT IdAgent, NumChecks, ReimburseTransactionFee, Goal FROM cte WHERE NumChecks >= Goal AND Goal > 0;

--SELECT * FROM @AgentsTemp

DECLARE @Min AS INT
SET @Min = (SELECT MIN(IdAgent) FROM @AgentsTemp)
WHILE @Min IS NOT NULL
BEGIN
	DECLARE @TotalTranFee AS MONEY = (SELECT ReimburseTransactionFee FROM @AgentsTemp WHERE IdAgent = @Min)
	
	
--{#2

	
if not exists
         (  
				   select
             1
           from
            AgentOtherCharge O with(nolock)
           where 
            Notes=@Notes
            and MONTH(O.DateOfLastChange) = MONTH( @CurrentDate) 
            and YEAR(O.DateOfLastChange) = YEAR( @CurrentDate)
            and O.IdAgent = @Min         
         ) 	
begin
	EXEC [dbo].[st_SaveOtherCharge]
	--SELECT
	1,
	@Min,
	@TotalTranFee,
	0, --IsDebit -> 1: Debit,0 : Credit
	@CurrentDate,
	@Notes, 
	'',
	37, --usersystem
	@HasError OUTPUT,
	@ErrorMessage OUTPUT,
	13,--13	4406-14 Reibursement 
	null;
end 

--}#2
	
	SET @Min = (SELECT MIN(IdAgent) FROM @AgentsTemp WHERE IdAgent > @Min)
END
END TRY
BEGIN CATCH
   SET @HasError = 1
    SELECT @ErrorMessage=ERROR_MESSAGE()
    INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_ReimburseTransactionFeeApplyToAgentBalance', GETDATE(), @ErrorMessage)
END CATCH

