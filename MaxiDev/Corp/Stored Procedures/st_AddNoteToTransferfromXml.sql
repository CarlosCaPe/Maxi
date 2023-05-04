CREATE PROCEDURE [Corp].[st_AddNoteToTransferfromXml]
	 @IdUser	INT,
	 @IdTransfersXml	XML
AS
BEGIN
	BEGIN TRY
		
		DECLARE @DocHandle 		INT,
			@IdTransfer			INT,
			@IdTransferDetail	INT
		
		CREATE TABLE #XmlIdTransfer (
		id_transfer	INT
		)
		
		
		
		EXEC sp_xml_preparedocument @DocHandle output, @IdTransfersXml
		
		INSERT INTO #XmlIdTransfer
		SELECT IdTransfer
		FROM OPENXML (@DocHandle, '/Main/Transfers', 2)
		WITH (
			IdTransfer INT
		)		
		
		DECLARE @count int = (SELECT COUNT(*) FROM #XmlIdTransfer)
		
		WHILE (@count > 0)
		BEGIN
			
			
			SELECT TOP 1 @IdTransfer = id_transfer
			FROM #XmlIdTransfer					
			
			SELECT @IdTransferDetail = dbo.fun_GetIdTransferDetail(@IdTransfer)			
			
			IF @IdTransferDetail IS NOT NULL 
			BEGIN
 
			 	INSERT INTO TransferNote (IdTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate) VALUES (@IdTransferDetail,3,@IdUser,'ClaimCode retrieved from Dashboard Payers Info',GETDATE());   
			 	          
			END 
			
			DELETE #XmlIdTransfer WHERE @IdTransfer = id_transfer
			SET @count = (SELECT COUNT(1) FROM #XmlIdTransfer)		
		
		END
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('[Corp].[st_BulkRejetedChekfromXml_Checks]', GETDATE(), @ErrorMessage)
	END CATCH
END