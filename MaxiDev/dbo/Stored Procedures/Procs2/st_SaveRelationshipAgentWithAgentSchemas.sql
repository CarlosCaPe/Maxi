
CREATE procedure [dbo].[st_SaveRelationshipAgentWithAgentSchemas]    
@IdAgent int,    
@Schemas xml,    
@EnterByIdUser int,    
@IsSpanishLanguage bit,    
@HasError bit out,    
@ResultMessage nvarchar(max) out    
as    
    
declare @IdGenericStatusEnable int    
set @IdGenericStatusEnable =1 --Enable    
    
    
Begin try    
  
   Declare @TempSchema Table
   (
   IdAgentSchema Int
   )
   
   Declare @DocHandle int        
   EXEC sp_xml_preparedocument @DocHandle OUTPUT, @Schemas      
   Insert into @TempSchema ( IdAgentSchema)
   Select IdAgentSchema    
   From OPENXML (@DocHandle, '/Schemas/Detail',2)        
   WITH ( IdAgentSchema int)         

        
   Delete RelationAgentSchema where IdAgent = @IdAgent and IdAgentSchema not in (Select IdAgentSchema from @TempSchema)        
               
   Insert into RelationAgentSchema ( IdAgentSchema, IdAgent, DateOfLastchange, EnterByIdUser,Spread,EndDateSpread)    
   Select IdAgentSchema,@IdAgent,GETDATE(), @EnterByIdUser, 0, Null  from  @TempSchema 
   where  IdAgentSchema not in (Select IdAgentSchema from RelationAgentSchema where IdAgent=@IdAgent)
       
    
  set @HasError =0    
  set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,50)    
End try    
Begin Catch    
   Declare @ErrorMessage nvarchar(max)             
   Select @ErrorMessage=ERROR_MESSAGE()            
   Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_SaveRelationshipAgentWithAgentSchemas]',Getdate(),@ErrorMessage)     
  set @HasError =1    
  set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,51)    
End catch    
    
return;
