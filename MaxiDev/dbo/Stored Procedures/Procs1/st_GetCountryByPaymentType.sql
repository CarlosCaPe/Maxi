-- =============================================
-- Author:		<bortega>
-- Create date: <21-10-2019>
-- Description:	<Se muestra la ciudad por cada tipo de pago>
-- =============================================
CREATE PROCEDURE [dbo].[st_GetCountryByPaymentType] --6075
(
 @IdAgent int
)	-- Add the parameters for the stored procedure here
	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT case 
	when PC.IdPaymentType = 4 then 1
	else PC.IdPaymentType
	end 
	IdPaymentType , co.IdCountry, CO.CountryName FROM PayerConfig PC with (nolock)
	inner join CountryCurrency CC with (nolock) on CC.IdCountryCurrency= PC.IdCountryCurrency
	inner join Country CO with (nolock) ON CO.IdCountry = CC.IdCountry
	inner join PaymentType PT with (nolock) ON PT.IdPaymentType = PC.IdPaymentType 
	inner join AgentSchema SH with(nolock) ON SH.IdCountryCurrency = PC.IdCountryCurrency
	where pc.IdGenericStatus = 1 and SH.IdGenericStatus = 1 and SH.IdAgent = @IdAgent
	group by PC.IdPaymentType, CO.CountryName, CO.IdCountry order by CO.CountryName
END
