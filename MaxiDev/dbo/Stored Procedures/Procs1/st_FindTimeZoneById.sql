
CREATE PROCEDURE [dbo].[st_FindTimeZoneById]
    @IdTimeZone int
AS
BEGIN

	SELECT
		tm.IdTimeZone,
		tm.TimeZone [Name],
		tm.HoursForLocalTime
	FROM TimeZone tm WITH(NOLOCK)
	WHERE tm.IdTimeZone = @IdTimeZone 

END
