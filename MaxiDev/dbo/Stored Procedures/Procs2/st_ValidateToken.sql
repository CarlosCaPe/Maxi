CREATE PROCEDURE [dbo].[st_ValidateToken]
	@Token AS UNIQUEIDENTIFIER,
	@IsValid AS BIT = 0 OUTPUT,
	@IsPrinting AS BIT = 0
AS
-- =============================================
-- Author:		Miguel Hinojo
-- Create date: 2016-11-03
-- Description:	Validate token and set disabled
--
-- 2017/01/29  mhinojo  Added Validation for printing
-- =============================================
BEGIN TRY
	--SET NOCOUNT ON;
	--Token eterno en Producción
	IF @Token = 'F7DFB0EF-FC89-4106-958C-3B5D0BDC783A' BEGIN 
	  	SET @IsValid = 1;
	END 
	ELSE 
	BEGIN
		IF @IsPrinting = 0
		BEGIN
			IF EXISTS (SELECT 1 FROM TokenSecurity WHERE Token = @Token AND IsEnabled = 1 AND CreationDate >= DATEADD(s,-10,getdate())) 
			BEGIN
				UPDATE TokenSecurity
				SET IsEnabled = 0
				WHERE Token = @Token AND IsEnabled = 1
				IF (@@ROWCOUNT > 0)
					SET @IsValid = 1;
			END
			ELSE 
			BEGIN
				UPDATE TokenSecurity
				SET IsEnabled = 0
				WHERE Token = @Token AND IsEnabled = 1
				SET @IsValid = 0;
			END
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 FROM TokenSecurity WHERE Token = @Token AND CONVERT(VARCHAR(10), CreationDate, 120) = CONVERT(VARCHAR(10), GETDATE(), 120))
				SET @IsValid = 1;
			ELSE
				SET @IsValid = 0;
		END
	END 
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_ValidateToken', GETDATE(), @ErrorMessage)
END CATCH


