CREATE PROCEDURE [dbo].[st_FetchTimeZone]
(
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

	SELECT
		COUNT(*) OVER() _PagedResult_Total,
		tm.IdTimeZone,
		tm.TimeZone [Name],
		tm.HoursForLocalTime
	FROM TimeZone tm WITH(NOLOCK)
	ORDER BY IdTimeZone
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
