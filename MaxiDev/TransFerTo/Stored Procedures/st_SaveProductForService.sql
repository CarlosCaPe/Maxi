CREATE procedure [TransFerTo].[st_SaveProductForService]
(    
    @IdCountry int = Null,
    @CountryName nvarchar(max),
    @IdCarrier int = Null,
    @CarrierName nvarchar(max),
    @IdProduct int = Null,
    @IdDestinationCurrency int = Null,
    @DestinationCurrency nvarchar(max),    
    @Product money = Null,
    @WholeSalePrice money = Null,
    @SuggestedPrice money = Null,
    @RetailPrice money = Null,
    @Fee money = Null,
    @Margin money = Null,
    @IdCountryTTo int = Null,
    @IdCarrierTTo int = Null,    
    @IdCountryOut int out,
    @IdCarrierOut int out,
    @IdProductOut int out,
    @IdDestinationCurrencyOut int out,    
    @HasError bit out,
    @Message nvarchar(max) out
)
as
Begin Try
declare @SystemUser int
declare @IdOriginCurrency int

select TOP 1 @IdOriginCurrency=IDCURRENCY from [TransFerTo].currency where currencyname='USD'
    
set    @IdCountryOut = null
set    @IdCarrierOut = null
set    @IdDestinationCurrencyOut = null
set    @IdProductOut = null

select @SystemUser=[dbo].[GetGlobalAttributeByName] ( 'SystemUserID' ) 

--Verificar id de producto
if (@IdProduct is not null)
begin    
    update [TransFerTo].[Product] 
    set 
        WholeSalePrice=@WholeSalePrice,	
        SuggestedPrice=@SuggestedPrice,	
        RetailPrice=@RetailPrice,	
        Fee=@Fee,	
        Margin=@Margin,
        EnterByIdUser = @SystemUser,
        DateOfLastChange = getdate()
    where 
        IdProduct=@IdProduct
end
else
begin 

    --verificar country
    if (@IdCountry is null)
    begin    
        insert into [TransFerTo].Country (CountryName,DateOfCreation,DateOfLastChange,EnterByIdUser,IdCountryTTo)
        values
        (@CountryName,getdate(),getdate(),@SystemUser,@IdCountryTTo)
        set @IdCountry = SCOPE_IDENTITY()
        set @IdCountryOut = @IdCountry
    end

    --verificar carrier
    if (@IdCarrier is null)
    begin            
        insert into [TransFerTo].Carrier (IdCountry,CarrierName,DateOfCreation,DateOfLastChange,EnterByIdUser,IdCarrierTTo)
        values
        (@IdCountry,@CarrierName,getdate(),getdate(),@SystemUser,@IdCarrierTTo)
        set @IdCarrier = SCOPE_IDENTITY()
        set @IdCarrierOut = @IdCarrier
    end

     --verificar destination currency 
    if (@IdDestinationCurrency is null)
    begin            
        insert into [TransFerTo].Currency (CurrencyName,DateOfCreation,DateOfLastChange,EnterByIdUser)
        values
        (@DestinationCurrency,getdate(),getdate(),@SystemUser)
        set @IdDestinationCurrency = SCOPE_IDENTITY()
        set @IdDestinationCurrencyOut = @IdDestinationCurrency
    end    
    
    insert into [TransFerTo].[Product] (IdCountry,IdCarrier,IdDestinationCurrency,IdOriginCurrency,Product,WholeSalePrice,SuggestedPrice,RetailPrice,Fee,Margin,DateOfCreation,DateOfLastChange,EnterByIdUser,IdGenericStatus,IdCountryTTo,IdCarrierTTo)
    values
    (@IdCountry,@IdCarrier,@IdDestinationCurrency,@IdOriginCurrency,@Product,@WholeSalePrice,@SuggestedPrice,@RetailPrice,@Fee,@Margin,getdate(),getdate(),@SystemUser,1,@IdCountryTTo,@IdCarrierTTo)

    set @IdProduct = SCOPE_IDENTITY()
    set @IdProductOut = @IdProduct
end

select @HasError = 0, @Message = dbo.GetMessageFromLenguajeResorces (0,60)

End Try
Begin Catch
	Set @HasError=1
	Select @Message =dbo.GetMessageFromLenguajeResorces (0,59)
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_SaveProductForService',Getdate(),@ErrorMessage)
End Catch