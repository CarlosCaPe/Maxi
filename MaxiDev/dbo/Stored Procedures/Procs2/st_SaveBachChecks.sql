
/********************************************************************
<Author>Unknow</Author>
<app>Agent</app>
<Description></Description>

<ChangeLog>
<log Date="18/01/2018" Author="azavala">Optimizacion Agente : Se declaran nuevos parametros necesarios para una actualizacion en ElasticSearch</log>
<log Date="06/08/2018" Author="azavala">Validacion monto maximo a nivel sql</log>
<log Date="08/11/2018" Author="jmolina">Se agrega validación de limite en amount por agencia #1</log>
<log Date="19/12/2018" Author="jmolina">Se agrega ; por cada insert/update </log>
<log Date="29/04/2021" Author="jgarza">Se agrega validar "edit hold" con st_SaveCheckEdits </log>
<log Date="2022/1/12" Author="jcsierra" Name="SD1-1291">Se implementa whitelist</log>
</ChangeLog>
*********************************************************************/
CREATE PROCEDURE [dbo].[st_SaveBachChecks](
	@Checks XML,
	@IdAgent INT,
    @EnteredByIdUser INT,
    @IdLenguage INT,    
	@GUID varchar(max),
    @HasError BIT OUTPUT,
    @Message varchar(max) OUTPUT,
    @AmountBatch varchar(max) OUTPUT,
    @FeeBatch varchar(max) OUTPUT,
    @Totbatch varchar(max) OUTPUT
)	
AS
BEGIN

BEGIN TRY

	DECLARE @IdValue int
	INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage, ExtraData)
	VALUES('st_SaveBachChecks', GETDATE(), 'INICIO', CONVERT(VARCHAR(MAX), @Checks));
	 SET @IdValue = SCOPE_IDENTITY()


	DECLARE @NoNameCust INT
	SELECT @NoNameCust = Value FROM dbo.GlobalAttributes(NOLOCK) WHERE Name = 'NoNameCustomer'
	SELECT @NoNameCust = ISNULL(@NoNameCust,-1)
	IF @NoNameCust = 0 SET @NoNameCust = -1


	DECLARE @DocHandle INT 
	DECLARE @isDeny2 Bit
	DECLARE @MessageDeny2 varchar(MAX)

    declare @IAmountBatch money
    declare @IFeeBatch money
    declare @ITotbatch int

	declare @IdCustomerOutput int /*Optimizacion Agente*/
	declare @idElasticCustomer varchar(max) /*Optimizacion Agente*/
	declare @IsUpdate bit /*Optimizacion Agente*/

	declare @ErrorCatch int = 999; /*15/Ago/2016*/
	SET @HasError = 0; /*15/Ago/2016*/

    set @IAmountBatch = 0
    set @IFeeBatch = 0
    set @ITotbatch = 0

	------ se revisa lenguage ------
		DECLARE @IsSpanish bit
		SET @IsSpanish = 1
		if(@IdLenguage = 1)
			Begin
				SET @IsSpanish = 0
			End
	------ se revisa lenguage ------

	Create Table #Checks(
		IdCheckTransaction INT IDENTITY(1,1),
		IdCustomer INT,
		IdIssuer INT,
		CustomerName varchar(max),
		CustomerFirstLastName varchar(max),
		CustomerSecondLastName varchar(max),
		IdentificationType varchar(max),
		[State] varchar(max),
		DateOfBirth datetime,
		IdIdentificationType INT,
		IdentificationDateOfExpiration datetime,
		Ocupation varchar(max),
		IdentificationNumber varchar(max),
		--[CountryBirthId] INT,
		CheckNumber varchar(max),
		RoutingNumber varchar(max),
		Account varchar(max),
		Micr varchar(max),
		MicrAuxOnUs varchar(max),
		MicrRoutingTransitNumber varchar(max),
		MicrOnUs varchar(max),
		MicrAmount varchar(max),
		IssuerName varchar(max),
		Amount Money,
		DateOfIssue datetime,
		IsEndorsed Bit,
		Fee Money,
		ManualMicrHold bit,
		MicrManual varchar(max),
		IssuerPhone Varchar(max)
		,IdCheckGuid varchar(max) /*15/Ago/2016*/

		,ValidationFee Money /*20/Sep/2016*/
		,TransactionFee Money /*20/Sep/2016*/

		--2021/04/29
		,IsIRD BIT
		,MicrEPC VARCHAR(1)
		,OriRouting VARCHAR(MAX)
		,OriRoutingScore INT
		,OriAccount VARCHAR(MAX)
		,OriAccountScore INT
		,OriCheckNum VARCHAR(MAX)
		,OriCheckNumScore INT
		,OriAmount MONEY
		,OriAmountScore INT
		,OriDateOfIssue DATETIME
		,OriDateOfIssueScore INT
		,IsDateOfIssueBySystem BIT
	);

    /*15/Ago/2016*/
    Create Table #Checks2(
		IdCheckGuid varchar(max)
		,IdCheck INT
		,IdIssuer INT
		,CheckNew INT
		,IdStatus INT
		,DateOfMovement datetime
		,IdCustomer INT /*Optimizacion Agente*/
		,IdElasticCustomer varchar(MAX) /*Optimizacion Agente*/
		,IsUpdate bit /*Optimizacion Agente*/
		);

	Begin Try 	/*15/Ago/2016*/
/*---------------------------------*/
/*---------------------------------*/
/*---------------------------------*/
	EXEC sp_xml_preparedocument @DocHandle OUTPUT,@Checks /*15/Ago/2016*/

	--Guardar informacion de depositos en tabla temporal
	INSERT INTO #Checks
	SELECT  IdCustomer,
			IdIssuer,
			CustomerName,
			CustomerFirstLastName,
			CustomerSecondLastName,
			IdentificationType,
			[State],
			DateOfBirth,
			IdIdentificationType,
			IdentificationDateOfExpiration,
			Ocupation varchar,
			IdentificationNumber,
			--[CountryBirthId],
			CheckNumber,
			RoutingNumber,
			Account,
			Micr,
			MicrAuxOnUs,
			MicrRoutingTransitNumber,
			MicrOnUs,
			MicrAmount,
			IssuerName,
			Amount,
			DateOfIssue,
			IsEndorsed, 
			Fee,
			ManualMicrHold,
			MicrManual,
			IssuerPhone
			,IdCheckGuid /*15/Ago/2016*/
			,ValidationFee /*20/Sep/2016*/
			,TransactionFee /*20/Sep/2016*/

			--2021/04/29
			,IsIRD
			,MicrEPC
			,OriRouting
			,OriRoutingScore
			,OriAccount
			,OriAccountScore
			,OriCheckNum
			,OriCheckNumScore
			,OriAmount
			,OriAmountScore
			,OriDateOfIssue
			,OriDateOfIssueScore
			,IsDateOfIssueBySystem
			From OPENXML (@DocHandle, '/Checks/Check',2)
			WITH(
			IdCustomer INT,
			IdIssuer INT,
			CustomerName varchar(max),
			CustomerFirstLastName varchar(max),
			CustomerSecondLastName varchar(max),
			IdentificationType varchar(max),
			[State] varchar(max),
			DateOfBirth datetime,
			IdIdentificationType INT,
			IdentificationDateOfExpiration datetime,
			Ocupation varchar(max),
			IdentificationNumber varchar(max),
			--[CountryBirthId] INT,
			CheckNumber varchar(max),
			RoutingNumber varchar(max),
			Account varchar(max),
			Micr varchar(max),
			MicrAuxOnUs varchar(max),
			MicrRoutingTransitNumber varchar(max),
			MicrOnUs varchar(max),
			MicrAmount varchar(max),
			IssuerName varchar(max),
			Amount Money,
			DateOfIssue datetime,
			IsEndorsed Bit,
			Fee Money,
			ManualMicrHold bit,
			MicrManual Varchar(Max),
			IssuerPhone Varchar(Max)
			,IdCheckGuid Varchar(Max)/*15/Ago/2016*/
			,IdCheck INT/*15/Ago/2016*/
			,ValidationFee Money /*20/Sep/2016*/
			,TransactionFee Money /*20/Sep/2016*/

			--2021/04/29
			,IsIRD BIT
			,MicrEPC VARCHAR(1)
			,OriRouting VARCHAR(MAX)
			,OriRoutingScore INT
			,OriAccount VARCHAR(MAX)
			,OriAccountScore INT
			,OriCheckNum VARCHAR(MAX)
			,OriCheckNumScore INT
			,OriAmount MONEY
			,OriAmountScore INT
			,OriDateOfIssue DATETIME
			,OriDateOfIssueScore INT
			,IsDateOfIssueBySystem BIT
		)
		

		While exists (Select 1 from #Checks)
		BEGIN
			--INSERT INTO Soporte.InfoLogForStoreProcedure (StoreProcedure, InfoDate, InfoMessage, ExtraData) VALUES ('st_SaveBachChecks', GETDATE(), 'Dentro de While', 'Comienza la pasada')
			DECLARE @IdIssuer INT
			DECLARE @IssuerName varchar(max)
			DECLARE @RoutingNumber varchar(max)
			DECLARE @Account varchar(max)
			DECLARE @Micr varchar(max)
			DECLARE @MicrAuxOnUs varchar(max)
			DECLARE @MicrRoutingTransitNumber varchar(max)
			DECLARE @MicrOnUs varchar(max)
			DECLARE @MicrAmount varchar(max)
			DECLARE @IssuerPhone varchar(max)
			DECLARE @IdIssuerOut INT

            DECLARE @IdCheck INT
			DECLARE @IdCustomer INT
			DECLARE @CustomerName varchar(max)
			DECLARE @CustomerFirstLastName varchar(max)
			DECLARE @CustomerSecondLastName varchar(max)
			DECLARE @IdentificationType varchar(max)
			DECLARE @State varchar(max)
			DECLARE @DateOfBirth datetime
			DECLARE @IdIdentificationType INT
			DECLARE @IdentificationDateOfExpiration datetime
			DECLARE @Ocupation varchar(max)
			DECLARE @IdentificationNumber varchar(max)
			--DECLARE @CountryOfBirthId INT
			DECLARE @CheckNumber varchar(max)
			DECLARE @DateOfIssue datetime
			DECLARE @Amount money
			DECLARE @IsEndorsed bit
			DECLARE @Fee Money
			DECLARE @ManualMicrHold bit
			DECLARE @MicrManual varchar(max)
            DECLARE @IdCheckTransaction INT

			DECLARE @IdCheckGuid Varchar(Max)/*15/Ago/2016*/

			DECLARE @CustomerFee Money /*20/Sep/2016*/
			DECLARE @TransactionFee Money /*20/Sep/2016*/

			DECLARE @IsIRD BIT;
			DECLARE @MicrEPC VARCHAR(1);
			DECLARE @OriRouting VARCHAR(MAX);
			DECLARE @OriRoutingScore INT;
			DECLARE @OriAccount VARCHAR(MAX);
			DECLARE @OriAccountScore INT;
			DECLARE @OriCheckNum VARCHAR(MAX);
			DECLARE @OriCheckNumScore INT;
			DECLARE @OriAmount MONEY;
			DECLARE @OriAmountScore INT;
			DECLARE @OriDateOfIssue DATETIME;
			DECLARE @OriDateOfIssueScore INT;
			DECLARE @IsDateOfIssueBySystem BIT;

			Select top 1 
            @IdCheckTransaction=IdCheckTransaction,
			@IdCustomer=IdCustomer,
			@CustomerName=CustomerName,
			@CustomerFirstLastName=CustomerFirstLastName,
			@CustomerSecondLastName=CustomerSecondLastName,
			@IdentificationType=IdentificationType,
			@State=[State],
			@DateOfBirth=DateOfBirth,
			@IdIdentificationType=IdIdentificationType,
			@IdentificationDateOfExpiration=IdentificationDateOfExpiration,
			@Ocupation=Ocupation,
			@IdentificationNumber=IdentificationNumber,
			--@CountryOfBirthId=[CountryBirthId],
			@CheckNumber=CheckNumber,
			@DateOfIssue=DateOfIssue,
			@Amount=Amount,
			@IsEndorsed = IsEndorsed,
			@Fee = Fee,
			@ManualMicrHold = ManualMicrHold,
			@MicrManual = MicrManual,
			@IssuerPhone = IssuerPhone,
            @IdIssuer=IdIssuer, 
            @IssuerName=IssuerName, 
            @RoutingNumber=RoutingNumber, 
            @Account=Account,
			@Micr= Micr,
            @MicrAuxOnUs=MicrAuxOnUs, 
            @MicrRoutingTransitNumber=MicrRoutingTransitNumber, 
            @MicrOnUs=MicrOnUs, 
            @MicrAmount=MicrAmount, 
            @IssuerPhone = IssuerPhone
			,@IdCheckGuid = IdCheckGuid /*15/Ago/2016*/

			,@CustomerFee = ValidationFee /*20-Sep-2016*/
			,@TransactionFee = TransactionFee /*20-Sep-2016*/

			,@IsIRD               = IsIrd
			,@MicrEPC             = MicrEPC
			,@OriRouting          = OriRouting
			,@OriRoutingScore	  = OriRoutingScore
			,@OriAccount		  = OriAccount
			,@OriAccountScore	  = OriAccountScore
			,@OriCheckNum		  = OriCheckNum
			,@OriCheckNumScore	  = OriCheckNumScore
			,@OriAmount			  = OriAmount
			,@OriAmountScore	  = OriAmountScore
			,@OriDateOfIssue	  = OriDateOfIssue
			,@OriDateOfIssueScore = OriDateOfIssueScore
			,@IsDateOfIssueBySystem=IsDateOfIssueBySystem
			FROM #Checks            


			
					/*15/Ago/2016*/
			--INSERT INTO Soporte.InfoLogForStoreProcedure (StoreProcedure, InfoDate, InfoMessage, ExtraData) VALUES ('st_SaveBachChecks', GETDATE(), 'Amount es menor o igual a la cantidad maxima por cheque', 'Comienza la pasada')
			DECLARE @IdCheck_Exists INT = 0;
			DECLARE @IdIssuer_Exists INT = 0;
			DECLARE @IdStatus_Exists INT = 0;
			DECLARE @DateOfMovement_Exists DateTime = NULL;

			/*15/Ago/2016*/
			select top 1
				@IdCheck_Exists = IdCheck
				,@IdIssuer_Exists = IdIssuer
				,@IdStatus_Exists = ISNULL(idstatus,0)
				,@DateOfMovement_Exists = DateOfMovement
			from checks with(nolock) 
				where CheckNumber = @CheckNumber and RoutingNumber=@RoutingNumber and Account=@Account and amount=@Amount
				/* Se Agrega validacion para bloquear rejected que no sean IRD */
				and @isIrd = 0 AND idstatus = 31/*IdStatus 31 = Rejected*/
			order by IdCheck desc;

			------------------------------------- Insert Customer/ UpdateCustomer -------------------

			if (@IdIdentificationType = 0)
				select top 1 @IdIdentificationType =  IdCustomerIdentificationType from CustomerIdentificationType


			SET @IdCustomerOutput = @IdCustomer

			IF @IdCustomer != @NoNameCust
			BEGIN
				--if( @IdCustomer = 0 and not exists (select top 1 1 from Customer with(nolock) where Name=@CustomerName and FirstLastName=@CustomerFirstLastName and SecondLastName=@CustomerSecondLastName and IdGenericStatus=1 order by 1))
				if( @IdCustomer = 0 and not exists (select 1 from Customer with(nolock) where Name=@CustomerName and FirstLastName=@CustomerFirstLastName and SecondLastName=@CustomerSecondLastName and IdGenericStatus=1))
					BEGIN
						Insert into Customer(IdAgentCreatedBy, IdGenericStatus, Name, FirstLastName, SecondLastName, Address, City, State, Country, Zipcode, DateOfLastChange, EnterByIdUser, SentAverage, [creationdate])
						Values (@IdAgent, 1, @CustomerName, @CustomerFirstLastName, @CustomerSecondLastName, '', '', '', '', '', GETDATE(), @EnteredByIdUser, 0, GETDATE());

						Select @IdCustomer=Scope_Identity()
						
							set @IdCustomerOutput=@IdCustomer /*Optimizacion Agente*/
							set @IsUpdate = 0 /*Optimizacion Agente*/
							set @idElasticCustomer = '' /*Optimizacion Agente*/
							select top 1 @IdIdentificationType = IdCustomerIdentificationType from CustomerIdentificationType with(nolock) order by IdCustomerIdentificationType desc
							--set @IdentificationDateOfExpiration = GETDATE()
					END
				ELSE
					BEGIN
						declare @IdCustomerExist int
						IF(@IdCustomer=0)
							BEGIN
								set @IdCustomerExist = (select top 1 IdCustomer from Customer with(nolock) where Name=@CustomerName and FirstLastName=@CustomerFirstLastName and SecondLastName=@CustomerSecondLastName and IdGenericStatus=1 order by 1)
								Update Customer set Name = @CustomerName, FirstLastName = @CustomerFirstLastName, SecondLastName = @CustomerSecondLastName, DateOfLastChange = GETDATE(), EnterByIdUser = @EnteredByIdUser where IdCustomer = @IdCustomerExist;
								set @IdCustomerOutput=@IdCustomerExist /*Optimizacion Agente*/
								set @IdCustomer=@IdCustomerExist
							END
						ELSE
							BEGIN
								Update Customer set Name = @CustomerName, FirstLastName = @CustomerFirstLastName, SecondLastName = @CustomerSecondLastName, DateOfLastChange = GETDATE(), EnterByIdUser = @EnteredByIdUser where IdCustomer = @IdCustomer;
								set @IdCustomerOutput=@IdCustomer /*Optimizacion Agente*/
							END
						
						SET @IsUpdate = 1 /*Optimizacion Agente*/
						SET @idElasticCustomer = (Select idElasticCustomer from Customer with(nolock) where IdCustomer=@IdCustomer) /*Optimizacion Agente*/
					END
			END--IF @NoNameCust
			ELSE
			BEGIN
				set @idElasticCustomer = '' 
				set @IsUpdate = 1
			END



			IF (@Amount <= ISNULL((SELECT  MAX(FC.ToAmount) FROM FeeChecks AS F with(nolock) inner JOIN FeeChecksDetail AS FC with(nolock) ON (F.IdFeeChecks = FC.IdFeeChecks ) WHERE IdAgent = @IdAgent), @Amount) ) --#1
			BEGIN
			if(@Amount <= (select cast((select Value from GlobalAttributes with(nolock) where name = 'MaxAmountForcheck') as money)))
				begin
 					/*15/Ago/2016*/
					IF (@IdStatus_Exists = 0) OR ((@Idstatus_Exists > 0) AND @Idstatus_Exists in (31,22))
					BEGIN
						Begin Try

						print 'insert' 

						----------------------------------- Insert Issuer --------------------------------------				

						EXEC st_InsertIssuerChecks @IdIssuer, @IssuerName, @RoutingNumber, @Account, @EnteredByIdUser, @IssuerPhone, @IdIssuerOut output;				

						----------------------------------- Insert Check --------------------------------------

						DECLARE @IdCheckStatus int
						DECLARE @ClaimCheck varchar(50)

						Create Table #ClaimChecks (Result nvarchar(max))
						Insert into #ClaimChecks (Result)
						EXEC ST_TNC_CLAIM_CODE_GEN N'WF';
						Select @ClaimCheck = ltrim(rtrim(Result)) From #ClaimChecks
						drop table #ClaimChecks			

						---------commissions and fee -----------

						DECLARE @Commission Money
						select @Commission = ReturnCheckFee from FeeChecks with(nolock) where IdAgent = @IdAgent

						/*20-Sep-2016*/
						DECLARE @ReturnFee Money
						SET @ReturnFee = ISNULL(@Commission,0);
						/*----------*/
			
						---------commissions and fee -----------

						DECLARE @ExistingHold Int
						SET @ExistingHold = 0

						if (exists (select checknumber from Checks with(nolock) where CheckNumber = @CheckNumber AND RoutingNumber = @RoutingNumber AND Account = @Account AND IdStatus <> 31 AND IdStatus <> 22))
						begin				
							SET @ExistingHold = 1		
						end

						set @IAmountBatch = @IAmountBatch + @Amount
						set @IFeeBatch = @IFeeBatch + @Fee
						set @ITotbatch = @ITotbatch + 1

						--insert into 
							  --  Checks(IdAgent, IdCustomer, Name, FirstLastName, SecondLastName, IdentificationType, State, DateOfBirth, IdIdentificationType, IdentificationDateOfExpiration, Ocupation, IdentificationNumber, CheckNumber, RoutingNumber, Account, IssuerName, DateOfIssue, Amount, IsEndorsed, IdStatus, DateOfMovement, DateStatusChange, DateOfLastChange, EnteredByIdUser, IdIssuer, ClaimCheck, BachCode, Comission, Fee
							  --  , MicrOriginal,MicrAuxOnUs, MicrRoutingTransitNumber,MicrOnUs,MicrAmount, MicrManual)
						   -- values 
							  --  (@IdAgent, @IdCustomer, @CustomerName, @CustomerFirstLastName, @CustomerSecondLastName, @IdentificationType, @State, null, @IdIdentificationType, 
							  --  null, @Ocupation, @IdentificationNumber, @CheckNumber, @RoutingNumber, @Account, @IssuerName, @DateOfIssue, 
							  --  @Amount, 1, 1, GETDATE(), GETDATE(), GETDATE(), @EnteredByIdUser, @IdIssuerOut, @ClaimCheck, @GUID, @Commission, @Fee
							  --  ,@Micr,@MicrAuxOnUs, @MicrRoutingTransitNumber,@MicrOnUs,@MicrAmount, @MicrManual)

						/*20/Sep/2016*/
						insert into 
								Checks(IdAgent, IdCustomer, Name, FirstLastName, SecondLastName, IdentificationType, [State], DateOfBirth, IdIdentificationType
								, IdentificationDateOfExpiration, Ocupation, IdentificationNumber, CheckNumber, RoutingNumber, Account, IssuerName, DateOfIssue
								, Amount, IsEndorsed, IdStatus, DateOfMovement, DateStatusChange, DateOfLastChange, EnteredByIdUser, IdIssuer, ClaimCheck, BachCode, Comission, Fee
								, MicrOriginal,MicrAuxOnUs, MicrRoutingTransitNumber,MicrOnUs,MicrAmount, MicrManual
								, CustomerFee, TransactionFee, ReturnFee, IsIRD, MicrEPC,IsDateOfIssueBySystem )
							values 
								(@IdAgent, @IdCustomer, @CustomerName, @CustomerFirstLastName, @CustomerSecondLastName, @IdentificationType, @State, null, @IdIdentificationType, 
								null, @Ocupation, @IdentificationNumber, @CheckNumber, @RoutingNumber, @Account, @IssuerName, @DateOfIssue, 
								@Amount, 1, 1, GETDATE(), GETDATE(), GETDATE(), @EnteredByIdUser, @IdIssuerOut, @ClaimCheck, @GUID, @Commission, @Fee
								,@Micr,@MicrAuxOnUs, @MicrRoutingTransitNumber,@MicrOnUs,@MicrAmount, @MicrManual
								,@CustomerFee, @TransactionFee, @ReturnFee, @IsIRD, @MicrEPC,@IsDateOfIssueBySystem);
								--ojo ver el insertar si es ird y epc


						

						set @IdCheck = (SELECT SCOPE_IDENTITY())

						/*20-Oct-2021*/
						/*UCF*/
						/*Todos los cheques procesados hacen abono al balance del agente desde que se procesa*/
						EXEC checks.st_CheckApplyToAgentBalance @IdCheck

						set @IdCheckStatus = (select IdStatus from Checks with(nolock) where IdCheck = @IdCheck)
						Declare @IdUserSystem int  
						Select @IdUserSystem = [Value] from GlobalAttributes with(nolock) where Name = 'SystemUserID'

						/*15/Ago/2016 : CheckNew es 1 si se requiere la imagen, 0 si no se requiere la imagen(ya existen) */
						INSERT INTO #Checks2 (IdCheckGuid,IdCheck,IdIssuer,CheckNew,IdStatus, IdCustomer,IdElasticCustomer,IsUpdate) VALUES (@IdCheckGuid, @IdCheck,@IdIssuerOut,1,1,@IdCustomerOutput,@idElasticCustomer,@IsUpdate);				

						If @IdCheckStatus = 1
						Begin          

						DECLARE @MessageOFAC varchar(max)
						--------------------------------------------------- Verify Endorsed --------------------------------------				
							--Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,58,'Endorse Validation',0 --- Log de Endorse validacion  	
				
							--If (@IsEndorsed=0)
							--Begin           
							--	Insert Into [dbo].[CheckHolds]([IdCheck],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
							--		Values(@IdCheck,57,GETDATE(),GETDATE() ,@IdUserSystem)  
							--	Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,57,'Endorse Hold',@IsEndorsed -- Log , se ha detenido en Endorse Hold                       

							--	SET @MessageOFAC = ''
							--End                   

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
						---------------------------------------------------------------------------------------------------

						-------------------------------------------------------------EXISTING HOLD--------------------------------------
									  --Existing Check--
				
								SET @MessageOFAC= ''

								Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,60,'Duplicate Checks Validation',0; --- Log de Duplicate Checks Validation           

								If (@ExistingHold=1)
								Begin           
									Insert Into [dbo].[CheckHolds]([IdCheck],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
										Values(@IdCheck,61,GETDATE(),GETDATE() ,@IdUserSystem);  
									Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,61,'Duplicate Checks Hold',0; -- Log , se ha detenido en Duplicate Checks Hold                       

									SET @MessageOFAC = 'Mensaje personalizado que el cheque cayo en ofac falta poner los idiomas'
								End               

				
						--------------------------------------------------- Edited Checks Hold --------------------------------------				
							SET @ManualMicrHold = 0;
							Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,63,'Edited Checks Hold Validation',0; --- Log de Edited Checks Hold Validation	

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
				
							If (@ManualMicrHold =1)
							Begin           
								Insert Into [dbo].[CheckHolds]([IdCheck],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
									Values(@IdCheck,64,GETDATE(),GETDATE() ,@IdUserSystem);  
								Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,64,'Edited Checks Hold',@IsEndorsed; -- Log , se ha detenido en Edited Checks Hold                       

								SET @MessageOFAC = ''
							End
	
        
						----------------------------------- Verify Deny List --------------------------------------

							DECLARE @isDeny bit
							DECLARE @MessageDeny varchar(max)
				
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

			    
							DECLARE @isOFAC bit
							SET @MessageOFAC= ''

							--Cambios Ofac
							Declare @IsOFACDoubleVerification bit

							--Cambios Ofac
							set @IsOFACDoubleVerification=0

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

								SET @MessageOFAC = ''
							End        

					----------------------------------------------------------------------------------------------------------------------------------    			    

							Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,41,'Verify Hold',0; --- Log de validación de Multiholds  
							Update checks Set IdStatus=41,DateStatusChange=GETDATE() Where IdCheck=@IdCheck;  
						End

					SET @HasError = 0
					SET @Message  = dbo.GetMessageFromLenguajeResorces (@IsSpanish,97) + ' / Check: '+ convert(varchar,@ITotbatch)

					--Delete #Checks where IdCheckTransaction = @IdCheckTransaction;

					End Try
						Begin Catch
							/*15/Ago/2016 : CheckNew es 1 si se requiere la imagen, 0 si no se requiere la imagen(ya existen) */
							INSERT INTO #Checks2 (IdCheckGuid,IdCheck,IdIssuer,CheckNew,IdStatus, IdCustomer, IdElasticCustomer, IsUpdate) VALUES (@IdCheckGuid, NULL,@IdIssuer,0, @ErrorCatch, @IdCustomerOutput, @idElasticCustomer, @IsUpdate);

							SET @HasError = 1;
							SET @Message =  dbo.GetMessageFromLenguajeResorces (@IsSpanish,96)
							Declare @ErrorMsg nvarchar(max)
							Select @ErrorMsg=ERROR_MESSAGE() + convert(varchar, ERROR_LINE()) + '- ErrorCatch: '+ convert(varchar,@ErrorCatch) +',IdAgent:' + convert(varchar,@IdAgent)+ ',Guid:' + convert(varchar,@IdCheckGuid) + ',IdIssuer:' + convert(varchar,@IdIssuer) +',IdCheckTransaction:'+ convert(varchar,ISNULL(@IdCheckTransaction,'NULL')) + ',IdCheck:'+ convert(varchar,ISNULL(@IdCheck,'NULL'));
							Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveBachChecks',Getdate(),@ErrorMsg);

						End Catch
					END
					ELSE
					BEGIN
							/*15/Ago/2016 : CheckNew es 1 si se requiere la imagen, 0 si no se requiere la imagen(ya existen) */
							INSERT INTO #Checks2 (IdCheckGuid,IdCheck,IdIssuer,CheckNew,IdStatus, DateOfMovement, IdCustomer, IdElasticCustomer, IsUpdate) VALUES (@IdCheckGuid, @IdCheck_Exists,@IdIssuer_Exists,0,@IdStatus_Exists, @DateOfMovement_Exists, @IdCustomerOutput, @idElasticCustomer, @IsUpdate);
					END

					Delete #Checks where IdCheckTransaction = @IdCheckTransaction;
			end
		else
			begin
				INSERT INTO dbo.ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) VALUES ('st_SaveBachChecks', GETDATE(), 'Amount es MAYOR a la cantidad maxima por cheque, @IdCheckGuid: ' + CONVERT(varchar(MAX), IsNull(@IdCheckGuid,'aaaaaaaa')) + ' @IdCheck_Exists: ' + CONVERT(varchar(MAX), IsNull(@IdCheck_Exists, 'Unknow')) + ' @IdIssuer_Exists: ' + CONVERT(varchar(MAX), IsNull(@IdIssuer_Exists,'Unknow')) + ' @IdStatus_Exists: ' + CONVERT(varchar(MAX), IsNull(@IdStatus_Exists,'Unknow')) + ' @IdCustomerOutput: ' + CONVERT(varchar(MAX), IsNull(@IdCustomerOutput,'Empty')) + ' @idElasticCustomer: ' + CONVERT(varchar(MAX), IsNull(@idElasticCustomer,'Empty')) + ' @IsUpdate: ' + CONVERT(varchar(MAX), IsNull(@IsUpdate,'0')));
				INSERT INTO #Checks2 (IdCheckGuid,IdCheck,IdIssuer,CheckNew,IdStatus, DateOfMovement, IdCustomer, IdElasticCustomer, IsUpdate) VALUES (@IdCheckGuid, @IdCheck_Exists,@IdIssuer_Exists,0,@IdStatus_Exists, GETDATE(), @IdCustomerOutput, @idElasticCustomer, @IsUpdate);
				Delete #Checks where IdCheckTransaction = @IdCheckTransaction;
			end

			END
			ELSE
			BEGIN --#1
				INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES ('st_SaveBachChecks', GETDATE(), 'Error, el monto excede el límite permitido por la agencia, @IdCheckGuid: ' + CONVERT(varchar(MAX), IsNull(@IdCheckGuid,'aaaaaaaa')) + ' @IdCheck_Exists: ' + CONVERT(varchar(MAX), IsNull(@IdCheck_Exists, 'Unknow')) + ' @IdIssuer_Exists: ' + CONVERT(varchar(MAX), IsNull(@IdIssuer_Exists,'Unknow')) + ' @IdStatus_Exists: ' + CONVERT(varchar(MAX), IsNull(@IdStatus_Exists,'Unknow')) + ' @IdCustomerOutput: ' + CONVERT(varchar(MAX), IsNull(@IdCustomerOutput,'Empty')) + ' @idElasticCustomer: ' + CONVERT(varchar(MAX), IsNull(@idElasticCustomer,'Empty')) + ' @IsUpdate: ' + CONVERT(varchar(MAX), IsNull(@IsUpdate,'0')));
				INSERT INTO #Checks2 (IdCheckGuid,IdCheck,IdIssuer,CheckNew,IdStatus, DateOfMovement, IdCustomer, IdElasticCustomer, IsUpdate) VALUES (@IdCheckGuid, @IdCheck_Exists,@IdIssuer_Exists,0,@IdStatus_Exists, GETDATE(), @IdCustomerOutput, @idElasticCustomer, @IsUpdate);
				Delete #Checks where IdCheckTransaction = @IdCheckTransaction;
			END
		END

		
        set @AmountBatch = convert(varchar(max),@IAmountBatch)
        set @FeeBatch = convert(varchar(max),@IFeeBatch)
        set @Totbatch = convert(varchar(max),@ITotbatch)

	End Try                                                                                            
	Begin Catch
		SET @HasError = 1
		SET @Message =  dbo.GetMessageFromLenguajeResorces (@IsSpanish,96)
		Declare @ErrorMessage nvarchar(max)                                                                                             
		Select @ErrorMessage=ERROR_MESSAGE()+convert(varchar, ERROR_LINE())
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveBachChecks',Getdate(),@ErrorMessage);                                                                                            
	End Catch		

	UPDATE Soporte.InfoLogForStoreProcedure SET InfoMessage = CONVERT(VARCHAR, GETDATE(), 121) WHERE IdInfoLogForStoreProcedure = @IdValue;

		/*15/Ago/2016*/
		/*26-Sep-2016*/
		select 
			IdCheck
			, IdIssuer
			, IdCheckGuid
			, CheckNew
			, IdStatus
			, DateOfMovement
			, IdCustomer
			, IdElasticCustomer
			, IsUpdate
		from #Checks2
		order by IdCheck asc;

END TRY
BEGIN CATCH
	Declare @MessageError nvarchar(max)                                                                                             
	Select @MessageError=ERROR_MESSAGE()+convert(varchar, ERROR_LINE())
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveBachChecks',Getdate(),@MessageError);                                                                                            
END CATCH

END

