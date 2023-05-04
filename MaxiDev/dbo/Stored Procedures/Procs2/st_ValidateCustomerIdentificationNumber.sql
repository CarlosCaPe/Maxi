/********************************************************************
<Author>adominguez</Author>
<app>MaxiAgent</app>
<Description>Busca si un mas de un Customer tiene el mismo Numero de ID</Description>

<ChangeLog>

<log Date="26/03/2020" Author="adominguez">Creation</log>

</ChangeLog>
*********************************************************************/
-- Select exec st_ValidateCustomerIdentificationNumber 43624, 'TN104666248' , 0
CREATE PROCEDURE st_ValidateCustomerIdentificationNumber 
(
	@IdCustomer int,
	@IdNumber nvarchar(15),
	@Exists bit out 

)
AS
BEGIN

set @Exists = 0

if exists  (Select top 1 * from Customer with(nolock) where IdentificationNumber = @IdNumber and IdCustomer != @IdCustomer)
	set @Exists = 1

End