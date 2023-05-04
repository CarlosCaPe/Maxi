/********************************************************************
<Author>adominguez</Author>
<app>MaxiAgent</app>
<Description>Busca si un mas de un Customer tiene el mismo SSN</Description>

<ChangeLog>

<log Date="26/03/2020" Author="adominguez">Creation</log>

</ChangeLog>
*********************************************************************/
-- exec st_ValidateCustomerTaxNumber 43624, '393372816' , 0 
CREATE PROCEDURE st_ValidateCustomerTaxNumber 
(
	@IdCustomer int,
	@SSNumber nvarchar(15),
	@Exists bit out 

)
AS
BEGIN

set @Exists = 0

if exists  (Select top 1 * from Customer with(nolock) where SSNumber = @SSNumber and IdCustomer != @IdCustomer)
	set @Exists = 1

End