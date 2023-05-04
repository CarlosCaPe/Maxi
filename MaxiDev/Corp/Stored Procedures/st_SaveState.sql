CREATE PROCEDURE [Corp].[st_SaveState] (@IdState INT,
@StateName NVARCHAR(MAX),
@IdCountry INT,
@EnterByIdUser INT,
@StateCode NVARCHAR(MAX) = NULL,
@StateCodeBTS NVARCHAR(MAX) = NULL,
@StateCodeISO3166 NVARCHAR(6) = NULL,
@SendLicense BIT,
@HasError INT OUT,
@Message NVARCHAR(MAX) OUT,
@ComplaintNoticeEnglish NVARCHAR(MAX) = NULL,
@ComplaintNoticeSpanish NVARCHAR(MAX) = NULL,
@AffiliationNoticeEnglish NVARCHAR(MAX) = NULL,
@AffiliationNoticeSpanish NVARCHAR(MAX) = NULL)
AS
SET NOCOUNT ON;
BEGIN
	SET @HasError = 0
	SET @Message = ''

	DECLARE @IdCountryUSA INT
	SELECT @IdCountryUSA = IdCountry FROM Country WITH (NOLOCK) WHERE CountryCode = 'USA'

	BEGIN TRY
		IF (@IdState = 0)
		BEGIN
			INSERT INTO [dbo].[State] ([StateName], [IdCountry], [DateOfLastChange], [EnterByIdUser], [StateCode], [StateCodeBTS], [StateCodeISO3166], [SendLicense])
				VALUES (@StateName, @IdCountry, GETDATE(), @EnterByIdUser, @StateCode, @StateCodeBTS, @StateCodeISO3166, @SendLicense)
		END
		ELSE
		BEGIN
			UPDATE [dbo].[State]
			SET [StateName] = @StateName
				,[IdCountry] = @IdCountry
				,[DateOfLastChange] = GETDATE()
				,[EnterByIdUser] = @EnterByIdUser
				,[StateCode] = ISNULL(NULLIF(@StateCode, ''), [StateCode])
				,[StateCodeBTS] = ISNULL(NULLIF(@StateCodeBTS, ''), [StateCodeBTS])
				,[StateCodeISO3166] = ISNULL(NULLIF(@StateCodeISO3166, ''), [StateCodeISO3166])
				,[SendLicense] = @SendLicense
			WHERE IdState = @IdState
			AND IdCountry = @IdCountry
		END
		IF (@IdCountry = @IdCountryUSA)
		BEGIN
			IF EXISTS (SELECT
						1
					FROM [dbo].[StateNote] WITH (NOLOCK)
					WHERE IdState = @IdState)
			BEGIN
				UPDATE [dbo].[StateNote]
				SET [ComplaintNoticeEnglish] = ISNULL(NULLIF(@ComplaintNoticeEnglish, ''), [ComplaintNoticeEnglish])
					,[ComplaintNoticeSpanish] = ISNULL(NULLIF(@ComplaintNoticeSpanish, ''), [ComplaintNoticeSpanish])
					,[AffiliationNoticeEnglish] = ISNULL(NULLIF(@AffiliationNoticeEnglish, ''), [AffiliationNoticeEnglish])
					,[AffiliationNoticeSpanish] = ISNULL(NULLIF(@AffiliationNoticeSpanish, ''), [AffiliationNoticeSpanish])
				WHERE [IdState] = @IdState
			END
			ELSE
			BEGIN
				INSERT INTO [dbo].[StateNote] ([IdState], [ComplaintNoticeEnglish], [ComplaintNoticeSpanish], [AffiliationNoticeEnglish], [AffiliationNoticeSpanish])
					VALUES (@IdState, @ComplaintNoticeEnglish, @ComplaintNoticeSpanish, @AffiliationNoticeEnglish, @AffiliationNoticeSpanish)
			END
		END
	END TRY
	BEGIN CATCH
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage)
			VALUES ('Corp.st_SaveState', GETDATE(), CONCAT(ERROR_MESSAGE(), ' on line: ', ERROR_LINE()))
	END CATCH
END
