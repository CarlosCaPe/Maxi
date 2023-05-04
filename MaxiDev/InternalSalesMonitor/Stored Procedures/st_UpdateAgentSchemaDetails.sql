CREATE procedure [InternalSalesMonitor].[st_UpdateAgentSchemaDetails]
(		
	@IdAgent int,	
	@EnterByIdUser int,
	@XMLExchangeRate xml, 
    @HasError bit out,
	@Message varchar(max) out
)
as
Begin Try

set @HasError = 0;
SEt @Message = '';

/*Example of xml structure*/
--<AgentSchemaDetail>
--	<IdAgentSchemaDetail>1</IdAgentSchemaDetail>
--	<IdAgentSchemaDetail>2</IdAgentSchemaDetail>
--	<IdAgentSchemaDetail>3</IdAgentSchemaDetail>
--</AgentSchemaDetail>
/**/
	Declare @Temp Table 
	( 
		Id int identity(1,1), 
		IdAgentSchemaDetail Int
	) 
  
	Declare @DocHandle int 
	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XMLExchangeRate 
	Insert into @Temp (IdAgentSchemaDetail) 
	SELECT IdAgentSchemaDetail FROM OPENXML (@DocHandle, '//AgentSchemaDetail/IdAgentSchemaDetail',1) 
		WITH (
		 [IdAgentSchemaDetail] int '.'
		) 
	EXEC sp_xml_removedocument @DocHandle;
 
	/*Deshabilitar todo los esquemas*/
	Update InternalSalesMonitor.AgentSchemaDetails 
	set IsEnabled = 0
		,[EnterByIdUser]  = @EnterByIdUser
		,[DateOfLastChange] = GETDATE()
	where IdAgentSchemaDetail in (
									SELECT B.IdAgentSchemaDetail 
										FROM AgentSchema AS A WITH (NOLOCK)
											INNER JOIN AgentSchemaDetail AS B WITH (NOLOCK) ON (A.IdAgentSchema =B.IdAgentSchema) WHERE A.IdAgent = @IdAgent)
	--SEt @Message = ''

	/*Re-Activar los esquemas existentes*/
	Update InternalSalesMonitor.AgentSchemaDetails 
		set	IsEnabled = 1
			,[EnterByIdUser]  = @EnterByIdUser
			,[DateOfLastChange] = GETDATE()
	where IdAgentSchemaDetail in (SELECT IdAgentSchemaDetail FROM @Temp);
	--SEt @Message = ''

	/*Agregar esquemas nuevos*/
	Insert into InternalSalesMonitor.AgentSchemaDetails ([IdAgentSchemaDetail],[IsEnabled],[EnterByIdUser],[DateOfLastChange])
		SELECT IdAgentSchemaDetail,1 ,@EnterByIdUser,GETDATE() FROM @Temp
			Where IdAgentSchemaDetail not in (select IdAgentSchemaDetail from InternalSalesMonitor.AgentSchemaDetails);
	--SEt @Message = ''

End Try
Begin Catch
	Set @HasError = 1;
	Declare @ErrorMessage nvarchar(max);
	Select @ErrorMessage = ERROR_MESSAGE();
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('InternalSalesMonitor.st_UpdateAgentSchemaDetails',Getdate(),@ErrorMessage);
End Catch

