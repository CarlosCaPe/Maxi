CREATE procedure st_tempLlena
(
@NewIdPayerConfig int
)
as
    Declare @SystemUserID int   
    Select @SystemUserID=dbo.GetGlobalAttributeByName ('SystemUserID')    
      
    
    Select  A.idAgentSchema,SpreadValue,COUNT(1) as Total into #temp from AgentSchemaDetail A     
    Join AgentSchema b on (A.IdAgentSchema=B.IdAgentSchema)     
    Where B.IdCountryCurrency=10    
    group by A.SpreadValue,A.IdAgentSchema    
    
    Insert into AgentSchemaDetail     
    (    
    IdAgentSchema,    
    IdPayerConfig,    
    SpreadValue,    
    DateOfLastChange,    
    EnterByIdUser    
    )    
    Select distinct idAgentschema, @NewIdPayerConfig as IdPayerConfig, (Select top 1 SpreadValue from #temp where idAgentSchema=A.idAgentschema order by total desc) as Spread,    
    GETDATE() as DateOfLastChange,@SystemUserID as EnterByIdUser From #temp A    


