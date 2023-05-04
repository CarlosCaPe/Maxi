
CREATE procedure [dbo].[st_AssignCasdVIP]
    @IdCustomer INT OUT,
    @IdAgentCreatedBy int,
    @Name nvarchar(max),
    @FirstLastName nvarchar(max),
    @SecondLastName nvarchar(max),
    @Address nvarchar(max),
    @City nvarchar(max),
    @State nvarchar(max),
    @Zipcode nvarchar(max),
    @PhoneNumber nvarchar(max),
    @CelullarNumber nvarchar(max),
    @CardNumber varchar(20),
    @EnterByIdUser int,
    @SaveMirror bit, -- new RMM
    @IdLenguage int,
    @HasError bit out,
    @ResultMessage nvarchar(max) out,
	@Update bit output, /*Optimizacion Agente*/
	@idElasticCustomer varchar(max) output, /*Optimizacion Agente*/
	@IdCustomerOut int output /*Optimizacion Agente*/

as
/********************************************************************
<Author>Not Known</Author>
<app>MaxiAgente</app>
<Description></Description>

<ChangeLog>
<log Date="2018/01/03" Author="adominguez"> 0000873: Datos de beneficiario borrados (Se agrego el parametro @IdCustomer al SELECT)</log>
<log Date="2018/01/18" Author="azavala"> Optimizacion Agente : Se agregaron parametros de salida necesarios para la actualizacion de Customer en ElastiSearch</log>
</ChangeLog>
********************************************************************/
declare @IdGenericStatusEnable int

set @IdGenericStatusEnable =1 --Enable

declare @IdGenericStatusDisable int

set @IdGenericStatusDisable =2 --Disable

declare @Country nvarchar(30)

set @Country ='USA'


if @IdLenguage is null 
    set @IdLenguage=2


Begin try

	if exists (select top 1 1 from cardvip where CardNumber = @CardNumber and IdGenericStatus = @IdGenericStatusDisable)

	begin

		set @HasError = 1
		set @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'CARDVIPE1')
		SELECT @ResultMessage, @IdCustomer

		return;
	end

	if exists(select 1 from dbo.CardVIP where CardNumber = @CardNumber AND IdGenericStatus = @IdGenericStatusEnable)
	Begin
	-- New RMM
		if @SaveMirror = 1 and exists(select 1 from dbo.CardVIP where CardNumber = @CardNumber AND IdGenericStatus = @IdGenericStatusEnable and IdCustomer = @IdCustomer)
		begin
			exec st_SaveCustomerMirror @IdCustomer

			UPDATE [dbo].[Customer] 

			SET [IdAgentCreatedBy] = @IdAgentCreatedBy,
				[Name] = @Name,
				[FirstLastName] = @FirstLastName,
				[SecondLastName] = @SecondLastName,
				[Address] = @Address,
				[City] = @City,
				[State] = @State,
				[Zipcode] = @Zipcode,
				[PhoneNumber] = @PhoneNumber,
				[CelullarNumber] = @CelullarNumber,
				[DateOfLastChange] = getdate(),
				[EnterByIdUser] = @EnterByIdUser
			WHERE IdCustomer = @IdCustomer    

			set @HasError = 0
			set @Update = 1 /*Optimizacion Agente*/
			set @idElasticCustomer = (select top 1 idElasticCustomer from Customer with (nolock) where IdCustomer=@IdCustomer) /*Optimizacion Agente*/
			SET @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE01') 
			set @IdCustomerOut = @IdCustomer /*Optimizacion Agente*/

			SELECT @ResultMessage,@IdCustomer, @Update,@idElasticCustomer,@IdCustomerOut

		end 
		-- End New RMM
		else
		begin
			set @HasError = 1
			SET @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE03') 
			set @Update = 0 /*Optimizacion Agente*/
			set @idElasticCustomer = '' /*Optimizacion Agente*/ 
			set @IdCustomerOut = @IdCustomer /*Optimizacion Agente*/
			SELECT @ResultMessage,@IdCustomer,@Update,@idElasticCustomer,@IdCustomerOut

		end
		return;	

	End

	if @IdCustomer <> 0 and exists(select 1 from dbo.Customer where IdCustomer = @IdCustomer)
	Begin
		UPDATE [dbo].[CardVIP] SET [IdGenericStatus] = @IdGenericStatusDisable WHERE IdCustomer = @IdCustomer 
		INSERT INTO [dbo].[CardVIP] ([IdCustomer], [CardNumber], [IdGenericStatus]) VALUES (@IdCustomer, @CardNumber, @IdGenericStatusEnable)
		exec st_SaveCustomerMirror @IdCustomer

			UPDATE [dbo].[Customer] 
			SET [IdAgentCreatedBy] = @IdAgentCreatedBy,
				[Name] = @Name,
				[FirstLastName] = @FirstLastName,
				[SecondLastName] = @SecondLastName,
				[Address] = @Address,
				[City] = @City,
				[State] = @State,
				[Zipcode] = @Zipcode,
				[PhoneNumber] = @PhoneNumber,
				[CelullarNumber] = @CelullarNumber,
				[DateOfLastChange] = getdate(),
				[EnterByIdUser] = @EnterByIdUser
			WHERE IdCustomer = @IdCustomer
			
			set @Update = 1 /*Optimizacion Agente*/
			set @IdCustomerOut = @IdCustomer /*Optimizacion Agente*/
			set @idElasticCustomer = (select top 1 idElasticCustomer from Customer with (nolock) where IdCustomer=@IdCustomer)   /*Optimizacion Agente*/
	End

	Else
		Begin

			IF ISNULL(@IdAgentCreatedBy, 0) = 0
			BEGIN
				INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage)
				VALUES('st_AssignCasdVIP: @CustomerName=' + @Name + '-' + @FirstLastName + '-' + @SecondLastName + ', @[IdAgentCreatedBy=' + CONVERT(varchar, @IdAgentCreatedBy), GETDATE(), 'Error por no traer id de agente')
			END

			INSERT INTO [dbo].[Customer]
				([IdAgentCreatedBy],
				[IdCustomerIdentificationType],
				[IdGenericStatus],
				[Name],
				[FirstLastName],
				[SecondLastName],
				[Address],
				[City],
				[State],
				[Country],
				[Zipcode],
				[PhoneNumber],
				[CelullarNumber],
				[SSNumber],
				[BornDate],
				[Occupation],
				[IdentificationNumber],
				[PhysicalIdCopy],
				[DateOfLastChange],
				[EnterByIdUser],
				[creationdate]
				)
			VALUES
				(@IdAgentCreatedBy ,
				null ,
				@IdGenericStatusEnable ,
				@Name ,
				@FirstLastName ,
				@SecondLastName ,
				@Address ,
				@City ,
				@State ,
				@Country ,
				@Zipcode ,
				@PhoneNumber ,
				@CelullarNumber ,
				'' ,
				null ,
				'' ,
				'' ,
				'' ,
				GETDATE() ,
				@EnterByIdUser,
				GETDATE() )

			set @IdCustomer = SCOPE_IDENTITY()
			set @Update = 0 /*Optimizacion Agente*/
			set @IdCustomerOut = @IdCustomer /*Optimizacion Agente*/
			set @idElasticCustomer = '' /*Optimizacion Agente*/

			INSERT INTO [dbo].[CardVIP] 
				([IdCustomer],
				[CardNumber],
				[IdGenericStatus])

			VALUES
				(@IdCustomer,
				@CardNumber,
				@IdGenericStatusEnable)

		End

		set @HasError = 0
		SET @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE01')
        SELECT @ResultMessage, @IdCustomer, @Update, @idElasticCustomer,@IdCustomerOut

End try

Begin Catch
	set @HasError = 1
	SET @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE02')
	set @Update = 0
	set @idElasticCustomer = ''
	set @IdCustomer = 0
	set @IdCustomerOut = 0
    SELECT @ResultMessage, @IdCustomer, @Update,@idElasticCustomer
	Declare @ErrorMessage NVARCHAR(MAX)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             

    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AssignCasdVIP',GETDATE(),@ErrorMessage)

End catch




