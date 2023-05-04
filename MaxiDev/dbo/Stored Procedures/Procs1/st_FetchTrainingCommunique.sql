CREATE PROCEDURE st_FetchTrainingCommunique
(
	@StartDate					DATETIME,
	@EndingDate					DATETIME,
	@FilterDate					VARCHAR(20),	-- StartDate, EndingDate, CreationDate
	@Title						VARCHAR(200),
	@Description				VARCHAR(200),
	@IdStatus					INT,
	@Active						BIT				-- NULL => All, 0 => Inactive, 1 => Active
)
AS
BEGIN
	DECLARE @SearchByDate BIT = IIF(
		@StartDate IS NOT NULL AND @EndingDate IS NOT NULL AND @FilterDate IN ('StartDate', 'EndingDate', 'CreationDate'), 
		1, 
		0
	)

	SELECT
		tc.*,
		u.UserName
	FROM TrainingCommunique tc WITH(NOLOCK)
		JOIN Users u WITH(NOLOCK) ON tc.IdUser = u.IdUser
	WHERE
		(
			@SearchByDate = 0 
			OR 
			(
				(@FilterDate = 'CreationDate' AND tc.CreationDate BETWEEN @StartDate AND @EndingDate)
				OR (@FilterDate = 'StartDate' AND tc.StartDate BETWEEN @StartDate AND @EndingDate)
				OR (@FilterDate = 'EndingDate' AND tc.EndingDate BETWEEN @StartDate AND @EndingDate)
			)
		)
		AND (@Title IS NULL OR tc.Title LIKE CONCAT('%', @Title, '%'))
		AND (@Description IS NULL OR tc.Description LIKE CONCAT('%', @Description, '%'))
		AND (@IdStatus IS NULL OR tc.IdStatus = @IdStatus)
		AND (@Active IS NULL OR tc.Active = @Active)
END
