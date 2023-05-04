--<SchemaPayers>
--   <SchemaPayer>
--        <IdAgent>1</IdAgent>
--        <IdSchema>1</IdSchema>
--        <IdPayer>340</IdPayer>        
--        <IdCountryCurrency>10</IdCountryCurrency>
--        <Exrate>19.22</Exrate>
--   </SchemaPayer>
--</SchemaPayers>


CREATE procedure [dbo].[st_SaveSpecialExRateXML]
(
    @ExRateXml xml ,
    @IdUser int ,
    @IsSpanishLanguage bit , 
    @HasError bit out,
    @MessageOUT varchar(max) out   
)
as
--declaracion de variables
DECLARE  @DocHandle INT 
declare  @i int
declare @IdAgent int = 0 , @IdAgentGroup int = 0
declare @IdSchema int,@IdPayer int,@IdCountryCurrency int,	@Exrate money, @DifRefExRate varchar(10)
declare @TempIdAgent int , @TempId int, @DateExiration datetime, @DaysDiference int,  @DateActual datetime = GETDATE()


Create Table #temp      
(      
id int identity(1,1),      
IdAgent int    
) 

Create Table #ExRate
(
    Id int identity(1,1),
	IdAgent int,
	IdSchema int,
	IdPayer int,
	IdCountryCurrency int,
	Exrate money,
	DifRefExRate varchar(10)
)

begin try

--Inicializar Variables
Set @HasError=0
--Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,79)   

EXEC sp_xml_preparedocument @DocHandle OUTPUT,@ExRateXml   

INSERT INTO #ExRate (IdAgent, IdSchema,IdPayer,IdCountryCurrency,Exrate, DifRefExRate)
SELECT IdAgent, IdSchema,IdPayer,IdCountryCurrency,Exrate, DifRefExRate 
FROM OPENXML (@DocHandle, '/SchemaPayers/SchemaPayer',2)
With (
		IdAgent int,
		IdSchema int,
		IdPayer int,
		IdCountryCurrency int,
		Exrate money,
		DifRefExRate varchar(10)
	)

EXEC sp_xml_removedocument @DocHandle 


if @IdAgent = 0
Begin
set @IdAgent = (Select Top 1 IdAgent from #ExRate)
	SELECT @DateExiration = DateOfLastChange from RefExRateByGroup with(nolock) where IdAgent = @IdAgent

	SELECT @DaysDiference = DATEDIFF(day, @DateExiration, @DateActual);

	if (@DaysDiference >= 1)
	begin
	delete from RefExRateByGroup where IdAgent = @IdAgent
	end
End


while exists (select top 1 1 from #ExRate)
	Begin

		select top 1 @i= Id, @IdAgent = IdAgent , @IdSchema = IdSchema, @IdPayer = IdPayer , @IdCountryCurrency = IdCountryCurrency, @Exrate = Exrate, @DifRefExRate = DifRefExRate
		from #ExRate where IdAgent = @IdAgent

		if exists(SELECT * FROM RefExRateByGroup with(nolock) where IdAgent = @IdAgent AND IdPayer = @IdPayer AND IdCountryCurrency = @IdCountryCurrency)
		BEGIN

		UPDATE RefExRateByGroup SET RefExRateByGroup = @Exrate, DateOfLastChange = GETDATE(), DifRefExRate = @DifRefExRate where IdAgent = @IdAgent AND IdPayer = @IdPayer AND IdCountryCurrency = @IdCountryCurrency AND IdAgentSchema = @IdSchema
		
		END
		ELSE
		BEGIN

		insert into RefExRateByGroup (IdAgent, IdAgentSchema, IdPayer,IdCountryCurrency, RefExRateByGroup,DateOfLastChange, DifRefExRate)
		values (@IdAgent,@IdSchema,@IdPayer,@IdCountryCurrency,@Exrate, GETDATE(), @DifRefExRate)

		END

		delete from #ExRate  where id=@i

	end   

  INSERT INTO [MAXILOG].[dbo].[LogRefExRateByGroup] ([XmlData] ,[IdPrimaryAgent],[IdUser],[DateOfLastChange]) values (@ExRateXml , @IdAgent, @IdUser, getdate())

End Try
Begin Catch
 Set @HasError=1                                                                                   
 Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,80)  
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveSpecialExRateXML',Getdate(),ERROR_MESSAGE())    
End Catch