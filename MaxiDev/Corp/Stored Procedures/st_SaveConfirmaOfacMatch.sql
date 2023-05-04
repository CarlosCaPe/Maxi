CREATE PROCEDURE [Corp].[st_SaveConfirmaOfacMatch]
(
	@IdOfacAuditDetail int,
	@IdOfacAuditStatus int,
	@ChangeStatusIdUser int,
	@ChangeStatusNote varchar(max),
	@LastChangeNote nvarchar(max),
	@LastChangeIP nvarchar(50),
	@LastChangeIdUser int,
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
		UPDATE [dbo].[OfacAuditDetail]
		SET [IdOfacAuditStatus] = @IdOfacAuditStatus, 
			[ChangeStatusIdUser] = @ChangeStatusIdUser, 
			[ChangeStatusNote] = @ChangeStatusNote, 
			[LastChangeDate] = GETDATE(), 
			[LastChangeNote] = @LastChangeNote, 
			[LastChangeIP] = @LastChangeIP, 
			[LastChangeIdUser] = @LastChangeIdUser
		WHERE IdOfacAuditDetail = @IdOfacAuditDetail
	END TRY
	BEGIN CATCH 
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
	END CATCH
END

