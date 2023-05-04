CREATE PROCEDURE [dbo].[st_SaveAgentCollection]
(
--    @IdAgentCollection int,
    @IdAgent INT,
    @IsSpanishLanguage INT,
    @AmountToPay MONEY,
    @Fee money,
    @EnterByIdUser INT,
    @IsPercent Bit = null,
    @PercentCommision INT,
    @MoneyCommision Money,
    @Note NVARCHAR(max),
    @IdAgentCollectType INT,
    @CallendarCollect XML,
    @HasError BIT OUT,
    @MessageOut NVARCHAR(max) OUT  
)
AS
--Declaracion de variables
DECLARE @LastAmountToPay MONEY 
DECLARE @ActualAmountToPay MONEY
DECLARE @DocHandle INT 
DECLARE @IdAgentCollection int

--inicializacion de variables
IF ISNULL(@Note,'')='' SET @Note='Note by AgentCollection'
SET @HasError=0
SET @MessageOut='ok'

BEGIN TRY

SELECT @IdAgentCollection=IdAgentCollection FROM AgentCollection WHERE IdAgent=@IdAgent
--Obtener ultimo adeudo
SELECT TOP 1 @ActualAmountToPay=ActualAmountToPay FROM dbo.AgentCollectionDetail WHERE IdAgentCollection=@IdAgentCollection ORDER BY IdAgentCollectiondetail desc
SET @ActualAmountToPay = ISNULL(@ActualAmountToPay,0)



IF ISNULL(@IdAgentCollection,0)=0
BEGIN
    --Agregar AgentCollection
    INSERT INTO dbo.AgentCollection
            ( IdAgent ,
              AmountToPay ,
              EnterByIdUser ,
              CreationDate ,
              DateofLastChange,
              Fee
            )
    VALUES  ( @IdAgent , -- IdAgent - int
              @AmountToPay , -- AmountToPay - money
              @EnterByIdUser , -- EnterByIdUser - int
              GETDATE() , -- CreationDate - datetime
              GETDATE(),  -- DateofLastChange - datetime
              @Fee
            )
    
    SET @IdAgentCollection = SCOPE_IDENTITY()   
    
    --Calcular Montos
    SET @LastAmountToPay=0
    SET @ActualAmountToPay=@AmountToPay
    SET @AmountToPay = @LastAmountToPay-@ActualAmountToPay
             
END
ELSE
BEGIN
        --Actualizar AgentCollection
        UPDATE AgentCollection 
            SET 
                AmountToPay=@AmountToPay,
                Fee=@Fee,
                EnterByIdUser=@EnterByIdUser,
                DateofLastChange=GETDATE()
            WHERE
                IdAgentCollection=@IdAgentCollection

        --Deparacion de plan de pago
        DELETE FROM AgentCommissionConfiguration WHERE IdAgentCollection=@IdAgentCollection
              
        --Depurar calendar collect
        DELETE FROM dbo.CalendarCollect WHERE IdAgent=@IdAgent

        --Calcular Montos        
        SET @LastAmountToPay = @ActualAmountToPay
        SET @ActualAmountToPay = @AmountToPay
        SET @AmountToPay = @LastAmountToPay-@ActualAmountToPay
        --SET @AmountToPay=@AmountToPay            
END

 --agregar detalle

INSERT INTO [dbo].[AgentCollectionDetail]
        ([IdAgentCollection]
        ,[LastAmountToPay]
        ,[ActualAmountToPay]
        ,[AmountToPay]
        ,[Note]
        ,[IdAgentCollectionConcept]
        ,[CreationDate]
        ,[DateofLastChange]
        ,[EnterByIdUser])
    VALUES
        (@IdAgentCollection
        ,@LastAmountToPay
        ,@ActualAmountToPay
        ,@AmountToPay
        ,@Note
        ,2 --@IdAgentCollectionConcept --Manual
        ,GETDATE()
        ,GETDATE()
        ,@EnterByIdUser) 

IF(@IsPercent is not null) 
BEGIN
    if (@IsPercent=1)
    begin
        INSERT into AgentCommissionConfiguration 
        values
        (@IdAgentCollection,@PercentCommision,0,@IsPercent)
    end
    else
    begin
        INSERT into AgentCommissionConfiguration 
        values
        (@IdAgentCollection,0,@MoneyCommision,@IsPercent)
    end
END 
ELSE
BEGIN    
EXEC sp_xml_preparedocument @DocHandle OUTPUT,@CallendarCollect

 --SELECT * FROM CalendarCollect
 
 INSERT INTO CalendarCollect  
 Select IdAgent,GETDATE(),PayDate,@EnterByIdUser,Amount,@IdAgentCollectType From OPENXML (@DocHandle, '/CalendarCollects/CalendarCollect',2) 
    WITH (      
        IdAgent INT,
        PayDate DATETIME,        
        Amount money
    )    
END

END TRY
BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @MessageOut = 'Error saving collection'--dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,0)                                                                               
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveAgentCollection',Getdate(),@ErrorMessage)    
END CATCH