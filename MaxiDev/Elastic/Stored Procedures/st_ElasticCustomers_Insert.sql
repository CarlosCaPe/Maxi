/********************************************************************
<Author> Alexis Zavala </Author>
<app> Elastic Search </app>
<Description> obtiene customers no registrados en elasticsearch por problema de conexion (WebApi)  </Description>

<ChangeLog>
<log Date="18/01/2018" Author="azavala">Creacion</log>
<log Date="06/08/2018" Author="jmmolina">Se agrego filtro para customers activos(genericstatus: 1) y que tengan mas de 5 minutos sin idElasticSearch</log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [Elastic].[st_ElasticCustomers_Insert]
AS
BEGIN try
	SET NOCOUNT ON;

	select top (10000) C.IdCustomer, C.Name, C.FirstLastName, C.SecondLastName, C.City, C.State, C.Country, C.Address, C.IdAgentCreatedBy as IdAgent
	,case   	   
		when ((Select TOP(1) CardNumber from CardVIP CV where CV.IdCustomer = C.IdCustomer) is null) then
		''
		else
		(Select TOP(1) CardNumber from CardVIP CV (nolock) where CV.IdCustomer = C.IdCustomer)
		end as CardNumber, REPLACE(REPLACE(REPLACE(REPLACE(C.CelullarNumber,'-',''),' ',''), '(',''),')','') as CelullarNumber, C.CelullarNumber as CelullarToShow, REPLACE(REPLACE(REPLACE(REPLACE(C.PhoneNumber,'-',''),' ',''), '(',''),')','') as PhoneNumber, C.PhoneNumber as PhoneToShow, (REPLACE(C.Name,' ','') + '_' + REPLACE(C.FirstLastName,' ','') + '_' + REPLACE(C.SecondLastName,' ','')) AS SearchString, null as idElasticCustomer, C.IdGenericStatus as Status, GETDATE() as lastUpdate
	from Customer C with (nolock) where (C.idElasticCustomer is null OR C.idElasticCustomer = '') 
	 and C.Name <> '' --AND UpdateCompleted = 0
	 AND C.IdGenericStatus = 1
	 AND DATEDIFF(MINUTE, CreationDate, GETDATE()) >= 8
END try
BEGIN CATCH
	Select null
END CATCH
