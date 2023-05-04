CREATE PROCEDURE [Corp].[st_CheckUpdateVerifyHold_Checks]
 (
    @EnterByIdUser INT, 
    @IsSpanishLanguage BIT, 
    @IdCheck INT, 
    @Note NVARCHAR(MAX), 
    @StatusHold INT, 
    @IsReleased BIT, 
    @HasError BIT OUT, 
    @Message NVARCHAR(MAX) OUT, 
    @IdCheckHold INT = NULL
 )
 AS

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/06/05" Author="mdelgado">s24_17 :: Add Notification of check rejected if agent allow notifications.. </log>
<log Date="23/01/2018" Author="jmolina">Add with(nolock) and schema</log>
<log Date="14/07/2022" Author="cagarcia">https://maxims.atlassian.net/browse/SD1-2034  Invalid MICR Line Information</log>
</ChangeLog>
********************************************************************/
	 SET NOCOUNT ON
	 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	 BEGIN TRY

	
		DECLARE @IdAgent INT
		DECLARE @CheckReject INT 
		DECLARE @HoldsChanged INT
		DECLARE @IdStatus INT
		DECLARE @SENDNotification bit
		DECLARE @HoldAcceptedStatus INT
		
		
		/*cagarcia SD1-2034*/
		IF (@IsReleased = 1 AND EXISTS (SELECT 1 FROM Checks WITH(NOLOCK) WHERE IdCheck = @IdCheck AND RoutingNumber <> MicrRoutingTransitNumber))
		BEGIN
			INSERT  INTO ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage)Values('Corp.st_CheckUpdateVerifyHold_Checks', GETDATE(), 'RoutingNumber and MicrRoutingTransitNumber are different')
			SET @HasError = 1
			SET @Message ='Check cannot be released, please contact IT Department'
			RETURN
		END
		

		SET	@CheckReject = 0
		--SET @IdAgent = (SELECT IdAgent FROM checks WHERE IdCheck = @IdCheck)	
		--SELECT @IdStatus = IdStatus FROM Checks WHERE IdCheck = @IdCheck
		SELECT @IdAgent = IdAgent, @IdStatus = IdStatus FROM Checks WHERE IdCheck = @IdCheck

		IF(@IsReleased = 0 AND (@StatusHold = 12 OR @StatusHold = 57 OR @StatusHold = 61 OR @StatusHold = 64))
		BEGIN

			IF EXISTS (SELECT 1 FROM [dbo].CheckHolds WHERE idCheck = @IdCheck AND IdStatus = 15 AND IsReleased IS NULL)
			BEGIN
				SET @HasError = 1
				SET @Message ='This transaction cannot be rejected because it has an OFAC Hold status'
				RETURN 
			END
		END

		IF (@IdCheckHold IS NULL)
		BEGIN
			UPDATE [dbo].CheckHolds SET IsReleased = @IsReleased, DateOfLastChange = GETDATE(), EnterByIdUser = @EnterByIdUser WHERE IdCheck = @IdCheck AND IdStatus = @StatusHold AND  IsReleased IS NULL
			SET @HoldsChanged = @@ROWCOUNT
			IF (@IsReleased = 0 AND @StatusHold = 15)
				BEGIN
					UPDATE [dbo].CheckHolds SET IsReleased = 0, DateOfLastChange = GETDATE(), EnterByIdUser = @EnterByIdUser WHERE IdCheck = @IdCheck AND IdStatus=12 AND  IsReleased IS NULL
				   SELECT * FROM [dbo].CheckHolds WITH(NOLOCK)
				END
		END
		ELSE
		BEGIN
			UPDATE [dbo].CheckHolds SET IsReleased = @IsReleased,  DateOfLastChange = GETDATE(), EnterByIdUser = @EnterByIdUser WHERE IdCheckHold = @IdCheckHold AND IdStatus = @StatusHold AND  IsReleased IS NULL
			SET @HoldsChanged = @@ROWCOUNT
		END

		IF @IdStatus= 41
		BEGIN
			IF (@HoldsChanged = 1  OR (@HoldsChanged = 2 AND @StatusHold=15))
			BEGIN
				IF @IsReleased = 1 --A Hold has been Released
				BEGIN
					IF (@StatusHold=57)
						SET @HoldAcceptedStatus = 59
					ELSE
						SET @HoldAcceptedStatus = @StatusHold +1

					EXEC Corp.st_SaveChangesToCheckLog_Checks @IdCheck, @HoldAcceptedStatus, @Note, @EnterByIdUser

					--Ofac Release
					IF (@StatusHold=15)
					BEGIN
						IF EXISTS(SELECT 1 from [dbo].CheckOFACInfo WITH(NOLOCK) WHERE idCheck = @IdCheck AND IdUserRelease1 IS NULL)
						BEGIN
							UPDATE [dbo].CheckOFACInfo SET IdUserRelease1 = @EnterByIdUser, UserNoteRelease1 = @Note, DateOfRelease1= GETDATE(), IdOFACAction1 = 2 WHERE idCheck = @IdCheck                        
						END  
						ELSE
						BEGIN
							UPDATE [dbo].CheckOFACInfo SET IdUserRelease2 = @EnterByIdUser, UserNoteRelease2 = @Note, DateOfRelease2 = GETDATE(), IdOFACAction2 = 2 WHERE idCheck = @IdCheck                         
						END	
						INSERT  INTO [dbo].CheckOFACReview (IdCheck, IdUserReview, DateOfReview, IdOFACAction, Note) VALUES (@IdCheck, @EnterByIdUser, GETDATE(), 2, @Note)
					END

					SELECT @Message=dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage, 30)
					SET @HasError=0
				END
				ELSE --A Hold has been Rejected
				BEGIN
					SET @CheckReject = 1
					UPDATE [dbo].Checks SET IdStatus=31, DateStatusChange= GETDATE() WHERE IdCheck = @IdCheck

					EXEC Corp.st_SaveChangesToCheckLog_Checks @IdCheck, 31, @Note, @EnterByIdUser
					EXEC [Corp].st_DismissComplianceNotificationByIdCheck @idCheck, @IsSpanishLanguage,  @HasError OUTPUT,  @Message OUTPUT			

					/*07-Sep-2021*/
					/*UCF*/
					/*TSI_MAXI_013*/
					/*Todos los cheques rechazados deben afectar el balance independientemente de su estatus previo*/
					EXEC [Checks].[st_CheckCancelToAgentBalance] @IdCheck, @EnterByIdUser, 0

					 --Ofac Reject
					IF (@StatusHold=15)
					BEGIN
						IF NOT EXISTS(SELECT 1 from [dbo].CheckOFACInfo WITH(NOLOCK) WHERE idCheck = @IdCheck AND IdUserRelease1 IS NULL)
						BEGIN
							UPDATE [dbo].CheckOFACInfo SET IdUserRelease1 = @EnterByIdUser, UserNoteRelease1 = @Note, DateOfRelease1 = GETDATE(), IdOFACAction1 = 3 WHERE idCheck = @IdCheck                        
						END 
						ELSE
						BEGIN
							UPDATE [dbo].CheckOFACInfo SET IdUserRelease2 = @EnterByIdUser, UserNoteRelease2 = @Note, DateOfRelease2 = GETDATE(), IdOFACAction2 = 3 WHERE idCheck = @IdCheck                        
						END                   
						INSERT INTO [dbo].CheckOFACReview (IdCheck, IdUserReview, DateOfReview, IdOFACAction, Note) VALUES (@IdCheck, @EnterByIdUser, GETDATE(), 3, @Note)
					END
					SELECT @Message=dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage, 92)
					SET @HasError=0
				END
			END
			ELSE
			BEGIN 
				SELECT @Message=dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage, 31)
				SET @HasError=1
			END
		END
	
		IF EXISTS (SELECT 1 from [dbo].agent WITH(NOLOCK) WHERE idagentcommunication in (1, 4) AND idagent = @IdAgent)
		BEGIN 
			SET @SENDNotification = 1

			 /*57 -> ENDorse Hold*/
			CREATE TABLE #Holds(Id INT IDENTITY(1, 1), IsReleased BIT)
			INSERT  INTO #Holds 
				SELECT IsReleased from [dbo].CheckHolds WITH(NOLOCK) WHERE IdCheck = @IdCheck AND IdStatus <> 57 AND IdStatus <> 68; /*2016/Ago/08 : Add 68->Image Checks Hold*/

			DECLARE @IsReviwed bit 
 
			WHILE EXISTS (SELECT 1 from #Holds WITH(NOLOCK))      
			BEGIN
				SELECT TOP 1 @IsReviwed=IsReleased from #Holds
					IF (@IsReviwed IS NULL)
					BEGIN
						SET @SENDNotification = 0
					END
				DELETE #Holds WHERE Id = (SELECT TOP 1 Id FROM #Holds)
			END

			SELECT @IsReviwed
			DROP TABLE #Holds

			
			IF (@SENDNotification = 1)
			BEGIN
				EXEC [Corp].[st_SENDKYCCheckMessage_msg]
					@IdCheck = @IdCheck, 
					@MessageTEXT = @Note, 
					@IdUser = @EnterByIdUser, 
					@IsSpanishLanguage = @IsSpanishLanguage, 
					@IsReleasedFromVerifyHold = @IsReleased, 
					@HasError = @HasError out, 
					@Message = @Message out

					--- REGISTRO DE ALERTA DE RECHAZO MANUAL DE CHEQUE
					IF(@CheckReject = 1)
					BEGIN
						PRINT 'NOTIFICATION SENT'
						EXEC [dbo].[st_RejectCheckNotification] @IdCheck, @EnterByIdUser, @Note
					END
			END
			ELSE
			BEGIN
				IF(@CheckReject = 1)
				BEGIN
					EXEC [Corp].[st_SENDKYCCheckMessage_msg]
						@IdCheck = @IdCheck, 
						@MessageTEXT = @Note, 
						@IdUser = @EnterByIdUser, 
						@IsSpanishLanguage = @IsSpanishLanguage, 
						@IsReleasedFromVerifyHold = @IsReleased, 
						@HasError = @HasError out, 
						@Message = @Message out		

					
				END
			END

			IF (@HasError = 1)
				RETURN
		END
	END TRY
	BEGIN CATCH
		SET @HasError = 1
		SELECT @Message = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage, 33)
		DECLARE @ErrorMessage NVARCHAR(max)
		SELECT @ErrorMessage = ERROR_MESSAGE()
		INSERT  INTO ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage)Values('Corp.st_CheckUpdateVerifyHold_Checks', GETDATE(), @ErrorMessage)
	END CATCH


