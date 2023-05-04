
-- =============================================
-- Author:		Jorge Gomez 
-- Create date: 25/09/2019
-- Description: Insertar los logs del Web Services
-- M00103 - CR Banco Industrial, Notificación Pago
-- =============================================

CREATE procedure [BIWS].[st_BIWebServicesLog]
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

	INSERT INTO [MAXILOG].[BIWS].[BIWebServicesLog]
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
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('BIWS.st_BIWebServicesLog',Getdate(),@ErrorMessage);
End catch

END
