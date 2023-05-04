
-- =============================================
-- Author:		Oscar Cardenas
-- Create date: 2023-04-01
-- Description:	Sending an email notifying errors in the Billers update
-- EXEC [dbo].[st_SendUpdateBillersError]
--<ChangeLog>
--<log Date="10/04/2023" Author="jacardenas">Se realiza el ajuste para que identifique el provider que contiene errores BM-866</log>
--</ChangeLog>
-- =============================================


CREATE   PROCEDURE [dbo].[st_SendUpdateBillersError]
AS
BEGIN TRY

DECLARE @Providers TABLE(
	Id INT IDENTITY(1,1),
	IdProvider INT,
	ProviderName VARCHAR(20)
);

INSERT INTO @Providers 
SELECT IdProvider,ProviderName 
FROM Providers WITH (NOLOCK)
WHERE IdProvider IN (5,8,9);

DECLARE @IdProvider INT;
DECLARE @ProviderName VARCHAR(20);
DECLARE @EmailProfile NVARCHAR(MAX);
DECLARE @recipients VARCHAR(MAX);	
DECLARE @Date VARCHAR(max) = CONVERT(VARCHAR, GETDATE() , 112);
SELECT @EmailProfile = [Value] FROM [dbo].[GlobalAttributes] WITH (NOLOCK) WHERE [Name] = 'EmailProfileDefault';
SELECT @recipients = [Value] FROM [dbo].[GlobalAttributes] EmailRecipientsBillers WITH (NOLOCK) WHERE [Name] = 'EmailRecipientsBillers';

DECLARE @IdProviders INT 
SET @IdProviders=1;

DECLARE @CountProviders INT
SET @CountProviders = (SELECT COUNT(*) FROM @Providers);

WHILE (@IdProviders <= @CountProviders)
BEGIN
	
	SELECT	@IdProvider = IdProvider, 
			@ProviderName = ProviderName 
	FROM @Providers WHERE Id = @IdProviders;

	DECLARE @body VARCHAR(MAX);
	DECLARE @subject VARCHAR(MAX)='Provider : ' + @ProviderName + ', Por favor revise la actualización de Billers con error.';
	
	DECLARE @Cmd nvarchar(4000);			
	DECLARE @html nvarchar(MAX);
	DECLARE @Query NVARCHAR(MAX);	
	
	IF @IdProvider != 5
	BEGIN

		IF @IdProvider = 8
		BEGIN
			SET @IdProvider = 1;
		END
		IF @IdProvider = 9
		BEGIN
			SET @IdProvider = 5;
		END

		IF NOT EXISTS(SELECT *  FROM MAXILOGDEV.dbo.ChargeBillersLog WITH (NOLOCK) WHERE IdProvider = @IdProvider AND CONVERT(VARCHAR, LogDate, 112) = CONVERT(VARCHAR, GETDATE(), 112))
		BEGIN
				SELECT @Query = N'SELECT ErrorDate as FechaError, ErrorMessage as Error FROM dbo.ErrorLogForStoreProcedure WITH (NOLOCK) WHERE StoreProcedure = ''BillPayment.UpdateBillers|' + CONVERT(VARCHAR,@IdProvider) + ''' AND CONVERT(VARCHAR, ErrorDate, 112) = ' + @Date +'';
				EXEC spQueryToHtmlTable @html = @html OUTPUT,  @query = @Query, @orderBy = ' Order by 1 desc';
				
				IF @html IS NULL 
				BEGIN					
					SET @html = 'Provider : ' + @ProviderName + ', por favor validar el servicio que realiza el proceso de actualización, puede estar inactivo o presenta algún error.';
				END

				SELECT @body= CONCAT('<p><strong>El sistema ha registrado errores en la carga de Billers, Provider '+ @ProviderName +':</strong></p><p>&nbsp;</p>', @html, '<p>&nbsp;</p><p><strong>Favor de informar al área de soporte técnico.</strong></p>');
		
				EXEC [msdb].[dbo].sp_send_dbmail
				@profile_name = @EmailProfile,
				@recipients = @recipients,
				@body = @body,
				@body_format = 'HTML',
				@subject = @subject 
		END    
	END
	ELSE
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM MAXILOGDEV.[Regalii].[UpdateLog] WITH (NOLOCK) WHERE CONVERT(VARCHAR, CreationDate, 112) = CONVERT(VARCHAR, GETDATE(), 112))
		BEGIN
				SELECT @Query = N'SELECT ErrorDate as FechaError, ErrorMessage as Error FROM dbo.ErrorLogForStoreProcedure WITH (NOLOCK) WHERE StoreProcedure like ''%Regalli.st_UpdateBillers%'' AND CONVERT(VARCHAR, ErrorDate, 112) = ' + @Date+'';
				EXEC spQueryToHtmlTable @html = @html OUTPUT,  @query = @Query, @orderBy = ' Order by 1 desc';
				
				IF @html IS NULL 
				BEGIN
					SET @html = 'Provider : ' + @ProviderName + ', por favor validar el servicio que realiza el proceso de actualización, puede estar inactivo o presenta algún error.';
				END

				SELECT @body= CONCAT('<p><strong>El sistema ha registrado errores en la carga de Billers, Provider '+ @ProviderName +':</strong></p><p>&nbsp;</p>', @html, '<p>&nbsp;</p><p><strong>Favor de informar al área de soporte técnico.</strong></p>');
		
				EXEC [msdb].[dbo].sp_send_dbmail
				@profile_name = @EmailProfile,
				@recipients = @recipients,
				@body = @body,
				@body_format = 'HTML',
				@subject = @subject  
		END  
	END
	
	SET @IdProviders  = @IdProviders  + 1
END
END TRY
BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(MAX)
		SELECT @ErrorMessage = ERROR_MESSAGE() + CONVERT(varchar(max), ERROR_LINE())
		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_SendUpdateBillersError', GETDATE(), @ErrorMessage)
END CATCH