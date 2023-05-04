CREATE PROCEDURE [dbo].[st_SaveTicket]
(
	@ActionType nvarchar(20),
	@IdTicket int,
    @IdUser int,
    @IdProduct int,
    @IdTransaction int,
    @Note nvarchar(max),
    @IdStatus int,
    @IdPriority int,
    @IdTicketCloseReason int = NULL,
    @LastChange_LastUserChange nvarchar(max),
    --@LastChange_LastDateChange datetime,
    @LastChange_LastIpChange nvarchar(max),
    @LastChange_LastNoteChange nvarchar(max),
    @Reference nvarchar(max),
    @OperationDate datetime = NULL,
    @IdAgent int,
    @ClosedDate datetime,
    @HasError int out,
    @Message nvarchar(max) out,
	@IdTicketOUT int out
)
AS
SET NOCOUNT ON;
BEGIN 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET @IdTicketOUT = 0
	SET @HasError = 0
	SET @Message = ''
	BEGIN TRY
		IF (@IdTicket = 0)
			BEGIN
				INSERT INTO [dbo].[Tickets] ([TicketDate], [IdUser], [IdProduct], [IdTransaction], [Note], [IdStatus], [IdPriority], [IdTicketCloseReason], [LastChange_LastUserChange], 
					[LastChange_LastDateChange], [LastChange_LastIpChange], [LastChange_LastNoteChange], [Reference], [OperationDate], [IdAgent], [ClosedDate])
				VALUES (GETDATE(), @IdUser, @IdProduct, @IdTransaction, @Note, @IdStatus, @IdPriority, @IdTicketCloseReason, @LastChange_LastUserChange, GETDATE(), 
					@LastChange_LastIpChange, @LastChange_LastNoteChange, @Reference, GETDATE(), @IdAgent, @ClosedDate)
					select @IdTicketOUT = SCOPE_IDENTITY()
			END
		ELSE IF (@ActionType = 'ChangePriority')
			BEGIN
				UPDATE [dbo].[Tickets]
					SET [IdPriority] = @IdPriority,
						[LastChange_LastUserChange] = @LastChange_LastUserChange, 
						[LastChange_LastDateChange] = GETDATE(),
						[LastChange_LastIpChange] = @LastChange_LastIpChange, 
						[LastChange_LastNoteChange] = @LastChange_LastNoteChange
					WHERE IdTicket = @IdTicket
					SET @IdTicketOUT = @IdTicket
			END
		ELSE IF (@ActionType = 'CloseTicket')
			BEGIN
				UPDATE [dbo].[Tickets]
					SET [IdStatus] = @IdStatus,
						[IdTicketCloseReason] = @IdTicketCloseReason, 
						[LastChange_LastUserChange] = @LastChange_LastUserChange, 
						[LastChange_LastDateChange] = GETDATE(),
						[LastChange_LastIpChange] = @LastChange_LastIpChange, 
						[LastChange_LastNoteChange] = @LastChange_LastNoteChange,
						[ClosedDate] = GETDATE()
					WHERE IdTicket = @IdTicket
					SET @IdTicketOUT = @IdTicket
			END
		ELSE IF (@ActionType = 'AddComment')
			BEGIN
				UPDATE [dbo].[Tickets]
					SET [IdTicketCloseReason] = @IdTicketCloseReason, 
						[LastChange_LastUserChange] = @LastChange_LastUserChange, 
						[LastChange_LastDateChange] = GETDATE(),
						[LastChange_LastIpChange] = @LastChange_LastIpChange, 
						[LastChange_LastNoteChange] = @LastChange_LastNoteChange
					WHERE IdTicket = @IdTicket
					SET @IdTicketOUT = @IdTicket
			END
	END TRY
	BEGIN CATCH 
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
	END CATCH
END
