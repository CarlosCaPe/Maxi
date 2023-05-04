CREATE PROCEDURE [dbo].[st_SaveBranch]
(
	@IdBranch int,
	@IdBranchOut int out,
	@IdPayer int,
	@BranchName nvarchar(max),
	@IdCity int,
	@Address nvarchar(max),
	@zipcode nvarchar(max),
	@Phone nvarchar(max),
	@Fax nvarchar(max),
	@IdGenericStatus int,
	@EnterByIdUser int,
	@code nvarchar(max) = NULL,
	@Schedule nvarchar(max) = NULL,
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
		IF (@IdBranch = 0)
			BEGIN
				INSERT INTO [dbo].[Branch] ([IdPayer], [BranchName], [IdCity], [Address], [zipcode], [Phone], [Fax], [IdGenericStatus], [DateOfLastChange], [EnterByIdUser], [code], [Schedule])
				VALUES (@IdPayer, @BranchName, @IdCity, @Address, @zipcode, @Phone, @Fax, @IdGenericStatus, GETDATE(), @EnterByIdUser, @code, @Schedule);
				set @IdBranchOut = SCOPE_IDENTITY();
			END
		ELSE
			BEGIN
				UPDATE [dbo].[Branch]
				SET [IdPayer] = @IdPayer, 
					[BranchName] = @BranchName, 
					[IdCity] = @IdCity, 
					[Address] = @Address, 
					[zipcode] = @zipcode, 
					[Phone] = @Phone, 
					[Fax] = @Fax, 
					[IdGenericStatus] = @IdGenericStatus, 
					[DateOfLastChange] = GETDATE(),
					[EnterByIdUser] = @EnterByIdUser, 
					[code] = @code, 
					[Schedule] = @Schedule
				WHERE IdBranch = @IdBranch;
				SELECT @IdBranchOut = IdBranch FROM Branch with(nolock) WHERE IdBranch = @IdBranch;
			END
	END TRY
	BEGIN CATCH 
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
	END CATCH
END
