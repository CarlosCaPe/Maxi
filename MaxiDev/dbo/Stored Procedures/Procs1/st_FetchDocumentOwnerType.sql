CREATE PROCEDURE st_FetchDocumentOwnerType
(
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

	SELECT 
		COUNT(*) OVER() _PagedResult_Total,
		do.IdDocumentOwnerType Id,
		do.Name
	FROM DocumentOwnerType do
	ORDER BY do.IdDocumentOwnerType
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
