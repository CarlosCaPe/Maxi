CREATE PROCEDURE [dbo].[st_FetchFee]
(
	@Name	   	        VARCHAR(200),
	@Offset			    BIGINT,
	@Limit			    BIGINT
)
AS
BEGIN

	DECLARE @Records TABLE (Id INT, _PagedResult_Total BIGINT)

	INSERT INTO @Records(Id, _PagedResult_Total)
	SELECT
		cc.IdFee,
		COUNT(*) OVER() _PagedResult_Total
	FROM Fee cc WITH(NOLOCK)
	WHERE
		(@Name IS NULL OR cc.FeeName LIKE CONCAT('%', @Name ,'%'))
	ORDER BY IdFee
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY

	SELECT
		cc.IdFee, 
		cc.FeeName, 
		cc.DateOfLastChange, 
		cc.EnterByIdUser,
		r._PagedResult_Total
	FROM Fee cc WITH(NOLOCK)
		JOIN @Records r ON r.Id = cc.IdFee

	SELECT
		pc.IdFeeDetail,
		pc.IdFee,
		pc.FromAmount,
		pc.ToAmount,
		pc.Fee,
		pc.DateOfLastChange,
		pc.EnterByIdUser,
		pc.IsFeePercentage
	FROM FeeDetail pc WITH(NOLOCK)
		JOIN @Records r ON r.Id = pc.IdFee

END