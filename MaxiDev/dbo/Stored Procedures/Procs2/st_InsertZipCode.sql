CREATE PROCEDURE [dbo].[st_InsertZipCode]
(
     @ZipCode int
    ,@IdState int
    ,@CityName varchar(200)
    ,@IdGenericStatus int
    ,@IdLenguage int
    ,@EnterByIdUser int
    ,@HasError bit out
    ,@Message nvarchar(max) out
)
as

declare
    @StateCode nvarchar(max), @StateName nvarchar(max)

Begin try

if exists (select top 1 1 from zipcode where zipcode=@ZipCode)
begin
    set @HasError=1
    set @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'ZIPCODEERR01')
    return
end

select @StateCode=StateCode,@StateName=StateName from state where idstate=@IdState


    INSERT INTO [dbo].[ZipCode]
           ([ZipCode]
           ,[StateCode]
           ,[StateName]
           ,[CityName]
           ,[IdCounty]
           ,[IdGenericStatus]
           ,EnterByIdUser
           ,DateOfLastChange
           )
     VALUES
           (@ZipCode
           ,isnull(@StateCode,'')
           ,isnull(@StateName,'')
           ,upper(@CityName)
           ,null
           ,@IdGenericStatus
           ,@EnterByIdUser
           ,getdate()
           )

    set @HasError=0
    set @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'ZIPCODEOK')

End try
begin catch
    set @HasError=1
    set @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'ZIPCODEERR02')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_InsertZipCode',Getdate(),@ErrorMessage)
end catch
