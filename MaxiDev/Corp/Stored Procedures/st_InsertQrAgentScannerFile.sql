CREATE PROCEDURE [Corp].[st_InsertQrAgentScannerFile]
(
    @Id INT,
    @FileName nvarchar(max),
    @FileGuid nvarchar(max),
	@Extension nvarchar(max),
    @BankName nvarchar(max),
    @Amount MONEY,
    @DepositDate DATETIME,
    @Notes NVARCHAR(max),
    @EnterByIdUser INT,
    @IdAgentCollectType INT,
    @ApplyDeposit BIT,
    @IsSpanishLanguage BIT,
    @IdScannerProcessFileParameter INT OUT,
    @HasError BIT OUT,
    @MessageOut NVARCHAR(max) out
)
as
--Declaracion de variables
DECLARE @IdUploadFile INT

--Inicializacion de variables
SET @HasError=0
SET @MessageOut='ok'
SET @ApplyDeposit = ISNULL(@ApplyDeposit,0)

SELECT IdAgentCollectType, [Name], CreationDate, DateofLastChange, EnterByIdUser, IdStatus FROM dbo.AgentCollectType WITH(NOLOCK)

IF @EnterByIdUser = 0 
    SET @EnterByIdUser = CONVERT(INT,dbo.GetGlobalAttributeByName('SystemUserID'))

BEGIN TRY

    INSERT INTO dbo.UploadFiles
            (IdReference, 
            IdDocumentType, 
            [FileName], 
            Fileguid, 
            Extension, 
            IdStatus, 
            IdUser, 
            LastChange_LastDateChange, 
            LastChange_LastUserChange, 
            LastChange_LastIpChange, 
            LastChange_LastNoteChange,
            CreationDate)
    VALUES  ( @Id , -- IdReference - int
              62 , -- IdDocumentType Scanner
              @FileName , -- FileName - nvarchar(max)
              @FileGuid , -- FileGuid - nvarchar(max)
              @Extension , -- Extension - nvarchar(max)
              1 , -- IdStatus - int
              @EnterByIdUser , -- IdUser - int
              GETDATE() , -- LastChange_LastUserChange - nvarchar(max)
              GETDATE() , -- LastChange_LastDateChange - datetime
              @EnterByIdUser , -- LastChange_LastIpChange - nvarchar(max)
              @Notes , -- LastChange_LastNoteChange - nvarchar(max)          
              GETDATE()  -- CreationDate - datetime
            )

    SET @IdUploadFile = SCOPE_IDENTITY()

    INSERT INTO dbo.ScannerProcessFile
            ( IdAgent ,
              IdUploadFile ,
              BankName ,
              Amount ,
              EnterByIdUser ,
              DepositDate ,
              CreationDate ,
              DateofLastChange ,
              IsProcessed
            )
    VALUES  ( @Id , -- IdAgent - int
              @IdUploadFile , -- IdUploadFile - int
              @BankName , -- BankName - nvarchar(max)
              @Amount , -- Amount - money
              @EnterByIdUser , -- EnterByIdUser - int
              @DepositDate , -- DepositDate - datetime
              GETDATE() , -- CreationDate - datetime
              GETDATE() , -- DateofLastChange - datetime
              @ApplyDeposit  -- IsProcessed - bit
            )

    SET @IdScannerProcessFileParameter=SCOPE_IDENTITY()

    IF @ApplyDeposit=1 
    BEGIN
          EXEC [Corp].[st_SaveDeposit] 
              @IsSpanishLanguage,
              @Id,
              @BankName,
              @Amount,
              @DepositDate,
              @Notes,
              @EnterByIdUser,
              @IdAgentCollectType,
              @HasError OUT,              
              @MessageOut OUT          
    END      

END TRY
BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,0)                                                                               
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_InsertQrAgentScannerFile]',Getdate(),@ErrorMessage)    
END CATCH

