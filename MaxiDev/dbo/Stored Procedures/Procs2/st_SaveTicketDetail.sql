CREATE PROCEDURE [dbo].[st_SaveTicketDetail]
(
	@IdTicket int,
	@Note nvarchar(max),
	@IdUser int,
	@LastChange_LastUserChange nvarchar(max),
	@LastChange_LastIpChange nvarchar(max),
	@LastChange_LastNoteChange nvarchar(max),
    @HasError int out,
    @Message nvarchar(max) out
)
AS
SET NOCOUNT ON;
BEGIN 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET @HasError = 0
	SET @Message = ''
	BEGIN TRY
		INSERT INTO [dbo].[TicketDetails] ([IdTicket], [NoteDate], [Note], [IdUser], [LastChange_LastUserChange], [LastChange_LastDateChange], [LastChange_LastIpChange], [LastChange_LastNoteChange])
		VALUES (@IdTicket, GETDATE(), @Note, @IdUser, @LastChange_LastUserChange, GETDATE(), @LastChange_LastIpChange, @LastChange_LastNoteChange)
	END TRY
	BEGIN CATCH 
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
	END CATCH
END


