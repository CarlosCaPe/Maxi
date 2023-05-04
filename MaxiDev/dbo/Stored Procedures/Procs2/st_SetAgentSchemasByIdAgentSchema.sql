
CREATE procedure [dbo].[st_SetAgentSchemasByIdAgentSchema]
(
     @IdAgent int,
     @IdAgentSchema int,
     @EnterByIdUser int    
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

declare     
    @IdAgentSchemaNew int,
    @SchemaName nvarchar(max),
    @IdFee int,
    @IdCommission int,
    @IdCountryCurrency int,
    @SchemaDefault nvarchar(max),    
    @IdGenericStatus int,
    @Description nvarchar(max),   
    @Spread money,
    @EndDateSpread datetime

begin try

--Validar si la agencia tiene o no esquemas asignados
if exists (select 1 from agentschema with(nolock) where idagent=@IdAgent and idagentschemaparent=@IdAgentSchema)
begin
   Print('Esquema Previamente Asignado')
   return
end

--Obtener los esquemas por default que se encuentran habilitados
select 
    IdAgentSchema,SchemaName,IdFee,IdCommission,IdCountryCurrency,SchemaDefault,IdGenericStatus,[Description],Spread,EndDateSpread into #TempAgentSchema 
from 
    [AgentSchema] with(nolock) 
where 
    IdAgentSchema=@IdAgentSchema

--Recorrer esquemas por default
while exists (select 1 from #TempAgentSchema)
begin    
    
    select top 1 @IdAgentSchema=IdAgentSchema,@SchemaName=SchemaName,@IdFee=IdFee,@IdCommission=IdCommission,@IdCountryCurrency=IdCountryCurrency,@SchemaDefault=0,@IdGenericStatus=IdGenericStatus,@Description=[Description],@Spread=Spread,@EndDateSpread=EndDateSpread from #TempAgentSchema

    --agregar esquema por default a la agencia
    INSERT INTO [dbo].[AgentSchema]
           ([SchemaName]
           ,[IdFee]
           ,[IdCommission]
           ,[IdCountryCurrency]
           ,[SchemaDefault]
           ,[DateOfLastChange]
           ,[EnterByIdUser]
           ,[IdGenericStatus]
           ,[Description]
           ,[IdAgent]
           ,[Spread]
           ,[EndDateSpread]
           ,[IdAgentSchemaParent]
           )
     VALUES
           (@SchemaName
           ,@IdFee
           ,@IdCommission
           ,@IdCountryCurrency
           ,@SchemaDefault
           ,Getdate()
           ,@EnterByIdUser
           ,@IdGenericStatus
           ,@Description
           ,@IdAgent
           ,@Spread
           ,@EndDateSpread
           ,@IdAgentSchema
           );

    set @IdAgentSchemaNew = SCOPE_IDENTITY();
    
    --agregar el detalle de los esquemas por default    
    --IdAgentSchemaDetail	IdAgentSchema	IdPayerConfig	SpreadValue	DateOfLastChange	EnterByIdUser
    insert into AgentSchemaDetail
    (IdAgentSchema,IdPayerConfig,SpreadValue,DateOfLastChange,EnterByIdUser)
    select @IdAgentSchemaNew,idpayerconfig,spreadvalue,getdate(),@EnterByIdUser from agentschemadetail with(nolock) where idagentschema=@IdAgentSchema;

    delete from #TempAgentSchema where IdAgentSchema=@IdAgentSchema ;   

end

Print('Esquema Asignado correctamente a la agencia: ' +convert(varchar,@IdAgent))

End Try
Begin Catch
	Print('Erro al intentar asignar el esquema a la agencia' +convert(varchar,@IdAgent))
End Catch