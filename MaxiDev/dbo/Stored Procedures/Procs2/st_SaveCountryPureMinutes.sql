--select * from dbo.CountryPureMinutes
create procedure st_SaveCountryPureMinutes
(
    @IdCountryPureMinutes	int,
    @CountryName nvarchar (max),
    @HasError bit out
)
as
BEGIN TRY
    insert into CountryPureMinutes
    (IdCountryPureMinutes,CountryName,IdGenericStatus)
    values
    (@IdCountryPureMinutes,@CountryName,1)
    Set @HasError=0
END TRY
BEGIN CATCH 
 Set @HasError=1                                                                                    
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveCountryPureMinutes',Getdate(),@ErrorMessage)    
END CATCH