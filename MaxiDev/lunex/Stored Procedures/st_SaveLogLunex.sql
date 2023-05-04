create procedure Lunex.st_SaveLogLunex
(
    @IdUser int,
    @Response nvarchar(max),
    @Request nvarchar(max),
    @HasError bit out
)
as
Begin Try  

     INSERT INTO [Lunex].[LogLunex]
           ([IdUser]
           ,[Request]
           ,[Response]
           ,[DateLastChange])
     VALUES
           (@IdUser
           ,@Request
           ,@Response
           ,getdate())

    set @HasError = 0
End Try                                                                                            
Begin Catch                                                                                       
 Set @HasError=1                                                                                     
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Lunex.st_SaveLogLunex',Getdate(),@ErrorMessage)                                                                                            
End Catch 
