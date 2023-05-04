CREATE PROCEDURE [Corp].[st_SaveBanchGatewayCode]
(
	@IsUpdate bit,
	@IdGateway int,
	@IdBranch int,
	@GatewayBranchCode nvarchar(max),
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
		IF (@IsUpdate = 0)
			BEGIN
				INSERT INTO [dbo].[GatewayBranch] ([IdGateway], [IdBranch], [GatewayBranchCode], [DateOfLastChange], [EnterByIdUser])
				VALUES (@IdGateway, @IdBranch, @GatewayBranchCode, GETDATE(), @EnterByIdUser)
			END
		ELSE
			BEGIN
				UPDATE [dbo].[GatewayBranch]
				SET [IdGateway] = @IdGateway, 
					[IdBranch] = @IdBranch, 
					[GatewayBranchCode] = @GatewayBranchCode, 
					[DateOfLastChange] = GETDATE(), 
					[EnterByIdUser] = @EnterByIdUser
				WHERE IdBranch = @IdBranch and IdGateway = @IdGateway
			END
	END TRY
	BEGIN CATCH 
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
	END CATCH
END
