
CREATE procedure [dbo].[st_GetStatisticsChecksByCustomer]
(	@IdCustomer int) AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

 Begin 
select  distinct(idcustomer), count(idstatus) as TotalChecks, IdStatus as Status
  from Checks
  where IdStatus = 30
 -- and DateStatusChange >= GETDATE() -30
    and IdCustomer = @IdCustomer
  group by idcustomer, idstatus, IdStatus

UNION
  --Customer rejected
 select  distinct(idcustomer), count(idstatus) as TotalChecks, IdStatus as Status
  from Checks
  where IdStatus = 31
 -- and DateStatusChange >= GETDATE() -30
    and IdCustomer = @IdCustomer
  group by idcustomer, idstatus, IdStatus
 
 End

