/********************************************************************
<Author>azavala</Author>
<app>WinService (Maxi_ElasticSearchCustomerProcess)</app>
<Description>Store for get customers with pending Update into ElasticSearch</Description>

<ChangeLog>
<log Date="31/07/2018" Author="azavala">Create new Store</log>
</ChangeLog>
*********************************************************************/
CREATE PROCEDURE elastic.st_ElasticCustomers_Update
AS
BEGIN
	SET NOCOUNT ON;
	select top (10000) C.IdCustomer,
	 C.Name,
	 C.FirstLastName, 
	 C.SecondLastName, 
	 C.City, 
	 C.State, 
	 C.Country, 
	 C.Address, 
	 C.IdAgentCreatedBy as IdAgent,
	 case   	   
		when ((Select TOP(1) CardNumber from CardVIP CV where CV.IdCustomer = C.IdCustomer) is null) then
		''
		else
		(Select TOP(1) CardNumber from CardVIP CV (nolock) where CV.IdCustomer = C.IdCustomer)
		end as CardNumber, 
		REPLACE(REPLACE(REPLACE(REPLACE(C.CelullarNumber,'-',''),' ',''), '(',''),')','') as CelullarNumber, 
		C.CelullarNumber as CelullarToShow, 
		REPLACE(REPLACE(REPLACE(REPLACE(C.PhoneNumber,'-',''),' ',''), '(',''),')','') as PhoneNumber,
		C.PhoneNumber as PhoneToShow, 
		(REPLACE(C.Name,' ','') + '_' + REPLACE(C.FirstLastName,' ','') + '_' + REPLACE(C.SecondLastName,' ','')) AS SearchString,
		C.idElasticCustomer, C.IdGenericStatus as Status, GETDATE() as lastUpdate
	from Customer C with (nolock) 
	where 
	C.idElasticCustomer is not null 
	and C.idElasticCustomer <>'Descartado' 
	and C.UpdateCompleted=0 
	and C.RequestUpdate=1 
	and C.IdGenericStatus=1
END
