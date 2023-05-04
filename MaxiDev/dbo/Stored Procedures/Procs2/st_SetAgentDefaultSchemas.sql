CREATE PROCEDURE [dbo].[st_SetAgentDefaultSchemas]
(
     @IdAgent int,
     @EnterByIdUser int,     
     @IdLenguage int,
     @HasError bit out,
     @MessageError nvarchar(max) out
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
    @IdAgentSchema int,
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
if exists (select 1 from agentschema with(nolock) where idagent=@IdAgent)
begin
    Set @HasError=1	
    set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError1')
    return
end

--Obtener los esquemas por default que se encuentran habilitados
select 
    IdAgentSchema,SchemaName,IdFee,IdCommission,IdCountryCurrency,SchemaDefault,IdGenericStatus,[Description],Spread,EndDateSpread into #TempAgentSchema 
from 
    [AgentSchema]  with(nolock)
where 
    idagent is null and schemadefault=1 and idgenericstatus=1

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
           ,NULL
           ,NULL
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
		(IdAgentSchema,IdPayerConfig,SpreadValue,DateOfLastChange,EnterByIdUser,IdFee, IdCommission)
			select @IdAgentSchemaNew,idpayerconfig,spreadvalue,getdate(),@EnterByIdUser,@IdFee, @IdCommission -- Insert default fee and commission by AgentScheme
			from agentschemadetail  with(nolock) where idagentschema=@IdAgentSchema;

    delete from #TempAgentSchema where IdAgentSchema=@IdAgentSchema;    

end

set @HasError = 0
set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaSave')

End Try
Begin Catch
	Set @HasError=1	
    set @MessageError=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError1')
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SetAgentDefaultSchemas',Getdate(),@ErrorMessage)
End Catch
