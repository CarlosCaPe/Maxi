CREATE PROCEDURE [dbo].[st_GetBranches] 
	@IdPayer INT,
	@IdBranch INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF (@IdPayer > 0)
		BEGIN
			SELECT [IdBranch], [IdPayer], [BranchName], [IdCity], [Address], [zipcode], [Phone], [Fax], [IdGenericStatus], [DateOfLastChange], [EnterByIdUser], [code], [Schedule]
			FROM [dbo].[Branch] WITH(NOLOCK)
			WHERE [IdPayer] = @IdPayer
		END
	ELSE IF (@IdBranch > 0)
		BEGIN 
			SELECT [IdBranch], [IdPayer], [BranchName], [IdCity], [Address], [zipcode], [Phone], [Fax], [IdGenericStatus], [DateOfLastChange], [EnterByIdUser], [code], [Schedule]
			FROM [dbo].[Branch] WITH(NOLOCK)
			WHERE [IdBranch] = @IdBranch
		END
END 

