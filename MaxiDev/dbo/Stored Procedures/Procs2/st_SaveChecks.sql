
/*
*/

--ojo: RENOMBRAR SP AL NOMBRE FINAL CUANDO SE PASE A PROD
CREATE PROCEDURE [dbo].[st_SaveChecks](
@IdAgent int, 
@IdCustomer int, 
@IdIssuer int,
@CustomerName varchar(MAX), 
@CustomerFirstLastName varchar(MAX), 
@CustomerSecondLastName varchar(MAX), 
@IdentificationType varchar(MAX),
@State varchar(MAX), 
@DateOfBirth datetime, 
@IdIdentificationType int,
@IdentificationDateOfExpiration datetime, 
@Ocupation varchar(MAX), 

@CustomerIdOccupation int = 0, /*M00207*/
@CustomerIdSubcategoryOccupation int = 0,/*M00207*/
@CustomerSubcategoryOccupationOther nvarchar(max) =null,/*M00207*/  
@IdentificationNumber varchar(MAX), 
@CountryOfBirthId INT, 
@CheckNumber varchar(MAX), 
@RoutingNumber varchar(MAX), 
@Account varchar(MAX),
@Micr varchar(MAX),
@MicrAuxOnUs varchar(MAX),
@MicrRoutingTransitNumber varchar(MAX),
@MicrOnUs varchar(MAX),
@MicrAmount varchar(MAX), 
@IssuerName varchar(MAX), 
@DateOfIssue datetime, 
@Amount money, 
@EnteredByIdUser int, 
@IdLenguage int,
@Fee money,  
@IsDuplicate int,	--Req 00158							 

@IsSaveCustomer bit,
@CustomerIdentificationIdState varchar(MAX),
@CustomerSSNumber varchar(MAX),
@CustomerTypeTaxID int,   --Req 00158								 
@CustomerAddress varchar(MAX),
@CustomerCity varchar(MAX),
@CustomerState varchar(MAX),
@CustomerZipcode varchar(MAX),
@CustomerPhoneNumber varchar(MAX),
@CustomerCelullarNumber varchar(MAX),
@CustomerIdCarrier int,
@CustomerIdentificationIdCountry int,
@IsEndorse bit,
@ManualMicrHold bit = null,
@MicrManual varchar(MAX)= null,
@IssuerPhone varchar(30)= null,

@ValidationFee Money = null, /*20-Sep-2016*/
@TransactionFee Money = null, /*20-Sep-2016*/

@HasError bit OUTPUT, 
@Message varchar(MAX) OUTPUT,
@IdCustomerOutput int OUTPUT, 
@IdCheck int OUTPUT,
@isDeny bit OUTPUT, 
@MessageDeny varchar(MAX) OUTPUT,
@isOFAC bit OUTPUT, 
@MessageOFAC varchar(MAX) OUTPUT,
@IdIssuerOut int OUTPUT,
@isDupliate bit OUTPUT,
@idElasticCustomer varchar(max) output /*Optimizacion Agente*/

,@IsIRD BIT = 0
,@MicrEPC VARCHAR(1) = ''

,@OriCheckNum VARCHAR(100)=''
,@OriCheckNumScore INT = 0

,@OriRouting VARCHAR(100)=''
,@OriRoutingScore INT = 0

,@OriAccount VARCHAR(100)=''
,@OriAccountScore INT = 0

,@OriAmount MONEY = 0
,@OriAmountScore INT = 0

,@OriDateOfIssue DATETIME = NULL
,@OriDateOfIssueScore INT = 0

,@GUID VARCHAR(max)  = NULL /*Optimizacion Batch MP-1230*/
,@IsBatch BIT = 0 /*Optimizacion Batch MP-1230*/
,@IsDateOfIssueBySystem BIT = NULL /*Optimizacion Batch MP-1230*/
,@IdCheckGuid VARCHAR(max) = NULL /*Optimizacion Batch MP-1230*/

,@AmountBatch VARCHAR(max) = NULL OUTPUT /*Optimizacion Batch MP-1230*/
,@FeeBatch VARCHAR(max) = NULL OUTPUT /*Optimizacion Batch MP-1230*/
,@Totbatch VARCHAR(max) = NULL OUTPUT /*Optimizacion Batch MP-1230*/

,@IdCheckGuidOutBatch VARCHAR(max)  = NULL OUTPUT /*Optimizacion Batch MP-1230*/
,@IdCheckOutBatch INT = NULL OUTPUT /*Optimizacion Batch MP-1230*/
,@IdIssuerOutBatch INT = NULL OUTPUT /*Optimizacion Batch MP-1230*/
,@CheckNewOutBatch INT = NULL OUTPUT /*Optimizacion Batch MP-1230*/
,@IdStatusOutBatch INT = NULL OUTPUT /*Optimizacion Batch MP-1230*/
,@DateOfMovementOutBatch datetime = NULL OUTPUT /*Optimizacion Batch MP-1230*/
,@IdCustomerOutBatch INT = NULL OUTPUT /*Optimizacion Batch MP-1230*/
,@IdElasticCustomerOutBatch VARCHAR(MAX) = NULL OUTPUT /*Optimizacion Batch MP-1230*/
,@IsUpdateOutBatch BIT = NULL OUTPUT /*Optimizacion Batch MP-1230*/

)
AS
/********************************************************************
<Author>Aldo Morán Márquez</Author>
<app>Agent</app>
<Description>This SP Insert a new check in the corresponding Table and also checks if the names has holds.</Description>

<ChangeLog>
<log Date="20/03/2015" Author="amoran"> Creación </log>
<log Date="02/02/2017" Author="fgonzalez"> Se realiza cambio #1 para que encuentre el ultimo fee registrado al agente.</log>
<log Date="18/01/2018" Author="azavala">Optimizacion Agente : Se agregan parametros de salida necesarios para una actualizacion en ElasticSearch</log>
<log Date="08/11/2018" Author="jmolina">Se agrega validación de limite en amount por agencia #1</log>
<log Date="31/03/2020" Author="bortega">Agregar campos Tax Req:: 00158</log>
<log Date="31/03/2020" Author="jgomez">M00210 - Merge de SP para requerimientos M00193 y M00158</log>	
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>																		
<log Date="2022/1/12" Author="jcsierra" Name="SD1-1291">Se implementa whitelist de issuer</log>
<log Date="2022/08/26" Author="maprado" Name="MP-1230">Optimizar procesamiento cheques batch</log>
</ChangeLog>
*********************************************************************/

BEGIN
	Begin Try
	--2016-07-25. New Check Flow. In order to save a check from Individual scanning it's necessary to set an IdIdentificationType such as batch check does. All batch checks are saved in this way so we did the same for
	--individual checks without additional info

	if @CustomerSubcategoryOccupationOther IS NULL Set @CustomerSubcategoryOccupationOther='' 

	IF(@IdIdentificationType = 0 OR @IdIdentificationType is null) 
		SET @IdIdentificationType = 63

	------ se revisa lenguage ------
		DECLARE @IsSpanish bit
		SET @IsSpanish = 1
		if(@IdLenguage = 1)
			Begin
				SET @IsSpanish = 0
			End
	------ se revisa lenguage ------

    
    IF 
      exists(select 1 from checks with(nolock) where CheckNumber=@CheckNumber and	RoutingNumber=@RoutingNumber and	Account=@Account and idagent=@idagent and amount=@Amount and idstatus not in (31,22))
    BEGIN
        SET @isDeny = 0      
        SET @isOFAC = 0      
        SET @isDupliate = 0      
        SET @HasError = 1
        SET @Message =  dbo.GetMessageFromLenguajeResorces (@IsSpanish,108)
		SET @IdCheckGuidOutBatch = @IdCheckGuid
		SET @IdCheckOutBatch = @IdCheck
		SET @IdIssuerOutBatch = @IdIssuer
		SET @CheckNewOutBatch = 0
		SET @IdStatusOutBatch = 999
		SET @DateOfMovementOutBatch = GETDATE()
		SET @IdCustomerOutBatch = @IdCustomer
		SET @IdElasticCustomerOutBatch = ''
		SET @IsUpdateOutBatch = 0
        RETURN
    END

	/* Se Agrega validacion para bloquear rejected que no sean IRD */
	IF 
      exists(select 1 from checks with(nolock) where CheckNumber=@CheckNumber and	RoutingNumber=@RoutingNumber and	Account=@Account and idagent=@idagent and amount=@Amount 
	  and @isIrd = 0 AND idstatus = 31)/*IdStatus 31 = Rejected*/
    BEGIN
        SET @isDeny = 0      
        SET @isOFAC = 0      
        SET @isDupliate = 0      
        SET @HasError = 1
        SET @Message =  dbo.GetMessageFromLenguajeResorces (@IsSpanish,108)
		SET @IdCheckGuidOutBatch = @IdCheckGuid
		SET @IdCheckOutBatch = @IdCheck
		SET @IdIssuerOutBatch = @IdIssuer
		SET @CheckNewOutBatch = 0
		SET @IdStatusOutBatch = 999
		SET @DateOfMovementOutBatch = GETDATE()
		SET @IdCustomerOutBatch = @IdCustomer
		SET @IdElasticCustomerOutBatch = ''
		SET @IsUpdateOutBatch = 0
        RETURN
    END
	

	IF @Amount > (SELECT  MAX(FC.ToAmount) FROM FeeChecks AS F with(nolock) inner JOIN FeeChecksDetail AS FC with(nolock) ON (F.IdFeeChecks = FC.IdFeeChecks ) WHERE IdAgent = @IdAgent) --#1
	BEGIN
			SET @isDeny = 0      
			SET @isOFAC = 0      
			SET @isDupliate = 0      
			SET @HasError = 1
			SET @Message = dbo.GetMessageFromLenguajeResorces (@IsSpanish,121)
			SET @IdCheckGuidOutBatch = @IdCheckGuid
			SET @IdCheckOutBatch = @IdCheck
			SET @IdIssuerOutBatch = @IdIssuer
			SET @CheckNewOutBatch = 0
			SET @IdStatusOutBatch = 999
			SET @DateOfMovementOutBatch = GETDATE()
			SET @IdCustomerOutBatch = @IdCustomer
			SET @IdElasticCustomerOutBatch = ''
			SET @IsUpdateOutBatch = 0
			RETURN
	END

		DECLARE @isDeny2 Bit
		DECLARE @MessageDeny2 varchar(MAX)
		DECLARE @DateOfLastChange datetime
		DECLARE @IdGenericStatus int
		DECLARE @PhysicalIdCopy bit
		DECLARE @AmountInDorllars money
		DECLARE @Transaction_Fee money /**/
		DECLARE @CustomerReceiveSms BIT

		SET @DateOfLastChange = GETDATE()
		SET @IdGenericStatus = 1
		SET @PhysicalIdCopy =  0
		SET @AmountInDorllars = 0
		SET @Transaction_Fee = 0 /**/
		SET @CustomerReceiveSms = 0
		
		SET @isDeny = 0
		SET @isOFAC = 0
		SET @isDupliate = 0
		SET @MessageOFAC= ''
		SET @MessageDeny = ''

		SET @HasError = 0
		SET @Message =  dbo.GetMessageFromLenguajeResorces (@IsSpanish,97)

		DECLARE @CustomerFee Money /*Optimizacion Batch MP-1230*/
		SET @CustomerFee = @ValidationFee /*Optimizacion Batch MP-1230*/

		------------------------------Inician Todas las Validaciones de limites----------------------------------------------

		DECLARE @BeginDate datetime
		DECLARE @BeginAmountDate datetime
		DECLARE @EndDate datetime
		DECLARE @ChecksCount int
		DECLARE @AccumulatedCustomer money
		DECLARE @AccumulatedIssuer money

		SET @BeginDate = (select DATEADD(day, -(select cast((select Value from GlobalAttributes with(nolock) where name = 'CheckLimitDaysPerCustomer') as int)), GETDATE()))
		SET @BeginAmountDate = (select DATEADD(day, -(select cast((select Value from GlobalAttributes with(nolock) where name = 'CheckLimitDaysAmount') as int)), GETDATE()))
		SET @EndDate = GETDATE()

		SET @ChecksCount = (select Count(idCheck) from checks with(nolock) where IdStatus NOT IN (31, 22) AND idcustomer = @IdCustomer AND CAST(DateOfMovement AS DATE) = CAST(GETDATE() AS DATE))
		SET @AccumulatedCustomer = (select cast ((select sum(Amount) from checks with(nolock) where IdStatus NOT IN (31, 22) AND idcustomer = @IdCustomer AND CAST(DateOfMovement AS DATE) = CAST(GETDATE() AS DATE)) as money) + @Amount)
		SET @AccumulatedIssuer = (select cast ((select sum(Amount) from checks with(nolock) where IdStatus NOT IN (31, 22) AND idissuer = @IdIssuer AND CAST(DateOfMovement AS DATE) = CAST(GETDATE() AS DATE)) as money) + @Amount)
		
		--Existing Check--
		DECLARE @ExistingHold Int
		SET @ExistingHold = 0

		if (exists (select checknumber from Checks with(nolock) where CheckNumber = @CheckNumber AND RoutingNumber = @RoutingNumber AND Account = @Account AND IdStatus <> 31))
		begin 
			SET @ExistingHold = 1;		
		end

		--Existing Check--

		-----------------------------------< Insert/Update Customer >----------------------------                                                                                            
		
			if @IdCustomer > 0
			begin 
				select @IdGenericStatus = IdGenericStatus, @PhysicalIdCopy = PhysicalIdCopy, @AmountInDorllars =  SentAverage, @CustomerReceiveSms = [ReceiveSms] from Customer WITH (NOLOCK) WHERE IdCustomer = @IdCustomer
			end
			                                             
			EXEC [dbo].[st_InsertCustomerByTransfer]
				@IdCustomer = @IdCustomer,                                                                                            
				@IdAgentCreatedBy = @IdAgent,                                                       
				@IdCustomerIdentificationType = @IdIdentificationType,                                                                                            
				@IdGenericStatus = @IdGenericStatus,                                                                                        
				@Name = @CustomerName,                                                                                              
				@FirstLastName = @CustomerFirstLastName,                                       
				@SecondLastName = @CustomerSecondLastName,                                                                                      
				@Address = @CustomerAddress,                                                                                      
				@City = @CustomerCity,                                                                                              
				@State = @CustomerState,                                                                   
				@Country = 'USA',                                                                                              
				@Zipcode = @CustomerZipcode,                                                                                              
				@PhoneNumber = @CustomerPhoneNumber,                                                                                              
				@CelullarNumber = @CustomerCelullarNumber,                                                                                              
				@SSNumber = @CustomerSSNumber,                                                                      
				@TypeTaxID = @CustomerTypeTaxID,		--Req 00158
				@IsDuplicate = @IsDuplicate,             --Req 00158 								 																					   
				@BornDate = @DateOfBirth,                                        
				@Occupation = @Ocupation,
				@IdOccupation = @CustomerIdOccupation , /*M00207*/
				@IdSubcategoryOccupation = @CustomerIdSubcategoryOccupation,/*M00207*/
				@SubcategoryOccupationOther= @CustomerSubcategoryOccupationOther,/*M00207*/                                                                                         
				@IdentificationNumber = @IdentificationNumber,                   
				@PhysicalIdCopy = @PhysicalIdCopy,                                                                                              
				@DateOfLastChange = @DateOfLastChange,
				@EnterByIdUser = @EnteredByIdUser,                                                                                            
				@ExpirationIdentification = @IdentificationDateOfExpiration,                                                                          
				@IdCarrier = @CustomerIdCarrier,     
				@IdentificationIdCountry = @CustomerIdentificationIdCountry ,  
				@IdentificationIdState = @CustomerIdentificationIdState , 
				@AmountSend = @AmountInDorllars,
				@IdCustomerCountryOfBirth = @CountryOfBirthId,
				@CustomerReceiveSms = @CustomerReceiveSms,
				@IdCustomerOutput = @IdCustomerOutput OUTPUT, /*Optimizacion Agente*/
				@idElasticCustomer = @idElasticCustomer Output; /*Optimizacion Agente*/

				--update customer set IdCustomerIdentificationType = @IdIdentificationType where @IdCustomerOutput = @IdCustomerOutput

		-----------------------------------</ Insert/Update Customer >----------------------------     

		--Max Amount Per Check--
		
		--#1 Se hace un top 1 ordenado por fecha para evitar multiples resultados
		if((SELECT TOP 1 TransactionFee from FeeChecks with(nolock) where IdAgent = @IdAgent ORDER BY DateOfLastChange DESC ) > 0)begin
			if(@Amount > (select cast((select Value from GlobalAttributes with(nolock) where name = 'MaxAmountForcheck') as money)))
			begin 
				SET @HasError = 1
				SET @Message  = dbo.GetMessageFromLenguajeResorces (@IsSpanish,95)
				SET @IdCheckGuidOutBatch = @IdCheckGuid
				SET @IdCheckOutBatch = @IdCheck
				SET @IdIssuerOutBatch = @IdIssuer
				SET @CheckNewOutBatch = 0
				SET @IdStatusOutBatch = 999
				SET @DateOfMovementOutBatch = GETDATE()
				SET @IdCustomerOutBatch = @IdCustomer
				SET @IdElasticCustomerOutBatch = ''
				SET @IsUpdateOutBatch = 0
				return
			end
		end
		else 
		begin
			/*20-Sep-2016 : @TransactionFee -> @Transaction_Fee*/
			SET @Transaction_Fee = (select cast ((select top 1 FD.ToAmount from FeeChecks FC with(nolock)
									join FeeChecksDetail FD with(nolock) on FD.IdFeeChecks = FC.IdFeeChecks 
								where FC.IdAgent = @IdAgent  AND FC.TransactionFee = 0 order by FD.IdFeeChecksDetail desc) as money))

			If(@Transaction_Fee > 0 AND @Amount > @Transaction_Fee)
			Begin
				SET @HasError = 1
				SET @Message  = dbo.GetMessageFromLenguajeResorces (@IsSpanish,95)
				SET @IdCheckGuidOutBatch = @IdCheckGuid
				SET @IdCheckOutBatch = @IdCheck
				SET @IdIssuerOutBatch = @IdIssuer
				SET @CheckNewOutBatch = 0
				SET @IdStatusOutBatch = 999
				SET @DateOfMovementOutBatch = GETDATE()
				SET @IdCustomerOutBatch = @IdCustomer
				SET @IdElasticCustomerOutBatch = ''
				SET @IsUpdateOutBatch = 0
				return
			End
		end
		
		--Max Amount Per Check--

		--Max number of checks--
		DECLARE @MaxNumberOfChecks nvarchar(max)
		select @MaxNumberOfChecks = Value from GlobalAttributes with(nolock) where name = 'CheckLimitPerCustomer'

		if(@ChecksCount >=  cast(@MaxNumberOfChecks as int))
		Begin
			SET @HasError = 1
			SET @Message  = dbo.GetMessageFromLenguajeResorces (@IsSpanish,99) + @MaxNumberOfChecks + dbo.GetMessageFromLenguajeResorces (@IsSpanish,107)
			SET @IdCheckGuidOutBatch = @IdCheckGuid
			SET @IdCheckOutBatch = @IdCheck
			SET @IdIssuerOutBatch = @IdIssuer
			SET @CheckNewOutBatch = 0
			SET @IdStatusOutBatch = 999
			SET @DateOfMovementOutBatch = GETDATE()
			SET @IdCustomerOutBatch = @IdCustomer
			SET @IdElasticCustomerOutBatch = ''
			SET @IsUpdateOutBatch = 0
			return
		End

		--Max number of checks--

		--Max Accumulated By Customer--

		if(@AccumulatedCustomer > (select cast((select Value from GlobalAttributes with(nolock) where name = 'CheckLimitAmountPerCustomer') as money)))
		Begin
			SET @HasError = 1
			SET @Message  = dbo.GetMessageFromLenguajeResorces (@IsSpanish,100)
			SET @IdCheckGuidOutBatch = @IdCheckGuid
			SET @IdCheckOutBatch = @IdCheck
			SET @IdIssuerOutBatch = @IdIssuer
			SET @CheckNewOutBatch = 0
			SET @IdStatusOutBatch = 999
			SET @DateOfMovementOutBatch = GETDATE()
			SET @IdCustomerOutBatch = @IdCustomer
			SET @IdElasticCustomerOutBatch = ''
			SET @IsUpdateOutBatch = 0
			return
		End

		--Max Accumulated By Customer--

		--Max Accumulated By Issuer--

		if(@AccumulatedIssuer > (select cast((select Value from GlobalAttributes with(nolock) where name = 'CheckLimitAmountPerIssuer') as money)))
		Begin
			SET @HasError = 1
			SET @Message  = dbo.GetMessageFromLenguajeResorces (@IsSpanish,101)
			SET @IdCheckGuidOutBatch = @IdCheckGuid
			SET @IdCheckOutBatch = @IdCheck
			SET @IdIssuerOutBatch = @IdIssuer
			SET @CheckNewOutBatch = 0
			SET @IdStatusOutBatch = 999
			SET @DateOfMovementOutBatch = GETDATE()
			SET @IdCustomerOutBatch = @IdCustomer
			SET @IdElasticCustomerOutBatch = ''
			SET @IsUpdateOutBatch = 0
			return
		End

		--Max Accumulated By Issuer--

		------------------------------Inician Todas las Validaciones de limites----------------------------------------------

		if(@HasError = 0)
		begin

	----------------------------------- Insert Issuer --------------------------------------

			EXEC st_InsertIssuerChecks @IdIssuer, @IssuerName, @RoutingNumber, @Account, @EnteredByIdUser, @IssuerPhone, @IdIssuerOut output;

	----------------------------------- Insert Check --------------------------------------

			DECLARE @IdCheckStatus int
			DECLARE @ClaimCheck varchar(50)

			Create Table #ClaimChecks (Result nvarchar(max))
			Insert into #ClaimChecks (Result)
			EXEC ST_TNC_CLAIM_CODE_GEN N'WF';
			Select @ClaimCheck = ltrim(rtrim(Result)) From #ClaimChecks    

			---------commissions and fee -----------

			DECLARE @Commission Money
			--DECLARE @Fee Money
			--DECLARE @IdFeeChecks int

			select @Commission = ReturnCheckFee from FeeChecks with(nolock) where IdAgent = @IdAgent

			/*20-Sep-2016*/
			DECLARE @ReturnFee Money
			SET @ReturnFee = ISNULL(@Commission,0);

			IF (@IsBatch = 1)
			BEGIN
				SET @ExistingHold = 0

				if (exists (select checknumber from Checks with(nolock) where CheckNumber = @CheckNumber AND RoutingNumber = @RoutingNumber AND Account = @Account AND IdStatus <> 31 AND IdStatus <> 22))
				begin				
					SET @ExistingHold = 1		
				end

				SET @AmountBatch = convert(varchar(max),@Amount)
				SET @FeeBatch = convert(varchar(max),@Fee)
				SET @Totbatch = convert(varchar(max),1)

				INSERT INTO
					Checks(IdAgent, IdCustomer, Name, FirstLastName, SecondLastName, IdentificationType, [State], DateOfBirth, IdIdentificationType
					, IdentificationDateOfExpiration, Ocupation, IdentificationNumber, CheckNumber, RoutingNumber, Account, IssuerName, DateOfIssue
					, Amount, IsEndorsed, IdStatus, DateOfMovement, DateStatusChange, DateOfLastChange, EnteredByIdUser, IdIssuer, ClaimCheck, BachCode, Comission, Fee
					, MicrOriginal,MicrAuxOnUs, MicrRoutingTransitNumber,MicrOnUs,MicrAmount, MicrManual
					, CustomerFee, TransactionFee, ReturnFee, IsIRD, MicrEPC,IsDateOfIssueBySystem )
				VALUES 
					(@IdAgent, @IdCustomerOutput, @CustomerName, @CustomerFirstLastName, @CustomerSecondLastName, @IdentificationType, @State, null, @IdIdentificationType, 
					null, @Ocupation, @IdentificationNumber, @CheckNumber, @RoutingNumber, @Account, @IssuerName, @DateOfIssue, 
					@Amount, 1, 1, GETDATE(), GETDATE(), GETDATE(), @EnteredByIdUser, @IdIssuerOut, @ClaimCheck, @GUID, @Commission, @Fee
					,@Micr,@MicrAuxOnUs, @MicrRoutingTransitNumber,@MicrOnUs,@MicrAmount, @MicrManual
					,@CustomerFee, @TransactionFee, @ReturnFee, @IsIRD, @MicrEPC,@IsDateOfIssueBySystem);
					--ojo ver el insertar si es ird y epc
			END
			ELSE
			BEGIN
				INSERT INTO
					Checks(IdAgent, IdCustomer, Name, FirstLastName, SecondLastName, IdentificationType, [State], DateOfBirth, IdIdentificationType
					, IdentificationDateOfExpiration, Ocupation, IdentificationNumber, CheckNumber, RoutingNumber, Account, IssuerName, DateOfIssue
					, Amount, IsEndorsed, IdStatus, DateOfMovement, DateStatusChange, DateOfLastChange, EnteredByIdUser, IdIssuer, ClaimCheck, comission, fee
					, MicrOriginal,MicrAuxOnUs, MicrRoutingTransitNumber,MicrOnUs,MicrAmount, MicrManual, [CountryBirthId]
					, CustomerFee, TransactionFee, ReturnFee, IsIRD, MicrEPC)
				VALUES 
					(@IdAgent, @IdCustomerOutput, @CustomerName, @CustomerFirstLastName, @CustomerSecondLastName, @IdentificationType, @State, @DateOfBirth, @IdIdentificationType 
					,@IdentificationDateOfExpiration, @Ocupation, @IdentificationNumber, @CheckNumber, @RoutingNumber, @Account, @IssuerName, @DateOfIssue 
					,@Amount, 1, 1, GETDATE(), GETDATE(), GETDATE(), @EnteredByIdUser, @IdIssuerOut, @ClaimCheck, @Commission, @Fee
					,@Micr,@MicrAuxOnUs, @MicrRoutingTransitNumber,@MicrOnUs,@MicrAmount, @MicrManual, @CountryOfBirthId
					,@ValidationFee ,@TransactionFee ,@ReturnFee, @IsIRD, @MicrEPC);
			END

			set @IdCheck = (SELECT SCOPE_IDENTITY())
			set @IdCheckStatus = (select IdStatus from Checks with(nolock) where IdCheck = @IdCheck)
			Declare @IdUserSystem int  
			Select @IdUserSystem = [Value] from GlobalAttributes with(nolock) where Name = 'SystemUserID'
			/*07-Sep-2021*/
			/*UCF*/
			/*Todos los cheques procesados hacen abono al balance del agente desde que se procesa*/
			EXEC checks.st_CheckApplyToAgentBalance @IdCheck
			/*En caso de ser IRD mantener IrdPrint de tabla RejectedChecks como 1*/
			if @IsIRD = 1
			Begin 
				declare @originalcheck as int = 0;
				set @originalcheck = (select h.IdCheck from CheckRejectHistory as h
				inner join Checks on (h.IdCheck = Checks.IdCheck)
				where Checks.CheckNumber = @CheckNumber
				and Checks.Account = @Account
				and Checks.RoutingNumber = @RoutingNumber)
					if @originalcheck > 0
					begin
						Update CheckRejectHistory set IrdPrinted = 1 where IdCheck = @originalcheck
					end
			end



			If @IdCheckStatus = 1
			Begin

							----------------------------------- Verify Endorse --------------------------------------

				--SET @MessageOFAC= ''

				----- OFAC validation ..  
				--Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,58,'Endorse Validation',0 --- Log de OFAC validacion            

			
				--If (@IsEndorse=0)
				--Begin           
				--	Insert Into [dbo].[CheckHolds]([IdCheck],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
				--		Values(@IdCheck,57,GETDATE(),GETDATE() ,@IdUserSystem)  
				--	Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,57,'Endorse Hold',0 -- Log , se ha detenido en Endorse Hold                       

				--	SET @MessageOFAC = 'Mensaje personalizado que el cheque cayo en ofac falta poner los idiomas'
				--End       
			
				-------------- Verify Amount for Hold -----------------
				--2021-07, Hace hold si el monto es >= al valor del parametro, se usa status 57
				DECLARE @AmountForHold MONEY;
				SELECT @AmountForHold = ISNULL(TRY_CAST(Value AS MONEY),0) FROM dbo.GlobalAttributes WHERE [Name]='AmountValue_ForHold';
				IF @AmountForHold > 0
				IF @Amount >= @AmountForHold
				BEGIN
					INSERT INTO [dbo].[CheckHolds]([IdCheck],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])
					VALUES( @IdCheck, 57, GETDATE(), GETDATE(), @IdUserSystem );
					EXEC Checks.[st_SaveChangesToCheckLog] @IdCheck,57,'Endorse Hold',0; -- Log , se ha detenido en Endorse Hold
				END;


----------------------------------------------------------------------------------------------------------------------------------

	----------------------------------- Verify Image Checks --------------------------------------
	/*2016/Ago/08*/
				SET @MessageOFAC= '';

				--67	Image Checks Validation
				Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,67,'Image Checks Validation',0; --- Log de Image Checks Validation

			
				--68 ->Image Checks Hold
					Insert Into [dbo].[CheckHolds]([IdCheck],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
						Values(@IdCheck,68,GETDATE(),GETDATE() ,@IdUserSystem);
					Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,68,'Image Checks Hold',0; -- Log , se ha detenido en Image Checks Hold

					SET @MessageOFAC = 'Mensaje personalizado que el cheque cayo en image hold falta poner los idiomas';

				--69 ->Image Checks Accepted
----------------------------------------------------------------------------------------------------------------------------------

	----------------------------------- Edited Checks Hold --------------------------------------

				SET @MessageOFAC= ''
				SET @ManualMicrHold = 0;
				EXEC Checks.[st_SaveChangesToCheckLog] @IdCheck,63,'Edited Checks Hold Validation',0; --- Edited Checks Hold validacion

				--checks if data was modified vs original
				EXEC dbo.[st_SaveCheckEdits]
				    @IdCheck = @IdCheck, -- int
				    @OriRouting      = @OriRouting,
				    @OriRoutingScore = @OriRoutingScore,
				    @Routing         = @RoutingNumber,
					---
				    @OriAccount = @OriAccount,
				    @OriAccountScore = @OriAccountScore,
				    @Account = @Account,
					---
				    @OriCheckNum = @OriCheckNum,
				    @OriCheckNumScore = @OriCheckNumScore,
				    @CheckNum = @CheckNumber,
					---
				    @OriDateOfIssue = @OriDateOfIssue,
				    @OriDateOfIssueScore = @OriDateOfIssueScore,
				    @DateOfIssue = @DateOfIssue,
					---
				    @OriAmount = @OriAmount,
				    @OriAmountScore = @OriAmountScore,
				    @Amount = @Amount,
					---
				    @IsEdited = @ManualMicrHold OUT
				
				If (@ManualMicrHold=1)
				Begin           
					Insert Into [dbo].[CheckHolds]([IdCheck],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
						Values(@IdCheck,64,GETDATE(),GETDATE() ,@IdUserSystem);  
					Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,64,'Edited Checks Hold',0; -- Log , se ha detenido en Edited Checks Hold

					SET @MessageOFAC = 'Mensaje personalizado que el cheque cayo en ofac falta poner los idiomas'
				End


----------------------------------EXISTING HOLD--------------------------------------
              
					SET @MessageOFAC= ''

					--- OFAC validation ..  
					Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,60,'Duplicate Checks Validation',0; --- Log de OFAC validacion            

			
					If (@ExistingHold=1)
					Begin           
						Insert Into [dbo].[CheckHolds]([IdCheck],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
							Values(@IdCheck,61,GETDATE(),GETDATE() ,@IdUserSystem);  
						Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,61,'Duplicate Checks Hold',0; -- Log , se ha detenido en Endorse Hold                       
						SET @isDupliate = 1
						SET @MessageOFAC = 'Mensaje personalizado que el cheque cayo en ofac falta poner los idiomas'
					End               

	----------------------------------- Verify Deny List --------------------------------------

				Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,11,'Deny List Verification',0; --- Log de DenyList validacion  

				EXEC [dbo].[st_FindDenyListByNameChecks]
	    			@Name = @CustomerName,
					@FirstLastName = @CustomerFirstLastName,
					@SecondLastName = @CustomerSecondLastName,
					@IdLenguage = @IdLenguage,
					@IsCustomer = 1,
					@HasError = @isDeny OUTPUT,
					@Message = @MessageDeny OUTPUT;
					
				EXEC [dbo].[st_FindDenyListIssuerByNameChecks]
	    				@Name = @IssuerName,
						@IdLenguage = @IdLenguage,
						@HasError = @isDeny2 OUTPUT,
						@Message = @MessageDeny2 OUTPUT;  
						
				IF EXISTS (SELECT 1 
					FROM WhiteListIssuerChecks wl WITH(NOLOCK) 
						JOIN IssuerChecks ic WITH(NOLOCK) ON ic.IdIssuer = wl.IdIssuerCheck
					WHERE 
						ic.IdIssuer = @IdIssuerOut
						OR (ic.RoutingNumber = @RoutingNumber AND ic.AccountNumber = @Account))
				BEGIN
					Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,12,'Issuer whitelisted, issuer denylist match by name is ignored',0; 
					SET @isDeny2 = 0
				END

				If (@isDeny=1 OR  @isDeny2=1)
					BEGIN  
						Insert Into [dbo].[CheckHolds]([IdCheck],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
						Values(@IdCheck,12,GETDATE(),GETDATE() ,@IdUserSystem);  
						Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,12,'Deny List Hold',0; -- Log , se ha detenido en DenyList Hold hold  
					END

				If (@isDeny=0 AND @isDeny2=1)
					Begin  
						SET @isDeny = @isDeny2
						SET @MessageDeny = @MessageDeny2
					End  

	----------------------------------- Verify OFAC --------------------------------------
        
				SET @MessageOFAC= ''

                --Cambios Ofac
                Declare @IsOFACDoubleVerification bit = 0

				--- OFAC validation ..  
				Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,14,'OFAC Verification',0; --- Log de OFAC validacion            

				--Verificacion Ofac
				EXEC	checks.[st_SaveCheckOFACInfo]
						@IdCheck = @IdCheck,		        
						@CustomerName = @CustomerName,
						@CustomerFirstLastName = @CustomerFirstLastName,
						@CustomerSecondLastName = @CustomerSecondLastName,		        
						@IssuerName = @IssuerName,		        
						@IsOFAC =  @isOFAC OUTPUT,
                        --Cambios Ofac
                        @IsOFACDoubleVerification =  @IsOFACDoubleVerification OUTPUT; 

				If (@IsOFAC=1)
				Begin           
					
                    Insert Into [dbo].[CheckHolds]([IdCheck],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
						Values(@IdCheck,15,GETDATE(),GETDATE() ,@IdUserSystem);  
					Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,15,'OFAC Hold',0; -- Log , se ha detenido en OFAC Hold                       

                    --Cambios Ofac
                   if (@IsOFACDoubleVerification=1)
                   begin
                    Insert Into [dbo].[CheckHolds]([IdCheck],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
                        Values(@IdCheck,15,GETDATE(),GETDATE() ,@IdUserSystem); 
                    Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,15,'OFAC Hold',0; -- Log , se ha detenido en OFAC Hold  
                   end

					SET @MessageOFAC = 'Mensaje personalizado que el cheque cayo en ofac falta poner los idiomas'
				End  

----------------------------------------------------------------------------------------------------------------------------------

				Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,41,'Verify Hold',0; --- Log de validación de Multiholds  
				Update checks Set IdStatus=41,DateStatusChange=GETDATE() Where IdCheck=@IdCheck;  
			End

			SET @HasError = 0
			SET @Message  = dbo.GetMessageFromLenguajeResorces (@IsSpanish,97)

			SET @IdCheckGuidOutBatch = @IdCheckGuid
			SET @IdCheckOutBatch = @IdCheck
			SET @IdIssuerOutBatch = @IdIssuerOut
			SET @CheckNewOutBatch = 1
			SET @IdStatusOutBatch = 1
			SET @IdCustomerOutBatch = @IdCustomerOutput
			SET @IdElasticCustomerOutBatch = @idElasticCustomer
			SET @IsUpdateOutBatch = 1

		end
	End Try                                                                                            
	Begin Catch
		SET @HasError = 1
		SET @Message =  dbo.GetMessageFromLenguajeResorces (@IsSpanish,96)
		Declare @ErrorMessage nvarchar(max)                                                                                             
		Select @ErrorMessage=ERROR_MESSAGE()                                             
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveChecks',Getdate(),@ErrorMessage);                                                                                            
	End Catch
END

