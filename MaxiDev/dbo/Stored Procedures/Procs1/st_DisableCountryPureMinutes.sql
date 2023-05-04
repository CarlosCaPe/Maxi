--select * from dbo.CountryPureMinutes
create procedure st_DisableCountryPureMinutes
(
    @IdCountryPureMinutes	int,
    @IdGenericStatus int, --Values 1 Enable, 2 Disable
    @HasError bit out
)
as
BEGIN TRY
    update CountryPureMinutes set idgenericstatus=@IdGenericStatus where IdCountryPureMinutes=@IdCountryPureMinutes    
    Set @HasError=0
END TRY
BEGIN CATCH 
 Set @HasError=1                                                                                    
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_DisableCountryPureMinutes',Getdate(),@ErrorMessage)    
END CATCH