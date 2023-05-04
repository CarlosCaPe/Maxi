CREATE PROCEDURE [dbo].[st_ApplyWfSubAccountDeposit]
(
    @DepositData XML,
    @IdUser INT,
    @IsSpanishLanguage INT,    
    @HasError BIT OUT,
    @Message varchar(max) OUT
)
AS
/********************************************************************
<Author>???</Author>
<app>Corporate</app>
<Description>Valida Archivos de Depositos Wells Fargo</Description>
<ChangeLog>
<log Date="17/09/2020" Author="jgomez">M00247 - Manejo de Subcuentas de Nevada y Nebraska en depósitos</log>
</ChangeLog>
*********************************************************************/

--Declaracion de variables
DECLARE @DocHandle INT 
declare @IdBank INT
declare @BankName NVARCHAR(max)
DECLARE @IdDeposit INT
DECLARE @IdAgent INT
DECLARE @Amount MONEY
DECLARE @Note nvarchar(max)
DECLARE @ReferenceNumber nvarchar(max)

--Inicializacion de variables
SELECT 
        @HasError=0,
        @Message=dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,14) 
        --@IdBank = CONVERT(INT,dbo.GetGlobalAttributeByName('DefaultBankSubAccount'))

--SELECT @BankName=BankName FROM dbo.AgentBankDeposit WHERE IdAgentBankDeposit=@IdBank

BEGIN TRY
EXEC sp_xml_preparedocument @DocHandle OUTPUT,@DepositData 

Create Table #Deposits
(
    IdDeposit INT IDENTITY(1,1),
    IdAgent INT,
    Amount MONEY,    
    Note nvarchar(max),
    DepositDate DATETIME,
    ReferenceNumber nvarchar(max),
	BankName nvarchar(max)
)

--Guardar informacion de depositos en tabla temporal
INSERT INTO #Deposits
SELECT IdAgent,Amount,Note,DepositDate,ReferenceNumber, BankName  From OPENXML (@DocHandle, '/WFSubAccountDeposits/WFSubAccountDeposit',2) 
    WITH (      
        IdAgent INT,
        Amount MONEY,
        DepositDate DATETIME,
        Note nvarchar(max),
        ReferenceNumber nvarchar(max),
		BankName nvarchar(max)
    )

DECLARE @HasErrorTmp BIT
DECLARE @MessageTmp  varchar(max)
DECLARE @Date DATETIME
    
     --Ciclo para aplicar los movimientos
    While exists (Select top 1 1 from #Deposits)      
    BEGIN
        Select top 1 @IdDeposit=IdDeposit, @IdAgent=IdAgent, @Amount=Amount, @Date = DepositDate, @Note=Note, @ReferenceNumber=ReferenceNumber, @BankName = BankName from #Deposits      
        EXEC [st_SaveDeposit] 
            @IsSpanishLanguage,
            @IdAgent,
            @BankName,
            @Amount,
            @Date,
            @Note,--@IdACHMovement,
            @IdUser,
            3, --Type Encode Deposit
            @HasErrorTmp OUT,
            @MessageTmp OUT,
            @ReferenceNumber
    
        Delete #Deposits where IdDeposit=@IdDeposit
    END
    
END TRY
BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @Message = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,80)                                                                               
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ApplyWfSubAccountDeposit',Getdate(),@ErrorMessage)    
END CATCH