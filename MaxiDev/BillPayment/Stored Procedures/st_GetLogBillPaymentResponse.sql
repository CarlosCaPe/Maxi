CREATE procedure [BillPayment].[st_GetLogBillPaymentResponse]
            @IdAgent int
           ,@IdUser int
           ,@IdAggregator int
           ,@Request nvarchar(max)
           ,@TypeMovent nvarchar(max) ='Bill Payment'
           ,@Response nvarchar(max)
           ,@HasError bit out
           ,@IdProductTransfer bigint
           ,@Message nvarchar(max) out
           
           
/********************************************************************
<Author>Amoreno</Author>
<app> </app>
<Description>Create Log Tranfer for BillPayment </Description>

<ChangeLog>
<log Date="2018-08-22" Author="amoreno"> Creacion  </log>
<log Date="19/10/2018" Author="amoreno">Se agrega campo de Tipo de Movimiento</log>

</ChangeLog>

*********************************************************************/
as
Begin Try  

INSERT INTO [MAXILOG].[BillPayment].[LogBillPaymentResponse]
           ([IdAgent]
           ,[IdUser]
           ,[IdAggregator]
           ,[Request]
           ,[Response]
           ,[DateLastChange]
           ,[TypeMovent]
           ,[IdProductTransfer])
          
     VALUES
           (
            @IdAgent
           ,@IdUser
           ,@IdAggregator
           ,@Request
           ,@Response
           ,getdate()
           ,@TypeMovent
           ,@IdProductTransfer
           )

Set @HasError=0
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                                                                                               
    Select @Message=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('BillPayment.LogBillPaymentResponse',Getdate(),@Message)                                                                                            
End Catch  
