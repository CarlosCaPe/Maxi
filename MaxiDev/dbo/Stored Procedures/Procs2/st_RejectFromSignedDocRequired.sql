-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-06-06
-- Description:	This stored allow reject an agent application in status SignedDocumentsRequired
-- =============================================
CREATE PROCEDURE [dbo].[st_RejectFromSignedDocRequired] 
	-- Add the parameters for the stored procedure here
	@IdAgentApplication int,
	@Note nvarchar(max)
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @FromIdStatus INT
			, @IdUserSeller INT
			, @AgentCode NVARCHAR(100)
			, @StausName NVARCHAR(MAX)
			, @IsStatusHold BIT
			, @NotificationType INT = 3
			, @ToIdStatus INT = 17 -- Rejected
			, @EnterByIdUser INT = 37 -- System
			, @Time DATETIME = GETDATE()

	SELECT @FromIdStatus=[IdAgentApplicationStatus], @AgentCode=[AgentCode], @IdUserSeller=[IdUserSeller] FROM [dbo].[AgentApplications] WITH (NOLOCK) WHERE [IdAgentApplication] = @IdAgentApplication
	
	IF @FromIdStatus NOT IN (4,7,8,9,10,11,12,13,14,15,19,20) -- Documents Status
		RETURN

	UPDATE [dbo].[AgentApplications] SET
		[IdAgentApplicationStatus]=@ToIdStatus
		, [EnterByIdUser]=@EnterByIdUser
		, [DateOfLastChange]= @Time
	WHERE [IdAgentApplication]=@IdAgentApplication
		
	--Add status history 
	INSERT [dbo].[AgentApplicationStatusHistory] ([IdAgentApplication], [IdAgentApplicationStatus], [DateOfMovement], [Note], [DateOfLastChange], [IdUserLastChange])
	VALUES (@IdAgentApplication, @ToIdStatus, @Time, @Note, @Time, @EnterByIdUser)
		
	UPDATE [dbo].[PendingFilesAgentApp] SET [SendNotification] = 0 WHERE [IdAgentApplication] = @IdAgentApplication -- New RMM
		
	--Insert notification 
	INSERT [dbo].[Notifications] ([IdAgentApplication], [IdSeller], [IdNotificationType], [Title], [ReadedByUser], [DateOfLastChange], [IdUserLastChange])
	VALUES (@IdAgentApplication, @IdUserSeller, @NotificationType,'Agent Application ' + @AgentCode + ' status has changed.', 0, @Time, 1)
	
END TRY
BEGIN CATCH

	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_RejectFromSignedDocRequired',GETDATE(),ERROR_MESSAGE())

END CATCH
