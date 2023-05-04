
CREATE Procedure [dbo].[st_InsertAgentSchema]        
(        
@SchemaName nvarchar(max),      
@Description nvarchar(max),        
@IdFee int,        
@IdCommission int,        
@IdCountryCurrency int,        
@SchemaDefault bit,        
@GenericStatus Int,        
@EnterByIdUser int,        
@IsSpanishLanguage bit,        
@XmlAgentSchemaDetail XML,
@IdAgent int = null,
@IdAgentSchemaInserted int output,        
@HasError bit out,        
@Message varchar(max) out        
)        
AS        
Set nocount on         
Begin Try        

 
if (@SchemaDefault=1) and (isnull(@IdAgent,0)=0) and exists (select 1 from [AgentSchema] with(nolock) where SchemaDefault=1 /*and idgenericstatus=1*/ and idagent is null and IdCountryCurrency=@IdCountryCurrency /*and IdAgentSchema!=@IdAgentSchema*/)
begin
    Set @HasError=1        
    Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,88)   
    return
end

 Declare @IdAgentSchema Int        
        
 Insert into AgentSchema         
 (        
 SchemaName,      
 [Description],        
 IdFee,        
 IdCommission,        
 IdCountryCurrency,        
 SchemaDefault,        
 DateOfLastChange,        
 EnterByIdUser,        
 IdGenericStatus,
 IdAgent        
 )        
  values         
 (        
 @SchemaName,      
 @Description,        
 @IdFee,        
 @IdCommission,        
 @IdCountryCurrency,        
 @SchemaDefault,        
 GETDATE(),        
 @EnterByIdUser,        
 @GenericStatus,
 @IdAgent        
 )        
        
 Select @IdAgentSchema=Scope_Identity() 
 Set @IdAgentSchemaInserted=@IdAgentSchema
        
 -------------------------- Insert in AgentSchemaDetail ------------------------------------        
 Declare @DocHandle int        
 EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XmlAgentSchemaDetail         
 Insert into AgentSchemaDetail (IdAgentSchema,IdPayerConfig,SpreadValue,DateOfLastChange,EnterByIdUser)        
 Select @IdAgentSchema,IdPayerConfig,SpreadValue,Getdate(),@EnterByIdUser From OPENXML (@DocHandle, '/AgentSchemaDetail/Detail',2)        
 WITH (        
 IdPayerConfig int,        
 SpreadValue Money        
 )         
 Exec sp_xml_removedocument @DocHandle        
 --------------------------------------------------------------------------------------------        
 Set @HasError=0        
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,90)        
End Try        
Begin Catch        
 Set @HasError=1        
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,89)        
 Declare @ErrorMessage nvarchar(max)         
 Select @ErrorMessage=ERROR_MESSAGE()        
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_InsertAgentSchema',Getdate(),@ErrorMessage)        
End Catch
