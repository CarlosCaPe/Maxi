CREATE PROCEDURE [Corp].[st_SavePayer]
(
	@IdPayer int,
	@PayerName nvarchar(max),
	@PayerCode nvarchar(max),
	@Folio int,
	@IdGenericStatus int,
	@EnterByIdUser int,
	@PayerLogo nvarchar(max) = NULL,
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
		IF (@IdPayer = 0)
			BEGIN
				INSERT INTO [dbo].[Payer] ([PayerName], [PayerCode], [Folio], [IdGenericStatus], [DateOfLastChange], [EnterByIdUser], [PayerLogo])
				VALUES (@PayerName, @PayerCode, @Folio, @IdGenericStatus, GETDATE(), @EnterByIdUser, @PayerLogo)
			END
		ELSE
			BEGIN
				UPDATE [dbo].[Payer]
				SET [PayerName] = @PayerName, 
					[PayerCode] = @PayerCode,
					[Folio] = @Folio, 
					[IdGenericStatus] = @IdGenericStatus, 
					[DateOfLastChange] = GETDATE(), 
					[EnterByIdUser] = @EnterByIdUser, 
					[PayerLogo] = @PayerLogo
				WHERE IdPayer = @IdPayer
			END
	END TRY
	BEGIN CATCH 
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
	END CATCH
END
