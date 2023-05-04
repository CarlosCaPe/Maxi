-- =============================================
-- Author:		<Eneas Salazar>
-- Create date: 09/08/2018
-- Description:	Modificación de información de Beneficiario
-- =============================================
/********************************************************************
<Author>Eneas Salazar</Author>
<app>Agente Nuevo</app>
<Description>Modificación de información de Beneficiario</Description>

<ChangeLog>
	<log Date="09/08/2018" Author="esalazar">Creacion</log>
	<log Date="08/10/2018" Author="azavala">Validar @TransferNote is null</log>
	<log Date="08/10/2018" Author="azavala">Obtener campos a evaluar desde la tabla transfer y no desde Beneficiario :: Ref: 280520191750_azavala</log>
	<log Date="02/25/2021" Author="jcsierra">Se elimina la restricción de 30 mins cuando la transacción esta en Signature Hold</log>
	<log Date="02/25/2023" Author="jacardenas">Se envía el usuario que modifica la transacción a st_TransferToCancelInProgress, BM-1361</log>
</ChangeLog>
*********************************************************************/
--Development Status
--56 -> Update Transfer
--70 -> Update In Progress

--QA
--74 -> Update Transfer
--73 -> Update In Progress

---Stage, Produccion Status
--70 -> Update In Progress
--71 -> Update Transfer

CREATE PROCEDURE [dbo].[st_UpdateBeneficiary]
	-- Add the parameters for the stored procedure here
	   @IdLenguage int 
	  ,@IdAgent int
	  ,@IdUser int
	  ,@IdTransfer int
	  ,@IdBeneficiary int
	  ,@NameNew nvarchar(max)
      ,@FirstLastNameNew nvarchar(max)
      ,@SecondLastNameNew nvarchar(max)
	  ,@AddressNew nvarchar(max)
	  ,@CellPhoneNumberNew nvarchar(max)
	  ,@IdBeneficiaryTypeNew int
	  ,@IdentificationNumberNew nvarchar(max)
	  ,@IsModify bit = 0
	  ,@StateNew nvarchar(max) = ''
	  ,@CountryNew nvarchar(max) = ''
	  ,@ZipcodeNew nvarchar(max) = ''
	  ,@CityNew nvarchar(max) = ''
	  ,@HasError bit out
	  ,@Message varchar(max) out
	  ,@PassedLimitModifications bit out
	  ,@IdBeneficiaryOutput int out
AS
DECLARE  
	   
       @Name nvarchar(max)
      ,@FirstLastName nvarchar(max)
      ,@SecondLastName nvarchar(max)
      ,@Address nvarchar(max)
      ,@City nvarchar(max)
      ,@State nvarchar(max)
      ,@Country nvarchar(max)
      ,@Zipcode nvarchar(max)
      ,@PhoneNumber nvarchar(max)
      ,@CellPhoneNumber nvarchar(max)
      ,@SSnumber nvarchar(max)
      ,@BornDate datetime
      ,@Occupation nvarchar(max)
      ,@Note nvarchar(max)
      ,@IdGenericStatus int
      ,@EnterByIdUser nvarchar(max)
      ,@IdCustomer int
      ,@FullName nvarchar(120)
      ,@IdBeneficiaryIdentificationType int
      ,@IdentificationNumber nvarchar(max)
      ,@IdCountryOfBirth int
	  ,@TranferNote nvarchar(max)
	  ,@IdTransferDetail int
	  ,@NameFlag bit
      ,@FirstLastNameFlag bit
      ,@SecondLastNameFlag bit
	  ,@AddressFlag bit
	  ,@CellPhoneNumberFlag bit
	  ,@BeneficiaryIdTypeFlag bit
	  ,@BeneficiaryIdNumberFlag bit
	  ,@StateFlag bit
	  ,@CountryFlag bit
	  ,@ZipcodeFlag bit
	  ,@CityFlag bit
	  ,@TranferDate DATETIME
	  ,@NumTransferModifications int
	  ,@NumGlobalTModifications int
	  ,@IdBeneficiaryTypeName nvarchar(max)
	  --,@IdBeneficiaryOutput INT    
	  ,@IsNewBeneficiary Bit
	  ,@IdBeneficiaryOld int = 0

Declare @IdAgentTransfer int
Declare @IdUpdatedTransferStatus int
Declare @EnterByIdUserT int  
Declare @CustomerName nvarchar(max)  
Declare @CustomerFirstLastName nvarchar(max)  
Declare @CustomerSecondLastName nvarchar(max)  
Declare @BeneficiaryName nvarchar(max)  
Declare @BeneficiaryFirstLastName nvarchar(max)
Declare @BeneficiarySecondLastName nvarchar(max)
Declare @TransferStatusID int   
DECLARE @IDUpdateInProgress int
DECLARE @AmountInMN money
DECLARE @IdGateway int
DECLARE @ConfirmationCodeOrigin varchar(MAX)
Set @IdBeneficiaryOutput = 0


--Development Status
--56 -> Update Transfer
--70 -> Update In Progress

--QA
--74 -> Update Transfer
--73 -> Update In Progress

--Stage, Produccion Status
--70 -> Update In Progress
--71 -> Update Transfer
SET @IDUpdateInProgress=70
SET @IdUpdatedTransferStatus=71
SET @PassedLimitModifications=0
SET @HasError = 0
SET @NameFlag= 0
SET @FirstLastNameFlag= 0
SET @SecondLastNameFlag= 0
SET @AddressFlag= 0
SET @CellPhoneNumberFlag= 0
SET @BeneficiaryIdTypeFlag = 0
SET @BeneficiaryIdNumberFlag = 0 
SET @StateFlag = 0
SET @CountryFlag = 0
SET @ZipcodeFlag = 0
SET @IsNewBeneficiary = 0

DECLARE @DetailTemp TABLE
(
  IdTransferDetail int
)

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT 
       @Name = T.[BeneficiaryName] --280520191750_azavala
      ,@FirstLastName = T.[BeneficiaryFirstLastName]--280520191750_azavala
      ,@SecondLastName = T.[BeneficiarySecondLastName]--280520191750_azavala
      ,@Address = T.[BeneficiaryAddress]--280520191750_azavala
      ,@City = B.[City]
      ,@State = B.[State]
      ,@Country = B.[Country]
      ,@Zipcode = B.[Zipcode]
      ,@PhoneNumber = T.[BeneficiaryPhoneNumber]--280520191750_azavala
      ,@CellPhoneNumber = T.[BeneficiaryCelularNumber]--280520191750_azavala
      ,@SSnumber = B.[SSnumber]
      ,@BornDate = B.[BornDate]
      ,@Occupation = B.[Occupation]
      ,@Note = B.[Note]
      ,@IdGenericStatus = B.[IdGenericStatus]
      ,@EnterByIdUser = B.[EnterByIdUser]
      ,@IdCustomer = B.[IdCustomer]
      ,@FullName = B.[FullName]
      ,@IdBeneficiaryIdentificationType = B.[IdBeneficiaryIdentificationType]
      ,@IdentificationNumber = B.[IdentificationNumber]
      ,@IdCountryOfBirth = B.[IdCountryOfBirth]
	  ,@IdBeneficiaryOld = B.[IdBeneficiary]
	FROM dbo.Beneficiary B with(nolock) 
	inner join dbo.[Transfer] T with(nolock) on B.IdBeneficiary=T.IdBeneficiary--280520191750_azavala
	WHERE T.IdTransfer=@IdTransfer--280520191750_azavala
	
	
	iF not exists (select top 1 1 from [Transfer] with(nolock) where idtransfer=@IdTransfer)
begin 
    SET @HasError = 1
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('Info: st_UpdateBeneficiary: IdCustomer: ' + CONVERT(VARCHAR, ISNULL(@IdCustomer, 0)) + ' IdBeneficiary: ' + CONVERT(VARCHAR,ISNULL(@IdBeneficiary, 0)) + ', IdAgent: ' + CONVERT(VARCHAR, ISNULL(@IdAgent, 0)) +', Beneficiary: ' + ISNULL(@Name, 'UNK') + ' - ' + ISNULL(@FirstLastName, 'UNK') + ' - ' + ISNULL(@SecondLastName, 'UNK'), GETDATE(),'no existe trans')
    RETURN
end
--IF @IdBeneficiary = 0 
--BEGIN
--	  set @Name = @NameNew
--      set @FirstLastName =@FirstLastNameNew
--      set @SecondLastName = @SecondLastNameNew
--      set @Address = @AddressNew
--      set @City = @CityNew
--      set @State = @StateNew
--      set @Country = @CountryNew
--      set @Zipcode = @ZipcodeNew
--      set @PhoneNumber = ''
--      set @CellPhoneNumber = @CellPhoneNumberNew
--      set @SSnumber = ''
--      set @BornDate = NULL
--      set @Occupation = ''
--      set @Note = ''
--      set @IdGenericStatus = 1
--      set @EnterByIdUser = @IdUser
--      set @IdCustomer = @IdCustomer
--      set @FullName = @NameNew + @FirstLastNameNew + @SecondLastNameNew
--      set @IdBeneficiaryIdentificationType = @IdBeneficiaryTypeNew
--      set @IdentificationNumber = @IdentificationNumberNew
--      set @IdCountryOfBirth = NULL
--	--SET @HasError=1
--	--SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
-- --   INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('Info: st_UpdateBeneficiary: IdCustomer: ' + CONVERT(VARCHAR, ISNULL(@IdCustomer, 0)) + ' IdBeneficiary: ' + CONVERT(VARCHAR,ISNULL(@IdBeneficiary, 0)) + ', IdAgent: ' + CONVERT(VARCHAR, ISNULL(@IdAgent, 0)) +', Beneficiary: ' + ISNULL(@Name, 'UNK') + ' - ' + ISNULL(@FirstLastName, 'UNK') + ' - ' + ISNULL(@SecondLastName, 'UNK'), GETDATE(),'Error por beneficiario no registrado')
--	--RETURN
--END




Select 
 @IdAgentTransfer = IdAgent,
 @CustomerName  =CustomerName,
 @CustomerFirstLastName  = CustomerFirstLastName,
 @CustomerSecondLastName = CustomerSecondLastName,
 @TranferDate=[DateOfTransfer],
 @TransferStatusID= [IdStatus],
 @NumTransferModifications= NumModify,
 @AmountInMN = AmountInMN,
 @IdGateway = IdGateway,
 @ConfirmationCodeOrigin = ConfirmationCode 
from [dbo].[Transfer] with(nolock)
WHERE IdTransfer= @IdTransfer
	
	If (@IsModify = 0)
			begin
			IF ((DATEDIFF(minute, @TranferDate, GETDATE())) >30 AND not exists(Select 1 from [dbo].[TransfersUpdateInProgress] with (nolock) where IdTransfer = @IdTransfer and  OriginalIdStatus in (Select IdStatus from [Status] with(nolock) where CanChangeRequest = 1))) --------------'>30'
				BEGIN
					SET @HasError=1
					INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('Info: st_UpdateBeneficiary: IdCustomer: ' + CONVERT(VARCHAR, ISNULL(@IdCustomer, 0)) + ' IdBeneficiary: ' + CONVERT(VARCHAR,ISNULL(@IdBeneficiary, 0)) + ', IdAgent: ' + CONVERT(VARCHAR, ISNULL(@IdAgent, 0)) +', Beneficiary: ' + ISNULL(@Name, 'UNK') + ' - ' + ISNULL(@FirstLastName, 'UNK') + ' - ' + ISNULL(@SecondLastName, 'UNK'), GETDATE(),'Error de tiempo')
				END
			end
	
	If (@IsModify = 0)
			begin
				/* Validacion Numero de Ediciones de Beneficiario*/  
				Select @NumGlobalTModifications= CONVERT(int,Value)FROM GlobalAttributes with(nolock) where Name = 'NumTransferModifications'
				SET @NumTransferModifications=ISNULL(@NumTransferModifications, 0)
						IF( @NumGlobalTModifications<=@NumTransferModifications )
						BEGIN
							SET @PassedLimitModifications=1
						END
			end
	
                                                      
    

BEGIN TRY
IF((@HasError=0) AND (@PassedLimitModifications = 0 )AND (( @TransferStatusID=@IDUpdateInProgress)))--or (@TransferStatusID = 23 or @TransferStatusID = 40)))
BEGIN
if (@IdBeneficiary = 0)
	Begin	
		declare @getDate datetime = getdate()
		EXEC st_InsertBeneficiaryByTransfer
		@IdBeneficiary,                                                   
		@NameNew,                                                                                              
		@FirstLastNameNew,                                                                                              
		@SecondLastNameNew,                                       
		@AddressNew,                                                                                              
		@CityNew,                                                                                            
		@StateNew,                                                                                              
		@CountryNew,                                                                                          
		@ZipcodeNew,                                                                                              
		@PhoneNumber,              
		@CellPhoneNumberNew,              
		'',                                                                            
		@BornDate,                                                                                              
		'',                                                                                              
		'',                                                                                              
		1,                                           
		@getDate,                                                                       
		@EnterByIdUser,    
		@IdBeneficiaryIdentificationType,     
		@IdentificationNumber,          
		@IdCountryOfBirth,                                                                                   
		@IdBeneficiaryOutput Output

		Set @IdBeneficiary = @IdBeneficiaryOutput
		Set @IsNewBeneficiary = 1

			INSERT INTO [dbo].[BeneficiaryMirror]
           ([IdBeneficiary]
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
           ,[SSnumber]
           ,[BornDate]
           ,[Occupation]
           ,[Note]
           ,[IdGenericStatus]
           ,[DateOfLastChange]
           ,[EnterByIdUser]
           ,[IdCustomer]
           ,[FullName]
           ,[IdBeneficiaryIdentificationType]
           ,[IdentificationNumber]
           ,[IdCountryOfBirth]
           ,[IdTransfer]
		   ,[ConfirmationCode]) 
		   VALUES
		   ( 
	   @IdBeneficiaryOld
      ,@Name 
      ,@FirstLastName 
      ,@SecondLastName 
      ,@Address 
      ,@City 
      ,@State
      ,@Country
      ,@Zipcode 
      ,@PhoneNumber 
      ,@CellPhoneNumber
      ,@SSnumber
      ,@BornDate
      ,@Occupation
      ,@Note 
      ,@IdGenericStatus
	  , GETDATE() 
      ,@EnterByIdUser
      ,@IdCustomer
      ,@FullName
      ,@IdBeneficiaryIdentificationType 
      ,@IdentificationNumber
      ,@IdCountryOfBirth 
	  ,@IdTransfer
	  ,@ConfirmationCodeOrigin)

	  if(@IsModify = 0)
	  Begin
		 UPDATE [dbo].[PreTransfer]
		   SET 
			   [DateOfLastChange] = GETDATE()  
			  ,[BeneficiaryName] = @NameNew
			  ,[BeneficiaryFirstLastName] = @FirstLastNameNew
			  ,[BeneficiarySecondLastName] = @SecondLastNameNew 
			  ,[BeneficiaryAddress] = @AddressNew 
			  ,[BeneficiaryCelularNumber] = @CellPhoneNumberNew
			  ,[IdBeneficiaryIdentificationType]=@IdBeneficiaryTypeNew
			  ,[BeneficiaryIdentificationNumber]= @IdentificationNumberNew   
			  ,[IdBeneficiary] = @IdBeneficiary
			  ,[BeneficiaryState] = @StateNew
			  ,[BeneficiaryCountry] = @CountryNew
			  ,[BeneficiaryZipcode] = @ZipcodeNew
			  ,[BeneficiaryCity] = @CityNew
		 WHERE IdTransfer = @IdTransfer
	  End

	End
Else
Begin
	------------Insert Beneficiary Mirror----------
	INSERT INTO [dbo].[BeneficiaryMirror]
           ([IdBeneficiary]
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
           ,[SSnumber]
           ,[BornDate]
           ,[Occupation]
           ,[Note]
           ,[IdGenericStatus]
           ,[DateOfLastChange]
           ,[EnterByIdUser]
           ,[IdCustomer]
           ,[FullName]
           ,[IdBeneficiaryIdentificationType]
           ,[IdentificationNumber]
           ,[IdCountryOfBirth]
           ,[IdTransfer]
		   ,[ConfirmationCode]) 
		   VALUES
		   ( 
	   @IdBeneficiary
      ,@Name 
      ,@FirstLastName 
      ,@SecondLastName 
      ,@Address 
      ,@City 
      ,@State
      ,@Country
      ,@Zipcode 
      ,@PhoneNumber 
      ,@CellPhoneNumber
      ,@SSnumber
      ,@BornDate
      ,@Occupation
      ,@Note 
      ,@IdGenericStatus
	  , GETDATE() 
      ,@EnterByIdUser
      ,@IdCustomer
      ,@FullName
      ,@IdBeneficiaryIdentificationType 
      ,@IdentificationNumber
      ,@IdCountryOfBirth 
	  ,@IdTransfer
	  ,@ConfirmationCodeOrigin)


UPDATE [dbo].[Beneficiary]
   SET [Name] = @NameNew
      ,[FirstLastName] = @FirstLastNameNew
      ,[SecondLastName] = @SecondLastNameNew
      ,[Address] =@AddressNew
      ,[CelullarNumber] =@CellPhoneNumberNew
	  ,[IdBeneficiaryIdentificationType]=@IdBeneficiaryTypeNew
	  ,[IdentificationNumber]= @IdentificationNumberNew
	  ,[State] = @StateNew
	  ,[Country] = @CountryNew
	  ,[Zipcode] = @ZipcodeNew
	  ,[City] = @CityNew
      ,[DateOfLastChange] = GETDATE()
 WHERE idBeneficiary = @idBeneficiary

 UPDATE [dbo].[PreTransfer]
   SET 
       [DateOfLastChange] = GETDATE()  
      ,[BeneficiaryName] = @NameNew
      ,[BeneficiaryFirstLastName] = @FirstLastNameNew
      ,[BeneficiarySecondLastName] = @SecondLastNameNew 
      ,[BeneficiaryAddress] = @AddressNew 
      ,[BeneficiaryCelularNumber] = @CellPhoneNumberNew
	  ,[IdBeneficiaryIdentificationType]=@IdBeneficiaryTypeNew
	  ,[BeneficiaryIdentificationNumber]= @IdentificationNumberNew  
	  ,[BeneficiaryState] = @StateNew
	  ,[BeneficiaryCountry] = @CountryNew
	  ,[BeneficiaryZipcode] = @ZipcodeNew
	  ,[BeneficiaryCity] = @CityNew
 WHERE IdTransfer = @IdTransfer
End
declare @ConfirmationCode varchar(MAX)
create table #Result (Result varchar(MAX))

if @IdGateway=3                                          
Begin                      

    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	Values('st_UpdateBeneficiary',Getdate(), CONCAT('CustomerName: ', @CustomerName, 'NameNew: ', @NameNew, 'FirstLastNameNew: ', @FirstLastNameNew, 'SecondLastNameNew: ', @SecondLastNameNew, 'AmountInMN: ', @AmountInMN))
	

	Delete #Result                                                                                  
	Insert into #Result (Result)                                                                                  
	EXECUTE DBO.ST_TNC_CONF_CODE_GEN '01', '01', @CustomerName, @NameNew, @FirstLastNameNew, @SecondLastNameNew, @AmountInMN                                                
	Select @ConfirmationCode = ltrim(rtrim(Result)) From #Result                                                                                       
End                                                                                 
Else                                     
Begin                                                                                
	Set @ConfirmationCode = @ConfirmationCodeOrigin                                                                                   
End
 drop table #Result
If (@IsModify = 0 and @IsNewBeneficiary = 0)
			begin
				UPDATE [dbo].[Transfer] 
				   SET [DateOfLastChange] = GETDATE()
					  ,[IdStatus]=@IdUpdatedTransferStatus
					  ,[DateStatusChange]= GETDATE()
				      ,[BeneficiaryName] = @NameNew
				      ,[BeneficiaryFirstLastName] = @FirstLastNameNew
				      ,[BeneficiarySecondLastName] = @SecondLastNameNew
				      ,[BeneficiaryAddress] = @AddressNew
				      ,[BeneficiaryCelularNumber] = @CellPhoneNumberNew 
					  ,[IdBeneficiaryIdentificationType]=@IdBeneficiaryTypeNew
					  ,[BeneficiaryIdentificationNumber]= @IdentificationNumberNew  
					  ,[BeneficiaryState] = @StateNew
					  ,[BeneficiaryCountry]=@CountryNew
					  ,[BeneficiaryZipcode]= @ZipcodeNew
					  ,[BeneficiaryCity]= @CityNew
				      ,[NumModify] = (ISNULL([NumModify], 0)+1)
					  ,[ConfirmationCode] = @ConfirmationCode
					  ,[IdBeneficiary] = @IdBeneficiary
				 WHERE  IdTransfer = @IdTransfer
			end
	

If (@IsModify = 0)
			begin
				 INSERT INTO [dbo].[TransferDetail]
						   ([IdStatus]
						   ,[IdTransfer]
						   ,[DateOfMovement])
						   OUTPUT inserted.IdTransferDetail
						   INTO @DetailTemp
					 VALUES
						   (@IdUpdatedTransferStatus
						   ,@IdTransfer
						   ,GETDATE())


				SELECT @IdTransferDetail=IdTransferDetail from @DetailTemp
			end
	

-------NOTAS-----

IF(@Name!=@NameNew)
BEGIN
SET @NameFlag=1
END
IF(@FirstLastName!=@FirstLastNameNew)
BEGIN
SET @FirstLastNameFlag=1
END
IF(@SecondLastName!=@SecondLastNameNew)
BEGIN
SET @SecondLastNameFlag=1
END
IF(@Address!=@AddressNew)
BEGIN
SET @AddressFlag=1
END
IF(@CellPhoneNumber!=@CellPhoneNumberNew)
BEGIN
SET @CellPhoneNumberFlag=1
END
IF(@IdBeneficiaryTypeNew!=@IdBeneficiaryIdentificationType)
BEGIN
SET @BeneficiaryIdTypeFlag=1
SET @IdBeneficiaryTypeName= (SELECT Name FROM [dbo].[BeneficiaryIdentificationType] with(nolock) where [IdBeneficiaryIdentificationType] = @IdBeneficiaryTypeNew)
END
IF(@IdentificationNumberNew!=@IdentificationNumber)
BEGIN
SET @BeneficiaryIdNumberFlag=1
END
IF(@State!=@StateNew)
BEGIN
SET @StateFlag=1
END
IF(@Country!=@CountryNew)
BEGIN
SET @CountryFlag = 1
END
IF(@Zipcode!=@ZipcodeNew)
BEGIN
SET @ZipcodeFlag=1
END
IF(@City!=@CityNew)
BEGIN
SET @CityFlag=1
END


IF(@NameFlag=1)
BEGIN
insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('st_UpdateBeneficiary', GETDATE(),'NameFlag=1')
SELECT @TranferNote= isnull(CONCAT([dbo].[GetMessageFromMultiLenguajeResorces] (1,'MESSAGE21'), @NameNew),'')
END
IF(@FirstLastNameFlag=1)
BEGIN
	insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('st_UpdateBeneficiary', GETDATE(),'FirstLastNameFlag=1')
SELECT @TranferNote= isnull(CONCAT(@TranferNote, CHAR(13),[dbo].[GetMessageFromMultiLenguajeResorces] (1,'MESSAGE22'), @FirstLastNameNew),@TranferNote)
END
IF(@SecondLastNameFlag=1)
BEGIN
insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('st_UpdateBeneficiary', GETDATE(),'SecondLastNameFlag=1')
SELECT @TranferNote= isnull(CONCAT(@TranferNote, CHAR(13),[dbo].[GetMessageFromMultiLenguajeResorces] (1,'MESSAGE23'), @SecondLastNameNew),@TranferNote)
END
IF(@AddressFlag=1)
BEGIN
insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('st_UpdateBeneficiary', GETDATE(),'AddressFlag=1')
SELECT @TranferNote= isnull(CONCAT(@TranferNote, CHAR(13),[dbo].[GetMessageFromMultiLenguajeResorces] (1,'MESSAGE24'), @AddressNew),@TranferNote)
END
IF(@CellPhoneNumberFlag=1)
BEGIN
insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('st_UpdateBeneficiary', GETDATE(),'CellPhoneNumberFlag=1')
SELECT @TranferNote= isnull(CONCAT(@TranferNote, CHAR(13),[dbo].[GetMessageFromMultiLenguajeResorces] (1,'MESSAGE25'), @CellPhoneNumberNew),@TranferNote)
END
IF(@BeneficiaryIdNumberFlag=1)
BEGIN
insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('st_UpdateBeneficiary', GETDATE(),'BeneficiaryIdNumberFlag=1')
SELECT @TranferNote= isnull(CONCAT(@TranferNote, CHAR(13),[dbo].[GetMessageFromMultiLenguajeResorces] (1,'MESSAGE30'), @IdentificationNumberNew),@TranferNote)
END
IF(@IdBeneficiaryTypeNew=1)
BEGIN
insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('st_UpdateBeneficiary', GETDATE(),'IdBeneficiaryTypeNew=1')
SELECT @TranferNote= isnull(CONCAT(@TranferNote, CHAR(13),[dbo].[GetMessageFromMultiLenguajeResorces] (1,'MESSAGE31'), @IdBeneficiaryTypeName),@TranferNote)
END
--IF(@StateFlag=1)
--BEGIN
--insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('st_UpdateBeneficiary', GETDATE(),'StateFlag=1')
--SELECT @TranferNote= isnull(CONCAT([dbo].[GetMessageFromMultiLenguajeResorces] (1,'MESSAGE21'), @StateNew),'')
--END
--IF(@CountryFlag=1)
--BEGIN
--insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('st_UpdateBeneficiary', GETDATE(),'CountryFlag=1')
--SELECT @TranferNote= isnull(CONCAT([dbo].[GetMessageFromMultiLenguajeResorces] (1,'MESSAGE21'), @CountryNew),'')
--END
--IF(@ZipcodeFlag=1)
--BEGIN
--insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('st_UpdateBeneficiary', GETDATE(),'ZipcodeFlag=1')
--SELECT @TranferNote= isnull(CONCAT([dbo].[GetMessageFromMultiLenguajeResorces] (1,'MESSAGE21'), @ZipcodeNew),'')
--END
--IF(@CityFlag=1)
--BEGIN
--insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('st_UpdateBeneficiary', GETDATE(),'ZipcodeFlag=1')
--SELECT @TranferNote= isnull(CONCAT([dbo].[GetMessageFromMultiLenguajeResorces] (1,'MESSAGE21'), @ZipcodeNew),'')
--END

IF @TranferNote is null
	set @TranferNote = ''
--/*

--SELECT @TranferNote= CONCAT([dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE22'), @FirstLastNameNew)
--SELECT @TranferNote= CONCAT([dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE22'), @SecondLastNameNew)
--SELECT @TranferNote= CONCAT([dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE24'), @AddressNew)
--SELECT @TranferNote= CONCAT([dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE25'), @CellPhoneNumberNew)
--SELECT @TranferNote= [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE26') 
--*/		
If (@IsModify = 0)
			begin   
				IF(@IdTransferDetail is not NULL)
					BEGIN
						INSERT INTO [dbo].[TransferNote]
								   ([IdTransferDetail]
								   ,[IdTransferNoteType]
								   ,[IdUser]
								   ,[Note]
								   ,[EnterDate])
							 VALUES
								   (@IdTransferDetail
								   ,1
								   ,@IdUser
								   ,@TranferNote
								   ,GETDATE())
					END
					ELSE
					BEGIN
					SET @HasError = 1 
					END
			end
	


SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE12') 


--------------------------------------------Service Broker---------------------------------------------------------------------
If (@IsModify = 0)
begin
			INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('Info: st_UpdateBeneficiary: IdCustomer: ' + CONVERT(VARCHAR, ISNULL(@IdCustomer, 0)) + ' IdBeneficiary: ' + CONVERT(VARCHAR,ISNULL(@IdBeneficiary, 0)) + ', IdAgent: ' + CONVERT(VARCHAR, ISNULL(@IdAgent, 0)) +', Beneficiary: ' + ISNULL(@Name, 'UNK') + ' - ' + ISNULL(@FirstLastName, 'UNK') + ' - ' + ISNULL(@SecondLastName, 'UNK'), GETDATE(),'Inicia Service Broker')
			DECLARE
			@conversation uniqueidentifier,
			@msg xml

		set @msg =(
		SELECT 
			@IdTransfer IdTransfer,
			@IdUpdatedTransferStatus IdTransferStatus,
			@IdUser EnterByIdUser,
			@IdAgentTransfer IdAgent, 
			@CustomerName CustomerName,
			@CustomerFirstLastName CustomerFirstLastName,
			@CustomerSecondLastName CustomerSecondLastName,
			@NameNew BeneficiaryName,
			@FirstLastNameNew BeneficiaryFirstLastName,
			@SecondLastNameNew BeneficiarySecondLastName,    			
			@TranferDate DateOfTransfer
		FOR XML PATH ('Transfer'),ROOT ('UpdateDataType'))

		INSERT INTO [dbo].[SBMessageLog] ([IdTransfer],[MessageXML]) values (@IdTransfer, @msg)


		--DESCOMENTARIZAR ajuaa
		--- Start a conversation:
		BEGIN DIALOG @conversation
		    FROM SERVICE [//Maxi/Transfer/UpdateSenderService]
		    TO SERVICE N'//Maxi/Transfer/UpdateRecipService'
		    ON CONTRACT [//Maxi/Transfer/UpdateContract]
		    WITH ENCRYPTION=OFF;

		--- Send the message
		SEND ON CONVERSATION @conversation
		    MESSAGE TYPE [//Maxi/Transfer/UpdateDataType]
		    (@msg);

		insert into [dbo].SBSendUpdateMessageLog (ConversationID,MessageXML,[IdTransfer]) values (@conversation,@msg,@IdTransfer)
end
Else
Begin
		exec [st_TransferToCancelInProgress] @IdUser, @IdLenguage , @IdTransfer ,'Cancelación por modificación',18,0,''   
end
	


			-----------------------------------------------------------------------------------------------------------------



END
ELSE
BEGIN
	SET @HasError = 1

	If (@IsModify = 0)
	begin
		IF(@TransferStatusID<>@IDUpdateInProgress)
		BEGIN
			SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE27') 
		END
		ELSE
		BEGIN
			SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE13') 
		END
	end
END

 END TRY
 BEGIN CATCH
	Declare @ErrorMessage nvarchar(max)
	SET @HasError = 1
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE13')                                                                                            
    Select  @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_UpdateBeneficiary]',Getdate(),@ErrorMessage)
 END CATCH
 END
