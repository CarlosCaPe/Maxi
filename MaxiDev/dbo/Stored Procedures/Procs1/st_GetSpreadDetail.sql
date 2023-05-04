CREATE PROCEDURE [dbo].[st_GetSpreadDetail] 
(
	@IdSpread INT
	,@SpreadName NVARCHAR (MAX) OUTPUT
	,@IdCountryCurrency NVARCHAR (MAX) OUTPUT
)
AS

	SELECT @SpreadName=SpreadName, @IdCountryCurrency=IdCountryCurrency FROM Spread S (NOLOCK) WHERE IdSpread =@IdSpread
	SET @SpreadName=ISNULL(@SpreadName,'') 

	SELECT SD.IdSpreadDetail
	,SD.FromAmount
	,SD.ToAmount
	,SD.SpreadValue
	,SD.DateOfLastChange
	,SD.EnterByIdUser 
	FROM SpreadDetail SD (NOLOCK)
	WHERE SD.IdSpread =@IdSpread
	ORDER BY FromAmount 
