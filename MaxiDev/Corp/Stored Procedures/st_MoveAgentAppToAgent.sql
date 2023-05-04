CREATE PROCEDURE [Corp].[st_MoveAgentAppToAgent]
(
    @IdAgentApplication int,
    @IsSpanishLanguage bit,
    @HasError bit output,
    @Message nvarchar(max) output, 
    @IdNewAgent int output
)
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
	<log Date="2017/07/10" Author="mdelgado">Add Needs & Request WellsFargo fields & Transition of it to Agent historical status</log>
	<log Date="17/10/2018" Author="azavala">FIX :: Modified IF to Disabled Exception for Agent with Bank ACH and CollectType ACH or ACH with Scanner</log>
	<log Date="26/10/2018" Author="jdarellano" Name="#1">Ticket 1486.- Se quita regla de eliminación de excepciones para agencias que no cumplan con ACH</log>
	<log Date="05/11/2018" Author="jmolina" Name="#2">Se inicializa la variable @NeedWFSubAccountIdUser</log>
	<log Date="23/12/2021" Author="jdarellano" Name="#3">Se agrega ISNULL ya que el campo AgentEmail de la tabla dbo.Agent no permite valores nulos (Ticket 1526).</log>
	<log Date="28/12/2021" Author="jcsierra">Se agrega el sp st_SetActiveTrainingCommunication para agregar los comunicados faltantes al agente al habilitar</log>
	<log Date="25/11/2022" Author="cagarcia">Se agrega logica para marcar campo RetainMoneyCommission dependiendo de IdAgentCommissionPay y IdAgentPaymentSchema</log>
	<log Date="05/10/2022" Author="cagarcia">MP-1312 Se agrega campo IdAgentBusinessType</log>
	<log Date="03/02/2023" Author="maprado">BM-668 Se setea CancelReturnCommission a 1</log>
	<log Date="10/02/2022" Author="cagarcia">MP-1334 Se agrega campo TaxIdType</log>
	<log Date="2023/02/16" Author = "jdarellano">Se agrega fix por atención a problema de TypeTaxID nulo.</log>
</ChangeLog>
********************************************************************/
Set nocount on

Begin Try  

Declare @IdAgentType int
Declare @IdAgentStatus int 
Declare @IdAgentPaymentSchema int
Declare @CreditAmount Money
--Declare @Folio int 
Declare @AmountRequiredToAskId money 
Declare @SwitchCommission bit
Declare @SwitchExrate	bit
Declare @CommissionTop	money 
Declare @CommissionBottom money 
Declare @ExrateTop money 
Declare @ExrateBottom money 
Declare @ShowAgentProfitWhenSendingTransfer bit
Declare @AgentBussinesType nvarchar(max)
Declare @Datetime Datetime
Declare @SystemUser int
Declare @AmountForClassF money
Declare @IdAgentClass INT
DEclare @IdAgentCollectType int

		DECLARE @NeedsWFSubaccountType    NVARCHAR(MAX) = 'NeedsWFSubaccount'
		DECLARE @RequestWFSubaccountType  NVARCHAR(MAX) = 'RequestWFSubaccount'
		DECLARE @NeedWFSubAccountIdUser INT = NULL
		DECLARE @RequestWFSubAccountIdUser INT = NULL
		DECLARE @NeedsWFSubaccount   BIT
		DECLARE @RequestWFSubaccount BIT

--Declare @IdOwner INT
--Declare	@OwnerName nvarchar(max) 
--Declare	@OwnerLastName nvarchar(max) 
--Declare	@OwnerSecondLastName nvarchar(max) 
--Declare	@OwnerAddress nvarchar(max) 
--Declare	@OwnerCity nvarchar(max) 
--Declare	@OwnerState nvarchar(max) 
--Declare	@OwnerZipcode nvarchar(max) 
--Declare	@OwnerPhone nvarchar(max) 
--Declare	@OwnerCel nvarchar(max) 
--Declare	@OwnerEmail nvarchar(max) 
--Declare	@OwnerSSN nvarchar(max) 
--Declare	@OwnerIdType nvarchar(max) 
--Declare @OwnerIdNumber nvarchar(max) 
--Declare	@OwnerIdExpirationDate date 
--Declare	@OwnerBornDate date 	
--Declare	@OwnerBornCountry nvarchar(max) 

Set @Datetime=GETDATE()

Select @SystemUser=dbo.GetGlobalAttributeByName ('SystemUserID')

Select Top 1
    @IdAgentType=IdAgentType,
    @IdAgentStatus=IdAgentStatus,
    @IdAgentPaymentSchema=IdAgentPaymentSchema,
    @CreditAmount=CreditAmount,
    --@Folio=Folio,
    @AmountRequiredToAskId=AmountRequiredToAskId, 
    @SwitchCommission=SwitchCommission,
    @SwitchExrate=SwitchExrate,
    @CommissionTop=CommissionTop, 
    @CommissionBottom=CommissionBottom, 
    @ExrateTop=ExrateTop,
    @ExrateBottom=ExrateBottom, 
    @ShowAgentProfitWhenSendingTransfer=ShowAgentProfitWhenSendingTransfer,
    @AgentBussinesType=AgentBussinesType,
    @AmountForClassF=AmountForClassF,
    @IdAgentClass=IdAgentClass
From dbo.DefaultValuesFromAgentAppToAgent with(nolock)

--SELECT
--    @IdOwner = IdOwner,
--    @OwnerName = OwnerName,
--    @OwnerLastName = OwnerLastName,
--    @OwnerSecondLastName = OwnerSecondLastName,
--    @OwnerAddress = OwnerAddress,
--    @OwnerCity = OwnerCity,
--    @OwnerState = OwnerState,
--    @OwnerZipcode = OwnerZipcode,
--    @OwnerPhone = OwnerPhone,
--    @OwnerCel = OwnerCel,
--    @OwnerEmail = OwnerEmail,
--    @OwnerSSN = Case when Len(OwnerSsn)>8 Then Substring(OwnerSsn,1,3)+'-'+Substring(OwnerSsn,4,2)+'-'+Substring(OwnerSsn,6,4) Else '' End,
--    @OwnerIdType = ISNULL(B.Name,''),
--    @OwnerIdNumber = OwnerIdNumber,
--    @OwnerIdExpirationDate = OwnerIdExpirationDate,
--    @OwnerBornDate = OwnerBornDate,
--    @OwnerBornCountry = OwnerBornCountry
--FROM 
--    AgentApplications A
--Left Join 
--        CustomerIdentificationType B on (A.OwnerIdType=B.IdCustomerIdentificationType)

--IF ISNULL(@IdOwner,0)=0
--BEGIN
--    INSERT INTO dbo.Owner
--            ( Name ,
--              LastName ,
--              SecondLastName ,
--              Address ,
--              City ,
--              State ,
--              Zipcode ,
--              Phone ,
--              Cel ,
--              Email ,
--              SSN ,
--              IdType ,
--              IdNumber ,
--              IdExpirationDate ,
--              BornDate ,
--              BornCountry ,
--              CreationDate ,
--              DateofLastChange ,
--              EnterByIdUser ,
--              IdStatus
--            )
--    VALUES  (               
--              @OwnerName,
--              @OwnerLastName,
--              @OwnerSecondLastName,
--              @OwnerAddress,
--              @OwnerCity,
--              @OwnerState,
--              @OwnerZipcode,
--              @OwnerPhone,
--              @OwnerCel,
--              @OwnerEmail,
--              @OwnerSSN,
--              @OwnerIdType,
--              @OwnerIdNumber,
--              @OwnerIdExpirationDate,
--              @OwnerBornDate,
--              @OwnerBornCountry,
--              GETDATE(),
--              GETDATE(),
--              @SystemUser,
--              1
--            )

--            SET @IdOwner=SCOPE_IDENTITY()
--END
--ELSE
--BEGIN
--    UPDATE owner SET
--        Name = @OwnerName,
--        LastName = @OwnerLastName,
--        SecondLastName = @OwnerSecondLastName,
--        Address = @OwnerAddress,
--        City = @OwnerCity,
--        State = @OwnerState,
--        Zipcode = @OwnerZipcode,
--        Phone = @OwnerPhone,
--        Cel = @OwnerCel,
--        Email = @OwnerEmail,
--        SSN = @OwnerSSN,
--        IdType = @OwnerIdType,
--        IdNumber = @OwnerIdNumber,
--        IdExpirationDate = @OwnerIdExpirationDate,
--        BornDate = @OwnerBornDate,
--        BornCountry = @OwnerBornCountry
--    WHERE IdOwner=@IdOwner
--END

--Begin tran
Insert into dbo.Agent
(
    IdAgentCommunication,
    IdAgentType,
    IdUserSeller,
    IdUserOpeningSalesRep,
    IdAgentStatus,
    IdAgentPaymentSchema,
    IdAgentReceiptType,
    IdAgentBankDeposit,
    AgentName,
    AgentCode,
    AgentAddress,
    AgentCity,
    AgentState,
    AgentZipcode,
    AgentPhone,
    AgentFax,
    AgentEmail,
    AgentContact,
    AgentTimeInBusiness,
    AgentBusinessType,   
    GuarantorName,
    GuarantorLastName,
    GuarantorSecondLastName,
    GuarantorAddress,
    GuarantorCity,
    GuarantorState,
    GuarantorZipcode,
    GuarantorPhone,
    GuarantorCel,
    GuarantorEmail,
    GuarantorSSN,
    GuarantorIdType,
    GuarantorIdNumber,
    GuarantorIdExpirationDate,
    GuarantorBornDate,
    TaxID,
    CreditAmount,
    --Folio,
    AmountRequiredToAskId,
    CreationDate,
    OpenDate,
    Notes,
    CloseDate,
    BusinessPermissionNumber,
    BusinessPermissionExpiration,
    DoneOnSundayPayOn,
    DoneOnMondayPayOn,
    DoneOnTuesdayPayOn,
    DoneOnWednesdayPayOn,
    DoneOnThursdayPayOn,
    DoneOnFridayPayOn,
    DoneOnSaturdayPayOn,
    DateOfLastChange,
    EnterByIdUser,
    SwitchCommission,
    SwitchExrate,
    CommissionTop,
    CommissionBottom,
    ExrateTop,
    ExrateBottom,
    ACHWellsFargo,
    --county,
    ShowAgentProfitWhenSendingTransfer,    
    GuarantorBornCountry,
    ExcludeReportSignatureHold,
    ExcludeReportExRates,
    IdAgentClass,
    IdOwner,
    AccountNumber,
    RoutingNumber,
    IdAgentCollectType,
	DoingBusinessAs,
    RetainMoneyCommission,
    IdAgentCommissionPay,
	AccountNumberCommission,
    RoutingNumberCommission,
    Idcounty,
    Idcountyguarantor,
	CheckEditMicr,
	IdTimeZone,
	NeedsWFSubaccount,
	NeedsWFSubaccountDate,
	NeedsWFSubaccountIduser,
	RequestWFSubaccount,
	RequestWFSubaccountDate,
	RequestWFSubaccountIdUser,
	AgentBusinessWebsite,
	AgentFinCENReg,
	AgentFinCENRegExpiration,
	AgentCheckCasher,
	AgentCheckLicense,
	AgentCheckLicenseNumber,
	MailCheckTo,
	ComplianceOfficerDateOfBirth,
	ComplianceOfficerPlaceOfBirth,
	ComplianceOfficerName,
	IdAgentBusinessType,
	CancelReturnCommission, -- BM-668
	IdTaxIDType
)
Select 
    IdAgentApplicationCommunication,
    @IdAgentType,
    IdUserSeller,
    IdUserSeller,
    @IdAgentStatus,
    isnull(IdAgentPaymentSchema,@IdAgentPaymentSchema),
    IdAgentApplicationReceiptType,
    IdAgentApplicationBankDeposit,
    AgentName,
    AgentCode,
    AgentAddress,
    AgentCity,
    AgentState,
    AgentZipCode,
    AgentPhone,
    AgentFax,
    ISNULL(AgentBusinessEmail,''),--#3
    AgentContact,
    AgentTimeInBusiness,
    @AgentBussinesType,  
    GuarantorName,
    GuarantorLastName,
    GuarantorSecondLastName,
    GuarantorAddress,
    GuarantorCity,
    GuarantorState,
    GuarantorZipCode,
    GuarantorPhone,
    GuarantorCel,
    GuarantorEmail,
    Case when Len(GuarantorSsn)>8 Then Substring(GuarantorSsn,1,3)+'-'+Substring(GuarantorSsn,4,2)+'-'+Substring(GuarantorSsn,6,4) Else '' End ,
    isnull(C.Name,''),
    GuarantorIdNumber,
    GuarantorIdExpirationDate,
    GuarantorBornDate,
    TaxId,
    @CreditAmount,
    --@Folio,
    @AmountRequiredToAskId,
    @Datetime,
    @Datetime,
    Notes,
    '1900/01/01',
    BusinessPermissionNumber,
    BusinessPermissionExpiration,
    DoneOnSundayPayOn,
    DoneOnMondayPayOn,
    DoneOnTuesdayPayOn,
    DoneOnWednesdayPayOn,
    DoneOnThursdayPayOn,
    DoneOnFridayPayOn,
    DoneOnSaturdayPayOn,
    @Datetime,
    @SystemUser,
    Case when HasFlexStatus=1 Then 1 Else 0 End,
    Case when HasFlexStatus=1 Then 1 Else 0 End,
    Case when HasFlexStatus=1 Then @CommissionTop Else 0 End,
    Case when HasFlexStatus=1 Then @CommissionBottom Else 0 End,
    Case when HasFlexStatus=1 Then @ExrateTop Else 0 End,
    Case when HasFlexStatus=1 Then @ExrateBottom Else 0 End,
    HasAch,
    --AgentCounty,
    @ShowAgentProfitWhenSendingTransfer,    
    GuarantorBornCountry,
    0,
    0,
    ISNULL(IdAgentClass,@IdAgentClass),
    ISNULL(IdOwner,1),
    ISNULL(i.AccountNumber,''),
    ISNULL(i.RoutingNumber,''),
    case isnull(HasAch,0)
        when 1 then 1
        else 4
    end,
	A.DoingBusinessAs,
	--isnull(RetainMoneyCommission,0),
	CASE WHEN A.IdAgentCommissionPay IN (1,2) AND A.IdAgentPaymentSchema = 1 THEN 1 ELSE 0 END, --RetainMoneyCommission
    IdAgentCommissionPay,
    isnull(AccountNumberCommission,''),
    isnull(RoutingNumberCommission,''),
    Idcounty,
    idcountyguarantor,
	0,
	(SELECT TOP 1 IdTimeZone FROM dbo.RelationTimeZoneState RTZ with(nolock) INNER JOIN dbo.[State] S with(nolock) ON RTZ.IdState = S.IdState WHERE StateCode = AgentState) AS IdTimeZone,
	NeedsWFSubaccount,
	NeedsWFSubaccountDate,
	NeedsWFSubaccountIduser,
	RequestWFSubaccount,
	RequestWFSubaccountDate,
	RequestWFSubaccountIdUser,
	AgentBusinessWebsite,
	AgentFinCENReg,
	AgentFinCENRegExpiration,
	AgentCheckCasher,
	AgentCheckLicense,
	AgentCheckLicenseNumber,
	MailCheckTo,
	ComplianceOfficerDateOfBirth,
	ComplianceOfficerPlaceOfBirth,
	ComplianceOfficerName,
	IdAgentBusinessType,
	1, -- BM-668
	CASE 
		WHEN ISNULL(TypeTaxID,0) = 0 THEN 1
	END
From 
    dbo.AgentApplications A with(nolock)
    Left Join 
        dbo.CustomerIdentificationType C with(nolock) on (A.GuarantorIdType=C.IdCustomerIdentificationType)
    LEFT JOIN 
        dbo.AgentAppAchInformation i with(nolock) ON a.IdAgentApplication=i.IdAgentApplication
where 
    a.IdAgentApplication=@IdAgentApplication and AgentCode not in (Select AgentCode from dbo.Agent with(nolock))

If @@ROWCOUNT=0
	Begin
		--Rollback tran	
		Set @HasError=1                                                                                 
		Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,59)
	End
Else
	Begin
		--Commit tran
		Declare @IdAgent int
		Set @IdAgent=SCOPE_IDENTITY() 
		Insert into dbo.RelationAgentApplicationWithAgent (IdAgent,IdAgentApplication) values (@IdAgent,@IdAgentApplication)

		--assignar esquemas
                    DECLARE	
                            @enteredByIdUser int,
		                    @HasError2 bit,
		                    @MessageError2 nvarchar(max)

                            
                    select @enteredByIdUser=dbo.GetGlobalAttributeByName('SystemUserID')


					Insert into dbo.AgentStatusHistory (IdUser,IdAgent,IdAgentStatus,DateOfchange,Note) 
					VALUES (@enteredByIdUser,@IdAgent,@idAgentStatus,GETDATE(),'Initial Status')

                    Declare @HasErrorLH bit

                    EXEC	[Corp].[st_SaveAgentCreditLimitHistory]
		                    @IdAgent = @IdAgent,   
		                    @CreditLimitSuggested = @CreditAmount,
		                    @EnterbyIdUser = @enteredByIdUser,
		                    @HasError = @HasErrorLH OUTPUT

                    EXEC	[Corp].[st_SetAgentDefaultSchemas]
		                    @IdAgent = @IdAgent,
		                    @EnterByIdUser = @enteredByIdUser,
		                    @IdLenguage = 1,
		                    @HasError = @HasError2 OUTPUT,
		                    @MessageError = @MessageError2 OUTPUT


		DECLARE @IdAgentCollectTypeACH INT = (SELECT TOP 1 idAgentCollectType FROM dbo.AgentCollectType WITH (NOLOCK) WHERE LTRIM(RTRIM([Name])) = 'ACH')
		DECLARE @IdAgentCollectTypeACHScan INT = (SELECT TOP 1 idAgentCollectType FROM dbo.AgentCollectType WITH (NOLOCK) WHERE LTRIM(RTRIM([Name])) = 'ACH with Scanner')
		DECLARE @IdAgentBankDepositACH INT = (SELECT TOP 1 IdAgentBankDeposit FROM dbo.AgentBankDeposit WITH (NOLOCK) WHERE BankName like 'ACH%')
		DECLARE @IsAgentException BIT = (SELECT dbo.fn_GetIsAgentException(@idAgent))
		DECLARE @idAgentCollectTypeInserted INT = (SELECT TOP 1 idAgentCollectType FROM dbo.Agent WITH (NOLOCK) WHERE IdAgent = @IdAgent)
		DECLARE @idAgentBankDepositInserted INT = (SELECT TOP 1 IdAgentBankDeposit FROM dbo.Agent WITH (NOLOCK) WHERE IdAgent = @IdAgent)
	
		IF ((@IsAgentException = 0) AND (@IdAgentCollectTypeACH = @idAgentCollectTypeInserted OR @IdAgentCollectTypeACHScan = @idAgentCollectTypeInserted) AND (@idAgentBankDepositInserted = @IdAgentBankDepositACH))
		BEGIN
			EXEC [Corp].[st_AddNoteAgentException] 1, @idAgent, 1, @SystemUser, 'Mark as exception by system; ACH', @HasError, @Message
		END
		/*ELSE
		IF ((@IsAgentException = 1) AND (@idAgentCollectTypeInserted not in (@IdAgentCollectTypeACH,@IdAgentCollectTypeACHScan) OR @idAgentBankDepositInserted <> @IdAgentBankDepositACH))
		BEGIN
			EXEC [dbo].[st_AddNoteAgentException] 1, @idAgent, 0, @SystemUser, 'Mark as exception disabled by system; ACH', @HasError, @Message
		END*/--#1




		
		--copy phone numbers
		if exists (select 1 from dbo.AgentApplicationPhoneNumber with(nolock) where IdAgentApplication = @IdAgentApplication)
		begin
			INSERT INTO dbo.AgentPhoneNumber (IdAgent, PhoneNumber)
			select @IdAgent,PhoneNumber from dbo.AgentApplicationPhoneNumber with(nolock) where IdAgentApplication = @IdAgentApplication
		end

		--New RMM
		-- Copy Pending Files
		if exists (select 1 from dbo.PendingFilesAgentApp with(nolock) where IdAgentApplication = @IdAgentApplication)
		begin
			INSERT INTO dbo.PendingFilesAgent (IdAgent, IdDocumentType, ExpirationDate, IsUpload, IdUserCreate, DateCreate, IdUserLastChange, DateLastChange, IdGenericStatus) 
			 select @IdAgent, dt.IdDocumentTypeDad, pf.ExpirationDate, pf.IsUpload, pf.IdUserCreate, pf.DateCreate, pf.IdUserLastChange, pf.DateLastChange, pf.IdGenericStatus 
			 from dbo.PendingFilesAgentApp pf with(nolock)
             JOIN dbo.DocumentTypes dt with(nolock) ON pf.IdDocumentType=dt.IdDocumentType
             WHERE IdAgentApplication = @IdAgentApplication

			 update dbo.PendingFilesAgentApp set SendNotification = 0 where IdAgentApplication = @IdAgentApplication

		end
		if exists (select 1 from dbo.PendingFilesAgent with(nolock) where IsUpload = 0 and IdGenericStatus = 1 and ExpirationDate <= GETDATE() and IdAgent = @IdAgent)
		begin
			declare @idUser INT
			
			DECLARE @SuspCompliance BIT, @SuspAMLTraining BIT, @SuspAccRec BIT, @SuspFraudMonitor BIT, @SuspAgentAdmin BIT
			
			SELECT @SuspCompliance = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 1
			--SELECT @SuspAMLTraining = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 2
			SELECT @SuspAccRec = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 3
			SELECT @SuspFraudMonitor = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 4
			SELECT @SuspAgentAdmin = Suspended FROM Corp.AgentSuspendedSubStatus WHERE IdAgent = @IdAgent AND IdMaxiDepartment = 5
						
			set @idUser = [dbo].[GetGlobalAttributeByName]('SystemUserID')
			
			exec [Corp].[st_AgentStatusChange] @idAgent, 
												3, 
												@idUser, 
												'AML Training - Suspended by System', 
												NULL,
												@SuspCompliance, 
												1, 
												@SuspAccRec, 
												@SuspFraudMonitor, 
												@SuspAgentAdmin
			
			update dbo.Agent set SuspendedDatePendingFile = GETDATE() where IdAgent = @IdAgent
		end

		--End New RMM

		If exists (Select 1 from dbo.AgentApplications with(nolock) where HasBillPayment=1 and IdAgentApplication=@IdAgentApplication)
		Begin
			--BillPayment
            Declare @IdFeeByOtherProducts int,@IdCommissionByOtherProducts int
			Select top 1 @IdFeeByOtherProducts=IdFeeByOtherProducts from dbo.FeeByOtherProducts with(nolock)
			Select top 1 @IdCommissionByOtherProducts=IdCommissionByOtherProducts from dbo.CommissionByOtherProducts with(nolock)
			Insert into dbo.AgentProducts (IdAgent,IdOtherProducts,IdGenericStatus) values (@IdAgent,1,1)
			Insert into dbo.AgentBillPaymentInfo (IdAgent,AmountForClassF,IdFeeByOtherProducts,IdCommissionByOtherProducts)
			values(@IdAgent,@AmountForClassF,@IdFeeByOtherProducts,@IdCommissionByOtherProducts)			

            --LongDistance
            set @IdCommissionByOtherProducts=dbo.GetGlobalAttributeByName('IdCommissionDefaultPureMinutes')
            Insert into dbo.AgentProducts (IdAgent,IdOtherProducts,IdGenericStatus) values (@IdAgent,5,1)
            insert into dbo.AgentPureMinutesInfo (IdAgent, IdCommissionByOtherProducts) values (@idAgent, @IdCommissionByOtherProducts)

            --TopUp
            Insert into dbo.AgentProducts (IdAgent,IdOtherProducts,IdGenericStatus) values (@IdAgent,7,1)
            insert into dbo.AgentOtherProductInfo(IdAgent, IdOtherProduct, AmountForAgent, IdFeeByOtherProducts, IdCommissionByOtherProducts) values (@idAgent,  7, 0, null, null)

		End
		
			Insert into dbo.UploadFiles
			(
			    IdReference,
			    IdDocumentType,
			    [FileName],
			    FileGuid,
			    Extension,
			    IdStatus,
			    IdUser,
			    LastChange_LastUserChange,
			    LastChange_LastDateChange,
			    LastChange_LastIpChange,
			    LastChange_LastNoteChange
			)
			Select 
			    @IdAgent as IdReference,
			    B.IdDocumentTypeDad as IdDocumentType,
			    A.[FileName],
			    A.FileGuid,
			    A.Extension,
			    A.IdStatus,
			    @SystemUser as IdUser,
			    A.LastChange_LastUserChange,
			    A.LastChange_LastDateChange,
			    A.LastChange_LastIpChange,
			    A.LastChange_LastNoteChange
			from 
                dbo.UploadFiles A with(nolock)
			Join 
                dbo.DocumentTypes B with(nolock) on (A.IdDocumentType=B.IdDocumentType)
			Where 
                B.IdType=3 and IdReference=@IdAgentApplication
		
		/* Begin  Agent hisotry Change  */
		--DECLARE @NeedsWFSubaccountType    NVARCHAR(MAX) = 'NeedsWFSubaccount'
		--DECLARE @RequestWFSubaccountType  NVARCHAR(MAX) = 'RequestWFSubaccount'
		--DECLARE @NeedWFSubAccountIdUser INT = NULL
		--DECLARE @RequestWFSubAccountIdUser INT = NULL
		--DECLARE @NeedsWFSubaccount   BIT
		--DECLARE @RequestWFSubaccount BIT

		SELECT 
		@NeedsWFSubaccount = NeedsWFSubaccount, 
		@NeedWFSubAccountIdUser = NeedsWFSubaccountIduser, --#2 --@NeedWFSubAccountIdUser, 
		@RequestWFSubaccount = RequestWFSubaccount, 
		@RequestWFSubAccountIdUser = RequestWFSubaccountIdUser 
		FROM dbo.Agent with(nolock)
		where IdAgent = @IdAgent;

		IF (@NeedsWFSubaccount = 1)
		BEGIN
			EXEC [Corp].[st_saveAgentChangeHistory] @idAgent, @NeedsWFSubaccount,@NeedsWFSubaccountType, @NeedWFSubAccountIdUser, 1;							
		END

		IF (@RequestWFSubaccount = 1)
		BEGIN
			EXEC [Corp].[st_saveAgentChangeHistory] @idAgent, @RequestWFSubaccount, @RequestWFSubaccountType , @RequestWFSubAccountIdUser, 1;
		END 
		/* End   Agent hisotry Change  */

		set @IdNewAgent=@IdAgent

		DECLARE @IdUserTrainingCommunication INT = [dbo].[GetGlobalAttributeByName]('SystemUserID')
		EXEC st_SetActiveTrainingCommunication @IdNewAgent, @IdUserTrainingCommunication

		Set @HasError=0         
		set @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,55)
		Select @Message,@IdNewAgent
	End	

                                     
End Try                                                                                          
Begin Catch      
 Set @HasError=1                                                                                 
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,59)                                                                             
 Declare @ErrorMessage nvarchar(max)                                                                                           
 Select @ErrorMessage=ERROR_MESSAGE()                                           
 Insert into dbo.ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_MoveAgentAppToAgent]',Getdate(),@ErrorMessage)                                                                                          
End Catch



