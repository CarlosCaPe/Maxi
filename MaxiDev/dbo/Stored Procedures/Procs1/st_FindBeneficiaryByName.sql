CREATE PROCEDURE [dbo].[st_FindBeneficiaryByName]
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
		 [IdBeneficiary] INT,
		 [Name] NVARCHAR(MAX),
		 [FirstLastName] NVARCHAR(MAX),
		 [SecondLastName] NVARCHAR(MAX),
		 [Address] NVARCHAR(MAX),
		 [City] NVARCHAR(MAX),
		 [State] NVARCHAR(MAX),
		 [ZipCode] NVARCHAR(MAX),
		 [PhoneNumber] NVARCHAR(MAX),
		 [AgentCode] NVARCHAR(MAX))

		declare @nameT nvarchar(40),
				@firstLastNameT nvarchar(40),
		   		@secondLastNameT nvarchar(40)
		   		
		set @nameT = '"'+LTRIM(RTRIM(ISNULL(@name,'')))+'*"'
		set @firstLastNameT = '"'+LTRIM(RTRIM(ISNULL(@firstLastName,'')))+'*"'
		set @secondLastNameT = '"'+LTRIM(RTRIM(ISNULL(@secondLastName,'')))+'*"'
		
	
		CREATE TABLE #beneficiaryPivot (idBeneficiary INT)
		
		DECLARE @SQL VARCHAR(max)
		
		SET  @SQL='INSERT INTO #beneficiaryPivot SELECT [IdBeneficiary] '
		SET @SQL= @SQL +'	FROM [dbo].[Beneficiary] [C] WITH (NOLOCK)'
		SET @SQL=@SQL +'		WHERE 1 = 1'
		IF @name !=''
		SET @SQL=@SQL +'	    AND CONTAINS([C].[Name],'''+@nameT+''') '
		IF @firstLastName != ''
		SET @SQL=@SQL +'		AND CONTAINS([C].[FirstLastName] ,'''+@firstLastNameT+''')'
		IF @secondLastName !=''
		SET @SQL=@SQL +'		AND CONTAINS([C].[SecondLastName],'''+@secondLastNameT+''')'
		SET @SQL = @SQL+ ' OPTION (RECOMPILE)'

		EXEC(@SQL)
		
		
		CREATE UNIQUE CLUSTERED INDEX TMP_PKBeneficiary ON #beneficiaryPivot (IdBeneficiary)

	SELECT @Tot = COUNT(1)
	FROM #beneficiaryPivot

	IF @Tot > 3000
	BEGIN
		SET @HasError = 1
		SET @Message = [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHERROR')
	END
	ELSE IF @Tot=0
		BEGIN
			SET @HasError=1
			SET @Message=REPLACE(REPLACE([dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHNOFOUND'),'Transfers','Match'),'transferencias','coincidencias')
	END
	ELSE
	
	
		INSERT INTO #result
		SELECT b.[IdBeneficiary], 
		[Name], [FirstLastName], 
		[SecondLastName], [Address], 
		[City], 
		[State], 
		[ZipCode], 
		[PhoneNumber] 
	 	,[dbo].[fn_GetLastAgentCode] (b.[IdBeneficiary], 0, 0) [AgentCode]
		FROM [dbo].[Beneficiary] b WITH (NOLOCK)
	    JOIN #beneficiaryPivot bp 
	    ON bp.IdBeneficiary = b.IdBeneficiary
	    
	    
		SELECT
			[IdBeneficiary]
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






