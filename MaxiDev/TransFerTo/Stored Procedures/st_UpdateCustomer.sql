/****************************************************
<Author>Aldo Morán Márquez</Author>
<app>Agent</app>
<Description>This SP Insert a new check in the corresponding Table and also checks if the names has holds.</Description>

<ChangeLog>
<log Date="20/03/2015" Author="amoran"> Creación </log>
<log Date="02/02/2017" Author="fgonzalez"> Se realiza cambio #1 para que encuentre el ultimo fee registrado al agente.</log>
<log Date="2018/01/18" Author="azavala">Optimizacion Agente : Se agrega @idElasticCustomer e @idAgent como output para posteriormente guardar datos en elastic</log>
</ChangeLog>
*****************************************************/
CREATE procedure [TransferTo].[st_UpdateCustomer]
(
	@IdCustomer int,
    @CustomerCelullarNumber nvarchar(max),
    @EnterByIdUser int,
	@Name nvarchar(max),	
	@FirstLastName nvarchar(max),
	@SecondLastName nvarchar(max),    
    @HasError bit out,
	@Message varchar(max) out,
	@idElasticCustomer varchar(max) output, /*Optimizacion Agente*/
	@idAgent int output /*Optimizacion Agente*/
)
as
Begin Try

    if (@IdCustomer <=0)
	begin
		set @HasError = 1
		set @Message = 'The customer should be inserted not updated, The IdCustomer was equals 0.'
	end
	else
	begin
		if (Len(isnull(@Name,''))=0)
		begin
			set @Name = 'UNKNOWN'
		end

        exec st_SaveCustomerMirror @IdCustomer 
    
		update dbo.Customer set
		CelullarNumber = case when ltrim(rtrim(isnull(@CustomerCelullarNumber,'')))='' then CelullarNumber else @CustomerCelullarNumber end,
		Name = case when ltrim(rtrim(isnull(@Name,'')))='' then Name else @Name end,
		FirstLastName = case when ltrim(rtrim(isnull(@FirstLastName,'')))='' then FirstLastName else @FirstLastName end,
		SecondLastName = case when ltrim(rtrim(isnull(@SecondLastName,'')))='' then SecondLastName else @SecondLastName end,
		DateOfLastChange = getdate(),
		EnterByIdUser = @EnterByIdUser
		where idCustomer = @IdCustomer          

		set @HasError = 0
		set @idElasticCustomer = (select top 1 idElasticCustomer from Customer with (nolock) where IdCustomer = @IdCustomer) /*Optimizacion Agente*/
		SET @idAgent = (select top 1 IdAgentCreatedBy from Customer with (nolock) where IdCustomer = @IdCustomer) /*Optimizacion Agente*/
	end 
End Try
Begin Catch
	Set @HasError=1	
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_UpdateCustomer',Getdate(),@ErrorMessage)
End Catch
