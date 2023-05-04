CREATE procedure [dbo].[st_OnWhoseBehalfByCustomer]
(
@idCustomer int
)
as

SELECT O.[IdOnWhoseBehalf]
      ,[IdAgentCreatedBy]
      ,[IdGenericStatus]
      ,[Name]
      ,[FirstLastName]
      ,[SecondLastName]
      ,[Address]
      ,[City]
      ,[State]
      ,[Country]
      ,[Zipcode]
      ,[PhoneNumber]
      ,[CelullarNumber]
      ,[SSNumber]
      ,[BornDate]
      ,[Occupation]
      ,[IdentificationNumber]
      ,[PhysicalIdCopy]
      ,[IdCustomerIdentificationType]
      ,[ExpirationIdentification]
      ,[Purpose]
      ,[Relationship]
      ,[MoneySource]
from OnWhoseBehalf O
	inner join 
		(
				select IdOnWhoseBehalf
				from Transfer
					where IdCustomer = @idCustomer and IdOnWhoseBehalf is not null 
			union
				select IdOnWhoseBehalf
				from TransferClosed
					where IdCustomer = @idCustomer and IdOnWhoseBehalf is not null 
		)L on L.IdOnWhoseBehalf= O.IdOnWhoseBehalf
