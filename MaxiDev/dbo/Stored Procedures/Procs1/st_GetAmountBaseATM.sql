/*
<Autor>Azavala</Autor>
<Application>New Agent</Application>
<Description>Obtain all the amount base to send by ATM type</Description>

<log data="08/02/2019" user="azavala">Create</log>
*/
CREATE PROCEDURE dbo.st_GetAmountBaseATM
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select CurrencyCode, IdPaymentType, AtmAmountBase, NumberLength, MaxAmount from AmountBaseByCurrency with(nolock)
END
