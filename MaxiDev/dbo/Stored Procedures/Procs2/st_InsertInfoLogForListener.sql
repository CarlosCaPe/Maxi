/********************************************************************
<Author>azavala</Author>
<app>Logs</app>
<Description></Description>

<ChangeLog>
<log Date="30/07/2018" Author="azavala">Guardar logs informativos</log>
</ChangeLog>
*********************************************************************/
CREATE procedure [dbo].[st_InsertInfoLogForListener]
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
BEGIN

SET NOCOUNT ON;

Begin Try

	INSERT INTO [Soporte].[InfoLogForListener]
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
			   ,@Priority);

End try
Begin catch
    Declare @ErrorMessage nvarchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('dbo.st_InsertInfoLogForListener',Getdate(),@ErrorMessage);
End catch

END
