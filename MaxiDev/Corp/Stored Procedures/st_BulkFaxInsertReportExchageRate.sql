CREATE PROCEDURE [Corp].[st_BulkFaxInsertReportExchageRate]  
(  
    @IsSpanishLanguage bit,  
    @IdAgent int,
    @EnterByIdUser int,
    @XMLIdAgent xml,  
    @HasError bit out,          
    @MessageOut varchar(max) out    
)
AS  
Set nocount on  
Begin Try  

INSERT INTO QueueFaxes(IdAgent,[Parameters],[ReportName],[Priority],IdQueueFaxStatus,EnterByIdUser)
values
(@IdAgent,@XMLIdAgent,'ReportExchangeRate',3,1,@EnterByIdUser) 

Set @HasError=0          
Set @MessageOut=dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,46)

End Try                                        
Begin Catch                                        
 Set @HasError=1                               
 Select @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,47)                                         
 Declare @ErrorMessage nvarchar(max)                                         
 Select @ErrorMessage=ERROR_MESSAGE()                                        
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_BulkUpdateStatusForCompliance',Getdate(),@ErrorMessage)                                        
End Catch
