/********************************************************************
<Author>Unknow</Author>
<app>Agent</app>
<Description></Description>

<ChangeLog>
<log Date="20/03/2015" Author="amoran"> Creación </log>
<log Date="02/02/2017" Author="fgonzalez"> Se realiza cambio #1 para que encuentre el ultimo fee registrado al agente.</log>
<log Date="18/01/2018" Author="azavala">Optimizacion Agente : Se agregan parametros de salida necesarios para una actualizacion en ElasticSearch</log>
<log Date="03/06/2019" Author="azavala">set @Update when VIP Card exist :: Ref: 030620191510_azavala </log>
<log Date="13/01/2022" Author="gnegrete">se agrega campo @IdDialingCodePhoneNumber para customer </log>
</ChangeLog>
*********************************************************************/
CREATE procedure [dbo].[st_SaveCustomerNewAgent]
	@IdCustomer int,
    @IdCustomerOut int out,
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
    @IdCarrier  int,
	@CardNumber varchar(20),
    @EnterByIdUser int,
    --@IsSpanishLanguage bit,
    @IdLenguage int,
    @HasError bit out,
	@Update bit out, /*Optimizacion Agente*/
	@idElasticCustomer varchar(MAX) out, /*Optimizacion Agente*/
    @ResultMessage nvarchar(max) out, /*Optimizacion Agente*/
	@IdDialingCodePhoneNumber int
as

declare @IdGenericStatusEnable int
set @IdGenericStatusEnable=1 --Enable
declare @IdGenericStatusDisable int
set @IdGenericStatusDisable=2 --Disable
declare @Country nvarchar(30)
set @Country ='USA'

if @IdLenguage is null 
    set @IdLenguage=2

if @CardNumber is null
BEGIN
	IF EXISTS(select 1 from CardVIP with(nolock) where IdGenericStatus = @IdGenericStatusEnable and IdCustomer=@IdCustomer)
		SET @CardNumber = (select top 1 CardNumber from CardVIP with(nolock) where IdGenericStatus = @IdGenericStatusEnable and IdCustomer=@IdCustomer)
	ELSE
		set @CardNumber = ''
END

Begin try
		if @CardNumber<>''
			begin
			if exists (select 1 from cardvip with(nolock) where CardNumber = @CardNumber and IdGenericStatus = @IdGenericStatusDisable)
			begin
				set @HasError = 1
				SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'CARDVIPE1'), @IdCustomerOut = @IdCustomer, @idElasticCustomer='', @Update=0
				return;
			end
		end

		if @IdCustomer<>0 and exists(select 1 from dbo.Customer with(nolock) where IdCustomer =@IdCustomer )
			Begin				
				if @CardNumber<>'' and not exists(select 1 from dbo.CardVIP with(nolock) where IdCustomer = @IdCustomer)
				begin
					if exists (select 1 from cardvip with(nolock) where CardNumber = @CardNumber and IdGenericStatus = @IdGenericStatusEnable)
					begin
						set @HasError = 1
						SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE03'), @idElasticCustomer='', @Update=0, @IdCustomerOut = @IdCustomer
						return;
					end
					else
					begin
						INSERT INTO [dbo].[CardVIP] ([IdCustomer], [CardNumber], [IdGenericStatus]) VALUES (@IdCustomer, @CardNumber, @IdGenericStatusEnable)
					end
				end
				else
				begin
					if (select CardNumber from CardVIP with(nolock) where IdGenericStatus = @IdGenericStatusEnable and IdCustomer=@IdCustomer) <> @CardNumber
					begin
						set @HasError = 1
						SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE72'), @IdCustomerOut = @IdCustomer, @idElasticCustomer='', @Update=0
						return;
					end
				end
				                
				exec st_SaveCustomerMirror @IdCustomer
				
				
				UPDATE [dbo].[Customer]
					   SET [IdAgentCreatedBy] = @IdAgentCreatedBy
						  ,[IdGenericStatus] = @IdGenericStatusEnable
						  ,[Name] =@Name
						  ,[FirstLastName] = @FirstLastName
						  ,[SecondLastName] = @SecondLastName
						  ,[Address] = @Address
						  ,[City] = @City
						  ,[State] = @State
						  ,[Country] = @Country
						  ,[Zipcode] = @Zipcode
						  ,[PhoneNumber] = @PhoneNumber
						  ,[CelullarNumber] = @CelullarNumber
						  ,[IdDialingCodePhoneNumber] = @IdDialingCodePhoneNumber
						  ,[IdCarrier] = @IdCarrier
                          ,[DateOfLastChange] = getdate()
					      ,[EnterByIdUser] = @EnterByIdUser
					 WHERE IdCustomer = @IdCustomer 

				set @Update = 1 /*Optimizacion Agente*/
				set @idElasticCustomer = (select idElasticCustomer from Customer with(nolock) where IdCustomer = @IdCustomer) /*Optimizacion Agente*/
			End
		Else
			Begin
				if @CardNumber<>'' and exists (select 1 from cardvip with(nolock) where CardNumber = @CardNumber and IdGenericStatus = @IdGenericStatusEnable)
				begin
					set @HasError = 1
					set @Update=0 -- 030620191510_azavala
					SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE03')
					return;
				end

				INSERT INTO [dbo].[Customer]
						([IdAgentCreatedBy]
						,[IdCustomerIdentificationType]
						,[IdGenericStatus]
						,[Name]
						,[FirstLastName]
						,[SecondLastName]
						,[Address]
						,[City]
						,[State]
						,[Country]
						,[Zipcode]
						,[PhoneNumber]
						,[CelullarNumber]
						,[IdDialingCodePhoneNumber]
						,[IdCarrier]
						,[SSNumber]
						,[BornDate]
						,[Occupation]
						,[IdentificationNumber]
						,[PhysicalIdCopy]
						,[DateOfLastChange]
						,[EnterByIdUser]
						,[creationdate]
						
						)
					VALUES
						(@IdAgentCreatedBy,
						null,
						@IdGenericStatusEnable,
						@Name,
						@FirstLastName,
						@SecondLastName,
						@Address,
						@City,
						@State,
						@Country,
						@Zipcode,
						@PhoneNumber,
						@CelullarNumber,
						@IdDialingCodePhoneNumber,
						@IdCarrier,
						'',
						null,
						'',
						'',
						'',
						GETDATE() ,
						@EnterByIdUser,
						GETDATE())

						set @IdCustomer =SCOPE_IDENTITY()

						if @CardNumber<>''
						begin
							
							INSERT INTO [dbo].[CardVIP] 
								([IdCustomer],
								[CardNumber],
								[IdGenericStatus])
							VALUES
								(@IdCustomer,
								@CardNumber,
								@IdGenericStatusEnable)
						end

						set @Update = 0 /*Optimizacion Agente*/
						set @idElasticCustomer = '' /*Optimizacion Agente*/
			END
		set @HasError = 0
		set @ResultMessage = [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE10')
		set @IdCustomerOut = @IdCustomer
        SELECT @ResultMessage, @IdCustomerOut, @Update, @idElasticCustomer
End try
Begin Catch
		 Declare @ErrorMessage nvarchar(max)         
		 Select @ErrorMessage=ERROR_MESSAGE()        
		 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_SaveCustomerNewAgent]: @IdCustomer: ' + CONVERT(varchar, ISNULL(@IdCustomer, -1)) + ', CustomerName: ' + ISNULL(@Name, 'NULL') + ' - ' + ISNULL(@FirstLastName, 'NULL') + ' - ' + ISNULL(@SecondLastName, 'NULL') + ', @CardNumber: ' + ISNULL(@CardNumber, 'NULL') +', ErrorLine: ' + CONVERT(varchar, ERROR_LINE()),Getdate(),@ErrorMessage) 
		set @HasError =1
		--set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,11)
        SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE11')
		
End catch

return;
