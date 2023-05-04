

CREATE PROCEDURE [dbo].[st_InitVerifyDepositHold_ReleaseTime]
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="13/09/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
BEGIN
	DECLARE @startTime as time(0) --Defines the low boundary
	DECLARE @endTime as time(0) --Defines the high boundary
	DECLARE @holdTime as int --Defines the time that a Transfer remains in DH Status, EXPRESSED in MINUTES

	SELECT @startTime = ga.Value
	FROM GlobalAttributes AS ga WITH(NOLOCK)
	WHERE ga.Name = 'DepositHoldStartTime'
	
	SELECT @endTime = ga.Value
	FROM GlobalAttributes AS ga WITH(NOLOCK)
	WHERE ga.Name = 'DepositHoldEndTime'

	SELECT @holdTime = ga.Value
	FROM GlobalAttributes AS ga WITH(NOLOCK)
	WHERE ga.Name = 'DepositHoldTime'    


	CREATE TABLE #DepositHolds(IdTransferHold int, IdTransfer int)

	INSERT INTO #DepositHolds
	SELECT th.IdTransferHold, th.IdTransfer
	FROM TransferHolds as th WITH(NOLOCK)
	WHERE th.IdStatus = 18 --Deposit Hold
		AND th.IsReleased IS NULL
	ORDER BY th.DateOfValidation

	DECLARE @idTransferHold as int, @idTransfer as int	

	WHILE EXISTS(SELECT 1 FROM #DepositHolds)
	BEGIN
		SELECT TOP 1 @idTransferHold = IdTransferHold, @idTransfer = IdTransfer
		FROM #DepositHolds

		EXEC st_VerifyDepositHold_ReleaseTime @idTransferHold, @idTransfer, @startTime, @endTime, @holdTime

		DELETE FROM #DepositHolds WHERE IdTransferHold = @idTransferHold
	END

END
