-- =============================================
-- Author:	Juan Hernandez	<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UploadPdfInfoTransaction]
	(
	@IdTransfer int,
	@Folder varchar(100),
	@FileName varchar(100),
	@FileType varchar (10),

	@HasError bit out, 
	@Message nvarchar(100) out
	)
AS
BEGIN TRY
	
	set @HasError = 0
	set @Message = 'Información creada correctamente'

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	insert into TransactionUploadFile (IdTransfer, FolderName, [FileName], FileType)
	values (@IdTransfer, @Folder, @FileName, @FileType)
END TRY
BEGIN CATCH
	set @HasError = 1
	set @Message = 'Error al insertar informacion del recibo PDF'
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[dbo].[UploadPdfInfoTransaction]',GETDATE(),@ErrorMessage)

END CATCH

--ROLLBACK 
--DROP PROCEDURE [MaxiMobile].[st_UploadPdfInfoTransaction]
