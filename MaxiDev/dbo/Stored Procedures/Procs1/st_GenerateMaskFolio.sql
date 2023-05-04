CREATE PROCEDURE st_GenerateMaskFolio
(
	@Name	NVARCHAR(100)
)
AS
BEGIN
	DECLARE @MSG_ERROR		NVARCHAR(500),
			@Mask			NVARCHAR(200),
			@MaskResult		NVARCHAR(200),
			@IdMaskConfiguration	INT,
			@FolioLength		INT


	DECLARE @FolioSegmensts TABLE 
	(	
		Id			INT IDENTITY,
		Mask		VARCHAR(200),
		Value		VARCHAR(200),
		NextMask	VARCHAR(200),
		IsFolio		BIT DEFAULT(0)
	)

	SELECT
		@IdMaskConfiguration = mf.IdMaskConfiguration,
		@Mask = mf.MaskFormat,
		@FolioLength = mf.FolioLength
	FROM MaskConfiguration mf 
	WHERE mf.Name = @Name

	IF ISNULL(@Mask, '') = ''
	BEGIN
		SET @MSG_ERROR = CONCAT('The FolioKey ', @Name, ' not exists')
		RAISERROR(@MSG_ERROR, 16, 1);
		RETURN
	END


	DECLARE @FistIndex		INT,
			@LastIndex		INT,
			@CurrentMask	VARCHAR(100)

	DECLARE @I INT = 1

	WHILE LEN(@Mask) > 0
	BEGIN
		IF (@I > 20)
		BEGIN
			SET @MSG_ERROR = CONCAT('The mask ', @Name, ' is recursive cannot be generated')
			RAISERROR(@MSG_ERROR, 16, 1);
			RETURN
		END
		

		SELECT 
			@FistIndex = CHARINDEX('{', @Mask),
			@LastIndex = CHARINDEX('}', @Mask)


		IF @FistIndex > 0 OR @LastIndex > 0
		BEGIN
			IF @FistIndex <> 1
			BEGIN
				SET @CurrentMask = SUBSTRING(@Mask, 1, @FistIndex - 1)
				INSERT INTO @FolioSegmensts(Mask, NextMask) VALUES (@CurrentMask, @Mask)

				SET @CurrentMask = NULL
			END

			SET @CurrentMask = SUBSTRING(@Mask, @FistIndex, @LastIndex - @FistIndex + 1)
			SET @Mask = SUBSTRING(@Mask, @LastIndex + 1, LEN(@Mask))

			INSERT INTO @FolioSegmensts(Mask, NextMask) VALUES (@CurrentMask, @Mask)
		END
		ELSE
		BEGIN
			INSERT INTO @FolioSegmensts(Mask) VALUES (@Mask)
			SET @Mask = NULL
		END

		SET @I = @I + 1
	END

	DECLARE	@CurrentId		INT,
			@CurrentValue	NVARCHAR(200),
			@CurrentElement NVARCHAR(200),
			@CurrentArg		 NVARCHAR(200)

	UPDATE @FolioSegmensts SET
		IsFolio = 1
	WHERE Mask LIKE '%{Folio%}%'

	WHILE EXISTS(SELECT 1 FROM @FolioSegmensts fs WHERE fs.Value IS NULL AND IsFolio = 0)
	BEGIN
		SET @CurrentValue = NULL
		SET @CurrentElement = NULL
		SET @CurrentMask = NULL

		SELECT
			@CurrentId = fs.Id,
			@CurrentMask = fs.Mask
		FROM @FolioSegmensts fs 
		WHERE fs.Value IS NULL AND fs.IsFolio = 0


		IF @CurrentMask NOT LIKE ('{%}')
			SET @CurrentValue = @CurrentMask
		ELSE
		BEGIN
			IF CHARINDEX(':', @CurrentMask) > 0
			BEGIN
				SET @CurrentElement = SUBSTRING(@CurrentMask, 1, CHARINDEX(':', @CurrentMask) - 1)
				SET @CurrentArg = SUBSTRING(@CurrentMask, CHARINDEX(':', @CurrentMask) + 1, LEN(@CurrentMask))
			END
			ELSE
				SET @CurrentElement = @CurrentMask

			SET @CurrentElement = REPLACE(@CurrentElement, '{', '')
			SET @CurrentElement = REPLACE(@CurrentElement, '}', '')

			SET @CurrentArg = REPLACE(@CurrentArg, '{', '')
			SET @CurrentArg = REPLACE(@CurrentArg, '}', '')

			SELECT @CurrentValue = CASE @CurrentElement
					WHEN 'CurrentDate' THEN FORMAT(GETDATE(), @CurrentArg)
					ELSE NULL
				END;

			IF @CurrentValue IS NULL
			BEGIN
				SET @MSG_ERROR = CONCAT('The element ', @CurrentElement, ' cannot implemented, cannot be generated this mask ', @Name)
				RAISERROR(@MSG_ERROR, 16, 1);
				RETURN
			END
		END

		UPDATE @FolioSegmensts SET
			Value = @CurrentValue
		WHERE Id = @CurrentId
	END



	DECLARE @IdLastValue	INT,
			@CurrentFolio	INT
	SELECT @MaskResult = STUFF((SELECT ISNULL(l.Value, '{Folio}') FROM @FolioSegmensts l FOR XML PATH('')), 1, 0, '')

	IF EXISTS(SELECT 1 FROM @FolioSegmensts fs WHERE fs.IsFolio = 1)
	BEGIN
		SELECT
			@IdLastValue = mf.IdMaskIncremental,
			@CurrentFolio = mf.LastFolio
		FROM MaskIncremental mf 
		WHERE mf.IdMaskConfiguration = @IdMaskConfiguration AND mf.MaskFormat = @MaskResult


		IF @IdLastValue IS NULL
		BEGIN
			SET @CurrentFolio = 0
			
			INSERT INTO MaskIncremental(IdMaskConfiguration, MaskFormat, LastFolio)
			VALUES(@IdMaskConfiguration, @MaskResult, @CurrentFolio)

			SET @IdLastValue = @@identity
		END

		SET @CurrentFolio = @CurrentFolio + 1

		UPDATE MaskIncremental SET
			LastFolio = @CurrentFolio
		WHERE IdMaskIncremental = @IdLastValue


		DECLARE @FolioFormat VARCHAR(MAX)

		WHILE ISNULL(@FolioLength, 0) > 0
		BEGIN
			SET @FolioFormat = CONCAT(@FolioFormat, '0')
			SET @FolioLength = @FolioLength - 1
		END

		UPDATE @FolioSegmensts SET
			Value = FORMAT(@CurrentFolio, @FolioFormat)
		WHERE IsFolio = 1

		SELECT @MaskResult = STUFF((SELECT l.Value + '' FROM @FolioSegmensts l FOR XML PATH('')), 1, 0, '')
	END


	SELECT @MaskResult
	SELECT * FROM @FolioSegmensts

END
