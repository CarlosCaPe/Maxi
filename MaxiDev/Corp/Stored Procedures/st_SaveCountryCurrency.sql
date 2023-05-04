CREATE PROCEDURE [Corp].[st_SaveCountryCurrency]
(
	@IdCountryCurrency INT = 0,
	@IdCountry int,
	@IdCurrency int,
	@EnterByIdUser int,
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
		INSERT INTO [dbo].[CountryCurrency] ([IdCountry], [IdCurrency], [DateOfLastChange], [EnterByIdUser])
		VALUES (@IdCountry, @IdCurrency, GETDATE(), @EnterByIdUser)
	END TRY
	BEGIN CATCH 
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
	END CATCH
END

