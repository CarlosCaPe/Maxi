/********************************************************************
<Author> Mhinojo </Author>
<app> WebApi </app>
<Description> Sp que actualiza o inserta en el detalle de internal sales monitor </Description>

<ChangeLog>
<log Date="05/06/2017" Author="Mhinojo">Creation</log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [InternalSalesMonitor].[st_UpdateDetails]
(	
	@IdDetail int,
	@IdAgent int,
	@ContacName nvarchar(max),
	@SendFax bit,
	@SundayStart time,
	@SundayEnd time,
	@SundayClosed bit,
	@MondayStart time,
	@MondayEnd time,
	@MondayClosed bit,
	@TuesdayStart time,
	@TuesdayEnd time,
	@TuesdayClosed bit,
	@WednesdayStart time,
	@WednesdayEnd time,
	@WednesdayClosed bit,
	@ThursdayStart time,
	@ThursdayEnd time,
	@ThursdayClosed bit,
	@FridayStart time,
	@FridayEnd time,
	@FridayClosed bit,
	@SaturdayStart time,
	@SaturdayEnd time,
	@SaturdayClosed bit,
	@EnterByIdUser int,
	@XMLExchangeRate xml, 
    @HasError bit out,
	@Message varchar(max) out
)
as
Begin Try

set @HasError = 0;


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
	EXEC sp_xml_removedocument @DocHandle 
 
SET @IdDetail = ISNULL((SELECT TOP 1 IdDetail FROM [InternalSalesMonitor].[Details] WHERE IdAgent = @IdAgent ORDER BY IdDetail DESC),0)

IF(@IdDetail = 0)
BEGIN	
	INSERT INTO [InternalSalesMonitor].[Details]
           ([IdAgent]
           ,[ContacName]
           ,[SendFax]
           ,[SundayStart]
           ,[SundayEnd]
           ,[SundayClosed]
           ,[MondayStart]
           ,[MondayEnd]
           ,[MondayClosed]
           ,[TuesdayStart]
           ,[TuesdayEnd]
           ,[TuesdayClosed]
           ,[WednesdayStart]
           ,[WednesdayEnd]
           ,[WednesdayClosed]
           ,[ThursdayStart]
           ,[ThursdayEnd]
           ,[ThursdayClosed]
           ,[FridayStart]
           ,[FridayEnd]
           ,[FridayClosed]
           ,[SaturdayStart]
           ,[SaturdayEnd]
           ,[SaturdayClosed]
           ,[EnterByIdUser]
           ,[CreationDate]
           ,[LastChangeByIdUser]
           ,[DateOfLastChange])
     VALUES
           (@IdAgent
           ,@ContacName
           ,@SendFax
           ,@SundayStart
           ,@SundayEnd
           ,@SundayClosed
           ,@MondayStart
           ,@MondayEnd
           ,@MondayClosed
           ,@TuesdayStart
           ,@TuesdayEnd
           ,@TuesdayClosed
           ,@WednesdayStart
           ,@WednesdayEnd
           ,@WednesdayClosed
           ,@ThursdayStart
           ,@ThursdayEnd
           ,@ThursdayClosed
           ,@FridayStart
           ,@FridayEnd
           ,@FridayClosed
           ,@SaturdayStart
           ,@SaturdayEnd
           ,@SaturdayClosed
           ,@EnterByIdUser
           --,@CreationDate
		   ,GETDATE()
           --,@LastChangeByIdUser
		   ,NULL
           --,@DateOfLastChange
		   ,NULL);

	Exec [InternalSalesMonitor].[st_UpdateAgentSchemaDetails] @IdAgent, @EnterByIdUser, @XMLExchangeRate, @HasError out, @Message out;
END
ELSE
BEGIN
	UPDATE [InternalSalesMonitor].[Details]
	   SET 
		--[IdAgent] = @IdAgent,
		  [ContacName] = @ContacName
		  ,[SendFax] = @SendFax
		  ,[SundayStart] = @SundayStart
		  ,[SundayEnd] = @SundayEnd
		  ,[SundayClosed] = @SundayClosed
		  ,[MondayStart] = @MondayStart
		  ,[MondayEnd] = @MondayEnd
		  ,[MondayClosed] = @MondayClosed
		  ,[TuesdayStart] = @TuesdayStart
		  ,[TuesdayEnd] = @TuesdayEnd
		  ,[TuesdayClosed] = @TuesdayClosed
		  ,[WednesdayStart] = @WednesdayStart
		  ,[WednesdayEnd] = @WednesdayEnd
		  ,[WednesdayClosed] = @WednesdayClosed
		  ,[ThursdayStart] = @ThursdayStart
		  ,[ThursdayEnd] = @ThursdayEnd
		  ,[ThursdayClosed] = @ThursdayClosed
		  ,[FridayStart] = @FridayStart
		  ,[FridayEnd] = @FridayEnd
		  ,[FridayClosed] = @FridayClosed
		  ,[SaturdayStart] = @SaturdayStart
		  ,[SaturdayEnd] = @SaturdayEnd
		  ,[SaturdayClosed] = @SaturdayClosed

		  --,[EnterByIdUser] = @EnterByIdUser
		  --,[CreationDate] = @CreationDate

		  --,[LastChangeByIdUser] = @LastChangeByIdUser
		  ,[LastChangeByIdUser] = @EnterByIdUser

		  --,[DateOfLastChange] = @DateOfLastChange
		  ,[DateOfLastChange] = GETDATE()

	 WHERE [IdDetail] = @IdDetail;

	Exec [InternalSalesMonitor].[st_UpdateAgentSchemaDetails] @IdAgent, @EnterByIdUser, @XMLExchangeRate, @HasError out, @Message out;
END
SET @Message ='The detail was successfully saved.'
End Try
Begin Catch
	Set @HasError = 1;
	Declare @ErrorMessage nvarchar(max);
	Select @ErrorMessage = ERROR_MESSAGE();
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('InternalSalesMonitor.st_UpdateDetails',Getdate(),@ErrorMessage);
End Catch
