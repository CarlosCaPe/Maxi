


create procedure [BillPayment].[st_GetLogCustomerSearch]
            @IdCustomer int
           ,@HasError bit out
           
           
/********************************************************************
<Author>Earreola</Author>
<app> </app>
<Description>Get Log Customer Search </Description>

<ChangeLog>
<log Date="2018-08-27" Author="earreola"> Get  </log>

</ChangeLog>

*********************************************************************/
as
Begin Try  

  SELECT isnull(MAX(IdCustomerFidelity),0) as IdCustomerFidelity
  FROM dbo.LogCustomerSearch with(nolock)
  where IdCustomer = @IdCustomer


Set @HasError=0
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                   
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('BillPayment.st_GetLogCustomerSearch',Getdate(),@ErrorMessage)                                                                                            
End Catch  

