CREATE PROCEDURE [dbo].st_ScannerFeeApplyToAgentBalance

AS
BEGIN TRY

    DECLARE @IdAgent INT
    DECLARE @Balance MONEY = 0
    DECLARE @Total MONEY
    DECLARE @Name NVARCHAR(MAX) = 'Check Scanner Fee'
    --DECLARE @DebitCredit NVARCHAR(MAX)= 'Credit'
    --DECLARE @TypeOfMovement NVARCHAR(MAX)= 'CGO'
    DECLARE @IdAgentBalance INT
	DECLARE @DateOfMovement DATETIME
    DECLARE	@EnterByIdUser INT
	DECLARE	 @Time DATETIME = GETDATE()

	DECLARE @ErrorMessage NVARCHAR(MAX)	
	DECLARE @HasError bit = 0

SELECT *  INTO #AgentScannerFee FROM ( SELECT f.FeeCheckScanner, a.[IdAgent] 
	                                       FROM Agent AS a WITH(NOLOCK)
	                                       INNER JOIN feechecks AS f  WITH(NOLOCK) on (a.IdAgent = f.IdAgent and f.FeeCheckScanner > 0) where a.idAgentStatus = 1 ) t 

WHILE (EXISTS (SELECT 1 FROM #AgentScannerFee))
BEGIN


	SELECT TOP 1
			@Total = FeeCheckScanner,
			@IdAgent = [IdAgent],
			@DateOfMovement = GetDate(),
			@EnterByIdUser = 37
	FROM #AgentScannerFee
---------------------------

 EXEC [dbo].[st_SaveOtherCharge]
		        1,
		        @IdAgent,
		        @Total,
		        1,      --IsDebit -> 1: Debit,0 : Credit
		        @DateOfMovement,
		        @Name, --N'',
		        '',--@IdCalendarCollect,
		        @EnterByIdUser,
		        @HasError OUTPUT,
		        @ErrorMessage OUTPUT,
                29,--11	Collection Plan Fee – (Fee by Calendar Collection) -> 29 Scanner Fee
                null;

-----------------------------
	DELETE FROM #AgentScannerFee WHERE IdAgent = @IdAgent
  
END
    
END TRY
BEGIN CATCH
   SET @HasError = 1
    SELECT @ErrorMessage=ERROR_MESSAGE()
    INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_ScannerFeeApplyToAgentBalance', GETDATE(), @ErrorMessage)
END CATCH

