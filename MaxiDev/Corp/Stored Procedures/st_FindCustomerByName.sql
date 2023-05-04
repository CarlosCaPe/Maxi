CREATE PROCEDURE [Corp].[st_FindCustomerByName]
	-- Add the parameters for the stored procedure here
    @Name NVARCHAR(MAX),
    @FirstLastName NVARCHAR(MAX),
    @SecondLastName NVARCHAR(MAX),
    @IdLenguage INT,
    @HasError BIT OUTPUT,
    @Message NVARCHAR(MAX) OUTPUT
AS
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="2023/02/23" Author="jdarellano">Performance: Se mejora método de búsqueda.</log>
</ChangeLog>
*********************************************************************/
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;  
	SET NOCOUNT ON;

	DECLARE @Tot INT;

	IF @IdLenguage IS NULL
		SET @IdLenguage = 2;

	SET @HasError = 0;
	SET @Message = 'Ok';


	SELECT [IdCustomer]
	INTO #IdCust
	FROM [dbo].[Customer] WITH (NOLOCK)  
	WHERE [Name] LIKE CONCAT('%',@Name,'%') AND [FirstLastName] LIKE CONCAT('%',@FirstLastName,'%') AND [SecondLastName] LIKE CONCAT('%',@SecondLastName,'%');

	SELECT @Tot = COUNT(1) FROM #IdCust;

	IF @Tot > 3000
	BEGIN
		SET @HasError = 1;
		SET @Message = [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHERROR');
	END
	ELSE IF @Tot = 0
	BEGIN
		SET @HasError = 1;
		SET @Message = REPLACE(REPLACE([dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHNOFOUND'),'Transfers','Match'),'transferencias','coincidencias');
	END
	ELSE
	BEGIN
		SELECT [IdCustomer], [Name], [FirstLastName], [SecondLastName], [Address], [City], [State], [ZipCode], [PhoneNumber], [dbo].[fn_GetLastAgentCode] ([IdCustomer], 1, 0) [AgentCode]
		FROM [dbo].[Customer] AS C WITH (NOLOCK)  
		WHERE EXISTS (SELECT 1 FROM #IdCust AS I WHERE C.IdCustomer = I.IdCustomer)
		AND [dbo].[fn_GetLastAgentCode] ([IdCustomer], 1, 0) IS NOT NULL
		ORDER BY [State] ASC;
	END
END
