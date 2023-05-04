
CREATE procedure [dbo].[st_GetPureMinuteBonification]
(
    @AccountNumber nvarchar(max),
	@IdAgent INT,
    @IsBonus bit out
)
as
SET NOCOUNT OFF
	IF NOT EXISTS(
		SELECT TOP 1 1 FROM [dbo].[AgentProducts] (NOLOCK)
		WHERE [IdAgent] = @IdAgent AND [IdOtherProducts] = 5 AND [IdGenericStatus] = 1) -- 5 is Long Distance
	BEGIN
		SET @IsBonus=1
		RETURN;
	END
	SET @IsBonus=0
	SET @AccountNumber=replace(replace(replace(replace(@AccountNumber,'(',''),')',''),'-',''),' ','')
	SET @AccountNumber='('+SUBSTRING(@AccountNumber,1,3)+') '+SUBSTRING(@AccountNumber,4,3)+'-'+SUBSTRING(@AccountNumber,7,4)
	IF exists (SELECT TOP 1 ReceiveAccountNumber FROM pureminutestransaction WITH (NOLOCK) where ReceiveAccountNumber=@AccountNumber)
	BEGIN
		SET @IsBonus=1
	END
return;