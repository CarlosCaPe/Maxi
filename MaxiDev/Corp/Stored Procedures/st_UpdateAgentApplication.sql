CREATE PROCEDURE [Corp].[st_UpdateAgentApplication]
(
     @IdAgentApplication int
    ,@IdAgentApplicationCommunication int
    --,@IdUserSeller int
    ,@IdAgentApplicationReceiptType int
    ,@IdAgentApplicationBankDeposit int
    ,@IdAgentBusinessType int
    ,@AgentName nvarchar(max)
    ,@AgentCode nvarchar(max)
    ,@AgentAddress nvarchar(max)
    ,@AgentCity nvarchar(max)
    ,@AgentState nvarchar(max)
    ,@AgentZipCode nvarchar(max)
    ,@AgentPhone nvarchar(max)
    ,@AgentFax nvarchar(max)
    ,@AgentContact nvarchar(max)
    ,@AgentTimeInBusiness datetime
    ,@AgentActivity  nvarchar(max)
    ,@GuarantorName  nvarchar(max)
    ,@GuarantorLastName  nvarchar(max)
    ,@GuarantorSecondLastName  nvarchar(max)
    ,@GuarantorAddress  nvarchar(max)
    ,@GuarantorCity  nvarchar(max)
    --,@GuarantorCounty  nvarchar(max)
    ,@IdCountyGuarantor  int
    ,@GuarantorState  nvarchar(max)
    ,@GuarantorZipCode  nvarchar(max)
    ,@GuarantorPhone nvarchar(max)
    ,@GuarantorCel nvarchar(max)
    ,@GuarantorEmail nvarchar(max)
    ,@GuarantorSsn nvarchar(max)
    ,@GuarantorIdType  int
    ,@GuarantorIdNumber  nvarchar(max)
    ,@GuarantorIdExpirationDate datetime
    ,@GuarantorBornDate datetime
    ,@GuarantorCreditScore  nvarchar(max)
    ,@GuarantorBornCountry  nvarchar(max)
    ,@GuarantorTitle  nvarchar(max)
    ,@TaxId  nvarchar(max)
    ,@Notes nvarchar(max)
    ,@BusinessPermissionNumber nvarchar(max)
    ,@BusinessPermissionExpiration datetime
    ,@DoneOnSundayPayOn int
    ,@DoneOnMondayPayOn int
    ,@DoneOnTuesdayPayOn int
    ,@DoneOnWednesdayPayOn int
    ,@DoneOnThursdayPayOn int
    ,@DoneOnFridayPayOn int
    ,@DoneOnSaturdayPayOn int
    ,@CommissionAgent money
    ,@CommissionCorp money
    ,@HasBillPayment bit
    ,@HasFlexStatus bit    
    ,@HasAch bit    
    ,@CommissionAgentOtherCountries money
    ,@CommissionCorpOtherCountries money    
    ,@IdAgentClass int
    ,@DoingBusinessAs nvarchar(max)
    ,@IdAgentPaymentSchema int
    ,@RetainMoneyCommission bit
    ,@IdAgentCommissionPay int
    ,@AccountNumberCommission nvarchar(max)
    ,@RoutingNumberCommission nvarchar(max)
    ,@IdCounty int
    ,@IdOwner int
    ,@OwnerName nvarchar(max)
    ,@OwnerLastName nvarchar(max)
    ,@OwnerSecondLastName nvarchar(max)
    ,@OwnerAddress nvarchar(max)
    ,@OwnerCity nvarchar(max)
    ,@OwnerState nvarchar(max)
    ,@OwnerZipcode nvarchar(max)
    ,@OwnerPhone nvarchar(max)
    ,@OwnerCel nvarchar(max)
    ,@OwnerEmail nvarchar(max)
    ,@OwnerSSN nvarchar(max)
    ,@OwnerIdType nvarchar(max)
    ,@OwnerIdNumber nvarchar(max)
    ,@OwnerIdExpirationDate datetime
    ,@OwnerBornDate datetime
    ,@OwnerBornCountry nvarchar(max)     
    ,@OwnerCreditScore nvarchar(max)
    ,@OwnerIdCounty int
    ,@EnterByIdUser int
    ,@PhoneNumbers xml
    ,@AgentCompetitions xml
    ,@IdLenguage int
    ,@IdOwnerOut int OUT
    ,@Message nvarchar(max) out
    ,@HasError bit OUT
	,@NeedsWFSubaccount bit = NULL
	,@RequestWFSubaccount bit = NULL

	,@OwnerGenericStatus int = null /*S13:Habilitar Opcion de Editar y Seleccionar Otro Dueño*/
	
	,@AgentBusinessEmail 			NVARCHAR(100) = NULL
	,@AgentBusinessWebsite			NVARCHAR(150) = NULL
	,@AgentFinCENReg				BIT = NULL
	,@AgentFinCENRegExpiration		DATE = NULL
	,@AgentCheckCasher				BIT = NULL
	,@AgentCheckLicense				BIT = NULL
	,@AgentCheckLicenseNumber		VARCHAR(50) = NULL
	,@MailCheckTo					VARCHAR(20) = NULL
	,@ComplianceOfficerDateOfBirth	DATE = NULL
	,@ComplianceOfficerPlaceofBirth	VARCHAR(250) = NULL
	,@OwnerIdStateEmission		 	INT = NULL
	,@OwnerIdCountryEmission 		INT = NULL
	,@ComplianceOfficerName			VARCHAR(250) = NULL
	,@TypeTaxID 					INT = NULL
)
as
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="04/07/2017" Author="mdelgado">S27 :: Add Log/Fields for Changes to Needs/Request Date and idUser Wells Fargo</log>
<log Date="08/09/2022" Author="cagarcia">MP1064/SD1-2024 - Add duplicate SSN validation</log>
<log Date="02/02/2023" Author="fresendiz">BM-805 :: Se agrega TypeTaxID al Update de la tabla AgentApplication </log>
<log Date="22/02/2023" Author="cagarcia">BM-860: Fix en validacion de SSN de Owner duplicado </log>
</ChangeLog>
********************************************************************/

IF(EXISTS(SELECT TOP 1 1
          FROM Owner WITH(nolock)
          WHERE replace(replace(SSN, '-', ''), ' ', '') = replace(replace(@OwnerSSN, '-', ''), ' ', '') AND IdOwner != @IdOwner))
BEGIN
    SET @HasError = 1
    SET @Message = dbo.GetMessageFromLenguajeResorces(0, 84)
    SET @IdOwnerOut = 0
    RETURN;
END

	DECLARE  @DocHandle INT 

	DECLARE @NeedsWFSubaccountType    nvarchar(25) = 'NeedsWFSubaccount'
	DECLARE @RequestWFSubaccountType  nvarchar(25) = 'RequestWFSubaccount' 
	DECLARE @NeedChange BIT = 0, @RequestChange BIT = 0;

Create Table #AgentCompetitions
(
    Transmitter nvarchar(max),
    Country nvarchar(max),
    FxRate nvarchar(max),
    TransmitterFee	nvarchar(max),
    MaxiFee nvarchar(max)
)

Create Table #PhoneNumbers
(
    PhoneNumber nvarchar(max),
    Comment nvarchar(max)
)

begin try

EXEC sp_xml_preparedocument @DocHandle OUTPUT,@AgentCompetitions   

INSERT INTO #AgentCompetitions (Transmitter,Country,FxRate,TransmitterFee,MaxiFee)
SELECT Transmitter,Country,FxRate,TransmitterFee,MaxiFee
FROM OPENXML (@DocHandle, '/AgentCompetitions/AgentCompetition',2)
With (
		Transmitter nvarchar(max),
        Country nvarchar(max),
        FxRate nvarchar(max),
        TransmitterFee	nvarchar(max),
        MaxiFee nvarchar(max)
	)

EXEC sp_xml_removedocument @DocHandle

EXEC sp_xml_preparedocument @DocHandle OUTPUT,@PhoneNumbers   

INSERT INTO #PhoneNumbers (PhoneNumber,Comment)
SELECT PhoneNumber,Comment
FROM OPENXML (@DocHandle, '/PhoneNumbers/PhoneNumber',2)
With (
		PhoneNumber nvarchar(max),
        Comment nvarchar(max)
	)

EXEC sp_xml_removedocument @DocHandle

/*
if ((exists (select top 1 1 from agent where agentcode=@AgentCode)) or (exists (select top 1 1 from [AgentApplications] where agentcode=@AgentCode)))
begin
    set @HasError=1
    set @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'CREATEAPPE1')
    return
end
*/

Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_UpdateAgentApplication:if]',Getdate()
,
'IdAgentApplication:' + CONVERT(VARCHAR(12),@IdAgentApplication)
+',IdOwner:' + CONVERT(VARCHAR(12),@IdOwner) 
)

if @IdOwner=0
begin
INSERT INTO [dbo].[Owner]
           ([Name]
           ,[LastName]
           ,[SecondLastName]
           ,[Address]
           ,[City]
           ,[State]
           ,[Zipcode]
           ,[Phone]
           ,[Cel]
           ,[Email]
           ,[SSN]
           ,[IdType]
           ,[IdNumber]
           ,[IdExpirationDate]
           ,[BornDate]
           ,[BornCountry]
           ,[CreationDate]
           ,[DateofLastChange]
           ,[EnterByIdUser]
           ,[IdStatus]
           ,[CreditScore]
           ,[IdCounty]
           ,[IdStateEmission]
           ,[IdCountryEmission])
     VALUES
           (@OwnerName
           ,@OwnerLastName
           ,@OwnerSecondLastName
           ,@OwnerAddress
           ,@OwnerCity
           ,@OwnerState
           ,@OwnerZipcode
           ,@OwnerPhone
           ,@OwnerCel
           ,@OwnerEmail
           ,@OwnerSSN
           ,@OwnerIdType
           ,@OwnerIdNumber
           ,@OwnerIdExpirationDate
           ,@OwnerBornDate
           ,@OwnerBornCountry
           ,GETDATE()
           ,getdate()
           ,@EnterByIdUser

           --,1
		   ,ISNULL(@OwnerGenericStatus,1) /*S13:Habilitar Opcion de Editar y Seleccionar Otro Dueño*/

           ,@OwnerCreditScore
           ,@OwnerIdCounty
           ,@OwnerIdStateEmission
           ,@OwnerIdCountryEmission)

           set @IdOwnerOut = SCOPE_IDENTITY()
end
else
begin

    UPDATE [dbo].[Owner]
        SET    [Name] = @OwnerName
              ,[LastName] = @OwnerLastName
              ,[SecondLastName] = @OwnerSecondLastName
              ,[Address] = @OwnerAddress
              ,[City] = @OwnerCity
              ,[State] = @OwnerState
              ,[Zipcode] = @OwnerZipcode
              ,[Phone] = @OwnerPhone
              ,[Cel] = @OwnerCel
              ,[Email] = @OwnerEmail
              ,[SSN] = @OwnerSSN
              ,[IdType] = @OwnerIdType
              ,[IdNumber] = @OwnerIdNumber
              ,[IdExpirationDate] = @OwnerIdExpirationDate
              ,[BornDate] = @OwnerBornDate
              ,[BornCountry] = @OwnerBornCountry              
              ,[DateofLastChange] = getdate()
              ,[EnterByIdUser] = @EnterByIdUser              
              ,[CreditScore] = isnull(@OwnerCreditScore,[CreditScore])
              ,[IdCounty] = @OwnerIdCounty
			  ,[IdStatus] = @OwnerGenericStatus
			  ,[IdStateEmission] = @OwnerIdStateEmission
			  ,[IdCountryEmission] = @OwnerIdCountryEmission
			   /*S13:Habilitar Opcion de Editar y Seleccionar Otro Dueño*/
 WHERE IdOwner=@IdOwner
    set @IdOwnerOut = @IdOwner
end;


	SELECT
		@NeedChange = CASE WHEN [NeedsWFSubaccount] = @NeedsWFSubaccount THEN 0 ELSE 1 END,
		@RequestChange = CASE WHEN [RequestWFSubaccount]  = @RequestWFSubaccount THEN 0 ELSE 1 END
	FROM [AgentApplications] WITH(NOLOCK)
	WHERE IdAgentApplication = @IdAgentApplication;


Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_UpdateAgentApplication:UPDATE]',Getdate()
, 
'IdAgentApplication:' + CONVERT(VARCHAR(100), isnull(@IdAgentApplication,''))
+',IdOwner:' + CONVERT(VARCHAR(100), isnull(@IdOwner,'')) 
+',NeedChange:' + CONVERT(VARCHAR(100), isnull(@NeedChange,''))
+',RequestChange:' + CONVERT(VARCHAR(100), isnull(@RequestChange,''))

+',GuarantorName:' + CONVERT(VARCHAR(100), isnull(@GuarantorName,''))
+',GuarantorLastName:' + CONVERT(VARCHAR(100), isnull(@GuarantorLastName,''))
+',GuarantorSecondLastName:' + CONVERT(VARCHAR(100), isnull(@GuarantorSecondLastName,''))
+',GuarantorAddress:' + CONVERT(VARCHAR(100), isnull(@GuarantorAddress,''))
+',GuarantorCity:' + CONVERT(VARCHAR(100),isnull(@GuarantorCity,''))
+',IdCountyGuarantor:' + CONVERT(VARCHAR(100), isnull(@IdCountyGuarantor,''))

+',EnterByIdUser:' + CONVERT(VARCHAR(100), isnull(@EnterByIdUser,''))
);

UPDATE [dbo].[AgentApplications]
   SET [IdAgentApplicationCommunication] = @IdAgentApplicationCommunication
      --,[IdUserSeller] = @IdUserSeller
      --,[IdAgentApplicationStatus] = @IdAgentApplicationStatus
      ,[IdAgentApplicationReceiptType] = @IdAgentApplicationReceiptType
      ,[IdAgentApplicationBankDeposit] = @IdAgentApplicationBankDeposit
      ,[IdAgentBusinessType] = @IdAgentBusinessType
      ,[AgentName] = @AgentName
      ,[AgentCode] = @AgentCode
      ,[AgentAddress] = @AgentAddress
      ,[AgentCity] = @AgentCity
      ,[AgentState] = @AgentState
      ,[AgentZipCode] = @AgentZipCode
      ,[AgentPhone] = @AgentPhone
      ,[AgentFax] = @AgentFax
      ,[AgentContact] = @AgentContact
      ,[AgentTimeInBusiness] = @AgentTimeInBusiness
      ,[AgentActivity] = @AgentActivity
      ,[GuarantorName] = isnull(@GuarantorName,'')
      ,[GuarantorLastName] = isnull(@GuarantorLastName,'')
      ,[GuarantorSecondLastName] = isnull(@GuarantorSecondLastName,'')
      ,[GuarantorAddress] = isnull(@GuarantorAddress,'')
      ,[GuarantorCity] = isnull(@GuarantorCity,'')
      --,[GuarantorCounty] = isnull(@GuarantorCounty,'')
      ,[IdCountyGuarantor] = @IdCountyGuarantor
      ,[GuarantorState] = isnull(@GuarantorState,'')
      ,[GuarantorZipCode] = isnull(@GuarantorZipCode,'')
      ,[GuarantorPhone] = isnull(@GuarantorPhone,'')
      ,[GuarantorCel] = isnull(@GuarantorCel,'')
      ,[GuarantorEmail] = isnull(@GuarantorEmail,'')
      ,[GuarantorSsn] = isnull(@GuarantorSsn,'')
      ,[GuarantorIdType] = isnull(@GuarantorIdType,'')
      ,[GuarantorIdNumber] = isnull(@GuarantorIdNumber,'')
      ,[GuarantorIdExpirationDate] = isnull(@GuarantorIdExpirationDate,'')
      ,[GuarantorBornDate] = isnull(@GuarantorBornDate,'')
      ,[GuarantorCreditScore] = isnull(@GuarantorCreditScore,[GuarantorCreditScore])
      ,[GuarantorBornCountry] = isnull(@GuarantorBornCountry,'')
      ,[GuarantorTitle] = isnull(@GuarantorTitle,'')
      ,[TaxId] = @TaxId
      ,[Notes] = @Notes
      ,[BusinessPermissionNumber] = @BusinessPermissionNumber
      ,[BusinessPermissionExpiration] = @BusinessPermissionExpiration
      ,[DoneOnSundayPayOn] = @DoneOnSundayPayOn
      ,[DoneOnMondayPayOn] = @DoneOnMondayPayOn
      ,[DoneOnTuesdayPayOn] = @DoneOnTuesdayPayOn
      ,[DoneOnWednesdayPayOn] = @DoneOnWednesdayPayOn
      ,[DoneOnThursdayPayOn] = @DoneOnThursdayPayOn
      ,[DoneOnFridayPayOn] = @DoneOnFridayPayOn
      ,[DoneOnSaturdayPayOn] = @DoneOnSaturdayPayOn
      ,[CommissionAgent] = @CommissionAgent
      ,[CommissionCorp] = @CommissionCorp
      ,[HasBillPayment] = @HasBillPayment
      ,[HasFlexStatus] = @HasFlexStatus
      ,[DateOfLastChange] = getdate()
      ,[EnterByIdUser] = @EnterByIdUser
      ,[HasAch] = @HasAch      
      --,[OfacOwnerChecked] = isnull(@OfacOwnerChecked,[OfacOwnerChecked])
      --,[OfacGuarantorChecked] = isnull(@OfacGuarantorChecked,[OfacGuarantorChecked])
      --,[OfacBusinessChecked] = isnull(@OfacBusinessChecked,[OfacBusinessChecked])
      ,[CommissionAgentOtherCountries] = @CommissionAgentOtherCountries
      ,[CommissionCorpOtherCountries] = @CommissionCorpOtherCountries
      ,[IdOwner] = @IdOwnerOut
      ,[IdAgentClass] = @IdAgentClass
      ,[DoingBusinessAs] = @DoingBusinessAs
      ,[IdAgentPaymentSchema] = @IdAgentPaymentSchema
      ,[RetainMoneyCommission] = @RetainMoneyCommission
      ,[IdAgentCommissionPay] = @IdAgentCommissionPay
      ,[AccountNumberCommission] = @AccountNumberCommission
      ,[RoutingNumberCommission] = @RoutingNumberCommission
      ,[IdCounty] = @IdCounty
	  ,[NeedsWFSubaccount] = ISNULL(@NeedsWFSubaccount,[NeedsWFSubaccount]) 
	  ,[RequestWFSubaccount] = ISNULL(@RequestWFSubaccount,[RequestWFSubaccount])
	  
	  ,NeedsWFSubaccountIduser = CASE WHEN NeedsWFSubaccount <> @NeedsWFSubaccount THEN @EnterByIdUser ELSE NeedsWFSubaccountIduser END
	  ,NeedsWFSubaccountDate = CASE WHEN NeedsWFSubaccount <> @NeedsWFSubaccount THEN GETDATE() ELSE NeedsWFSubaccountDate END
	  
	  ,RequestWFSubaccountIdUser = CASE WHEN RequestWFSubaccount <> @RequestWFSubaccount THEN @EnterByIdUser ELSE RequestWFSubaccountIdUser END
	  ,RequestWFSubaccountDate = CASE WHEN RequestWFSubaccount <> @RequestWFSubaccount THEN @EnterByIdUser ELSE RequestWFSubaccountDate END
	  ,AgentBusinessEmail = isnull(@AgentBusinessEmail, AgentBusinessEmail)
	  ,AgentBusinessWebsite = isnull(@AgentBusinessWebsite, AgentBusinessWebsite)
	  ,AgentFinCENReg = @AgentFinCENReg
	  ,AgentFinCENRegExpiration = @AgentFinCENRegExpiration
	  ,AgentCheckCasher = @AgentCheckCasher
	  ,AgentCheckLicense = @AgentCheckLicense
	  ,AgentCheckLicenseNumber = isnull(@AgentCheckLicenseNumber, AgentCheckLicenseNumber)
	  ,MailCheckTo = isnull(@MailCheckTo, MailCheckTo)
	  ,ComplianceOfficerDateOfBirth = @ComplianceOfficerDateOfBirth
	  ,ComplianceOfficerPlaceOfBirth = isnull(@ComplianceOfficerPlaceOfBirth, ComplianceOfficerPlaceOfBirth)
	  ,ComplianceOfficerName = isnull(@ComplianceOfficerName, ComplianceOfficerName)
	  ,[TypeTaxID] = @TypeTaxID
 WHERE 
        IdAgentApplication = @IdAgentApplication

	-- Agregar historial de Needs/Request Wells Fargo subaccount
	IF (@NeedChange = 1)
	BEGIN
		EXEC [Corp].[st_saveAgentApplicationChangeHistory] @idAgentApplication, @NeedsWFSubaccount,@NeedsWFSubaccountType, @EnterByIdUser;
	END

	IF (@RequestChange = 1)
	BEGIN
		EXEC [Corp].[st_saveAgentApplicationChangeHistory] @idAgentApplication, @RequestWFSubaccount, @RequestWFSubaccountType , @EnterByIdUser;
	END


--agregar numero de telefono
Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_UpdateAgentApplication:AgentApplicationPhoneNumber]',Getdate(),'agregar numero de telefono');
delete from AgentApplicationPhoneNumber where IdAgentApplication=@IdAgentApplication
insert into AgentApplicationPhoneNumber
(IdAgentApplication,PhoneNumber,Comment)
select @IdAgentApplication,PhoneNumber,Comment from #PhoneNumbers

--agregar competitions
Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_UpdateAgentApplication:AgentApplicationCompetition]',Getdate(),'agregar competitions');

delete from AgentApplicationCompetition where IdAgentApplication=@IdAgentApplication
insert into AgentApplicationCompetition
(IdAgentApplication,Transmitter,Country,FxRate,TransmitterFee,MaxiFee,EnterByIdUser,DateOfLastChange)
select @IdAgentApplication,c.Transmitter,c.Country,c.FxRate,c.TransmitterFee,c.MaxiFee,@EnterByIdUser,getdate() from #AgentCompetitions c

set @HasError=0
set @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'CREATEAPP')

end try
begin catch
    set @HasError=1
    set @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'CREATEAPPE2')
    Declare @ErrorMessage nvarchar(max)                                                                                   
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateAgentApplication',Getdate(),@ErrorMessage)
end catch



