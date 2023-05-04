create procedure [TransFerTo].[st_UpdateTToIDForService]
(
    @IdCountry int,
    @IdCarrier int,
    @IdProduct int,    
    @IdCountryTTo int,
    @IdCarrierTTo int,    
    @HasError bit output
)
as
Set nocount on 
begin try
    set @HasError = 1
    
    if @IdCountry is null or @IdCarrier is null or @IdProduct is null  or @IdCountryTTo is null or @IdCarrierTTo is null
    begin
        return
    end

    Update [TransFerTo].[Country] set IdCountryTTo=@IdCountryTTo where IdCountry=@IdCountry

    Update [TransFerTo].[Carrier] set IdCarrierTTo=@IdCarrierTTo where idCarrier=@idCarrier

    Update [TransFerTo].[Product] set IdCountryTTo=@IdCountryTTo,IdCarrierTTo=@IdCarrierTTo where IdProduct=@IdProduct

    set @HasError = 0
end try

begin catch
    set @HasError = 1
    Declare @ErrorMessage nvarchar(max)
    Select  @ErrorMessage=ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_UpdateTToIDForService',Getdate(),@ErrorMessage)
end catch