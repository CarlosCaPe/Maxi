/********************************************************************
<Author>Unknow</Author>
<app>Agent</app>
<Description></Description>

<ChangeLog>
<log Date="18/01/2018" Author="azavala">Optimizacion Agente : Se agregan parametros de salida necesarios para una actualizacion en ElasticSearch</log>
<log Date="18/07/2020" Author="adominguez">Se agregan parametros de onfo Adicional M00187</log>
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
</ChangeLog>
*********************************************************************/
CREATE procedure [dbo].[st_SaveCustomer]
    @IdCustomer int out,
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
    --@IsSpanishLanguage bit,

	@CustomerBornDate datetime = null,
	@CustomerIdCustomerIdentificationType int = null,
	@CustomerSSNumber nvarchar(max)='',
	@TypeTaxId int=null,
	@HasTaxId bit=0,
	@HasDuplicatedTaxId bit=0,
    @CustomerOccupation nvarchar(max)= '',
	@CustomerIdOccupation int = 0, /*M00207*/
	@CustomerIdSubcategoryOccupation int = 0,/*M00207*/
	@CustomerSubcategoryOccupationOther nvarchar(max) ='',/*M00207*/   
	@CustomerOccupationDetail nvarchar(max) = '',  
    @CustomerIdentificationNumber nvarchar(max)='',
    @CustomerExpirationIdentification datetime=null,	
	@CustomerIdentificationIdCountry int = null,
    @CustomerIdentificationIdState int = null,

    @IdLenguage int,
    @HasError bit out,
	@Update bit out, /*Optimizacion Agente*/
	@idElasticCustomer varchar(MAX) out, /*Optimizacion Agente*/
    @ResultMessage nvarchar(max) out, /*Optimizacion Agente*/
	@IdDialingCodePhoneNumber int= null
as

declare @IdGenericStatusEnable int
set @IdGenericStatusEnable =1 --Enable
declare @IdGenericStatusDisable int
set @IdGenericStatusDisable =1 --Disable
declare @Country nvarchar(30)
set @Country ='USA'

SET @SecondLastName = isnull(@SecondLastName,'');

if @IdLenguage is null 
    set @IdLenguage=2

Begin try
		if @IdCustomer<>0 and exists(select 1 from dbo.Customer with(nolock) 
											where IdCustomer =@IdCustomer )
			Begin	

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
						  ,[IdCarrier]=@IdCarrier
                          ,[DateOfLastChange] = getdate()
					      ,[EnterByIdUser] = @EnterByIdUser
						  ,[IdCustomerIdentificationType] = @CustomerIdCustomerIdentificationType
						  ,[SSNumber]= @CustomerSSNumber
						  ,[IdTypeTax] = @TypeTaxId
						  ,[HasAnswerTaxId] = @HasTaxId
						  ,[IdTaxDupli] = @HasDuplicatedTaxId
						  ,[Occupation] = @CustomerOccupation
						  ,[IdOccupation] = @CustomerIdOccupation
						  ,[IdSubcategoryOccupation] = @CustomerIdSubcategoryOccupation
						  ,[SubcategoryOccupationOther] = @CustomerSubcategoryOccupationOther
						  ,[IdentificationNumber] = @CustomerIdentificationNumber
						  ,[ExpirationIdentification] = @CustomerExpirationIdentification
						  ,[OccupationDetail] = @CustomerOccupationDetail 
						  ,[IdentificationIdCountry] = @CustomerIdentificationIdCountry      
						  ,[IdentificationIdState] = @CustomerIdentificationIdState 
						  ,[BornDate] = @CustomerBornDate
						  ,[IdDialingCodePhoneNumber] = @IdDialingCodePhoneNumber
					 WHERE IdCustomer = @IdCustomer                
				
				set @Update = 1 /*Optimizacion Agente*/
				set @idElasticCustomer = (select idElasticCustomer from Customer with(nolock) where IdCustomer = @IdCustomer) /*Optimizacion Agente*/
			End
		Else
			Begin
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
					   ,[IdOccupation]
					   ,[IdSubcategoryOccupation]
					   ,[SubcategoryOccupationOther]
					   ,[IdentificationNumber]
					   ,[PhysicalIdCopy]
					   ,[DateOfLastChange]
					   ,[EnterByIdUser]
					   ,[creationdate]
					  ,[IdTypeTax] 
					  ,[HasAnswerTaxId]
					  ,[IdTaxDupli]  
					  ,[ExpirationIdentification] 
					  ,[OccupationDetail] 
					   ,[IdentificationIdCountry]      
					   ,[IdentificationIdState]  
					   ,[IdDialingCodePhoneNumber]
					   )
				 VALUES
					   (@IdAgentCreatedBy ,
					   @CustomerIdCustomerIdentificationType ,
					   @IdGenericStatusEnable ,
					   @Name ,
					   @FirstLastName ,
					   @SecondLastName ,
					   isnull(@Address,'') ,
					   isnull(@City,'') ,
					   isnull(@State,'') ,
					   isnull(@Country,'') ,
					   isnull(@Zipcode,'') ,
					   isnull(@PhoneNumber,'') ,
					   isnull(@CelullarNumber,'') ,
					   @IdCarrier,
					   @CustomerSSNumber ,
					   @CustomerBornDate ,
					   @CustomerOccupation ,
					   @CustomerIdOccupation,
					   @CustomerIdSubcategoryOccupation,
					   @CustomerSubcategoryOccupationOther,
					   @CustomerIdentificationNumber ,
					   '' ,
					   GETDATE() ,
					   @EnterByIdUser,
					   GETDATE()
						, @TypeTaxId
						,@HasTaxId
						,@HasDuplicatedTaxId
						, @CustomerExpirationIdentification
						, @CustomerOccupationDetail 
						,@CustomerIdentificationIdCountry 
						,@CustomerIdentificationIdState						
					    ,@IdDialingCodePhoneNumber
					    )

					set @IdCustomer =SCOPE_IDENTITY()
					set @Update = 0 /*Optimizacion Agente*/
					set @idElasticCustomer = '' /*Optimizacion Agente*/
					
					
			End

		set @HasError =0
		set @ResultMessage = [dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'MESSAGE10')
        SELECT @ResultMessage, @IdCustomer, @Update, @idElasticCustomer
End try
Begin Catch
		 Declare @ErrorMessage nvarchar(max)         
		 Select @ErrorMessage=ERROR_MESSAGE()        
		 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_SaveCustomer]: Customer: ' + @Name + ' - ' + @FirstLastName + ' - ' + @SecondLastName +', ErrorLine: ' + CONVERT(varchar, ERROR_LINE()) ,Getdate(),@ErrorMessage) 
		set @HasError =1
		--set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,11)
        SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE11')
		
End catch

return;

