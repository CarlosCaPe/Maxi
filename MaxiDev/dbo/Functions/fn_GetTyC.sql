CREATE   FUNCTION [dbo].[fn_GetTyC]
(
	@IsDomestic			BIT,
	@IsGeneral			BIT,
	@IdLenguage			INT
)
RETURNS VARCHAR(3000)
AS
BEGIN
	DECLARE @TyC			VARCHAR(3000);
	DECLARE @MessageKey		VARCHAR(50);

	IF (@IsDomestic = 1)
		SET @MessageKey = 'Domestic';
	ELSE
		SET @MessageKey = 'International';

	IF (@IsGeneral = 1)
		SET @MessageKey = CONCAT(@MessageKey,'General');
	ELSE
		SET @MessageKey = CONCAT(@MessageKey,'California');

	SET @MessageKey = CONCAT(@MessageKey,'TyC');

	SELECT
		@TyC = LR.[Message]
	FROM LenguageResource LR WITH(NOLOCK) 
	WHERE LR.MessageKey = @MessageKey
	AND LR.IdLenguage = @IdLenguage;

	RETURN @TyC
END