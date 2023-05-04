

CREATE procedure [BillPayment].[st_InsertLogCustomerSearch]
            @IdCustomer int
           ,@IdCustomerFidelity int
           ,@Request nvarchar(max)
           ,@Response nvarchar(max)
           ,@HasError bit out
           
           
/********************************************************************
<Author>Earreola</Author>
<app> </app>
<Description>Create Log Customer Search </Description>

<ChangeLog>
<log Date="2018-08-27" Author="earreola"> Creacion  </log>

</ChangeLog>

*********************************************************************/
as
Begin Try  

INSERT INTO [dbo].[LogCustomerSearch]
           ([IdCustomer]
           ,[IdCustomerFidelity]
           ,[Request]
           ,[Response]
           ,[CreationDate])
     VALUES
           (@IdCustomer
           ,@IdCustomerFidelity
           ,@Request
           ,@Response
           ,GETDATE())

Set @HasError=0
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                   
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('BillPayment.st_InsertLogCustomerSearch',Getdate(), '@IdCustomer = ' + CONVERT(VARCHAR(10), @IdCustomer) + ', @IdCustomerFidelity = ' + CONVERT(VARCHAR(10), @IdCustomerFidelity) + @ErrorMessage)
End Catch  

