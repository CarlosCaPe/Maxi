
CREATE procedure [dbo].[st_GetAccountsByCustomerId]
@CustomerId int, @IdAgent int
as 
declare @State nvarchar(max)

select @State = Agentstate from agent where idagent=@IdAgent

select t1.IdBillAccounts, t1.AccountNumber, t2.VEndorName,t1.IdProductsByProvider,t2.VendorID from [BillAccounts] t1
join ProductsByProvider t2 on t1.[IdProductsByProvider] = t2.idProductsByProvider
join softgate.Billers A on  A.VendorID=t2.VendorID 
Join Softgate.MerchIdState B on (A.TerminalNumber=B.MerchID)  
where t1.IdCustomer = @CustomerId and B.StateCode=@State

/*
ALTER procedure [dbo].[st_GetAccountsByCustomerId]
@CustomerId int
as 
select t1.IdBillAccounts, t1.AccountNumber, t2.VEndorName from [BillAccounts] t1
join ProductsByProvider t2 on t1.[IdProductsByProvider] = t2.idProductsByProvider
where t1.IdCustomer = @CustomerId
*/