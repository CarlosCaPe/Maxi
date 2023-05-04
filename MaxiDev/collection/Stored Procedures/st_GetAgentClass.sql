
-- =============================================
-- Author:		Nevarez, Sergio
-- Create date: 2017-Mayr-08
-- Description:	This stored gets agent class
-- =============================================
CREATE PROCEDURE [Collection].[st_GetAgentClass] 
	-- Add the parameters for the stored procedure here
	@SpecialCategory BIT = NULL
AS
Begin Try

	DECLARE @HasError INT = 0;
	DECLARE @Message VARCHAR(MAX)='';

	SET NOCOUNT ON;

	Declare @AgentClass Table
	(
		[Id] INT IDENTITY(1,1) NOT NULL,
		[IdAgentClass] INT, 
		[Name] [nvarchar](100), 
		[Description] [nvarchar](100)
	);

	INSERT INTO @AgentClass
	SELECT 
		[IdAgentClass] AS [IdAgentClass], 
		[Name] AS [Name], 
		[Description] AS [Description]
	FROM [dbo].[AgentClass] WITH(NOLOCK)
		ORDER BY Name;

/*
	IF(ISNULL(@SpecialCategory,0)= 1)
	BEGIN
		INSERT INTO @AgentClass ([IdAgentClass],[Name],[Description]) VALUES (0,'Special Category','Special Category');
	END
	*/
	
	SELECT 
		[IdAgentClass] AS [IdAgentClass], 
		[Name] AS [Name], 
		[Description] AS [Description]
	FROM @AgentClass
		ORDER BY [Id] ASC;

End Try
Begin Catch
	Set @HasError = 1;
	Declare @ErrorMessage nvarchar(max);
	Select @ErrorMessage = ERROR_MESSAGE();
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Collection.st_GetAgentClass',Getdate(),@ErrorMessage);
End Catch