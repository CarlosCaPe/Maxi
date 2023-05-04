CREATE PROCEDURE [dbo].[st_UpdateZipCode]
(
     @ZipCode int   
    ,@CityName varchar(200)
    ,@IdGenericStatus int
    ,@IdLenguage int
    ,@EnterByIdUser int
    ,@HasError bit out
    ,@Message nvarchar(max) out
)
as

Begin try

    UPDATE [dbo].[ZipCode]
    SET 
       [CityName] = @CityName
      ,[IdGenericStatus] = @IdGenericStatus
      ,[EnterByIdUser] = @EnterByIdUser
      ,[DateOfLastChange] = getdate()
     WHERE [ZipCode] = @ZipCode

   set @HasError=0
   set @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'ZIPCODEOK')

End try
begin catch
    set @HasError=1
    set @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'ZIPCODEERR02')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateZipCode',Getdate(),@ErrorMessage)
end catch
