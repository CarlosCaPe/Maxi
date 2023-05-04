CREATE procedure [dbo].[st_InserLogForListener]
@Type varchar(50),
@Proyect varchar(100),
@SessionGuid varchar(50),
@IdUser int,
@ClientDatetime datetime,
@Message nvarchar(max),
@ExceptionMessage nvarchar(max),
@StackTrance nvarchar(max),
@Priority int

as
Begin Try

INSERT INTO [dbo].[LogForListener]
           ([Type]
           ,[Proyect]
           ,[SessionGuid]
           ,[IdUser]
           ,[ClientDatetime]
           ,[ServerDatetime]
           ,[Message]
           ,ExceptionMessage
           ,[StackTrace]
           ,[Priority])
     VALUES
           (@Type
           ,@Proyect
           ,@SessionGuid
           ,@IdUser
           ,@ClientDatetime
           ,GETDATE()
           ,@Message
           ,@ExceptionMessage
           ,@StackTrance
           ,@Priority)


End try
Begin catch

End catch
