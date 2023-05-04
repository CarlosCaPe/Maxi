CREATE PROCEDURE st_NSGetProcessJob
AS
BEGIN
	SELECT
		nj.IdProcessJob,
		nj.IdProcessType,
		nj.IdJob,
		nj.CreationDate,
		nj.Status,
		nj.Response,
		nj.LastUpdate
	FROM NSProcessJob nj WITH(NOLOCK)
	WHERE ISNULL(nj.Status, '') NOT IN ('FINISHEDWITHERRORS', 'FINISHED')
	ORDER BY nj.CreationDate
END
IF OBJECT_ID('st_GetNSProcessJob') IS NOT NULL
	DROP PROCEDURE st_GetNSProcessJob
