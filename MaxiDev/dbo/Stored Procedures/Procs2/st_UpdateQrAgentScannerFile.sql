
CREATE PROCEDURE [dbo].[st_UpdateQrAgentScannerFile]
(
    @IdScannerProcessFiles INT,
    @IdAgent INT,    
    @BankName nvarchar(max),
    @Amount MONEY,
    @DepositDate DATETIME,
    @Notes NVARCHAR(max),
    @EnterByIdUser INT,
    --@IdAgentCollectType INT,
    @ApplyDeposit BIT,
    @IsSpanishLanguage BIT,  
    @IdScannerProcessFileParameter INT OUT,  
    @HasError BIT OUT,
    @MessageOut NVARCHAR(max) out
)
AS

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="24/01/2018" Author="jmolina">Add with(nolock) And Schema</log>
</ChangeLog>
********************************************************************/

DECLARE @IdAgentCollectType int
--Inicializacion de variables
SET @HasError=0
SET @MessageOut='ok'
SET @ApplyDeposit = ISNULL(@ApplyDeposit,0)
SET @IdAgentCollectType = 4

--IF @EnterByIdUser= 0 
--    SET @EnterByIdUser = CONVERT(INT,dbo.GetGlobalAttributeByName('SystemUserID'))

BEGIN TRY
UPDATE dbo.ScannerProcessFile 
SET    [IdAgent] = @IdAgent      
      ,[BankName] = @BankName
      ,[Amount] = @Amount
      ,[EnterByIdUser] = @EnterByIdUser
      ,[DepositDate] = @DepositDate   
      ,[DateofLastChange] = GETDATE()
      ,[IsProcessed] = @ApplyDeposit
 WHERE IdScannerProcessFiles=@IdScannerProcessFiles

 SET @IdScannerProcessFileParameter=@IdScannerProcessFiles

 IF @ApplyDeposit=1 
    BEGIN
          EXEC dbo.st_SaveDeposit 
              @IsSpanishLanguage,
              @IdAgent,
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
 Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,80)                                                                               
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateQrAgentScannerFile',Getdate(),@ErrorMessage)    
END CATCH
