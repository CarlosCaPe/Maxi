CREATE procedure [dbo].[st_SaveAgentSchemaSpread]  
(  
    @IdAgentSchema int,  
    @IdAgent int,  
    @Spread Money,   
    @EndDateSpread DateTime,  
    @IdUser int,  
    @IsSpanishLanguage bit,  
    @HasError bit out,            
    @Message varchar(max) out       
)  
as  
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description>/Description>

<ChangeLog>
<log Date="05/04/2017" Author="dalmeida">Se agrega Log a AgentSchemaDetailSpreadLog</log>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

Set nocount on  
Begin Try   
  
Declare @tempsSpread as table(
	IdPayerConfig int,
	SpreadValue money
);

--Update RelationAgentSchema set Spread=@Spread,EndDateSpread=@EndDateSpread  
--where IdAgent=@IdAgent and IdAgentSchema=@IdAgentSchema  

UPDATE AGENTSCHEMA SET Spread=@Spread,EndDateSpread=@EndDateSpread
where IdAgentSchema=@IdAgentSchema;  
  
If  @@ROWCOUNT=0  
Begin  
 Set @HasError=1            
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,52)  
 Return    
End   
  
Insert into LogAgentSchemaSpread   
(  
IdAgentSchema,  
IdAgent,  
Spread,  
EndDateSpread,  
EnterByIdUser,  
EnterDate  
)  
Values  
(  
@IdAgentSchema,  
@IdAgent,  
@Spread,  
@EndDateSpread,  
@IdUser,  
GETDATE()  
);  

INSERT INTO @tempsSpread SELECT IdPayerConfig, CurrentSpreadValue FROM AgentSchemaDetailSpreadLog with(nolock) where IdAgentSchema=@IdAgentSchema;  

INSERT AgentSchemaDetailSpreadLog (IdAgentSchema, IdPayerConfig, IdPreviousSpreadValue, PreviousSpreadValue, IdCurrentSpreadValue, CurrentSpreadValue, DateOfLastChange, EnterByIdUser)
		SELECT @IdAgentSchema, tm.IdPayerConfig, IdCurrentSpreadValue, CurrentSpreadValue, NULL, @Spread, GETDATE(), @IdUser
			FROM @tempsSpread tm
			INNER JOIN AgentSchemaDetailSpreadLog ag with(nolock) ON tm.IdPayerConfig = ag.IdPayerConfig
			WHERE ag.IdAgentSchema = @IdAgentSchema;

 Set @HasError=0            
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,41)            
End Try            
Begin Catch            
 Set @HasError=1            
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)            
 Declare @ErrorMessage nvarchar(max)             
 Select @ErrorMessage=ERROR_MESSAGE()            
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveAgentSchemaSpread',Getdate(),@ErrorMessage)            
End Catch
