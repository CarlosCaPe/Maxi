CREATE procedure [dbo].[st_GetGirosLatinosCancels]          
as          
Set Nocount on         
Select  ClaimCode,getdate() as CancellationDate,convert(varchar(25),IdGirosLatinos) as ReceiptNumber  from Transfer A
Join GirosLatinosSerial B on (A.IdTransfer=B.IdTransfer)
Where IdGateway=9 and IdStatus=25  
