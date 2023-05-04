CREATE PROCEDURE [Services].[st_SaveServiceLog]
-- Add the parameters for the stored procedure here
@EventId INT
, @Priority INT
, @Severity NVARCHAR(MAX)
, @Title NVARCHAR(MAX)
, @LogDate DATETIME
, @MachineName NVARCHAR(MAX)
, @AppDomainName NVARCHAR(MAX)
, @ProcessId NVARCHAR(MAX)
, @ProcessName NVARCHAR(MAX)
, @ManagedThreadName NVARCHAR(MAX)
, @WinThreadId NVARCHAR(MAX)
, @Message NVARCHAR(MAX)

AS
BEGIN TRY
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

-- Insert statements for procedure here
INSERT INTO Maxi.[Services].[LogServices]
([eventId], [logpriority], [severity], [title], [logdate], [machineName], [appDomainName], [processId], [processName], [managedThreadName], [win32ThreadId], [message])
VALUES (@EventId, @Priority, @Severity, @Title, @LogDate, @MachineName, @AppDomainName, @ProcessId, @ProcessName, @ManagedThreadName, @WinThreadId, @Message)


END TRY
BEGIN CATCH
DECLARE @ErrorMessage NVARCHAR(MAX)
SELECT @ErrorMessage=ERROR_MESSAGE()
INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_SaveServiceLog', GETDATE(), @ErrorMessage)
END CATCH
