CREATE PROCEDURE [dbo].[st_CreateSession_v2]
@IdUser int,
@IP varchar(50),
@Session uniqueidentifier = null,
@MachineDescription varchar(max),
@DateOfCreation datetime = null,
@FrameworkVersion varchar(50) = null,
@SOVersion varchar(100) = null,
@SessionId VARCHAR(50) OUTPUT
AS
/********************************************************************
<Author>???</Author>
<app>Corporate and Agent</app>
<Description>Create a session for a user</Description>

<ChangeLog>
<log Date="30/09/2022" Author="raarce">Add encoding to @MachineDescription</log>
<log Date="23/07/2018" Author="mhinojo">Add aditional info</log>
<log Date="05/07/2019" Author="bortega">
Save the framework and operating system of the session.</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY
Delete [dbo].[UsersSession] where IdUser =@IdUser

DECLARE @FrameOldVersion varchar(max),
		@OS varchar(max),
		@DocHandle int

if (@Session IS NULL)
    BEGIN
        SET @Session = NEWID()
        SET @SessionId = @Session
    end

if (@DateOfCreation IS NULL)
    BEGIN
        SET @DateOfCreation = GETDATE()
    end

if (@FrameworkVersion IS NOT NULL)
	BEGIN
	
		set @MachineDescription = '<?xml version="1.0" encoding="ISO-8859-1"?> ' + @MachineDescription
		EXEC sp_xml_preparedocument @DocHandle output, @MachineDescription
		sELECT @DocHandle DocHandle
		SELECT @FrameOldVersion= FrameworkVersion, @OS = OSVersionName
			FROM OPENXML (@DocHandle, '/PcInformation/Enviroment', 2)
			WITH (
			FrameworkVersion varchar(50),
			OSVersionName varchar(100)
			)

			set @MachineDescription = (Select replace(@MachineDescription, @FrameOldVersion, @FrameworkVersion))

			INSERT INTO [dbo].[UsersSession]
			   ([SessionGuid]
			   ,[IdUser]
			   ,[IP]
			   ,[DateOfCreation]
			   ,[LastAccess]
			   ,[MachineDescription]
			   ,[FrameworkVersion]
			   ,[OperativeSystem])
		 VALUES
			   (@Session
			   ,@IdUser
			   ,@IP
			   ,@DateOfCreation
			   ,@DateOfCreation
			   ,@MachineDescription
			   ,@FrameworkVersion
			   ,@SOVersion)

	END
ELSE
BEGIN
	INSERT INTO [dbo].[UsersSession]
			   ([SessionGuid]
			   ,[IdUser]
			   ,[IP]
			   ,[DateOfCreation]
			   ,[LastAccess]
			   ,[MachineDescription])
		 VALUES
			   (@Session
			   ,@IdUser
			   ,@IP
			   ,@DateOfCreation
			   ,@DateOfCreation
			   ,@MachineDescription)
END



INSERT INTO [dbo].[UsersSessionLog]
           ([SessionGuid]
           ,[IdUser]
           ,[IP]
           ,[DateOfCreation]
           ,[MachineDescription])
     VALUES
           (@Session
           ,@IdUser
           ,@IP
           ,@DateOfCreation
           ,@MachineDescription)

IF EXISTS (SELECT 1 FROM UsersAditionalInfo WITH(NOLOCK) WHERE IdUser = @IdUser)
		UPDATE UsersAditionalInfo SET AttemptsToLogin = 0 WHERE IdUser = @IdUser
	ELSE
		INSERT INTO UsersAditionalInfo (IdUser, DateOfChangeLastPassword, AttemptsToLogin) VALUES (@IdUser, GETDATE(), 0)
END TRY

BEGIN CATCH
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('UsersSession', GETDATE(), ERROR_MESSAGE())
END CATCH

RETURN;