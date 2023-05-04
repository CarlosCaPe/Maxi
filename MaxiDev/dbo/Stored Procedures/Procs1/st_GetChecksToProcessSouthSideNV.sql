
CREATE PROCEDURE [dbo].[st_GetChecksToProcessSouthSideNV]
AS
/********************************************************************
<Author>Miguel Hinojo</Author>
<app>Maxi Host Manager Service</app>
<Description>Get checks that are on standy by to process Southside Bank</Description>

<ChangeLog>
<log Date="08/09/2016" Author="Mhinojo"> Creación </log>
<log Date="24/12/2018" Author="jmolina"> Add With(nolock) and ; by Insert/update </log>
<log Date="15/05/2020" Author="jgomez"> M00153 </log>
<log Date="02/06/2022" Author="jdarellano" Name="#1">Se cambian variables tipo tabla por tablas temporales, y se agrega esquema a tablas físicas.</log>
<log Date="02/06/2022" Author="jdarellano" Name="#2">Se cambia la forma de obtener las imágenes para cada cheque.</log>
<log Date="02/06/2022" Author="jdarellano" Name="#3">Se agrega validación para no considerar agencias de 1st Midwest (dbo.AgentsFirstMidwest).</log>
<log Date="15/11/2022" Author="adominguez" Name="#7">Se excluyen IRd's.</log>
</ChangeLog>

*********************************************************************/
BEGIN
	BEGIN TRY
		DECLARE @currentDate datetime = GETDATE();
		DECLARE @IssuerCheckPath varchar(100) = (SELECT [Value] FROM dbo.GlobalAttributes WITH (NOLOCK) WHERE [Name] = 'IssuerCheckPath');
		DECLARE @IdUserSystem int = dbo.GetGlobalAttributeByName('SystemUserID');
		DECLARE @BundleMaxSize int = 999;
		DECLARE @IdStatusStandBy int = 20;
		DECLARE @IdStatusPendingGatewayResponse int = 21;

		--declare @Checks TABLE
		CREATE TABLE #Checks--#1
		(
			IdCheck int,
			[MicrAuxOnUs] varchar(max), 
			MicrExternalProcessingCode varchar(1), 
			[MicrRoutingTransitNumber] varchar(max),
			[MicrRoutingTransitNumberCheckDigit] varchar(max),
			Amount money,
			MicrOnUs varchar(max),
			ItemSequenceNumber int ,
			FrontImagePath varchar(max),
			RearImagePath varchar(max),
			IdAgent int,
			IdCheckCredit int,
			BundleSequence int,
			AgentCode varchar(100),
			IsReclear bit
		);

		--declare @Credits TABLE
		CREATE TABLE #Credits--#1
		(
			[IdCheckCredit] int,
			IdAgent int,
			[SubAccount] varchar(50),
			[Amount] money,
			BundleSequence int
		);

		--declare @Bundles TABLE 
		CREATE TABLE #Bundles--#1
		(
			IdCheckBundle int,
			BundleSequence int,
			Amount money, 
			ItemsWithinBundleCount int, 
			ImagesWithinBundleCount int
		);

		--{#2
		SELECT u.*
		INTO #UF
		FROM dbo.UploadFiles AS u WITH (NOLOCK)
		INNER JOIN dbo.Checks AS c WITH (NOLOCK) ON u.IdReference = c.IdCheck AND c.IdStatus = 20 and C.IsIRD = 0 --#7
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON c.IdAgent = A.IdAgent AND A.AgentState = 'NV'
		WHERE u.IdDocumentType = 69 AND u.[FileName] LIKE REPLACE('00000000-0000-0000-0000-000000000000', '0', '[0-9a-fA-F]');

		SELECT u.IdReference,MIN(u.IdUploadFile) AS FrontIdUploadFile
		INTO #UFUFD_F
		FROM #UF AS u WITH (NOLOCK)
		INNER JOIN dbo.UploadFilesDetail AS d WITH (NOLOCK) ON u.IdUploadFile = d.IdUploadFile AND d.IdDocumentImageType = 1
		GROUP BY IdReference;

		SELECT u.IdReference,  MIN(u.IdUploadFile) AS RearIdUploadFile
		INTO #UFUFD_R
		FROM #UF AS u WITH (NOLOCK)
		INNER JOIN dbo.UploadFilesDetail AS d WITH (NOLOCK) ON u.IdUploadFile = d.IdUploadFile AND d.IdDocumentImageType = 2
		GROUP BY IdReference;
		--}#2

		--Insert Into @Checks
		INSERT INTO #Checks--#1
		(
			IdCheck,
			[MicrAuxOnUs] , 
			MicrExternalProcessingCode , 
			[MicrRoutingTransitNumber] ,
			[MicrRoutingTransitNumberCheckDigit] ,
			Amount ,
			MicrOnUs ,
			ItemSequenceNumber  ,
			FrontImagePath ,
			RearImagePath ,
			IdAgent ,
			AgentCode,
			IsReclear
		)
		SELECT 
		C.IdCheck,
		REPLACE(REPLACE(C.[MicrAuxOnUs],'d','-'),'c','/') MicrAuxOnUs, 
		'' MicrExternalProcessingCode, 
		SUBSTRING (C.[MicrRoutingTransitNumber],1,8) [MicrRoutingTransitNumber],
		SUBSTRING (C.[MicrRoutingTransitNumber],9,1) [MicrRoutingTransitNumberCheckDigit],
		C.Amount,
		REPLACE(REPLACE(C.MicrOnUs,'d','-'),'c','/') MicrOnUs,
		C.IdCheck ItemSequenceNumber,
		@IssuerCheckPath + CONVERT(varchar(max),C.[IdIssuer]) + '\Checks\' + CONVERT(varchar(max),C.IdCheck) + '\' + UF.[FileName] + UF.Extension FrontImagePath,
		@IssuerCheckPath + CONVERT(varchar(max),C.[IdIssuer]) + '\Checks\' + CONVERT(varchar(max),C.IdCheck) + '\' + UR.[FileName] + UR.Extension RearImagePath,
		C.IdAgent,
		A.AgentCode,
		ISNULL((SELECT TOP 1 1 FROM dbo.Checks WITH(NOLOCK) WHERE idstatus = 31 AND IdCheckProcessorBank IS NOT NULL AND RoutingNumber = C.RoutingNumber AND Account = C.Account AND CheckNumber = C.CheckNumber),0)
		FROM [dbo].[Checks] C WITH(NOLOCK)
		/*inner join 
			(
				Select IdReference, Min(u.IdUploadFile) FrontIdUploadFile
				from UploadFiles u WITH(NOLOCK)
				join UploadFilesDetail d WITH(NOLOCK) on u.IdUploadFile=d.IdUploadFile and d.IdDocumentImageType=1 
				Where IdDocumentType=69 and [FileName] like REPLACE('00000000-0000-0000-0000-000000000000', '0', '[0-9a-fA-F]')
				group by  IdReference
			)F on F.IdReference=C.IdCheck
		inner join 
			(
				Select IdReference,  Min(u.IdUploadFile) RearIdUploadFile
				from UploadFiles u WITH(NOLOCK)
				join UploadFilesDetail d WITH(NOLOCK) on u.IdUploadFile=d.IdUploadFile and d.IdDocumentImageType=2
				Where IdDocumentType=69 and [FileName] like REPLACE('00000000-0000-0000-0000-000000000000', '0', '[0-9a-fA-F]')
				group by  IdReference
			)F2 on F2.IdReference=C.IdCheck*/
		INNER JOIN #UFUFD_F AS F ON F.IdReference = C.IdCheck--#2
		INNER JOIN #UFUFD_R AS F2 ON F2.IdReference = C.IdCheck--#2
		INNER JOIN dbo.UploadFiles UF WITH (NOLOCK) ON UF.IdUploadFile = F.FrontIdUploadFile
		INNER JOIN dbo.UploadFiles UR WITH (NOLOCK) ON UR.IdUploadFile = F2.RearIdUploadFile
		--INNER JOIN dbo.Agent A WITH (NOLOCK) ON A.IdAgent = C.IdAgent AND A.AgentState = 'NV' AND A.AgentCode NOT IN ('5525-KS','6172-KS','4947-KS','5301-KS','7030-KY','11210-IL')	
		INNER JOIN dbo.Agent A WITH (NOLOCK) ON A.IdAgent = C.IdAgent AND A.AgentState = 'NV' AND NOT EXISTS (SELECT 1 FROM dbo.AgentsFirstMidwest AS F WITH (NOLOCK) WHERE A.IdAgent = F.IdAgent)--#3
		WHERE LTRIM(RTRIM(ISNULL(C.MicrManual,''))) != '' AND C.IdStatus = @IdStatusStandBy AND C.CheckFile IS NULL
		and C.IsIRD = 0--#7;;

		UPDATE [dbo].[Checks] SET IdStatus = @IdStatusPendingGatewayResponse, IdCheckProcessorBank = 2
		WHERE IdCheck IN (SELECT IdCheck FROM #Checks);--#1

		INSERT INTO [dbo].[CheckDetails]
				   ([IdCheck]
				   ,[IdStatus]
				   ,[DateOfMovement]
				   ,[Note]
				   ,[EnterByIdUser])
		SELECT IdCheck
			,@IdStatusPendingGatewayResponse
			,@currentDate
			,''
			,@IdUserSystem
		FROM #Checks;--#1

		INSERT INTO [dbo].[CheckCredit]
				   ([IdAgent]
				   ,[SubAccount]
				   ,[Amount]
				   ,[IdStatus]
				   ,[CreateDate])
		OUTPUT Inserted.[IdCheckCredit], Inserted.IdAgent, Inserted.SubAccount, Inserted.Amount, NULL INTO #Credits--#1
		SELECT A.IdAgent
			, SUBSTRING(A.agentcode,0,CHARINDEX('-', A.agentcode))
			, C.Amount, @IdStatusPendingGatewayResponse, @currentDate
		FROM dbo.Agent A WITH (NOLOCK)
		INNER JOIN 
		(
			SELECT C.IdAgent, SUM(C.Amount) Amount
			FROM #Checks C--#1
			GROUP BY C.IdAgent
		)C ON C.IdAgent = A.IdAgent AND A.AgentState = 'NV';

		UPDATE C 
		SET C.IdCheckCredit = Cr.IdCheckCredit
		FROM #Checks C--#1
		INNER JOIN #Credits Cr ON Cr.IdAgent = C.IdAgent;--#1

		UPDATE C 
		SET C.IdCheckCredit = Cr.IdCheckCredit
		FROM dbo.Checks C
		INNER JOIN #Checks Cv ON Cv.IdCheck = C.IdCheck--#1
		INNER JOIN #Credits Cr ON Cr.IdAgent = C.IdAgent;--#1


		DECLARE @TempIdAgent int;
		DECLARE @BundleSequence int = 0;
		DECLARE @IdCheckBundle int = 0;
		DECLARE @FileIdentifier varchar(50) = NEWID();
		DECLARE @CreditsOnBundle int = 0;

		SELECT TOP 1 @TempIdAgent = IdAgent
		FROM #Credits--#1
		WHERE BundleSequence IS NULL
		ORDER BY IdAgent;

		WHILE (@TempIdAgent IS NOT NULL)
		BEGIN
			UPDATE #Credits SET BundleSequence = @BundleSequence--#1
			WHERE IdAgent = @TempIdAgent;

			SET @CreditsOnBundle = 1;

			--while ((Select count(1) from @Checks where IdAgent=@TempIdAgent and BundleSequence is null)>0)
			WHILE EXISTS (SELECT 1 FROM #Checks WHERE IdAgent = @TempIdAgent AND BundleSequence IS NULL)--#1
			BEGIN		
				UPDATE #Checks SET BundleSequence = @BundleSequence--#1
				WHERE IdCheck IN (SELECT TOP (@BundleMaxSize - @CreditsOnBundle) IdCheck FROM #Checks WHERE IdAgent = @TempIdAgent AND BundleSequence IS NULL ORDER BY IdCheck);--#1
		
				SET @CreditsOnBundle = 0;
				SET @BundleSequence = @BundleSequence + 1;
			END

			SET @TempIdAgent = NULL;

			SELECT TOP 1 @TempIdAgent = IdAgent
			FROM #Credits--#1
			WHERE BundleSequence IS NULL
			ORDER BY IdAgent;
		END;
	
		INSERT INTO [dbo].[CheckBundle]([FileIdentifier],[BundleSequence],[Amount],[ItemsWithinBundleCount],[ImagesWithinBundleCount],[CreateDate])
		OUTPUT Inserted.[IdCheckBundle], Inserted.BundleSequence, Inserted.Amount, Inserted.ItemsWithinBundleCount, Inserted.ImagesWithinBundleCount INTO #Bundles--#1
		SELECT @FileIdentifier,BundleSequence, SUM(Amount) Amount, COUNT(1) ItemsWithinBundleCount, SUM([Type]) * 2 ImagesWithinBundleCount, @currentDate
		FROM 
		(
			SELECT [IdCheckCredit] Id, 0 [Type], BundleSequence, 0 Amount
			FROM #Credits--#1
			UNION ALL
			Select [IdCheck] Id, 1 [Type], BundleSequence, Amount
			FROM #Checks--#1
		) L
		GROUP BY BundleSequence;

		UPDATE C 
		SET C.[IdCheckBundle] = B.IdCheckBundle
		FROM dbo.Checks C
		INNER JOIN #Checks CT ON CT.IdCheck = C.IdCheck--#1
		INNER JOIN #Bundles B ON B.BundleSequence = CT.BundleSequence;--#1

		UPDATE C 
		SET C.[IdCheckBundle] = B.IdCheckBundle
		FROM dbo.CheckCredit C
		INNER JOIN #Credits CT ON CT.IdCheckCredit = C.IdCheckCredit--#1
		INNER JOIN #Bundles B ON B.BundleSequence = CT.BundleSequence;--#1

	
		DECLARE @DestinationRoutingNumber varchar(100) = (SELECT [Value] FROM [Services].[ServiceAttributes] WITH (NOLOCK) WHERE [Code] = 'SOUTHSIDENVSEND' AND [Key] = 'Field_DestinationRoutingNumber');
		DECLARE @IdAgent int;
		DECLARE @AccountConfig int;
	 
		SELECT @IdAgent = IdAgent FROM #Checks;--#1
		SELECT @AccountConfig = Account FROM dbo.AgentBankConfigAccount WITH (NOLOCK) WHERE IdAgent = @IdAgent AND IdStatus = 1 ORDER BY 1 DESC;

		IF (@AccountConfig IS NULL)
		BEGIN
			DECLARE @OriginRoutingNumber varchar(100) = (SELECT [Value] FROM [Services].[ServiceAttributes] WITH (NOLOCK) WHERE [Code] = 'SOUTHSIDENVSEND' AND [Key] = 'Field_OriginRoutingNumber');
		END
		ELSE
		BEGIN
			SELECT @OriginRoutingNumber = @AccountConfig;
		END

		SELECT
		IdCheckBundle,
		BundleSequence,
		Amount,
		ItemsWithinBundleCount,
		ImagesWithinBundleCount
		FROM #Bundles;--#1

		SELECT
		@OriginRoutingNumber OriginRoutingNumberNV,
		C.[IdCheckCredit],
		C.IdAgent,
		C.SubAccount,
		C.Amount,
		C.BundleSequence,
		A.AgentCode+ ' '+ A.AgentName ImageDataAgentName,
		'Routing Number: '+@DestinationRoutingNumber+ CHAR(13)+CHAR(10)+'Account Number: '+@OriginRoutingNumber + CHAR(13)+CHAR(10)+'        Amount: $'+convert(varchar,C.Amount,0) ImageDataResume,
		dbo.fn_FormatCheckDetailForCredit(C.IdCheckCredit) ImageDataCheckDetail
		FROM #Credits C--#1
		INNER JOIN dbo.Agent A WITH (NOLOCK) ON A.IdAgent = C.IdAgent AND A.AgentState = 'NV';

		SELECT 
		C.IdCheck,
		C.[MicrAuxOnUs], 
		C.MicrExternalProcessingCode, 
		C.[MicrRoutingTransitNumber],
		C.[MicrRoutingTransitNumberCheckDigit],
		C.Amount,
		C.MicrOnUs,
		C.ItemSequenceNumber,
		C.FrontImagePath,
		C.RearImagePath,
		C.IdAgent,
		C.IdCheckCredit,
		C.BundleSequence,
		C.AgentCode,
		C.IsReclear
		FROM #Checks C;--#1

	END TRY                                                                                            
	BEGIN CATCH
		DECLARE @ErrorMessage nvarchar(max) = ERROR_MESSAGE();
		INSERT INTO dbo.ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('dbo.st_GetChecksToProcessSouthSideNV',GETDATE(),@ErrorMessage);
	END CATCH
END