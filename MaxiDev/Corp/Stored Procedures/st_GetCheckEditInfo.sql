CREATE PROCEDURE Corp.st_GetCheckEditInfo
	@IdCheck	INT
AS
BEGIN
	
		SELECT EditName, OriValue, Value, OriScore, EditLevel
		FROM dbo.CheckEdits WITH(NOLOCK)
		WHERE IdCheck = @IdCheck
		
END
