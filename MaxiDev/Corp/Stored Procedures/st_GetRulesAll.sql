CREATE PROCEDURE [Corp].[st_GetRulesAll] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT CASE WHEN (( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) AND ( NOT (([Project3].[C1] = 1) AND ([Project3].[C1] IS NOT NULL))) AND ( NOT (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL))) AND ( NOT (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)))) THEN '0X' WHEN (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL)) THEN '0X0X' WHEN (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL)) THEN '0X1X' WHEN (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)) THEN '0X2X' ELSE '0X3X' END AS [C1], 
		VL.[IdValidationRule] AS [IdValidationRule], 
		VL.[IdEntityToValidate] AS [IdEntityToValidate], 
		VL.[IdValidator] AS [IdValidator], 
		VL.[IdPayerConfig] AS [IdPayerConfig], 
		VL.[Field] AS [Field], 
		VL.[ErrorMessageES] AS [ErrorMessageES], 
		VL.[ErrorMessageUS] AS [ErrorMessageUS], 
		VL.[OrderByEntityToValidate] AS [OrderByEntityToValidate], 
		VL.[IdGenericStatus] AS [IdGenericStatus], 
		VL.[IsAllowedToEdit] AS [IsAllowedToEdit], 
		CASE WHEN (( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) AND ( NOT (([Project3].[C1] = 1) AND ([Project3].[C1] IS NOT NULL))) AND ( NOT (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL))) AND ( NOT (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)))) THEN CAST(NULL AS int) WHEN (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL)) THEN [Project4].[Minimum] WHEN (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL)) THEN CAST(NULL AS int) WHEN (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)) THEN CAST(NULL AS int) END AS [C2], 
		CASE WHEN (( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) AND ( NOT (([Project3].[C1] = 1) AND ([Project3].[C1] IS NOT NULL))) AND ( NOT (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL))) AND ( NOT (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)))) THEN CAST(NULL AS int) WHEN (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL)) THEN [Project4].[Maximo] WHEN (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL)) THEN CAST(NULL AS int) WHEN (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)) THEN CAST(NULL AS int) END AS [C3], 
		CASE WHEN (( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) AND ( NOT (([Project3].[C1] = 1) AND ([Project3].[C1] IS NOT NULL))) AND ( NOT (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL))) AND ( NOT (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)))) THEN CAST(NULL AS varchar(1)) WHEN (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) WHEN (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL)) THEN [Project1].[FromValue] WHEN (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) END AS [C4], 
		CASE WHEN (( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) AND ( NOT (([Project3].[C1] = 1) AND ([Project3].[C1] IS NOT NULL))) AND ( NOT (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL))) AND ( NOT (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)))) THEN CAST(NULL AS varchar(1)) WHEN (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) WHEN (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL)) THEN [Project1].[ToValue] WHEN (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) END AS [C5], 
		CASE WHEN (( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) AND ( NOT (([Project3].[C1] = 1) AND ([Project3].[C1] IS NOT NULL))) AND ( NOT (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL))) AND ( NOT (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)))) THEN CAST(NULL AS varchar(1)) WHEN (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) WHEN (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL)) THEN [Project1].[Type] WHEN (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) END AS [C6], 
		CASE WHEN (( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) AND ( NOT (([Project3].[C1] = 1) AND ([Project3].[C1] IS NOT NULL))) AND ( NOT (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL))) AND ( NOT (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)))) THEN CAST(NULL AS varchar(1)) WHEN (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) WHEN (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) WHEN (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)) THEN [Project2].[Pattern] END AS [C7], 
		CASE WHEN (( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) AND ( NOT (([Project3].[C1] = 1) AND ([Project3].[C1] IS NOT NULL))) AND ( NOT (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL))) AND ( NOT (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)))) THEN CAST(NULL AS varchar(1)) WHEN (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) WHEN (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) WHEN (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) ELSE [Project3].[ComparisonValue] END AS [C8], 
		CASE WHEN (( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) AND ( NOT (([Project3].[C1] = 1) AND ([Project3].[C1] IS NOT NULL))) AND ( NOT (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL))) AND ( NOT (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)))) THEN CAST(NULL AS varchar(1)) WHEN (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) WHEN (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) WHEN (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) ELSE [Project3].[Type] END AS [C9], 
		CASE WHEN (( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) AND ( NOT (([Project3].[C1] = 1) AND ([Project3].[C1] IS NOT NULL))) AND ( NOT (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL))) AND ( NOT (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)))) THEN CAST(NULL AS varchar(1)) WHEN (([Project4].[C1] = 1) AND ([Project4].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) WHEN (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) WHEN (([Project2].[C1] = 1) AND ([Project2].[C1] IS NOT NULL)) THEN CAST(NULL AS varchar(1)) ELSE [Project3].[Expression] END AS [C10]
    FROM [dbo].[ValidationRules] AS VL WITH(NOLOCK)
    LEFT OUTER JOIN  (SELECT 
        RR.[IdValidationRule] AS [IdValidationRule], 
        RR.[FromValue] AS [FromValue], 
        RR.[ToValue] AS [ToValue], 
        RR.[Type] AS [Type], 
        cast(1 as bit) AS [C1]
        FROM [dbo].[RangeRule] AS RR WITH(NOLOCK) ) AS [Project1] ON VL.[IdValidationRule] = [Project1].[IdValidationRule]
    LEFT OUTER JOIN  (SELECT 
        RE.[IdValidationRule] AS [IdValidationRule], 
        RE.[Pattern] AS [Pattern], 
        cast(1 as bit) AS [C1]
        FROM [dbo].[RegularExpressionRule] AS RE WITH(NOLOCK) ) AS [Project2] ON VL.[IdValidationRule] = [Project2].[IdValidationRule]
    LEFT OUTER JOIN  (SELECT 
        SCR.[IdValidationRule] AS [IdValidationRule], 
        SCR.[ComparisonValue] AS [ComparisonValue], 
        SCR.[Type] AS [Type], 
        SCR.[Expression] AS [Expression], 
        cast(1 as bit) AS [C1]
        FROM [dbo].[SimpleComparisonRule] AS SCR WITH(NOLOCK) ) AS [Project3] ON VL.[IdValidationRule] = [Project3].[IdValidationRule]
    LEFT OUTER JOIN  (SELECT 
        LR.[IdValidationRule] AS [IdValidationRule], 
        LR.[Minimum] AS [Minimum], 
        LR.[Maximo] AS [Maximo], 
        cast(1 as bit) AS [C1]
        FROM [dbo].[LengthRule] AS LR WITH(NOLOCK) ) AS [Project4] ON VL.[IdValidationRule] = [Project4].[IdValidationRule]		

END


