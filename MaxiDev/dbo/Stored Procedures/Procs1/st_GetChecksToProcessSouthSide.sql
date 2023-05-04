
--exec st_GetChecksToProcessSouthSide
CREATE procedure [dbo].[st_GetChecksToProcessSouthSide]
AS
/********************************************************************

<Author> ??? </Author>
<app> Services </app>
<Description> Gets checks for Servce</Description>
<ChangeLog>
<log Date="03/12/2018" Author="amoreno">se identifica cuenta y routing por agencia</log>
<log Date="29/08/2019" Author="erojas">Cambio para agregar el ImageDataAgentName y el AgentCode al credit record de Southside - M00054</log>
<log Date="05/10/2021" Author="jdarellano" Name="#3">Se agrega agentcode 11412-TN para procesamiento de cheques por 1st Midwest</log>
<log Date="27/01/2022" Author="jdarellano" Name="#4">Se agregan agencias 10185-TN y 11757-IL para procesamiento de cheques por 1st Midwest</log>
<log Date="17/02/2022" Author="jdarellano" Name="#5">Se agrega agencia 14324-IL para procesamiento de cheques por 1st Midwest</log>
<log Date="31/05/2022" Author="jdarellano" Name="#6">Se modifica SP para optimizar procedimiento.</log>
<log Date="15/11/2022" Author="adominguez" Name="#7">Se excluyen IRd's.</log>
<log Date="28/04/2023" Author="jisotelo" Name="#8">Se agrega el campo del MICR OnUs al registro de Credit(Type61) ahora Check(Type25)</log>
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
		DECLARE @AbaRoutingDefualt nvarchar(255);
		DECLARE @AccountDefault nvarchar(255);
		DECLARE @Trancode varchar(3) = '003'; -- value provided by SouthSide

		--declare @Checks TABLE(
		CREATE TABLE #Checks--#6
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
			IsReclear bit,
			[AbaRouting] varchar(max),
			[Account] varchar(max),
			IdBankConfig int,
			AgentCode varchar(max) --M00054
		);

		--declare @Credits TABLE(
		CREATE TABLE #Credits--#6
		(
			[IdCheckCredit] int,
			IdAgent int,
			[SubAccount] varchar(50),
			[Amount] money,
			BundleSequence int
		);

		--declare @Bundles TABLE (
		CREATE TABLE #Bundles--#6
		(
			IdCheckBundle int,
			BundleSequence int,
			Amount money, 
			ItemsWithinBundleCount int, 
			ImagesWithinBundleCount int
		);

		SET @AbaRoutingDefualt = (SELECT [Value] FROM [Services].ServiceAttributes WITH (NOLOCK) WHERE [Key] = 'Field_DestinationRoutingNumber' AND Code = 'SOUTHSIDESEND');
		SET @AccountDefault = (SELECT [Value] FROM [Services].ServiceAttributes WITH (NOLOCK) WHERE [Key] = 'Field_OriginRoutingNumber' AND Code = 'SOUTHSIDESEND');
		
		SELECT U.*
		INTO #UF--#6
		FROM dbo.UploadFiles AS U WITH (NOLOCK)
		INNER JOIN dbo.Checks AS C WITH (NOLOCK) ON U.IdReference = C.IdCheck AND C.IdStatus = 20 and C.IsIRD = 0 --#7
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON c.IdAgent = A.IdAgent AND A.AgentState <> 'NV'
		WHERE u.IdDocumentType = 69 AND u.[FileName] LIKE REPLACE('00000000-0000-0000-0000-000000000000', '0', '[0-9a-fA-F]');

		SELECT U.IdReference,MIN(U.IdUploadFile) AS FrontIdUploadFile
		INTO #UFUFD_F--#6
		FROM #UF AS U
		INNER JOIN dbo.UploadFilesDetail AS D WITH (NOLOCK) ON U.IdUploadFile = D.IdUploadFile AND D.IdDocumentImageType = 1
		GROUP BY IdReference;

		SELECT U.IdReference, MIN(U.IdUploadFile) AS RearIdUploadFile
		INTO #UFUFD_R--#6
		FROM #UF AS U
		INNER JOIN dbo.UploadFilesDetail AS D WITH (NOLOCK) ON U.IdUploadFile = D.IdUploadFile AND D.IdDocumentImageType = 2
		GROUP BY IdReference;
		/*
		Insert Into @Checks
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
		IdAgent,
		IsReclear
		)
		*/

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
			 AbaRouting = ( CASE
   										 when Aco.Aba IS NOT NULL
   										 then Aco.Aba
   								ELSE	
		  						   @AbaRoutingDefualt
								END 
							   ) ,
			 Account  = ( CASE
				   							WHEN Aco.Account IS NOT NULL
				   							THEN Aco.Account
				   						 ELSE	
						  				 @AccountDefault
									   END 
									 ),
			IdBankConfig = (SELECT IdBank FROM dbo.AgentBankConfigAccount WITH (NOLOCK) WHERE IdAgent = C.IdAgent AND IdStatus = 1),						     				     
			IsReclear = ISNULL((SELECT TOP 1 1 FROM Checks Cd WITH(NOLOCK) WHERE Cd.idstatus = 31 AND Cd.IdCheckProcessorBank IS NOT NULL AND Cd.RoutingNumber = C.RoutingNumber AND Cd.Account = C.Account AND Cd.CheckNumber = C.CheckNumber),0),
			A.AgentCode --M00054
		INTO #temp2		
		FROM [dbo].[Checks] C WITH (NOLOCK)
		/*INNER JOIN
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
		INNER JOIN #UFUFD_F AS F ON F.IdReference = C.IdCheck--#6
		INNER JOIN #UFUFD_R AS F2 ON F2.IdReference = C.IdCheck--#6
		INNER JOIN dbo.UploadFiles UF WITH (NOLOCK) ON UF.IdUploadFile = F.FrontIdUploadFile
		INNER JOIN dbo.UploadFiles UR WITH (NOLOCK) ON UR.IdUploadFile = F2.RearIdUploadFile
		INNER JOIN dbo.Agent A WITH (NOLOCK) ON A.IdAgent = C.IdAgent AND A.AgentState <> 'NV' AND NOT EXISTS (SELECT 1 FROM dbo.AgentsFirstMidwest AS F WITH (NOLOCK) WHERE A.IdAgent = F.IdAgent)--#6
		--AND A.AgentCode NOT IN ('5525-KS','6172-KS','4947-KS','5301-KS','7030-KY','4913-KS','5088-KS','6460-KY','5557-KY','8338-KY','5464-KY','6548-MO','4009-MO','9398-IL','11384-IL','9398-IN','11210-IL','11780-IL','11412-TN','10185-TN','11757-IL','14324-IL')--#3--#4--#5
		LEFT JOIN dbo.AgentBankConfigAccount AS Aco WITH (NOLOCK) ON Aco.IdStatus = 1 AND Aco.IdBank = 2 AND Aco.IdAgent = A.IdAgent 
		WHERE LTRIM(RTRIM(ISNULL(C.MicrManual,''))) != '' AND C.IdStatus = @IdStatusStandBy
		and C.IsIRD = 0--#7;


		--Insert Into @Checks
		INSERT INTO #Checks--#6
		(
			IdCheck
			, IdBankConfig
			, [MicrAuxOnUs] 
			, MicrExternalProcessingCode  
			, [MicrRoutingTransitNumber] 
			, [MicrRoutingTransitNumberCheckDigit] 
			, Amount 
			, MicrOnUs 
			, ItemSequenceNumber  
			, FrontImagePath 
			, RearImagePath 
			, IdAgent
			, IsReclear
			, AbaRouting
			, Account 
			, AgentCode --M00054
		)		
		SELECT 
			IdCheck
			, IdBankConfig
			, [MicrAuxOnUs] 
			, MicrExternalProcessingCode  
			, [MicrRoutingTransitNumber] 
			, [MicrRoutingTransitNumberCheckDigit] 
			, Amount 
			, MicrOnUs 
			, ItemSequenceNumber  
			, FrontImagePath 
			, RearImagePath 
			, IdAgent
			, IsReclear
			, AbaRouting
			, Account 
			, AgentCode --M00054
		FROM #temp2 
		WHERE IdBankConfig = 2 OR IdBankConfig IS NULL;


		UPDATE [dbo].[Checks] 
		SET IdStatus = @IdStatusPendingGatewayResponse, 
			IdCheckProcessorBank = 2
		--WHERE IdCheck  in (Select IdCheck from @Checks)
		WHERE IdCheck IN (Select IdCheck from #Checks);--#6

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
		--FROM @Checks
		FROM #Checks;--#6

		INSERT INTO [dbo].[CheckCredit]
				   ([IdAgent]
				   ,[SubAccount]
				   ,[Amount]
				   ,[IdStatus]
				   ,[CreateDate])
		--OUTPUT Inserted.[IdCheckCredit], Inserted.IdAgent, Inserted.SubAccount, Inserted.Amount, null INTO @Credits
		OUTPUT Inserted.[IdCheckCredit], Inserted.IdAgent, Inserted.SubAccount, Inserted.Amount, null INTO #Credits--#6
		SELECT A.IdAgent
			, SUBSTRING(A.agentcode,0,CHARINDEX('-', A.agentcode))
			, C.Amount, @IdStatusPendingGatewayResponse, @currentDate
		FROM dbo.Agent A WITH (NOLOCK) 
		INNER JOIN 
		(
			SELECT C.IdAgent, sum(C.Amount) Amount
			FROM #Checks C--#6
			GROUP BY C.IdAgent
		)C ON C.IdAgent = A.IdAgent;

		UPDATE C 
		SET C.IdCheckCredit = Cr.IdCheckCredit
		FROM #Checks C--#6
		INNER JOIN #Credits Cr on Cr.IdAgent = C.IdAgent;--#6

		UPDATE C 
		set C.IdCheckCredit = Cr.IdCheckCredit
		FROM dbo.Checks C
		INNER JOIN #Checks Cv on Cv.IdCheck = C.IdCheck--#6
		INNER JOIN #Credits Cr on Cr.IdAgent = C.IdAgent;--#6

		DECLARE @TempIdAgent int;
		DECLARE @BundleSequence int = 0;
		DECLARE @IdCheckBundle int = 0;
		DECLARE @FileIdentifier varchar(50) = NEWID();
		DECLARE @CreditsOnBundle int = 0;

		SELECT TOP 1 @TempIdAgent = IdAgent
		FROM #Credits--#6 
		WHERE BundleSequence IS NULL
		ORDER BY IdAgent;

		WHILE (@TempIdAgent IS NOT NULL)
		BEGIN
			UPDATE #Credits SET BundleSequence = @BundleSequence--#6
			WHERE IdAgent = @TempIdAgent;

			SET @CreditsOnBundle = 1;

			--while ((Select count(1) from @Checks where IdAgent=@TempIdAgent and BundleSequence is null)>0)
			WHILE EXISTS (SELECT 1 FROM #Checks WHERE IdAgent = @TempIdAgent AND BundleSequence IS NULL)--#6
			BEGIN		
				UPDATE #Checks SET BundleSequence = @BundleSequence--#6
				WHERE IdCheck IN (SELECT TOP (@BundleMaxSize-@CreditsOnBundle) IdCheck FROM #Checks WHERE IdAgent = @TempIdAgent AND BundleSequence IS NULL ORDER BY IdCheck);
		
				SET @CreditsOnBundle = 0;
				SET @BundleSequence = @BundleSequence + 1;
			END

			SET @TempIdAgent = NULL;

			SELECT TOP 1 @TempIdAgent = IdAgent
			FROM #Credits--#6 
			WHERE BundleSequence IS NULL
			ORDER BY IdAgent;
		END
	
		INSERT INTO [dbo].[CheckBundle]([FileIdentifier],[BundleSequence],[Amount],[ItemsWithinBundleCount],[ImagesWithinBundleCount],[CreateDate])
		OUTPUT Inserted.[IdCheckBundle], Inserted.BundleSequence, Inserted.Amount, Inserted.ItemsWithinBundleCount, Inserted.ImagesWithinBundleCount  INTO #Bundles--#6
		SELECT @FileIdentifier,BundleSequence, SUM(Amount) Amount, COUNT(1) ItemsWithinBundleCount, SUM([Type]) * 2 ImagesWithinBundleCount, @currentDate
		FROM 
		(
			SELECT [IdCheckCredit] Id, 0 [Type], BundleSequence, 0 Amount
			FROM #Credits--#6
			UNION ALL
			SELECT [IdCheck] Id, 1 [Type], BundleSequence, Amount
			FROM #Checks--#6
		) L
		GROUP BY BundleSequence;

		UPDATE C 
		SET C.[IdCheckBundle] = B.IdCheckBundle
		FROM dbo.Checks C
		INNER JOIN #Checks CT on CT.IdCheck = C.IdCheck--#6
		INNER JOIN #Bundles B on B.BundleSequence = CT.BundleSequence;--#6

		UPDATE C 
		SET C.[IdCheckBundle] = B.IdCheckBundle
		FROM dbo.CheckCredit C
		INNER JOIN #Credits CT on CT.IdCheckCredit = C.IdCheckCredit--#6
		INNER JOIN #Bundles B on B.BundleSequence = CT.BundleSequence;--#6

		SELECT
			Bu.IdCheckBundle
			, Bu.BundleSequence
			, Bu.Amount
			, Bu.ItemsWithinBundleCount
			, Bu.ImagesWithinBundleCount
			, [AbaRouting] = (SELECT TOP 1 C.AbaRouting FROM #Checks C WHERE C.BundleSequence = bu.BundleSequence)
			, [Account] = (SELECT TOP 1 C.Account FROM #Checks C WHERE C.BundleSequence = bu.BundleSequence)
		FROM #Bundles Bu;--#6
	
		--CANTIDADES CREDIT RECORD - M00054
		--BEGIN M00054
		--declare @DestinationRoutingNumber varchar(100) = (select [Value] from [Services].[ServiceAttributes] with (nolock) where [Code]='SOUTHSIDESEND' and [Key]='Field_DestinationRoutingNumber')
		--declare @OriginRoutingNumber varchar(100) = (select [Value] from [Services].[ServiceAttributes] with (nolock) where [Code]='SOUTHSIDESEND' and [Key]='Field_OriginRoutingNumber')

		SELECT
			C.[IdCheckCredit],
			C.IdAgent,
			C.SubAccount,
			C.Amount,
			C.BundleSequence,
			A.AgentCode+ ' '+ A.AgentName as ImageDataAgentName,
			--'Routing Number: '+@DestinationRoutingNumber+ CHAR(13)+CHAR(10)+'Account Number: '+@OriginRoutingNumber + CHAR(13)+CHAR(10)+'        Amount: $'+convert(varchar,C.Amount,0) as ImageDataResume,
			'Routing Number: '+ Ch.AbaRouting + CHAR(13)+CHAR(10)+'Account Number: '+ ch.Account + CHAR(13)+CHAR(10)+'        Amount: $'+convert(varchar,C.Amount,0) as ImageDataResume,
			Ch.AbaRouting + ch.Account + @Trancode + REPLACE(convert(varchar,C.Amount,0),'.',' ') as MicrOnUs,
			dbo.fn_FormatCheckDetailForCredit(C.IdCheckCredit) as ImageDataCheckDetail,
			--@DestinationRoutingNumber AbaRouting,
			--@OriginRoutingNumber Account
			Ch.AbaRouting AbaRouting,
			ch.Account Account

		FROM #Credits C--#6 
		INNER JOIN dbo.Agent A WITH (NOLOCK) ON A.IdAgent = C.IdAgent AND A.AgentState != 'NV'
		RIGHT JOIN #Checks Ch ON Ch.IdAgent = A.IdAgent--#6
		--_________END M00054______________




		--Select distinct
		--Cr.[IdCheckCredit]
		--, Cr.IdAgent
		--, Cr.SubAccount
		--, Cr.Amount
		--, Cr.BundleSequence
	 -- , [AbaRouting]  =Ch.AbaRouting
	 -- , [Account]    =Ch.Account
		--FROM
		--  @Credits Cr
		--	right join 
	 -- @Checks Ch
		--on Ch.IdCheckCredit=Cr.IdCheckCredit

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
			C.IsReclear,
			C.AbaRouting,
			C.Account,
			C.AgentCode --M00054
		FROM #Checks C;--#6

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage nvarchar(max) = ERROR_MESSAGE();
		INSERT INTO dbo.ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('st_GetChecksToProcessSouthSide',Getdate(),@ErrorMessage);
	END CATCH
END
