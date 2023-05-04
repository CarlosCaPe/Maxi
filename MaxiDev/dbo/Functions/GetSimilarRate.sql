CREATE FUNCTION GetSimilarRate
(
	@InputA VARCHAR(100),
	@InputB VARCHAR(100)
)
RETURNS INT
AS
BEGIN
	DECLARE @Count	INT,
			@Limit	INT,
			@Result INT



	SELECT	@Count = 1,
			@Limit = LEN(@InputA),
			@Result = 0

	IF ISNULL(@Limit, 0) = 0
		SET @Limit = 1

	WHILE @Count <= @Limit
	BEGIN
		IF SUBSTRING(@InputA, @Count, 1) = SUBSTRING(@InputB, @Count, 1)
			SET @Result = @Result + 1

		--IF SUBSTRING(@InputA, LEN(@InputA) - (@Count - 1), 1) = SUBSTRING(@InputB, LEN(@InputB) - (@Count - 1), 1)
		--	SET @Result = @Result + 1

		SET @Count = @Count + 1
	END

	SET @Result = (CAST(@Result AS FLOAT) / CAST(@Limit AS FLOAT)) * 100

	IF @Result > 100
		SET @Result = 100

	RETURN @Result
END