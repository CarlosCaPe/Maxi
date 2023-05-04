CREATE procedure [dbo].[st_InserLogForListenerWinService]
@Type varchar(50),
@Proyect varchar(100),
@ClientDatetime datetime,
@Message nvarchar(max),
@StackTrance nvarchar(max) = NULL,
@Priority int

as
Begin Try

INSERT INTO [dbo].[LogForListenerWinService]
           ([Type]
           ,[Proyect]
           ,[ClientDatetime]
           ,[ServerDatetime]
           ,[Message]
           ,[StackTrace]
           ,[Priority])
     VALUES
           (@Type
           ,@Proyect
           ,@ClientDatetime
           ,GETDATE()
           ,@Message
           ,@StackTrance
           ,@Priority)


End try
Begin catch

End catch
