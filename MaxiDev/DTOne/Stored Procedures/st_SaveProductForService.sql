CREATE   procedure [DTOne].[st_SaveProductForService]
(    
    @CounTRYCode NVARCHAR(3) = Null,
    @CounTRYName NVARCHAR(MAX),
    @IdCarrierDTO INT = Null,
    @CarrierName NVARCHAR(MAX),
    @IdProduct INT = Null,
    @DestinationCurrency NVARCHAR(MAX),    
    @Product MONEY = Null,
    @WholeSalePrice MONEY = Null,
    @SuggestedPrice MONEY = Null,
    @RetailPrice MONEY = Null,
    @Fee MONEY = Null,
    @Margin MONEY = Null,     
    @IdCounTRYOUT INT OUT,
    @IdCarrierOUT INT OUT,
    @IdProductOUT INT OUT,
    @IdDestinationCurrencyOUT INT OUT,    
    @HasError BIT OUT,
    @Message NVARCHAR(max) OUT
)
AS
BEGIN TRY
DECLARE @SystemUser INT
DECLARE @IdOriginCurrency INT
DECLARE  @IdCounTRY INT
DECLARE  @IdCurrency INT
DECLARE  @IdCarrier INT

SELECT TOP 1 @IdOriginCurrency=IDCURRENCY FROM [DTOne].Currency WHERE currencyname='USD'
SELECT TOP 1 @IdCounTRY=[IdCounTRY] FROM [DTOne].[CounTRY] WHERE [CounTRYCode]=@CounTRYCode
SELECT TOP 1 @IdCurrency=[IdCurrency] FROM [DTOne].[Currency] WHERE [CurrencyName]=@DestinationCurrency
SELECT TOP 1 @IdCarrier=[IdCarrier] FROM [DTOne].[Carrier] WHERE [IdCarrierDTO]=@IdCarrierDTO

SET    @IdCounTRYOUT = null
SET    @IdCarrierOUT = null
SET    @IdDestinationCurrencyOUT = null
SET    @IdProductOUT = null

SELECT @SystemUser=[dbo].[GetGlobalAttributeByName] ( 'SystemUserID' ) 

--VerIFicar id de producto
IF EXISTS(SELECT TOP 1 [IdProductDTO] FROM [DTOne].[Product] WHERE [IdProductDTO] = @IdProduct )
BEGIN    
    update [DTOne].[Product] 
    SET 
        WholeSalePrice=@WholeSalePrice,	
        SuggestedPrice=@SuggestedPrice,	
        RetailPrice=@RetailPrice,	
        Fee=@Fee,	
        Margin=@Margin,
        EnterByIdUser = @SystemUser,
        DateOfLastChange = GETDATE()
    WHERE 
        [IdProductDTO] = @IdProduct
END
ELSE
BEGIN 

    --verIFicar counTRY
    IF (@IdCounTRY is null)
    BEGIN    
        INSERT INTO [DTOne].CounTRY (CounTRYName,DateOfCreation,DateOfLastChange,EnterByIdUser,[CounTRYCode],IdGenericStatus)
        VALUES
        (@CounTRYName,GETDATE(),GETDATE(),@SystemUser,@CounTRYCode,1)
        SET @IdCounTRY = SCOPE_IDENTITY()
        SET @IdCounTRYOUT = @IdCounTRY
    END

    --verIFicar carrier
    IF (@IdCarrier is null)
    BEGIN        
	 -- SELECT * FROM [DTOne].Carrier
        INSERT INTO [DTOne].Carrier (IdCounTRY,CarrierName,DateOfCreation,DateOfLastChange,EnterByIdUser,IdCarrierDTO,IdGenericStatus)
        VALUES
        (@IdCounTRY,@CarrierName,GETDATE(),GETDATE(),@SystemUser,@IdCarrierDTO,1)
        SET @IdCarrier = SCOPE_IDENTITY()
        SET @IdCarrierOUT = @IdCarrier
    END

     --verIFicar destination currency 
    IF (@IdCurrency is null)
    BEGIN            
        INSERT INTO [DTOne].Currency (CurrencyName,DateOfCreation,DateOfLastChange,EnterByIdUser)
        VALUES
        (@DestinationCurrency,GETDATE(),GETDATE(),@SystemUser)
        SET @IdCurrency = SCOPE_IDENTITY()
        SET @IdDestinationCurrencyOUT = @IdCurrency
    END    
    
    INSERT INTO [DTOne].[Product] 
	(
			IdCounTRY,
			IdCarrier,
			IdDestinationCurrency,
			IdOriginCurrency,
			Product,
			WholeSalePrice,
			SuggestedPrice,
			RetailPrice,
			Fee,
			Margin,
			DateOfCreation,
			DateOfLastChange,
			EnterByIdUser,
			IdGenericStatus,
			IdCounTRYDTO,	
			IdCarrierDTO,
			[IdProductDTO]
	)
    VALUES
    (
			@IdCounTRY,
			@IdCarrier,
			@IdCurrency,
			@IdOriginCurrency,
			@Product,
			@WholeSalePrice,
			@SuggestedPrice,
			@RetailPrice,
			@Fee,
			@Margin,
			GETDATE(),
			GETDATE(),
			@SystemUser,
			1,
			@CounTRYCode,
			@IdCarrierDTO,
			@IdProduct
	)

    SET @IdProduct = SCOPE_IDENTITY()
    SET @IdProductOUT = @IdProduct
END

SELECT @HasError = 0, @Message = dbo.GetMessageFROMLenguajeResorces (0,60)

END TRY
BEGIN CATCH
	SET @HasError=1
	SELECT @Message =dbo.GetMessageFROMLenguajeResorces (0,59)
	DECLARE @ErrorMessage NVARCHAR(max)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('DTOne.st_SaveProductForService',GETDATE(),@ErrorMessage)
END CATCH