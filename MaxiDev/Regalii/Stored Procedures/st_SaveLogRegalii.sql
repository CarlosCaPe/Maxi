create procedure Regalii.st_SaveLogRegalii
            @IdAgent int
           ,@IdUser int
           ,@JsonRequest nvarchar(max)
           ,@JsonResponse nvarchar(max)
           ,@HasError bit out
as
Begin Try  

INSERT INTO [Regalii].[LogRegalii]
           ([IdAgent]
           ,[IdUser]
           ,[JsonRequest]
           ,[JsonResponse]
           ,[DateLastChange])
     VALUES
           (
            @IdAgent
           ,@IdUser
           ,@JsonRequest
           ,@JsonResponse
           ,getdate()
           )

Set @HasError=0
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                   
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Regalii.SaveLogRegalii',Getdate(),@ErrorMessage)                                                                                            
End Catch  