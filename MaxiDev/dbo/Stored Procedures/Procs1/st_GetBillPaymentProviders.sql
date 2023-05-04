CREATE PROCEDURE [dbo].[st_GetBillPaymentProviders]
	-- Add the parameters for the stored procedure here
	
AS
/********************************************************************
<Author></Author>
<app>MaxiAgente</app>
<Description>This stored is used in agent for search screen billers transaction</Description>

<ChangeLog>
<log Date="10/08/2018" Author="snevarez">Creacion del Store</log>
</ChangeLog>
*********************************************************************/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT [IdProvider], [ProviderName] FROM [dbo].[Providers] WHERE [IdProvider] IN (1,5) ORDER BY [ProviderName]
/*
	DECLARE @Providers AS TABLE (IdOtherProduct INT, ProviderName NVARCHAR(MAX))
	INSERT INTO @Providers VALUES (14,'Regalii')
	INSERT INTO @Providers VALUES (1,'Softgate')
	SELECT [IdOtherProduct], [ProviderName] FROM @Providers ORDER BY [ProviderName]
*/
   	select IdOtherProduct=IdOtherProducts, ProviderName=Name from BillPayment.Aggregator

END
