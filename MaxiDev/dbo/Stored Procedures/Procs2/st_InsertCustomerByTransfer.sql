CREATE Procedure [dbo].[st_InsertCustomerByTransfer]
(      
@IdCustomer int,      
@IdAgentCreatedBy int,      
@IdCustomerIdentificationType int,      
@IdGenericStatus int,      
@Name nvarchar(max),      
@FirstLastName nvarchar(max),      
@SecondLastName nvarchar(max),      
@Address nvarchar(max),      
@City nvarchar(max),      
@State nvarchar(max),      
@Country nvarchar(max),      
@Zipcode nvarchar(max),      
@PhoneNumber nvarchar(max),      
@CelullarNumber nvarchar(max),      
@SSNumber nvarchar(max),      
@BornDate datetime,      
@Occupation nvarchar(max),
@IdOccupation int = 0, /*M00207*/
@IdSubcategoryOccupation int = 0,/*M00207*/
@SubcategoryOccupationOther nvarchar(max) =null,/*M00207*/      
@IdentificationNumber nvarchar(max),      
@PhysicalIdCopy int,      
@DateOfLastChange datetime,      
@EnterByIdUser int,      
@ExpirationIdentification datetime,
@IdCarrier int,    
@IdentificationIdCountry int,
@IdentificationIdState int, 
@AmountSend Money, 
@IdCustomerCountryOfBirth Int = null,
@CustomerReceiveSms BIT = 0,
@ReSendSms BIT = 0,
@AgentIdRequest INT = NULL,
@TypeTaxID int,  --Req 00158
@IsDuplicate int , --Req 00158
@HasTaxId bit = 0,--Req 00157
@CustomerOccupationDetail nvarchar(max) = NULL /*S44:REQ. MA.025*/
,@IdCustomerOutput Int Output /*Optimizacion Agente*/
,@idElasticCustomer varchar(max)=null output /*Optimizacion Agente*/
,@IdDialingCodePhoneNumber						INT = NULL
)      
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/10/30" Author="snevarez">S44::REQ. MA.025 : Add detail for Other Occupations</log>
<log Date="2017/10/30" Author="snevarez">Optimizacion Agente : Se agregaron parametros de salida necesarios para actualizacion en ElastiSearch</log>
<log Date="31/03/2020" Author="bortega">Agregar campos Tax Req:: 00158</log>
<log Date="2020/10/04" Author="esalazar" Name="">-- CR M00207	</log>
</ChangeLog>
********************************************************************/

Set nocount on;

Begin TRY

	IF @IdCustomer=0       
	BEGIN
	
		 Insert into Customer       
		 (      
			IdAgentCreatedBy,      
			IdCustomerIdentificationType,      
			IdGenericStatus,      
			Name,      
			FirstLastName,      
			SecondLastName,      
			[Address],      
			City,      
			[State],      
			Country,      
			Zipcode,      
			PhoneNumber,      
			CelullarNumber,      
			SSNumber,
			IdTypeTax, --Req 00158
			IdTaxDupli,  --Req 00158  
			HasAnswerTaxId, --Req 00157  
			BornDate,      
			Occupation,  
			[IdOccupation], --M00207
			[IdSubcategoryOccupation], --M00207
			[SubcategoryOccupationOther], --M00207  
			IdentificationNumber,      
			PhysicalIdCopy,      
			DateOfLastChange,      
			EnterByIdUser,      
			ExpirationIdentification,
			IdCarrier,
			IdentificationIdCountry ,
			IdentificationIdState      ,
			SentAverage,
			IdCountryOfBirth,
			[ReceiveSms],
			[creationdate]
			,OccupationDetail, /*S44:REQ. MA.025*/
			IdDialingCodePhoneNumber						
		 )      
		 Values      
		 (      
			@IdAgentCreatedBy,      
			@IdCustomerIdentificationType,      
			@IdGenericStatus,      
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
			@SSNumber,
			@TypeTaxID,    --Req 00158
			@IsDuplicate,  --Req 00158
			@HasTaxId, -- Req 00157
			@BornDate,      
			@Occupation,
			@IdOccupation, --M00207
			@IdSubcategoryOccupation,--M00207
			@SubcategoryOccupationOther, --M00207         
			@IdentificationNumber,      
			@PhysicalIdCopy,      
			@DateOfLastChange,      
			@EnterByIdUser,      
			@ExpirationIdentification ,
			@IdCarrier  ,
			@IdentificationIdCountry ,
			@IdentificationIdState  ,
			@AmountSend  ,
			@IdCustomerCountryOfBirth,
			@CustomerReceiveSms,
			GETDATE()
			,@CustomerOccupationDetail, /*S44:REQ. MA.025*/
			@IdDialingCodePhoneNumber
		 );    
		 Set @IdCustomerOutput=Scope_Identity() /*Optimizacion Agente*/
		 Set @idElasticCustomer=''   /*Optimizacion Agente*/
	END      
	ELSE
	BEGIN
	
		EXEC [dbo].[st_SaveCustomerMirror] @IdCustomer;
	
	 
		 Update Customer Set      
			IdAgentCreatedBy=@IdAgentCreatedBy,      
			IdCustomerIdentificationType= case when @IdCustomerIdentificationType is null then IdCustomerIdentificationType else @IdCustomerIdentificationType end,
			IdGenericStatus=@IdGenericStatus,      
			Name=@Name,      
			FirstLastName=@FirstLastName,      
			SecondLastName= @SecondLastName,      
			[Address]=isnull(NULLIF(@Address,''),[Address]),      
			City= isnull(NULLIF(@City,''),City),      
			[State]= isnull(NULLIF(@State,''),[State]),      
			Country=isnull(NULLIF(@Country,''),Country),      
			Zipcode=isnull(NULLIF(@Zipcode,''),Zipcode),      
			PhoneNumber= @PhoneNumber,      
			CelullarNumber=isnull(NULLIF(@CelullarNumber,''),CelullarNumber),      
			SSNumber=case when @SSNumber is null or len(@SSNumber) = 0 then SSNumber else @SSNumber end,
			IdTaxDupli = case when @IsDuplicate is null then IdTypeTax else @IsDuplicate end,				--Req 00158
			IdTypeTax = case when @TypeTaxID is null then IdTypeTax else @TypeTaxID end,					--Req 00158
			HasAnswerTaxId = @HasTaxId,					-- Req 00157
			BornDate= case when @BornDate is null then BornDate else @BornDate end,  
			Occupation=case when @Occupation is null or len(@Occupation) = 0 then Occupation else @Occupation end,
			IdentificationNumber=case when @IdentificationNumber is null or len(@IdentificationNumber) = 0 then IdentificationNumber else @IdentificationNumber end,
			PhysicalIdCopy=@PhysicalIdCopy,      
			DateOfLastChange=@DateOfLastChange,      
			EnterByIdUser= case when @EnterByIdUser is null then EnterByIdUser else @EnterByIdUser end,
			ExpirationIdentification=case when @ExpirationIdentification is null then ExpirationIdentification else @ExpirationIdentification end,
			IdCarrier= @IdCarrier,
			IdentificationIdCountry= case when @IdentificationIdCountry is null then IdentificationIdCountry else @IdentificationIdCountry end,
			IdentificationIdState= case when @IdentificationIdState is null then IdentificationIdState else @IdentificationIdState end,
			SentAverage =  case when SentAverage=0 then @AmountSend else SentAverage end,
			IdCountryOfBirth = case when @IdCustomerCountryOfBirth is null then IdCountryOfBirth else @IdCustomerCountryOfBirth end,
			[ReceiveSms] = @CustomerReceiveSms,

			OccupationDetail = @CustomerOccupationDetail, /*S44:REQ. MA.025*/
			[IdOccupation] = @IdOccupation, --M00207
			[IdSubcategoryOccupation] = @IdSubcategoryOccupation, --M00207
			[SubcategoryOccupationOther] = @SubcategoryOccupationOther, --M00207  
			IdDialingCodePhoneNumber	=@IdDialingCodePhoneNumber						
		 Where IdCustomer=@IdCustomer;
	     
		 Set @IdCustomerOutput=@IdCustomer /*Optimizacion Agente*/
		 Set @idElasticCustomer =  (Select idElasticCustomer from Customer with (nolock) where IdCustomer=@IdCustomer) /*Optimizacion Agente*/
	End
	
	
	EXEC [Infinite].[st_insertInvitationSms] @CelullarNumber = @CelullarNumber, @EnterByIdUser = @EnterByIdUser, @AgentId = @AgentIdRequest, @InsertSms = @CustomerReceiveSms, @IdCustomer = @IdCustomerOutput

	Select @IdCustomerOutput, @idElasticCustomer
End Try                                                                                            
Begin Catch

	Declare @ErrorMessage nvarchar(max)                                                                                             
	Select @ErrorMessage=ERROR_MESSAGE()                                             
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_InsertCustomerByTransfer',Getdate(),@ErrorMessage)                                                                                            
End Catch



