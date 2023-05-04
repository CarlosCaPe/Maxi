CREATE PROCEDURE st_GeneateClaimCode
(
	@PayerCode				VARCHAR(200),
	@TimeOut				VARCHAR(50) = NULL
)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE
			@payer_name nvarchar(100),
			@payer_prefix nvarchar(100),
			@payer_random_characters int,
			@payer_acceptable_characters nvarchar(100),
			@payer_fixed_length bit,
			@payer_length_no tinyint,
			@payer_filler char,
			@payer_include_prefix bit,
			@payer_fixed_range bit,
			@payer_min_range bigint,
			@payer_max_range bigint,
			@payer_current_number bigint
		
		SELECT
			@payer_name = payer_name,
			@payer_prefix = payer_prefix,
			@payer_random_characters = payer_random_characters,
			@payer_acceptable_characters = payer_acceptable_characters,
			@payer_fixed_length = payer_fixed_length,
			@payer_length_no = payer_length_no,
			@payer_filler = payer_filler,
			@payer_include_prefix = payer_include_prefix,
			@payer_fixed_range = payer_fixed_range,
			@payer_min_range = payer_min_range,
			@payer_max_range = payer_max_range,
			@payer_current_number = payer_current_number
		FROM ClaimCodePayers c WITH(XLOCK, ROWLOCK) 
		WHERE c.payer_name = @PayerCode

		
		SET @payer_current_number = @payer_current_number + 1

		UPDATE ClaimCodePayers WITH(XLOCK, ROWLOCK) SET 
			payer_current_number = @payer_current_number  
		WHERE payer_name = @PayerCode

		SELECT CONCAT(@payer_prefix, @payer_current_number)

		IF @TimeOut IS NOT NULL
			WAITFOR DELAY @TimeOut
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @MSG_ERROR NVARCHAR(500)
		IF(ISNULL(@MSG_ERROR, '') = '')
			SET @MSG_ERROR = ERROR_MESSAGE();

		RAISERROR(@MSG_ERROR, 16, 1);
	END CATCH
END