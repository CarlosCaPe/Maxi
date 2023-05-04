/********************************************************************
<Author>Unknow</Author>
<app>Agent</app>
<Description></Description>

<ChangeLog>
<log Date="2018/01/18" Author="azavala"> Optimizacion Agente : Se agregaron parametros de salida necesarios para la actualizacion de Customer en ElastiSearch</log>
</ChangeLog>
********************************************************************/
CREATE procedure [TransFerTo].[st_CreateCustomer]
(
    @CustomerCelullarNumber nvarchar(max),
    @IdAgent int,
    @EnterByIdUser int,
	@Name nvarchar(max),	
	@FirstLastName nvarchar(max),
	@SecondLastName nvarchar(max),
    @IdCustomerOut int out,
    @HasError bit out,
	@IdElasticCustomer varchar(max) output /*Optimizacion Agente*/
)
as

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Begin Try

    if ltrim(rtrim(isnull(@CustomerCelullarNumber,'')))!=''
    begin
        select top 1 @IdCustomerOut=idcustomer from customer where CelullarNumber=@CustomerCelullarNumber and IdGenericStatus=1 and Name=@Name and FirstLastName=@FirstLastName and SecondLastName=@SecondLastName order by DateOfLastChange desc

		set @IdElasticCustomer = (select top 1 idElasticCustomer from Customer where CelullarNumber=@CustomerCelullarNumber and IdGenericStatus=1 and Name=@Name and FirstLastName=@FirstLastName and SecondLastName=@SecondLastName order by DateOfLastChange desc) /*Optimizacion Agente*/
    end

	if (Len(isnull(@Name,''))=0)
	begin
		set @Name = 'UNKNOWN'
	end
    
    if @IdCustomerOut is null
    begin
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
           ,[SSNumber]
           ,[BornDate]
           ,[Occupation]
           ,[IdentificationNumber]
           ,[PhysicalIdCopy]
           ,[DateOfLastChange]
           ,[EnterByIdUser]
           ,[ExpirationIdentification]
           ,[IdCarrier]
           ,[IdentificationIdCountry]
           ,[IdentificationIdState]
           ,[SentAverage]
           ,[FullName]
		   ,[creationdate]
		   )
     VALUES
           (@IdAgent
           ,null
           ,1
           ,@Name
           ,@FirstLastName
           ,@SecondLastName
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,@CustomerCelullarNumber
           ,''
           ,null
           ,''
           ,''
           ,null
           ,getdate()
           ,@EnterByIdUser
           ,null
           ,null
           ,null
           ,null
           ,0
           ,''
		   ,GETDATE()
		   )
        set @IdCustomerOut=scope_identity()
		set @IdElasticCustomer = '' /*Optimizacion Agente*/
    end
    
    set @HasError = 0
End Try
Begin Catch
	Set @HasError=1	
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_CreateCustomer',Getdate(),@ErrorMessage)
End Catch
