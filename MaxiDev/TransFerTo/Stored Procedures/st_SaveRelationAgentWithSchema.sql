create procedure [TransFerTo].[st_SaveRelationAgentWithSchema]
    @IdAgent int,    
    @Schemas xml,    
    @EnterByIdUser int,    
    @IdLenguage int,    
    @HasError bit out,    
    @Message nvarchar(max) out    
as
Begin try    
  
   Declare @TempSchema Table
   (
        IdSchema Int
   )
   
   Declare @DocHandle int        
   EXEC sp_xml_preparedocument @DocHandle OUTPUT, @Schemas      
   Insert into @TempSchema ( IdSchema)
   Select IdSchema    
   From OPENXML (@DocHandle, '/Schemas/Detail',2)        
   WITH ( IdSchema int)  

   Delete [TransFerTo].[AgentSchema] where IdAgent = @IdAgent and IdSchema not in (Select IdSchema from @TempSchema)        
               
   Insert into [TransFerTo].[AgentSchema] ( IdSchema, IdAgent, DateOfLastchange, EnterByIdUser)    
   Select IdSchema,@IdAgent,GETDATE(), @EnterByIdUser  from  @TempSchema 
   where  IdSchema not in (Select IdSchema from [TransFerTo].[AgentSchema] where IdAgent=@IdAgent) and isnull(IdSchema,0)!=0
       
    
  set @HasError=0
set @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaSave')     
End try    
Begin Catch    
    Set @HasError=1            
    Select @Message =dbo.[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError1')  
    Declare @ErrorMessage nvarchar(max)             
    Select @ErrorMessage=ERROR_MESSAGE()            
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_SaveRelationAgentWithSchemas',Getdate(),@ErrorMessage)        
End catch    
