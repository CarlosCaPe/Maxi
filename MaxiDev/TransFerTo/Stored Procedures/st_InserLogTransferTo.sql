CREATE procedure [TransFerTo].[st_InserLogTransferTo]
	@IdUser int,
    @Request nvarchar(max), 
    @Response nvarchar(max), 
    @DateLastChange datetime, 
    @Authenticationkey bigint,
	@IdRequestType int,
    @ReturnCode int,
    @Destination_Number nvarchar(max)
as
Begin Try

INSERT INTO [TransFerTo].[LogTransferTo]
           ([IdUser]
           ,[Request]
           ,[Response]
           ,[DateLastChange]
           ,[Authenticationkey]
		   ,[IdRequestType]
           ,ReturnCode
           ,Destination_Number
           )
     VALUES
           (@IdUser
           ,@Request
           ,@Response
           ,@DateLastChange
           ,@Authenticationkey
		   ,@IdRequestType
           ,@ReturnCode
           ,@Destination_Number
           )


End try
Begin catch
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_InserLogTransferTo',Getdate(),@ErrorMessage)
End catch