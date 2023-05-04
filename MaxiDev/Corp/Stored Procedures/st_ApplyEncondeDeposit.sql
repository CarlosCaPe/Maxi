CREATE PROCEDURE [Corp].[st_ApplyEncondeDeposit]
(
    @DepositData XML,
    @IdUser INT,
    @IsSpanishLanguage INT,
    @CodifiedDepositFileName NVARCHAR(1000) = NULL,     
    @HasError BIT OUT,
    @Message varchar(max) OUT
)
AS
--Declaracion de variables
DECLARE @DocHandle INT 
declare @IdBank INT
declare @BankName NVARCHAR(max)
DECLARE @IdDeposit INT
DECLARE @IdAgent INT
DECLARE @Amount MONEY
DECLARE @Note nvarchar(max)

--Inicializacion de variables
SELECT 
        @HasError=0,
        @Message=dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,14) ,
        @IdBank = CONVERT(INT,dbo.GetGlobalAttributeByName('DefaultBankEncodeDeposit'))

SELECT @BankName=BankName FROM dbo.AgentBankDeposit WITH (NOLOCK) WHERE IdAgentBankDeposit=@IdBank

BEGIN TRY
EXEC sp_xml_preparedocument @DocHandle OUTPUT,@DepositData 

Create Table #Deposits
(
    IdDeposit INT IDENTITY(1,1),
    IdAgent INT,
    Amount MONEY,    
    Note nvarchar(max),
    DepositDate DATETIME
)

--Guardar informacion de depositos en tabla temporal
INSERT INTO #Deposits
SELECT IdAgent,Amount,'By Process Encode Deposit',DepositDate  From OPENXML (@DocHandle, '/AgentDeposits/AgentDeposit',2) 
    WITH (      
        IdAgent INT,
        Amount MONEY,
        DepositDate DATETIME
    )

DECLARE @HasErrorTmp BIT
DECLARE @MessageTmp  varchar(max)
DECLARE @Date DATETIME
    
     --Ciclo para aplicar los movimientos
    While exists (Select top 1 1 from #Deposits)      
    BEGIN
        Select top 1 @IdDeposit=IdDeposit, @IdAgent=IdAgent, @Amount=Amount, @Date = DepositDate, @Note=Note from #Deposits      
        EXEC [Corp].[st_SaveDeposit] 
            @IsSpanishLanguage,
            @IdAgent,
            @BankName,
            @Amount,
            @Date,
            @Note,--@IdACHMovement,
            @IdUser,
            3, --Type Encode Deposit
            @HasErrorTmp OUT,
            @MessageTmp OUT
    
        Delete #Deposits where IdDeposit=@IdDeposit
    END
    
END TRY
BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @Message = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,80)                                                                               
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_ApplyEncondeDeposit]',Getdate(),@ErrorMessage)    
END CATCH

