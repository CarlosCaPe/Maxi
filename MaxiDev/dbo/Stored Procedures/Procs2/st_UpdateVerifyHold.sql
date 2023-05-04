-- =============================================
-- Author: Francisco Lara
-- Create date: 2016-03-17
-- Description: This stored is used for release/reject a transfer in corporate
--<ChangeLog>
--<log Date="09/01/2020" Author="bortega, adominguez">Agregar validacion de rechazos. Ref: T-2116 Rechazos desde Deposit Hold</log>
--<log Date="04/05/2020" Author="jgomez">Agregar validacion de rechazos. Ref: T-2116 Rechazos desde Deposit Hold</log>
--<log Date="24/08/2020" Author="jgomez">Unclaimed Hold</log>
--<log Date="01/10/2020" Author="jgomez">M00273 - Escenarios holds (Ticket 2245)</log>
--</ChangeLog>
-- =============================================
CREATE PROCEDURE [dbo].[st_UpdateVerifyHold]
(
@EnterByIdUser INT,
@IsSpanishLanguage BIT,
@IdTransfer INT,
@Note NVARCHAR(MAX),
@StatusHold INT,
@IsReleased BIT,
@HasError BIT OUTPUT,
@Message NVARCHAR(MAX) OUT,
@IdTransferHold INT = NULL
,@ReviewId BIT = NULL /*S17:Abr/2017*/
)
AS
BEGIN TRY
	SET NOCOUNT ON
	DECLARE @HoldsChanged INT
	, @IdStatus INT
	, @ComesFromStandBy BIT
	, @ClaimCode NVARCHAR(MAX)
	, @AgentCode NVARCHAR(MAX)
	, @IsSome bit = 0

	SELECT
	@IdStatus = T.[IdStatus]
	, @ComesFromStandBy = ISNULL(T.[FromStandByToKYC],0)
	, @ClaimCode = ISNULL(T.[ClaimCode],'')
	, @AgentCode = ISNULL(A.[AgentCode],'')
	FROM [dbo].[Transfer] T WITH (NOLOCK)
	JOIN [dbo].[Agent] A WITH (NOLOCK) ON T.[IdAgent] = A.[IdAgent]
	WHERE [IdTransfer] = @IdTransfer

	CREATE TABLE #TempTransferHolds
	(
		IdStatus INT,
		IsReleased varchar(20),
	)
	
	INSERT INTO #TempTransferHolds
	SELECT IdStatus, case when IsReleased is null then  2 else IsReleased end
	FROM dbo.TransferHolds with(nolock) where IdTransfer=@IdTransfer
	
	if (@Note = 'Rejected by MaxiMobileApp' or @Note = 'Released by MaxiMobileApp' or @Note = 'Transfer released by agent' or @Note = 'Transfer rejected by agent')
	Begin
	set @IsSome = 1
	update #TempTransferHolds set IsReleased = 2 
	END

	if EXISTS (Select * from #TempTransferHolds with(nolock) where IsReleased = 2) or Exists(Select * from transfer with(nolock) where IdTransfer = @IdTransfer AND IdStatus IN(24, 27))
	BEGIN

	if (@IsSome = 0 AND @StatusHold in (15, 18)) AND EXISTS (SELECT * FROM dbo.TransferHolds with(nolock) where IdTransferHold=@IdTransferHold and IdStatus in (15, 18) and IsReleased in (1, 0) AND EnterByIdUser = @EnterByIdUser) AND Not Exists(Select * from transfer with(nolock) where IdTransfer = @IdTransfer AND IdStatus IN(24, 27))--T-2116
	BEGIN
		SELECT @Message=[dbo].[GetMessageFromLenguajeResorces](@IsSpanishLanguage,122) -- CR M00273 --Agregar Id correspondiente a cada ambiente
		SET @HasError=1
	END
	ELSE 
	BEGIN

	--T-2116
	if (SELECT IsReleased FROM dbo.TransferHolds with(nolock) where IdTransfer=@IdTransfer and IdStatus=18 and IsReleased = 1 and (@StatusHold not in (3,6,9,12,15,18,24))) = 1
		SET @IsReleased = 1
	--T-2116

	IF @IdTransferHold IS NULL
	BEGIN
		UPDATE [dbo].[TransferHolds] SET [IsReleased]=@IsReleased, [DateOfLastChange]=GETDATE(),[EnterByIdUser]=@EnterByIdUser WHERE [IdTransfer] = @IdTransfer AND [IdStatus]=@StatusHold AND [IsReleased] IS NULL
	END

	ELSE
	BEGIN
		UPDATE [dbo].[TransferHolds] SET [IsReleased]=@IsReleased, [DateOfLastChange]=GETDATE(),[EnterByIdUser]=@EnterByIdUser WHERE [IdTransferHold] = @IdTransferHold AND [IdStatus]=@StatusHold AND [IsReleased] IS NULL
	END

	SET @HoldsChanged = @@ROWCOUNT
	IF @IdStatus= 41
	BEGIN
		IF @HoldsChanged = 1
		BEGIN
			--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateVerifyHoldDebug',Getdate(),'Hold Changed. @@rowcount='+CAST(@HoldsChanged AS VARCHAR(10))+' IdTransfer='+CAST(@IdTransfer AS VARCHAR(10))+ ' IdStatusHold='+CAST(@StatusHold AS VARCHAR(10)) +' IsRelease='+CAST(@IsReleased AS VARCHAR(10)))
			IF @IsReleased = 1 --A Hold has been Released
			BEGIN
				--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateVerifyHoldDebug',Getdate(),'Starting release hold')
				DECLARE @HoldAcceptedStatus INT
				SET @HoldAcceptedStatus = @StatusHold + 1
				EXEC [dbo].[st_SaveChangesToTransferLog] @IdTransfer,@HoldAcceptedStatus,@Note,@EnterByIdUser
				--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateVerifyHoldDebug',Getdate(),'Ending release hold')

				--Ofac Release
				IF @StatusHold=15
				BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM [dbo].[TransferOFACInfo] WITH (NOLOCK) WHERE [IdTransfer]=@IdTransfer AND [IdUserRelease1] IS NULL)
					BEGIN
						UPDATE [dbo].[TransferOFACInfo] SET [IdUserRelease1]=@EnterByIdUser,[UserNoteRelease1]=@Note,[DateOfRelease1]=GETDATE(),[IdOFACAction1]=2 WHERE [IdTransfer]=@IdTransfer
					END

					ELSE
					BEGIN
						UPDATE [dbo].[TransferOFACInfo] SET [IdUserRelease2]=@EnterByIdUser,[UserNoteRelease2]=@Note,[DateOfRelease2]=GETDATE(),[IdOFACAction2]=2 WHERE [IdTransfer]=@IdTransfer
					END
					INSERT INTO [dbo].[TransferOFACReview] ([IdTransfer],[IdUserReview],[DateOfReview],[IdOFACAction],[Note]) VALUES (@IdTransfer,@EnterByIdUser,GETDATE(),2,@Note)
				END

				SELECT @Message=dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,30)
				SET @HasError=0

			END

			ELSE --A Hold has been Rejected
			BEGIN
				--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateVerifyHoldDebug',Getdate(),'Starting reject hold')
				UPDATE [dbo].[Transfer] SET [IdStatus]=31, [DateStatusChange]=GETDATE() WHERE [IdTransfer]=@IdTransfer
				EXEC [dbo].[st_RejectedCreditToAgentBalance] @IdTransfer
				EXEC [dbo].[st_SaveChangesToTransferLog] @IdTransfer,31,@Note,@EnterByIdUser
				EXEC [dbo].[st_DismissComplianceNotificationByIdTransfer] @IdTransfer, @IsSpanishLanguage, @HasError OUTPUT, @Message OUTPUT
				--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateVerifyHoldDebug',Getdate(),'Ending reject hold')

				--Ofac Reject
				IF @StatusHold=15
				BEGIN
					IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[TransferOFACInfo] WITH (NOLOCK) WHERE [IdTransfer]=@IdTransfer AND [IdUserRelease1] IS NULL)
					BEGIN
						UPDATE [dbo].[TransferOFACInfo] SET [IdUserRelease1]=@EnterByIdUser,[UserNoteRelease1]=@Note,[DateOfRelease1]=GETDATE(),[IdOFACAction1]=3 WHERE [IdTransfer]=@IdTransfer
					END

					ELSE
					BEGIN
						UPDATE [dbo].[TransferOFACInfo] SET [IdUserRelease2]=@EnterByIdUser, [UserNoteRelease2]=@Note, [DateOfRelease2]=GETDATE(),[IdOFACAction2]=3 WHERE [IdTransfer]=@IdTransfer
					END
					INSERT INTO [dbo].[TransferOFACReview] ([IdTransfer],[IdUserReview],[DateOfReview],[IdOFACAction],[Note]) VALUES (@IdTransfer,@EnterByIdUser,GETDATE(),3,@Note)
				END

				SELECT @Message=[dbo].[GetMessageFromLenguajeResorces](@IsSpanishLanguage,92)
				SET @HasError=0
			END
			IF @StatusHold = 9 AND @ComesFromStandBy = 1 -- KYC Hold AND [FromStandByToKYC] = 1
			BEGIN
				DECLARE @DistributionList NVARCHAR(MAX), @Subject NVARCHAR(MAX), @Body NVARCHAR(MAX)
				EXEC [dbo].[st_GetGlobalAttributeValueByName] @AttributeName = 'StandByToKycEmails', @AttributeValue = @DistributionList OUTPUT
				SELECT @Subject = 'Daily Monitoring - Transaction ' + @ClaimCode +' was ' + CASE WHEN @IsReleased = 1 THEN 'released' ELSE 'rejected' END + ' from KYC Hold'
				SELECT @Body = 'Transaction ' + @ClaimCode + ' from ' + @AgentCode + ' was ' + CASE WHEN @IsReleased = 1 THEN 'released' ELSE 'rejected' END + ' from KYC Hold ' + FORMAT(GETDATE(), '', 'en-US')

				EXEC [MoneyAlert].[MailByTelephoneServiceProvider]
				@FullEmail = @DistributionList,
				@SubjectMessage = @Subject,
				@BodyMessage = @Body
			END

            IF @StatusHold = 15
            BEGIN
                DECLARE @IdCustomer     		INT,
                        @IdBeneficiary  		INT,
						@CustomerHasMarch		BIT,
						@BeneficiaryHasMarch	BIT

                SELECT
                    @IdCustomer = t.IdCustomer,
                    @IdBeneficiary = t.IdBeneficiary,

					@CustomerHasMarch = IIF(o.CustomerMatch IS NULL, 0, 1),
					@BeneficiaryHasMarch = IIF(o.BeneficiaryMatch IS NULL, 0, 1)
                FROM Transfer t WITH(NOLOCK)
					JOIN TransferOFACInfo o WITH(NOLOCK) ON o.IdTransfer = t.IdTransfer
                WHERE t.IdTransfer = @IdTransfer

                IF 	@CustomerHasMarch = 1 AND 
					(SELECT TOP 1 t.IdTransfer FROM Transfer t WITH(NOLOCK) WHERE t.IdCustomer = @IdCustomer ORDER BY t.IdTransfer DESC) = @IdTransfer
                    EXEC st_UpdateEvaluationOFACAutoRelease @IdCustomer, 1, @IsReleased

				IF 	@BeneficiaryHasMarch = 1 AND 
					(SELECT TOP 1 t.IdTransfer FROM Transfer t WITH(NOLOCK) WHERE t.IdCustomer = @IdCustomer AND t.IdBeneficiary = @IdBeneficiary ORDER BY t.IdTransfer DESC) = @IdTransfer
                    EXEC st_UpdateEvaluationOFACAutoRelease @IdBeneficiary, 2, @IsReleased
            END
		END
		ELSE
		BEGIN --Invalid change due to someone else changed it before
			--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateVerifyHoldDebug',Getdate(),'Invalid change due to someone else changed it before. @@rowcount='+CAST(@HoldsChanged AS VARCHAR(10))+' IdTransfer='+CAST(@IdTransfer AS VARCHAR(10))+ ' IdStatusHold='+CAST(@StatusHold AS VARCHAR(10)) +' IsRelease='+CAST(@IsReleased AS VARCHAR(10)))
			SELECT @Message=[dbo].[GetMessageFromLenguajeResorces](@IsSpanishLanguage,122) -- CR M00273 --Agregar Id correspondiente a cada ambiente
			SET @HasError=1
		END
	END

	ELSE
	BEGIN
		IF (@IdStatus =24 AND EXISTS(SELECT TOP 1 [IdTransferHold] FROM [dbo].[TransferHolds] WITH (NOLOCK) WHERE [IdTransfer] = @IdTransfer AND ([IsReleased] IS NULL OR [IsReleased]=0)))--fax returned
		BEGIN
			UPDATE [dbo].[Transfer] SET [IdStatus]=41, [DateStatusChange]=GETDATE() WHERE [IdTransfer]=@IdTransfer --revert status to verify hold

			EXEC [dbo].[st_UpdateVerifyHold] @EnterByIdUser, @IsSpanishLanguage, @IdTransfer, @Note, 3, @IsReleased,
			@HasError = @HasError OUTPUT,
			@Message = @Message OUTPUT

			--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateVerifyHold Signature',Getdate(),@Message)

		END
		ELSE
		BEGIN
		--normal process
		--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateVerifyHoldDebug',Getdate(),'Invalid change, transfer not in verify hold status @@rowcount='+CAST(@HoldsChanged AS VARCHAR(10))+' IdTransfer='+CAST(@IdTransfer AS VARCHAR(10))+ ' IdStatus='+CAST(@IdStatus AS VARCHAR(10)) +' IdStatusHold='+CAST(@StatusHold AS VARCHAR(10))+' IsRelease='+CAST(@IsReleased AS VARCHAR(10)))
		DECLARE @NewStatus INT
		IF (@IsReleased = 1)
		BEGIN
			SELECT @NewStatus =
			CASE @IdStatus
			WHEN 24 THEN 20 --Returned pass to StandBy
			WHEN 27 THEN 28 --Unclaim pass to UnclaimCompleted
			END
		END

		ELSE
		BEGIN
			SET @NewStatus = 31
		END

		EXEC [dbo].[st_UpdateComplianceStatus] @EnterByIdUser, @IsSpanishLanguage, @IdTransfer, @Note, @IdStatus,@NewStatus,
		@HasError = @HasError OUTPUT,
		@Message = @Message OUTPUT

		IF @HasError=0 and @NewStatus=31
		BEGIN
			SET @Message = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,92)
		END

		END
	 END
    END
   END

ELSE

	BEGIN
	SELECT @Message=[dbo].[GetMessageFromLenguajeResorces](@IsSpanishLanguage,122) -- CR M00273 --Agregar Id correspondiente a cada ambiente
		SET @HasError=1
	END

	
END TRY

BEGIN CATCH
	SET @HasError=1
	SELECT @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_UpdateVerifyHold', GETDATE(),@ErrorMessage)
END CATCH
drop table #TempTransferHolds
