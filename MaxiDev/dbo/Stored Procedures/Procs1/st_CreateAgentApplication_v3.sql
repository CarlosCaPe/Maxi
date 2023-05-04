CREATE procedure [dbo].[st_CreateAgentApplication_v3]
(
     @IdAgentApplicationCommunication int
    ,@IdUserSeller int
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
    ,@TypeTaxId int /*TypeTaxId*/
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
    ,@OwnerTypeTaxId int /*TypeTaxId*/
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
	,@SaveNote bit
	,@Note nvarchar(max)
	,@subjectMail nvarchar(max)
    ,@IdOwnerOut int OUT
    ,@IdAgentApplicationOut int out
    ,@Message nvarchar(max) out
    ,@HasError bit OUT
	,@NeedsWFSubaccount bit = NULL
	,@RequestWFSubaccount bit = NULL
	,@ValuesAgentBusinessType VARCHAR(max) = NULL
	,@AgentBusinessEmail VARCHAR(max) = ''
	,@AgentBusinessWebsite VARCHAR(max) = NULL
	,@AgentFinCENReg bit = 0
	,@AgentFinCENRegExpiration date = NULL
	,@AgentCheckCasher bit = 0
	,@AgentCheckLicense bit = 0
	,@AgentCheckLicenseNumber VARCHAR(max) = ''
	,@MailCheckTo VARCHAR(max) = ''
	,@ComplianceOfficerDateOfBirth date
	,@ComplianceOfficerPlaceOfBirth VARCHAR(max) = NULL
	,@ComplianceOfficerTitle VARCHAR(max) = ''
	,@ComplianceOfficerName VARCHAR(max) = ''
	,@IdStateEmission int = 1
	,@IdCountryEmission int = 1

)
as
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="04/07/2017" Author="mdelgado">S27 :: Add Log/Fields for Changes to Needs/Request Date and idUser Wells Fargo</log>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
SET NOCOUNT ON;

--declaracion de variables
DECLARE  @DocHandle INT

	DECLARE @NeedsWFSubaccountType    nvarchar(25) = 'NeedsWFSubaccount'
	DECLARE @RequestWFSubaccountType  nvarchar(25) = 'RequestWFSubaccount'

	DECLARE @NeedsWFSubaccountText		  nvarchar(25) = 'Needs Wells Fargo Sub Account'
	DECLARE @RequestWFSubaccountText	  nvarchar(25) = 'Requested Wells Fargo Sub Account'

	DECLARE @DoesnNeedsWFSubaccountText   nvarchar(25) = 'Doesn''t Need Wells Fargo Sub Account'
	DECLARE @DoesnRequestWFSubaccountText nvarchar(25) = 'Request for Wells Fargo Sub Account Was Cancelled'



--Si viene en cero es por que traemos nuevos catalogos y lo asignamos a 1
IF (@IdAgentBusinessType = 0) BEGIN
	SET @IdAgentBusinessType = 1
END

Create Table #AgentCompetitions
(
    Transmitter nvarchar(max),
    Country nvarchar(max),
    FxRate nvarchar(max),
    TransmitterFee	nvarchar(max),
    MaxiFee nvarchar(max)
);

Create Table #PhoneNumbers
(
    PhoneNumber nvarchar(max),
    Comment nvarchar(max)
);

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
	);

EXEC sp_xml_removedocument @DocHandle

EXEC sp_xml_preparedocument @DocHandle OUTPUT,@PhoneNumbers

INSERT INTO #PhoneNumbers (PhoneNumber,Comment)
SELECT PhoneNumber,Comment
FROM OPENXML (@DocHandle, '/PhoneNumbers/PhoneNumber',2)
With (
		PhoneNumber nvarchar(max),
        Comment nvarchar(max)
	);

EXEC sp_xml_removedocument @DocHandle


if ((exists (select 1 from agent with(nolock) where agentcode=@AgentCode)) or (exists (select 1 from [AgentApplications] with(nolock) where agentcode=@AgentCode)))
begin
    set @HasError=1
    set @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'CREATEAPPE1')
    return
end

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
           ,[IdCountryEmission]
           ,[TypeTaxId])
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
           ,1
           ,@OwnerCreditScore
           ,@OwnerIdCounty
           ,@IdStateEmission
           ,@IdCountryEmission
           ,@OwnerTypeTaxId);

           set @IdOwnerOut = SCOPE_IDENTITY();
end
else
begin
    set @IdOwnerOut= @IdOwner

	declare @OwnerIdTypeTemp nvarchar(max)
    declare @OwnerIdNumberTemp nvarchar(max)
    declare @OwnerIdExpirationDateTemp date
    declare @OwnerTypeTaxIdTemp int
	select @OwnerIdTypeTemp = ot.IdType, @OwnerIdNumberTemp = ot.IdNumber, @OwnerIdExpirationDateTemp = ot.IdExpirationDate, @OwnerTypeTaxIdTemp = ot.TypeTaxId from [Owner] ot with(nolock) where IdOwner = @IdOwner

	if @OwnerIdTypeTemp <> @OwnerIdType or @OwnerIdNumberTemp <> @OwnerIdNumber or @OwnerIdExpirationDateTemp <> @OwnerIdExpirationDate or @OwnerTypeTaxIdTemp <> @OwnerTypeTaxId
	begin
		update Owner set IdType = @OwnerIdType, IdNumber = @OwnerIdNumber, IdExpirationDate = @OwnerIdExpirationDate, DateofLastChange = GETDATE(), EnterByIdUser = @EnterByIdUser, TypeTaxId = @OwnerTypeTaxId where IdOwner = @IdOwner;
	end

end


INSERT INTO [dbo].[AgentApplications]
           ([IdAgentApplicationCommunication]
           ,[IdUserSeller]
           ,[IdAgentApplicationStatus]
           ,[IdAgentApplicationReceiptType]
           ,[IdAgentApplicationBankDeposit]
           ,[IdAgentBusinessType]
           ,[AgentName]
           ,[AgentCode]
           ,[AgentAddress]
           ,[AgentCity]
           ,[AgentState]
           ,[AgentZipCode]
           ,[AgentPhone]
           ,[AgentFax]
           ,[AgentContact]
           ,[AgentTimeInBusiness]
           ,[AgentActivity]
           ,[GuarantorName]
           ,[GuarantorLastName]
           ,[GuarantorSecondLastName]
           ,[GuarantorAddress]
           ,[GuarantorCity]
           --,[GuarantorCounty]
           ,[GuarantorState]
           ,[GuarantorZipCode]
           ,[GuarantorPhone]
           ,[GuarantorCel]
           ,[GuarantorEmail]
           ,[GuarantorSsn]
           ,[GuarantorIdType]
           ,[GuarantorIdNumber]
           ,[GuarantorIdExpirationDate]
           ,[GuarantorBornDate]
           ,[GuarantorCreditScore]
           ,[GuarantorBornCountry]
           ,[GuarantorTitle]
           ,[TaxId]
           ,[Notes]
           ,[BusinessPermissionNumber]
           ,[BusinessPermissionExpiration]
           ,[DoneOnSundayPayOn]
           ,[DoneOnMondayPayOn]
           ,[DoneOnTuesdayPayOn]
           ,[DoneOnWednesdayPayOn]
           ,[DoneOnThursdayPayOn]
           ,[DoneOnFridayPayOn]
           ,[DoneOnSaturdayPayOn]
           ,[CommissionAgent]
           ,[CommissionCorp]
           ,[HasBillPayment]
           ,[HasFlexStatus]
           ,[DateOfLastChange]
           ,[EnterByIdUser]
           ,[HasAch]
           ,[DateOfCreation]
           ,[OfacOwnerChecked]
           ,[OfacGuarantorChecked]
           ,[OfacBusinessChecked]
           ,[CommissionAgentOtherCountries]
           ,[CommissionCorpOtherCountries]
           ,[IdOwner]
           ,[IdAgentClass]
           ,[DoingBusinessAs]
           ,[IdAgentPaymentSchema]
           ,[RetainMoneyCommission]
           ,[IdAgentCommissionPay]
         ,[AccountNumberCommission]
           ,[RoutingNumberCommission]
           ,[IdCounty]
		   ,[NeedsWFSubaccount]
		   ,[RequestWFSubaccount]
		   ,[AgentBusinessEmail]
		   ,[AgentBusinessWebsite]
		   ,[AgentFinCENReg]
		   ,[AgentFinCENRegExpiration]
		   ,[AgentCheckCasher]
		   ,[AgentCheckLicense]
		   ,[AgentCheckLicenseNumber]
		   ,[MailCheckTo]
		   ,[ComplianceOfficerDateOfBirth]
		   ,[ComplianceOfficerPlaceOfBirth]
		   ,[ComplianceOfficerTitle]
		   ,[ComplianceOfficerName]
           ,[TypeTaxID])
     VALUES
           (@IdAgentApplicationCommunication
           ,@IdUserSeller
           ,1
           ,@IdAgentApplicationReceiptType
           ,@IdAgentApplicationBankDeposit
           ,@IdAgentBusinessType
           ,@AgentName
           ,@AgentCode
           ,@AgentAddress
           ,@AgentCity
           ,@AgentState
           ,@AgentZipCode
           ,@AgentPhone
           ,@AgentFax
           ,@AgentContact
           ,@AgentTimeInBusiness
           ,@AgentActivity
           ,''
           ,''
           ,''
           ,''
           ,''
           --,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,@TaxId
           ,@Notes
           ,@BusinessPermissionNumber
           ,@BusinessPermissionExpiration
           ,@DoneOnSundayPayOn
           ,@DoneOnMondayPayOn
           ,@DoneOnTuesdayPayOn
           ,@DoneOnWednesdayPayOn
           ,@DoneOnThursdayPayOn
           ,@DoneOnFridayPayOn
           ,@DoneOnSaturdayPayOn
           ,@CommissionAgent
           ,@CommissionCorp
           ,@HasBillPayment
           ,@HasFlexStatus
           ,getdate()
           ,@EnterByIdUser
           ,@HasAch
           ,getdate()
           ,0
           ,0
           ,0
           ,@CommissionAgentOtherCountries
           ,@CommissionCorpOtherCountries
           ,@IdOwnerOut
           ,@IdAgentClass
           ,@DoingBusinessAs
           ,@IdAgentPaymentSchema
           ,@RetainMoneyCommission
           ,@IdAgentCommissionPay
           ,@AccountNumberCommission
           ,@RoutingNumberCommission
           ,@IdCounty
		   ,ISNULL(@NeedsWFSubaccount,0)
		   ,ISNULL(@RequestWFSubaccount,0)
		   ,@AgentBusinessEmail
		   ,@AgentBusinessWebsite
		   ,@AgentFinCENReg
		   ,@AgentFinCENRegExpiration
		   ,@AgentCheckCasher
		   ,@AgentCheckLicense
		   ,@AgentCheckLicenseNumber
		   ,@MailCheckTo
		   ,@ComplianceOfficerDateOfBirth
		   ,@ComplianceOfficerPlaceOfBirth
		   ,@ComplianceOfficerTitle
		   ,@ComplianceOfficerName
           ,@TypeTaxId );

           set @IdAgentApplicationOut = SCOPE_IDENTITY();

		 IF ISNULL(@EnterByIdUser, 0) = 0
		 BEGIN
			INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage, ExtraData) VALUES('st_CreateAgentApplication', GETDATE(), 'Usuario null o 0 en stored procedures',  '@EnterByIdUser = ' + CONVERT(VARCHAR(10), @EnterByIdUser));
		 END

		 --agregar historial de Needs/Request Wells Fargo subaccount
			IF (@NeedsWFSubaccount = 1)
				EXEC st_saveAgentChangeHistory @IdAgentApplicationOut, @NeedsWFSubaccountText,@NeedsWFSubaccountType, @EnterByIdUser, 0;
			ELSE
				EXEC st_saveAgentChangeHistory @IdAgentApplicationOut, @DoesnNeedsWFSubaccountText,@NeedsWFSubaccountType, @EnterByIdUser, 0;

			IF (@RequestWFSubaccount = 1)
				EXEC st_saveAgentChangeHistory @IdAgentApplicationOut, @RequestWFSubaccount, @RequestWFSubaccountType , @EnterByIdUser, 0;
			ELSE
				EXEC st_saveAgentChangeHistory @IdAgentApplicationOut, @DoesnRequestWFSubaccountText, @RequestWFSubaccountType , @EnterByIdUser, 0;


	if @SaveNote = 1
	begin
		insert into AgentApplicationStatusHistory
		(IdAgentApplication, IdAgentApplicationStatus, DateOfMovement, Note, DateOfLastChange, IdUserLastChange)
		values (@IdAgentApplicationOut, 1, getdate(),@Note,getdate(),@EnterByIdUser);

		-- New RMM - 01/07/2015
		--
		Declare @EmailProfile nvarchar(max)
		Declare @recipients nvarchar (max)
		set @subjectMail += ' Alert - '
		Select @EmailProfile = Value from GLOBALATTRIBUTES with(nolock) where Name='EmailProfiler'
		Select @subjectMail += AgentCode from AgentApplications with(nolock) where IdAgentApplication=@IdAgentApplicationOut

		set @recipients = 'cob@maxi-ms.com;newagents@maxi-ms.com;'
		select @recipients += Email from Seller with(nolock) where IdUserSeller = @IdUserSeller


		if (@recipients is not null and @recipients != '')
		begin
			set @Note = replace(@Note, '\n', char(13))
			EXEC msdb.dbo.sp_send_dbmail
			@profile_name = @EmailProfile,
			@recipients = @recipients,
			@body = @Note,
			@subject = @subjectMail;
		end
		-- End RMM
	end

--validar si viene parametro
IF @AgentActivity IS NOT NULL BEGIN

	DECLARE @items VARCHAR(max) = @AgentActivity --'Signature Hold,KYC Accepted,OFAC Validation,Ar accepted'
	DECLARE @tmpStatus AS TABLE (id INT IDENTITY, idStatus INT);

	INSERT INTO @tmpStatus (idStatus)
	SELECT IdAgentBusinessType
	FROM dbo.fnSplit(@items,',') i
	JOIN [dbo].[AgentBusinessType] s with(nolock)    --Status s                                           --
	ON i.item=s.Name;

	DECLARE @ini INT, @fin INT , @idStatus INT , @cadena VARCHAR(max)

	SELECT @ini=1, @fin = count(*) FROM @tmpStatus
	SET @cadena='<AgentBusinessTypes>'
	WHILE @ini <= @fin BEGIN
	SELECT @idStatus = idStatus FROM @tmpStatus WHERE id =@ini

	SET @cadena= @cadena+'<IdAgentBusinessType>'+convert(VARCHAR,@idStatus)+'</IdAgentBusinessType>'

	SET @ini = @ini+1
	END

	SET @cadena= @cadena+'</AgentBusinessTypes>'

   --	SELECT @cadena

	DECLARE @tuvoError BIT

	EXECUTE st_SaveAgentBusinessTypes
	@AgentCode = @AgentCode,
	@AgentBusinessTypes = @cadena,
	@EnterByIdUser =@EnterByIdUser,
	@HasError = @tuvoError OUT ;

    --Check error | Date: 17/09/2021
    Declare @tuvoErrorMessage nvarchar(max)
    Select @tuvoErrorMessage=ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_CreateAgentApplication',Getdate(),@tuvoErrorMessage);


END

--agregar al historial
insert into AgentApplicationStatusHistory
(IdAgentApplication,IdAgentApplicationStatus,DateOfMovement,Note,DateOfLastChange,IdUserLastChange)
values
(@IdAgentApplicationOut,1,getdate(),'Initial capture',getdate(),@EnterByIdUser);

--agregar numero de telefono
insert into AgentApplicationPhoneNumber
(IdAgentApplication,PhoneNumber,Comment)
select @IdAgentApplicationOut,PhoneNumber,Comment from #PhoneNumbers;

--agregar competitions
insert into AgentApplicationCompetition
(IdAgentApplication,Transmitter,Country,FxRate,TransmitterFee,MaxiFee,EnterByIdUser,DateOfLastChange)
select @IdAgentApplicationOut,c.Transmitter,c.Country,c.FxRate,c.TransmitterFee,c.MaxiFee,@EnterByIdUser,getdate() from #AgentCompetitions c;

set @HasError=0
set @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'CREATEAPP')

end try
begin catch
    set @HasError=1
    set @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'CREATEAPPE2')
    Declare @ErrorMessage nvarchar(max)
    Select @ErrorMessage=ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_CreateAgentApplication',Getdate(),@ErrorMessage);
end catch
