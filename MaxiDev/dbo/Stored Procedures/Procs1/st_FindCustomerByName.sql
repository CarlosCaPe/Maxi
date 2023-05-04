-- Author:		Francisco Lara
-- Create date: 2016-01-04
-- Description:	This store is used in coporate, reports, Customer/Beneficiary History
CREATE PROCEDURE [dbo].[st_FindCustomerByName]
	-- Add the parameters for the stored procedure here
    @Name NVARCHAR(MAX),
    @FirstLastName NVARCHAR(MAX),
    @SecondLastName NVARCHAR(MAX),
    @IdLenguage INT,
    @HasError BIT OUTPUT,
    @Message NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET TRANSACTION ISOLATION  LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;  
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @Tot INT

	IF @IdLenguage IS NULL
		SET @IdLenguage = 2
	SET @HasError = 0
	SET @Message = 'Ok'

	CREATE TABLE #result(
		 [IdCustomer] INT,
		 [Name] NVARCHAR(MAX),
		 [FirstLastName] NVARCHAR(MAX),
		 [SecondLastName] NVARCHAR(MAX),
		 [Address] NVARCHAR(MAX),
		 [City] NVARCHAR(MAX),
		 [State] NVARCHAR(MAX),
		 [ZipCode] NVARCHAR(MAX),
		 [PhoneNumber] NVARCHAR(MAX),
		 [AgentCode] NVARCHAR(MAX))


	INSERT INTO #result
		SELECT [IdCustomer], [Name], [FirstLastName], [SecondLastName], [Address], [City], [State], [ZipCode], [PhoneNumber], [dbo].[fn_GetLastAgentCode] ([IdCustomer], 1, 0) [AgentCode]
		--SELECT [IdCustomer], [Name], [FirstLastName], [SecondLastName], [Address], [City], [State], [ZipCode], [PhoneNumber], [dbo].[fn_GetLastAgentCode_2] ([IdCustomer], 1, 0) [AgentCode]
		FROM [dbo].[Customer] WITH (NOLOCK)  
		WHERE [Name] LIKE '%'+@Name+'%' AND [FirstLastName] LIKE '%'+@FirstLastName+'%' AND [SecondLastName] LIKE '%'+ @SecondLastName+'%'

	SELECT @Tot = COUNT(1)
	FROM #result

	IF @Tot > 3000
	BEGIN
		SET @HasError = 1
		SET @Message = [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHERROR')         
	END
	ELSE IF @Tot = 0
		BEGIN
			SET @HasError = 1
			SET @Message = REPLACE(REPLACE([dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHNOFOUND'),'Transfers','Match'),'transferencias','coincidencias')
		END
	ELSE
		SELECT
			[IdCustomer]
			, [Name]
			, [FirstLastName]
			, [SecondLastName]
			, [Address]
			, [City]
			, [State]
			, [ZipCode]
			, [PhoneNumber]
			, [AgentCode]
		FROM #result
		WHERE [AgentCode] IS NOT NULL
		ORDER BY [State] ASC
	
END