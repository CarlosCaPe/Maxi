CREATE PROCEDURE [Corp].[st_FindBeneficiaryByName]
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
<log Date="2023/03/02" Author="jdarellano">Performance: Se mejora método de búsqueda.</log>
</ChangeLog>
*********************************************************************/
BEGIN
	SET TRANSACTION ISOLATION  LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;  
	SET NOCOUNT ON;

	DECLARE @Tot INT;

	IF @IdLenguage IS NULL
		SET @IdLenguage = 2;

	SET @HasError = 0;
	SET @Message = 'Ok';

	DECLARE @nameT nvarchar(40),
		@firstLastNameT nvarchar(40),
		@secondLastNameT nvarchar(40)
		   		
	SET @nameT = '"'+LTRIM(RTRIM(@name))+'*"';
	SET @firstLastNameT = '"'+LTRIM(RTRIM(@firstLastName))+'*"';
	SET @secondLastNameT = '"'+LTRIM(RTRIM(ISNULL(@secondLastName,'')))+'*"';
		
	CREATE TABLE #beneficiaryPivot (idBeneficiary INT);

	INSERT INTO #beneficiaryPivot
	SELECT [IdBeneficiary]
	FROM [dbo].[Beneficiary] WITH (NOLOCK)
	WHERE CONTAINS([Name],@nameT) AND CONTAINS(FirstLastName,@firstLastNameT) AND CONTAINS(SecondLastName,@secondLastNameT);
		
	CREATE UNIQUE CLUSTERED INDEX TMP_PKBeneficiary ON #beneficiaryPivot (IdBeneficiary);

	SELECT @Tot = COUNT(1) FROM #beneficiaryPivot;

	IF @Tot > 3000
	BEGIN
		SET @HasError = 1;
		SET @Message = [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHERROR');
	END
	ELSE IF @Tot=0
	BEGIN
		SET @HasError = 1;
		SET @Message = REPLACE(REPLACE([dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHNOFOUND'),'Transfers','Match'),'transferencias','coincidencias');
	END
	ELSE
		SELECT 
			b.[IdBeneficiary], 
			[Name], 
			[FirstLastName], 
			[SecondLastName], 
			[Address], 
			[City], 
			[State], 
			[ZipCode], 
			[PhoneNumber],
			[dbo].[fn_GetLastAgentCode] (b.[IdBeneficiary], 0, 0) [AgentCode]
		FROM [dbo].[Beneficiary] AS b WITH (NOLOCK)
		WHERE EXISTS (SELECT 1 FROM #beneficiaryPivot AS bp WHERE b.IdBeneficiary = bp.IdBeneficiary)
		AND [dbo].[fn_GetLastAgentCode] (b.[IdBeneficiary], 0, 0) IS NOT NULL
		ORDER BY [State] ASC;
END
