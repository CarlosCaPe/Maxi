CREATE PROCEDURE [dbo].[st_GetTypeOrStatusOrUserData] 
	@table NVARCHAR(15),
	@id INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (@table = 'Type')
		BEGIN
			SELECT [IdOfacAuditType] AS ID, [Name]
			FROM [dbo].[OfacAuditType] WITH(NOLOCK)
			WHERE IdOfacAuditType = @id
		END
	
	IF (@table = 'Status')
		BEGIN 
			SELECT [IdOfacAuditStatus] AS ID, [Name]
			FROM [dbo].[OfacAuditStatus] WITH(NOLOCK)
			WHERE IdOfacAuditStatus = @id
		END 

	IF (@table = 'UserData')
		BEGIN
			SELECT [IdUser] AS ID, [UserName] AS [Name], [UserLogin], [UserPassword], [DateOfCreation], [CreatedByIdUser], [IdUserType], [ChangePasswordAtNextLogin], 
				[AllowToRegisterPc], [IdGenericStatus], [salt], [DateOfLastChange], [EnterByIdUser], [FirstName], [LastName], [SecondLastName]
			FROM [dbo].[Users] WITH(NOLOCK)
			WHERE IdUser = @id
		END 
END





