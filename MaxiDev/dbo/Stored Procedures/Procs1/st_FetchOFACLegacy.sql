CREATE PROCEDURE st_FetchOFACLegacy (
        @Name nvarchar(max),
        @FirstLastName nvarchar(max),
        @SecondLastName nvarchar(max)
) AS 
BEGIN 
	DECLARE @PercentOfac			FLOAT,
            @PercentOfacMatchBit	FLOAT,
			@CustomerPercentMatch	FLOAT,
			@IsCustomerFullMatch	BIT
			
	SELECT 
        @PercentOfac= dbo.GetGlobalAttributeByName('MinOfacMatch'),
		@PercentOfacMatchBit= dbo.GetGlobalAttributeByName('PercentOfacMatchBit')

	DECLARE @CustomerPercentDataMatch table
	(
		name nvarchar(max),
		percentMatch float,
		IsCustomerFullMatch bit not null default 0
	)

	DECLARE @CustomerDataMatch TABLE (
        SDN_NAME nvarchar(max),
        SDN_REMARKS nvarchar(max),
        ALT_TYPE nvarchar(max),
        ALT_NAME nvarchar(max),
        ALT_REMARKS nvarchar(max),
        ADD_ADDRESS nvarchar(max),
        ADD_CITY_NAME nvarchar(max),
        ADD_COUNTRY nvarchar(max),
        ADD_REMARKS nvarchar(max),
        FULL_Match bit NOT NULL DEFAULT 0,
        Percent_Match NUMERIC(9, 2) NOT NULL DEFAULT 0
    )

	INSERT INTO @CustomerPercentDataMatch (name,percentMatch)
	EXEC st_OfacSearchDetailsLetterPairsByNameClr @Name ,@FirstLastName, @SecondLastName

	
	DELETE FROM @CustomerPercentDataMatch where percentMatch<@PercentOfac

	UPDATE @CustomerPercentDataMatch SET 
		IsCustomerFullMatch = CASE WHEN percentMatch >= @PercentOfacMatchBit THEN 1 ELSE 0 END

	SELECT TOP 1 
		@CustomerPercentMatch = percentMatch,
		@IsCustomerFullMatch = IsCustomerFullMatch 
	FROM @CustomerPercentDataMatch 
	ORDER BY percentMatch DESC

	IF @CustomerPercentMatch>=@PercentOfac
	BEGIN 
		INSERT INTO @CustomerDataMatch (SDN_NAME,SDN_REMARKS,ALT_TYPE,ALT_NAME,ALT_REMARKS,ADD_ADDRESS,ADD_CITY_NAME,ADD_COUNTRY,ADD_REMARKS)
		EXEC st_OfacSearchDetailsLetterPairsClr @Name, @FirstLastName, @SecondLastName 
	
		IF NOT EXISTS(SELECT top 1 1 FROM @CustomerDataMatch WHERE alt_name = '') 
			INSERT INTO @CustomerDataMatch (SDN_NAME, SDN_REMARKS, ALT_TYPE, ALT_NAME, ALT_REMARKS, ADD_ADDRESS, ADD_CITY_NAME, ADD_COUNTRY, ADD_REMARKS, FULL_Match, Percent_Match)
			SELECT TOP 1 SDN_NAME, SDN_REMARKS, 'a.k.a.', SDN_NAME, '-0- ', '', '', '', '', 0, 0 FROM @CustomerDataMatch
		ELSE
			UPDATE @CustomerDataMatch SET alt_name = SDN_NAME 
			WHERE alt_name = ''

		UPDATE @CustomerDataMatch SET 
			Full_Match = t.IsCustomerFullMatch,
			Percent_Match = t.percentMatch
		FROM (SELECT * FROM @CustomerPercentDataMatch) t WHERE alt_name=t.name
	END


	SELECT * FROM @CustomerDataMatch
END
