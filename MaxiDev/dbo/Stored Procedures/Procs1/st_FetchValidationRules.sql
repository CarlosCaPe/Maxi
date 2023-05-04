CREATE PROCEDURE st_FetchValidationRules
(
	@IdEntityToValidate		INT,
	@IdValidator			INT,
	@IdPayerConfig			INT
)
AS
BEGIN

	SELECT
		vr.*,
		v.ValidatorName RuleName
	INTO #CurrentRules
	FROM ValidationRules vr WITH(NOLOCK)
		JOIN Validator v WITH(NOLOCK) ON v.IdValidator = vr.IdValidator
	WHERE vr.IdEntityToValidate = @IdEntityToValidate
		AND vr.IdValidator = @IdValidator
		AND vr.Field <> 'Occupation' -- Deprecated Field
		AND (vr.IdPayerConfig = @IdPayerConfig OR vr.IdPayerConfig IS NULL)
		AND vr.IdGenericStatus = 1

	IF @IdValidator = 1 -- LengthRule
		SELECT cr.*, lr.Minimum, lr.Maximo Maximum
		FROM #CurrentRules cr
			JOIN LengthRule lr ON lr.IdValidationRule = cr.IdValidationRule
	ELSE IF @IdValidator = 2 -- RangeRule
		SELECT cr.*, rr.FromValue, rr.ToValue, rr.Type
		FROM #CurrentRules cr
			JOIN RangeRule rr ON rr.IdValidationRule = cr.IdValidationRule
	ELSE IF @IdValidator = 3 -- RegularExpressionRule
		SELECT cr.*, re.Pattern
		FROM #CurrentRules cr
			JOIN RegularExpressionRule re ON re.IdValidationRule = cr.IdValidationRule
	ELSE IF @IdValidator = 5 -- SimpleComparison
		SELECT cr.*, sc.ComparisonValue, sc.Expression, sc.Type
		FROM #CurrentRules cr
			JOIN SimpleComparisonRule sc ON sc.IdValidationRule = cr.IdValidationRule
	ELSE --RequiredRule
		SELECT cr.*
		FROM #CurrentRules cr
END