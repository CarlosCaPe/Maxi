CREATE procedure [dbo].[st_GetConfigGatewayNotification]
(
	@IdUser int,
	@IdGateway int,
	@IdTransfer int,
	@IdStatus int,
	@DocumentsXml XML,
	@IsInfoRequired bit
)
as
BEGIN TRY

	declare @SubjectKey nvarchar(max)
	declare @SubjectMail nvarchar(max)
	declare @UserName nvarchar(max)
	declare @UserMail nvarchar(max)
	declare @StateName nvarchar(max)
	declare @PaymentReadyDate DateTime
	declare @CountryDestination nvarchar(max)

	declare @UrlUploadFiles nvarchar(max)
	DECLARE @UrlTransferFiles NVARCHAR(MAX)
	declare @PathBsaTemplate nvarchar(max)
	declare @PathBtsTemplate nvarchar(max)
	declare @PathTnTemplate nvarchar(max)
	
	set @SubjectKey = CASE @IdStatus
         WHEN 23 THEN 'SubjectPaymentReady'
         WHEN 29 THEN 'SubjectGatewayInfo'
         WHEN 30 THEN 'SubjectPaid'
         ELSE 'NoExist'
      END

	select @SubjectMail = Value from GlobalAttributes where Name like @SubjectKey



	select @UrlUploadFiles = value from GlobalAttributes where Name like 'CustomerPath'
	SELECT @UrlTransferFiles = [Value] + '\\Transfer' FROM [dbo].[GlobalAttributes] (NOLOCK) WHERE [Name] = 'UploadPath'
	select @PathBsaTemplate = value from GlobalAttributes where Name like 'NotificationGatewayFormat'
	select @PathBtsTemplate = value from GlobalAttributes where Name like 'BtsFormatPath'
	select @PathTnTemplate = value from GlobalAttributes where Name like 'TnFormatPath'
	select top 1 @PaymentReadyDate = DateOfMovement from TransferDetail where IdTransfer = @IdTransfer and IdStatus = 23 order by IdTransferDetail
	select @CountryDestination = c.CountryName from Transfer t 
	join CountryCurrency cc on t.IdCountryCurrency = cc.IdCountryCurrency
	join Country c on cc.IdCountry = c.IdCountry
	where t.IdTransfer = @IdTransfer

	SELECT TOP 1
		@StateName = ISNULL(S.[StateName] + '-' + C.[CountryName], ISNULL(C.[CountryName],ISNULL(S.[StateName],'')))
	FROM [dbo].[Transfer] T (NOLOCK)
	LEFT JOIN [dbo].[UploadFiles] UF (NOLOCK) ON T.[IdCustomer] = UF.[IdReference] AND T.[CustomerIdCustomerIdentificationType] = UF.[IdDocumentType]
	LEFT JOIN [dbo].[UploadFilesDetail] UFD (NOLOCK) ON UF.[IdUploadFile] = UFD.[IdUploadFile]
	LEFT JOIN [dbo].[Country] C (NOLOCK) ON UFD.[IdCountry] = C.[IdCountry]
	LEFT JOIN [dbo].[State] S (NOLOCK) ON UFD.[IdState] = S.IdState
	WHERE T.[IdTransfer] = @IdTransfer AND UF.[ExpirationDate] >= GETDATE()
	ORDER BY UF.[CreationDate] DESC

	IF LTRIM(ISNULL(@StateName,'')) = ''
	BEGIN
		SELECT @StateName = s.[StateName] FROM [dbo].[Transfer] t (NOLOCK)
		JOIN [dbo].[State] s (NOLOCK) ON t.CustomerIdentificationIdState = s.IdState
		WHERE t.IdTransfer = @IdTransfer

		IF LTRIM(ISNULL(@StateName,'')) = ''
		 BEGIN 
			SELECT @StateName = c.CountryName FROM [dbo].[Transfer] t (NOLOCK)
			JOIN [dbo].[Country] c (NOLOCK) ON t.CustomerIdentificationIdCountry = c.IdCountry
			WHERE t.IdTransfer = @IdTransfer
		 END
	END
	
	select @UserName = u.UserName, @UserMail = c.Email from users u
	join Corporate c on u.IdUser = c.IdUserCorporate
	where u.IdUser = @IdUser
	
	DECLARE @Count INT
	DECLARE @Records INT
	DECLARE @TempId INT
	DECLARE @IsCustomerDoc BIT

	CREATE TABLE #DocumentsId(
		IdTemporal INT IDENTITY(1,1),
		IdDocument INT,
		IsCustomerDoc BIT,
		DocumentPath NVARCHAR(MAX)
	)

	DECLARE @DocHandle INT    
	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @DocumentsXml
	INSERT INTO #DocumentsId (IdDocument, IsCustomerDoc)
		SELECT IdItem, IsCustomerDoc FROM OPENXML (@DocHandle, '/Ids/Id', 2)
		WITH (IdItem INT, IsCustomerDoc BIT)
	EXEC sp_xml_removedocument @DocHandle

	SET @Count = 1
	SELECT @Records = COUNT(1) FROM #DocumentsId
	WHILE @Count <= @Records
	BEGIN
		SELECT @TempId=IdDocument, @IsCustomerDoc=IsCustomerDoc FROM #DocumentsId WHERE [IdTemporal] = @Count
		UPDATE #DocumentsId SET [DocumentPath] =
			(SELECT
				CASE @IsCustomerDoc WHEN 1 THEN @UrlUploadFiles ELSE @UrlTransferFiles END
				+ '\' + CONVERT(NVARCHAR(MAX),[IdReference]) + '\' + [FileGuid] + [Extension] FROM [UploadFiles] (NOLOCK) WHERE [IdUploadFile] = @TempId)
		WHERE [IdTemporal] = @Count
		SET @Count = @Count + 1
	END
	
	DECLARE @BCC VARCHAR(200) = ''--'maxi-mscomaclaraciones@aclaracionesmaxi.freshdesk.com'
	--SET @UserMail ='aclaraciones@maxi-ms.com'
	
    --INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_GetConfigGatewayNotification',GETDATE(),'Notificacion enviada')
	
	select @SubjectMail as 'SubjectMail', @UserName as 'UserName', @UserMail as 'UserMail', @UrlUploadFiles as 'UploadFilesPath', @PathBsaTemplate as 'NotificationGatewayFormat', @StateName as 'stateName',
	 @PathBtsTemplate as 'BtsFormatPath', @PathTnTemplate as 'TnFormatPath', @PaymentReadyDate as 'PaymentReadyDate', @CountryDestination as 'CountryDestination', @BCC AS 'BCCMail'

	SELECT [DocumentPath] FROM #DocumentsId

	select Mail from GatewayConfigMail where IdGateway = @IdGateway and IdGenericStatus = 1 and IsInfoRequired = @IsInfoRequired

END TRY
BEGIN CATCH
	 DECLARE @Message NVARCHAR(MAX) = ERROR_MESSAGE()
	 DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
	 INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_GetConfigGatewayNotification',GETDATE(),@ErrorMessage)
END CATCH



