CREATE PROCEDURE [Corp].[st_BulkFaxInsertSignatureHold]  
(  
    @IsSpanishLanguage bit,  
    @XMLIdAgent xml,  
    @EnterByIdUser int,
    @HasError bit out,          
    @MessageOut varchar(max) out    
)  
AS  
Set nocount on  
Begin Try  
  
Declare @DocHandle int              
EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XMLIdAgent               
INSERT INTO QueueFaxes(IdAgent,[Parameters],[ReportName],[Priority],IdQueueFaxStatus,EnterByIdUser)           
SELECT IdAgent,'<Parameters><Parameter name="IdAgent" value="'+Convert(varchar,IdAgent)+'" /></Parameters>','RequestSignatures',3,1,@EnterByIdUser  FROM OPENXML (@DocHandle, 'Main/Agent',2)  WITH (IdAgent int)
EXEC sp_xml_removedocument @DocHandle     
  
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
