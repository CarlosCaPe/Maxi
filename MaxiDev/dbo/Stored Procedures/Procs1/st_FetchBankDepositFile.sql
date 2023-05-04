CREATE PROCEDURE st_FetchBankDepositFile
(
	@StartDate					DATE,
	@EndingDate					DATE,
	@FileName					VARCHAR(200),
	@Processed					BIT
)
AS
BEGIN
	SELECT 
		b.*
	FROM BankDepositFile b WITH(NOLOCK)
	WHERE
		CONVERT(DATE, b.CreationDate) BETWEEN @StartDate AND @EndingDate
		AND (ISNULL(@FileName, '') = '' OR b.FileName LIKE CONCAT('%', @FileName ,'%'))
		AND (@Processed IS NULL OR b.Processed = @Processed)

END
