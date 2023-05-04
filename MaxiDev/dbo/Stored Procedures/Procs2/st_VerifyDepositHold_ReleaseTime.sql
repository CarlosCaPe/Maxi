CREATE PROCEDURE [dbo].[st_VerifyDepositHold_ReleaseTime](@idTransferHold as int, @idTransfer as int, @startTime as time(0), @endTime as time(0), @holdTime as int)
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="13/09/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
AS
BEGIN	
	SET NOCOUNT ON;
	--NOTE DH = Deposit Hold	
	DECLARE @statusDateTime as datetime --Defines the datetime when a transfer falls in DH
	DECLARE @ellapsedTime as int --defines the ellapsed time since a transfer falls in DH, EXPRESSED in MINUTES
	DECLARE @remainingTime as time(0) --defines the ellapsed time WHEN a transfer falls in DH in a day and reaches the @endTime WITHOUT complete the RELASE so continues the NEXT DAY

	DECLARE @statusDate as date --defines the date part of the @statusDateTime
	DECLARE @statusTime as time(3) --defines the time part of the @statusDateTime
	DECLARE @currentTime as time(0) --defines the current time of the server	

	SET @currentTime = CONVERT(time, GETDATE())	
	
	--if out of boundaries then return
	IF(@currentTime < @startTime AND @currentTime < @endTime) OR
		(@currentTime > @startTime AND @currentTime > @endTime)
		RETURN

	SELECT @statusDateTime = DateOfValidation,
			@statusDate = CONVERT(date, DateOfValidation),
			@statusTime = CONVERT(time, DateOfValidation)
	FROM TransferHolds AS th WITH(NOLOCK)
    inner join [transfer] AS t WITH(NOLOCK) on th.idTransfer=t.idtransfer	
	WHERE th.IdTransferHold = @idTransferHold	
    and t.idstatus=41    
    
	--In the same day
	IF(DATEPART(dayofyear, @statusDate) = DATEPART(dayofyear, GETDATE()))
		BEGIN			
			--verify boundaries
			DECLARE @maxStatusTime as time(0) = DATEADD(MINUTE,@holdTime,@statusTime)
			
			--exceeds high boundary
			IF(@maxStatusTime > @endTime)
				RETURN

			IF(@statusTime <= @startTime)--For the cases when the transfer is created before the @startTime in the same day we take the @startTime instead of @statusTime
				SET @ellapsedTime = DATEDIFF(MINUTE, @startTime, CONVERT(time, GETDATE()))
			ELSE
				SET @ellapsedTime = DATEDIFF(MINUTE, @statusTime, CONVERT(time, GETDATE()))
							
			
			--SET @ellapsedTime = DATEDIFF(MINUTE, @statusTime, CONVERT(time, GETDATE()))
			IF(@ellapsedTime >= @holdTime)
				BEGIN
					--release
					UPDATE TransferHolds SET IsReleased = 1, DateOfLastChange = GETDATE() WHERE IdTransferHold = @idTransferHold
					Exec st_SaveChangesToTransferLog @idTransfer, 19, 'Deposit Accepted: Automatically released it by the system',0
					RETURN
				END			
		END
	ELSE IF((DATEPART(dayofyear,@statusDate) < DATEPART(dayofyear, GETDATE())) OR
			DATEPART(year,@statusDate) < DATEPART(year, GETDATE()))
		BEGIN 
			DECLARE @ellapsedAux as int, @remainingAux as int

			--verify boundaries			
			SET @ellapsedAux = DATEDIFF(MINUTE, @statusTime, @endTime) --got yesterday's left time

			IF(@ellapsedAux < 0)--If negative it means the transfer was created after the EndTime in a day so it must be processed the next day at the begining of @startTime
				SET @ellapsedAux = 0

			SET @remainingAux = @holdTime - @ellapsedAux
			SET @remainingTime = DATEADD(MINUTE, @remainingAux, @startTime)			
			
			IF(CONVERT(time(0), GETDATE()) >= @remainingTime OR @remainingAux < 0) --the validation ->(@remainingAux < 0): is for weird cases when a transfer has more than 1 day in hold (in tehory this must never happens)
				BEGIN
					--release
					UPDATE TransferHolds SET IsReleased = 1, DateOfLastChange = GETDATE() WHERE IdTransferHold = @idTransferHold
					Exec st_SaveChangesToTransferLog @idTransfer, 19, 'Deposit Accepted: Automatically released it by the system',0
					RETURN
				END
		END							
		
END
