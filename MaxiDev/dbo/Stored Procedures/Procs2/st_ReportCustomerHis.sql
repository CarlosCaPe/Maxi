create PROCEDURE [dbo].[st_ReportCustomerHis] 
(
	@IdCustomer int
)
as

select a.IdCustomer, 
       a.IdAgentCreatedBy, 
	   a.IdCustomerIdentificationType, 
	   isnull(c.Name,'') CustomerIdentificationType,  
	   a.IdGenericStatus, 
	   d.GenericStatus, 
	   a.Name, 
	   a.FirstLastName,
	   a.SecondLastName,
       a.Address, a.City,
	   a.State, 
	   a.Country, 
	   a.Zipcode, 
	   a.PhoneNumber, 
	   a.CelullarNumber, 
	   a.SSNumber, 
	   a.BornDate, 
	   a.Occupation, 
	   a.IdentificationNumber,
       --a.PhysicalIdCopy, 
	   a.DateOfLastChange, 
	   a.ExpirationIdentification, 
	   a.IdCarrier, 
	   isnull(e.name,'') Carrier, 
	   a.IdentificationIdCountry,
       isnull(countryname,'') IdentificationCountryName,
       a.IdentificationIdState, 	   
       isnull(statename,'') IdentificationStateName,
	   a.EnterByIdUser, 
	   b.username
from Customer a
  join users b on b.iduser = a.EnterByIdUser
  join GenericStatus d on d.IdGenericStatus = a.IdGenericStatus
  left join CustomerIdentificationType c on c.IdCustomerIdentificationType = a.IdCustomerIdentificationType  
  left join Carriers e on e.IdCarrier = a.IdCarrier
  left join country co on a.IdentificationIdCountry=co.idcountry
  left join state st on a.IdentificationIdState=st.idstate
where a.IdCustomer = @IdCustomer

union all

select a.IdCustomer, 
       a.IdAgentCreatedBy, 
	   a.IdCustomerIdentificationType, 
	   isnull(c.Name,'') CustomerIdentificationType,  
	   a.IdGenericStatus, 
	   d.GenericStatus, 
	   a.Name, 
	   a.FirstLastName,
	   a.SecondLastName,
       a.Address, a.City,
	   a.State, 
	   a.Country, 
	   a.Zipcode, 
	   a.PhoneNumber, 
	   a.CelullarNumber, 
	   a.SSNumber, 
	   a.BornDate, 
	   a.Occupation, 
	   a.IdentificationNumber,
       --a.PhysicalIdCopy, 
	   a.DateOfLastChange, 
	   a.ExpirationIdentification, 
	   a.IdCarrier, 
	   isnull(e.name,'') Carrier, 
	   a.IdentificationIdCountry,
       isnull(countryname,'') IdentificationCountryName,
       a.IdentificationIdState, 	   
       isnull(statename,'') IdentificationStateName,
	   a.EnterByIdUser, 
	   b.username
from CustomerMirror a
  join users b on b.iduser = a.EnterByIdUser
  join GenericStatus d on d.IdGenericStatus = a.IdGenericStatus
  left join CustomerIdentificationType c on c.IdCustomerIdentificationType = a.IdCustomerIdentificationType  
  left join Carriers e on e.IdCarrier = a.IdCarrier
  left join country co on a.IdentificationIdCountry=co.idcountry
  left join state st on a.IdentificationIdState=st.idstate
where a.IdCustomer = @IdCustomer

order by dateoflastchange desc