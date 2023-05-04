CREATE PROCEDURE [dbo].[st_SaveCity]
(
	@IdCity INT,
	@IdState int,
	@CityName nvarchar(max),
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
		IF (@IdCity = 0)
			BEGIN
				INSERT INTO [dbo].[City] ([IdState], [CityName], [DateOfLastChange], [EnterByIdUser])
				VALUES (@IdState, @CityName, GETDATE(), @EnterByIdUser)
			END
		ELSE
			BEGIN
				UPDATE [dbo].[City]
				SET [IdState] = @IdState, 
					[CityName] = @CityName, 
					[DateOfLastChange] = GETDATE(),
					[EnterByIdUser] = @EnterByIdUser
				WHERE IdCity = @IdCity AND IdState = @IdState
			END
	END TRY
	BEGIN CATCH 
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
	END CATCH
END
