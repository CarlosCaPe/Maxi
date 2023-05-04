CREATE PROCEDURE [dbo].[st_AMLPGetHistoryReport]
(
	@IdEntity		INT,
	@TypeEntity		VARCHAR(50),
	@DateFrom		DATE,
	@DateTo			DATE
)
AS
BEGIN
	SELECT
		ghr.*
	FROM dbo.fnAMLPGetHistoryReport(@IdEntity, @TypeEntity, @DateFrom, @DateTo) ghr
END
