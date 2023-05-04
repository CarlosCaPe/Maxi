-- =============================================
-- Author:		<bortega>
-- Create date: <02/10/2020,>
-- Description:	<Redondeo en Monto Envíos de Dinero>
-- =============================================
CREATE PROCEDURE [dbo].[st_GetPayerScaleRounding]
	-- Add the parameters for the stored procedure here
	@IdPayer int,
	@IdPaymentType int,
	@AmountDls money,
	@SelectedExchangeRate money,
	@IdPayerConfig int,
	@AmountRound money output,
	@IdScaleRound int = 0 output
AS
BEGIN TRY

	DECLARE @CCMexicoPesos INT
	SELECT
		@CCMexicoPesos = TRY_CAST(ga.Value AS INT)
	FROM GlobalAttributes ga 
	WHERE ga.Name = 'IdCountryCurrencyMexicoPesos'

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Num money

	if exists (Select top 1 * from Payer where PayerCode = 'EXITO' AND IdPayer = @IdPayer)
	BEGIN
		SET @IdScaleRound = 0
		SET @AmountRound = Round(CEILING(@AmountDls * @SelectedExchangeRate / 50) * 50,2);
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM PayerConfig pc WHERE pc.IdPayerConfig = @IdPayerConfig AND pc.IdGateway = 4 AND pc.IdCountryCurrency = @CCMexicoPesos AND pc.IdPaymentType IN (1, 4))
			SET @IdScaleRound = 2
		ELSE
		BEGIN
			SET @IdScaleRound = (select ISNULL(IdScaleRounding,0) from PayerRounding PR with(nolock)
				INNER JOIN PayerConfig PC with(nolock) ON PC.IdPayer = PR.IdPayer  
				where PR.IdPayer = @IdPayer and PR.IdPaymentType = PC.IdPaymentType and IsEnabled = 1 and PC.IdPayerConfig = @IdPayerConfig)
	
			SET @IdScaleRound = ISNULL(@IdScaleRound,0)
		END
	
		SET @Num = @amountDls * @SelectedExchangeRate
		SET @AmountRound = Case @IdScaleRound
			WHEN 1 THEN ROUND(@Num,1)
			WHEN 2 THEN ROUND(@Num,0)
			WHEN 3 THEN ROUND(@Num,-1)
			WHEN 4 THEN ROUND(@Num,-2)
			ELSE ROUND(@Num, 2)
		END
	END
END TRY
BEGIN CATCH
		SET @IdScaleRound = -1
		SET @AmountRound = 0
		Declare @ErrorMessage nvarchar(max)                                                                                             
		Select @ErrorMessage=ERROR_MESSAGE()                                             
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetPayerScaleRounding',Getdate(),@ErrorMessage); 
END CATCH

