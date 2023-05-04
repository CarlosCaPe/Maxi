-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-01-05
-- Description:	This stored is used in wells fargo windows service, update check bundles
-- =============================================
CREATE PROCEDURE [dbo].[st_UpdateCheckBundles]
@BundlesXml XML,
@FileName VARCHAR(255),
@Error VARCHAR(MAX) OUTPUT
AS
BEGIN TRY

	DECLARE @currentDate DATETIME = GETDATE();
	DECLARE @IdUserSystem INT = [dbo].[GetGlobalAttributeByName]('SystemUserID') 
	DECLARE @IdStatusPaid INT = 30
	DECLARE @DocHandle INT 

	DECLARE @Bundles TABLE(
		[IdCheckBundle] INT,
		[Amount] MONEY,
		[ItemsWithinBundleCount] INT,
		[ImagesWithinBundleCount] INT)

	EXEC sp_xml_preparedocument @DocHandle OUTPUT,@BundlesXml
	INSERT INTO @Bundles ([IdCheckBundle], [Amount], [ItemsWithinBundleCount], [ImagesWithinBundleCount])
		SELECT [IdCheckBundle], [Amount], [ItemsWithinBundleCount], [ImagesWithinBundleCount]
		FROM OPENXML (@DocHandle, '/Bundles/Bundle',2)
		WITH (
				[IdCheckBundle] INT,
				[Amount] MONEY,
				[ItemsWithinBundleCount] INT,
				[ImagesWithinBundleCount] INT
		)

	DECLARE @TempBundleCount INT = ISNULL((
				SELECT COUNT(1)
				FROM @Bundles B
				),0)

	DECLARE @BundleCount INT = ISNULL((
				SELECT COUNT(1)
				FROM [dbo].[CheckBundle] B
				INNER JOIN @Bundles BT ON BT.[IdCheckBundle]=B.[IdCheckBundle] AND  BT.[Amount]=B.[Amount]
						AND BT.[ImagesWithinBundleCount]=B.[ImagesWithinBundleCount] AND BT.[ItemsWithinBundleCount]=B.[ItemsWithinBundleCount]
				),0)

	--select * from @Bundles
	--select * from CheckBundle where IdCheckBundle in (select IdCheckBundle from @Bundles)

	IF @TempBundleCount = 0
	BEGIN
		SET @Error ='Bundle Information empty'
		RETURN
	END

	IF @TempBundleCount!= @BundleCount
	BEGIN
		SET @Error ='Bundle Information doesn''t  match'
		RETURN
	END

	UPDATE [dbo].[CheckBundle] SET [ApplyDate]=@currentDate , [FileName]=@FileName
	WHERE [IdCheckBundle] IN (SELECT [IdCheckBundle] FROM @Bundles)

	UPDATE [dbo].[Checks] SET [IdStatus]=@IdStatusPaid, [DateStatusChange] = @currentDate
		WHERE [IdCheckBundle] IN (SELECT [IdCheckBundle] FROM @Bundles)

	INSERT INTO [dbo].[CheckDetails]
			   ([IdCheck]
			   ,[IdStatus]
			   ,[DateOfMovement]
			   ,[Note]
			   ,[EnterByIdUser])
	SELECT [IdCheck]
		,@IdStatusPaid
		,@currentDate
		,''
		,@IdUserSystem
	FROM [Checks] 
		WHERE [IdCheckBundle] IN (SELECT [IdCheckBundle] FROM @Bundles)

	UPDATE [dbo].[CheckCredit] SET [IdStatus]=@IdStatusPaid
		WHERE [IdCheckBundle] IN (SELECT [IdCheckBundle] FROM @Bundles)

 END TRY                                       
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_UpdateCheckBundles', GETDATE(), @ErrorMessage)
END CATCH



