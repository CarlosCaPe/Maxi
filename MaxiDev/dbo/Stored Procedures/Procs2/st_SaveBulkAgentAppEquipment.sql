

CREATE procedure [dbo].[st_SaveBulkAgentAppEquipment]            
@Equipment XML, 
@IdAgentApplication int,                  
@EnterByIdUser int,
@IsSpanishLanguage bit,       
@HasError bit out,  
@Message varchar(max) out              
as           
Set Nocount on   
set @HasError=0  
set @Message =''  
  
  
Begin Try   

 Delete AgentAppEquipmentDetails where IdAgentApplication=@IdAgentApplication
  
 Declare @Today Datetime
 Set @Today=GETDATE() 
 Declare @DocHandle int            
 EXEC sp_xml_preparedocument @DocHandle OUTPUT, @Equipment 
 
      
 Insert into AgentAppEquipmentDetails 
 (
 	IdAgentApplication,
	InventoryNumber,
	IdEquipmentType,
	EnterByIdUser,
	DateOfLastChange,
	Brand,
	Model
  )      
 SELECT @IdAgentApplication,InventoryNumber,IdEquipmentType,@EnterByIdUser,@Today, Brand, Model    
 FROM OPENXML (@DocHandle, 'root/equipment',2)  WITH (IdEquipmentType int, InventoryNumber varchar(max),Brand varchar(max), Model varchar(max))                   
 EXEC sp_xml_removedocument @DocHandle            
    
  
 Set @HasError=0                         
 set @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,60)   
 
End Try                                  
Begin Catch                                  
 Set @HasError=1                         
 set @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,59)                                                            
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_SaveBulkAgentAppEquipment]',Getdate(),ERROR_MESSAGE()  )  
End Catch  
  
----------------------------- Ejemplo --------------------------



--USE [MaxiDev]
--GO

--DECLARE	@return_value int,
--		@HasError bit,
--		@Message varchar(max)

--EXEC	@return_value = [dbo].[st_SaveBulkAgentAppEquipment]
--		@Equipment = N'<root>
--<equipment>
--	<IdEquipmentType>1</IdEquipmentType>
--	<InventoryNumber>1</InventoryNumber>
--</equipment>
--<equipment>
--	<IdEquipmentType>2</IdEquipmentType>
--	<InventoryNumber>2</InventoryNumber>
--</equipment>
--<equipment>
--	<IdEquipmentType>1</IdEquipmentType>
--	<InventoryNumber>1</InventoryNumber>
--</equipment>
--<equipment>
--	<IdEquipmentType>2</IdEquipmentType>
--	<InventoryNumber>2</InventoryNumber>
--</equipment>
--</root>',
--		@IdAgentApplication = 10,
--		@EnterByIdUser = 1,
--		@IsSpanishLanguage=0,
--		@HasError = @HasError OUTPUT,
--		@Message = @Message OUTPUT

--SELECT	@HasError as N'@HasError',
--		@Message as N'@Message'

--SELECT	'Return Value' = @return_value

--GO


