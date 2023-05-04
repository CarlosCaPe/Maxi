CREATE procedure [dbo].[st_SaveCustomerBlackList]
(
    @IdCustomer int,
    @XMLCBLRule xml,
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
    @EnterByIdUser int,    
    @IdLenguage int,
    @Notes nvarchar(max) = NULL,    
    @IdCustomerOut int out,
    @HasError bit out,
    @ResultMessage nvarchar(max) out,
	@idElasticCustomer varchar(max) = null out 
)
as
/********************************************************************
<Author> azavala </Author>
<app>AGENT</app>
<Description> Obtiene idelastic al momento de mandar un nuevo cliente a la lista de denegados</Description>

<ChangeLog>
<log Date="18/05/2018" Author="azavala">Creacion</log>
</ChangeLog>
*********************************************************************/
begin try
declare @IdGenericStatusEnable int = 1
declare @Country nvarchar(max) = 'USA'
declare @FullName nvarchar(max) = ltrim(rtrim(@Name))+ltrim(rtrim(@FirstLastName))+ltrim(rtrim(@SecondLastName))
Declare @Rules table    
      (    
       id int    
      ) 

Declare @DocHandle int    
Declare @hasStatus bit    
EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XMLCBLRule      
    
insert into @Rules(id)     
select id    
FROM OPENXML (@DocHandle, '/rules/rule',1)     
WITH (id int)    
    
EXEC sp_xml_removedocument @DocHandle  

if @IdLenguage is null 
    set @IdLenguage=2  

if (isnull(@IdCustomer,0)=0)
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
			@IdCarrier,
			'' ,
			null ,
			'' ,
			'' ,
			'' ,
			GETDATE() ,
			@EnterByIdUser,
			GETDATE()
			)

		set @IdCustomerOut =SCOPE_IDENTITY()
        SET @IdCustomer=@IdCustomerOut
		set @idElasticCustomer = ''
end
else
begin
    set @IdCustomerOut=@IdCustomer
	set @idElasticCustomer = (Select idElasticCustomer from Customer with(nolock) where IdCustomer=@IdCustomer)
end

insert into [CustomerBlackList]
(Notes,IdCustomerBlackListRule,IdCustomer,CustomerName,CustomerFirstLastName,CustomerSecondLastName,CustomerFullName,DateOfCreation,DateOfLastChange,EnterByIdUser,IdGenericStatus)
select @Notes,id,@IdCustomer,@Name,@FirstLastName,@SecondLastName,replace(@FullName,' ',''),getdate(),getdate(),@EnterByIdUser,1 from @Rules where id not in (select idcustomerblacklistrule from [CustomerBlackList] where idcustomer=@IdCustomer and idgenericstatus=1)



SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'CBLIST'),@HasError=0

End Try          
Begin Catch          
 SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'CBLISTERROR'),@HasError=1
 Declare @ErrorMessage nvarchar(max)           
 Select @ErrorMessage=ERROR_MESSAGE()          
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveCustomerBlackList',Getdate(),@ErrorMessage)          
End Catch

