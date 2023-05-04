CREATE PROCEDURE [dbo].[st_SaveCountry]
(
	@IdCountry INT,
    @CountryName nvarchar(max),
    @CountryCode nvarchar(max),
    @EnterByIdUser int,
    @CountryFlag nvarchar(max) = NULL,
    @CountryCodeISO3166 nvarchar(2) = NULL,
    @HasError int out,
    @Message nvarchar(max) out
)
AS
SET NOCOUNT ON;
BEGIN 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET @HasError = 0
	SET @Message = ''
	BEGIN TRY
		IF (@IdCountry = 0)
			BEGIN
				INSERT INTO [dbo].[Country] ([CountryName], [CountryCode], [DateOfLastChange], [EnterByIdUser], [CountryFlag], [CountryCodeISO3166])
				VALUES (@CountryName, @CountryCode, GETDATE(), @EnterByIdUser, @CountryFlag, @CountryCodeISO3166)
			END
		ELSE
			BEGIN
				UPDATE [dbo].[Country]
				SET [CountryName] = @CountryName,
					[CountryCode] = @CountryCode,
					[DateOfLastChange] = GETDATE(),
					[EnterByIdUser] = @EnterByIdUser,
					[CountryFlag] = ISNULL(NULLIF(@CountryFlag,''),[CountryFlag]),
					[CountryCodeISO3166] = ISNULL(NULLIF(@CountryCodeISO3166,''),[CountryCodeISO3166])
				WHERE IdCountry = @IdCountry
			END
	END TRY
	BEGIN CATCH 
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveCountry',Getdate(), CONCAT(ERROR_MESSAGE(),' on line: ', ERROR_LINE()) )   
	END CATCH
END
