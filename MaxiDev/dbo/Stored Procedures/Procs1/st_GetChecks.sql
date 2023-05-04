CREATE procedure [dbo].[st_GetChecks]
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

BEGIN

BEGIN TRY

	declare @currentDate datetime =getDate();
	declare @IssuerCheckPath varchar(100)= (select value from GlobalAttributes with(nolock) where Name ='IssuerCheckPath')
	declare @IdUserSystem int =dbo.GetGlobalAttributeByName('SystemUserID') 
	declare @BundleMaxSize int =300
	declare @IdStatusStandBy int =20
	declare @IdStatusPendingGatewayResponse int=21

	declare @Checks TABLE(
	IdCheck int,
	[MicrAuxOnUs] varchar(max), 
	MicrExternalProcessingCode varchar(1), 
	[MicrRoutingTransitNumber] varchar(max),
	[MicrRoutingTransitNumberCheckDigit] varchar(max),
	Amount money,
	MicrOnUs varchar(max),
	CorrectionIndicator varchar(1),
	ItemSequenceNumber int ,
	FrontImagePath varchar(max),
	RearImagePath varchar(max),
	IdAgent int,
	IdCheckCredit int,
	BundleSequence int
	);

	declare @Credits TABLE(
	[IdCheckCredit] int,
	IdAgent int,
	[SubAccount] varchar(50),
	[Amount] money,
	BundleSequence int
	);

	declare @Bundles TABLE (
	IdCheckBundle int,
	BundleSequence int,
	Amount money, 
	ItemsWithinBundleCount int, 
	ImagesWithinBundleCount int
	);


	Insert Into @Checks
	(
	IdCheck,
	[MicrAuxOnUs] , 
	MicrExternalProcessingCode , 
	[MicrRoutingTransitNumber] ,
	[MicrRoutingTransitNumberCheckDigit] ,
	Amount ,
	MicrOnUs ,
	CorrectionIndicator ,
	ItemSequenceNumber  ,
	FrontImagePath ,
	RearImagePath ,
	IdAgent 
	)
	select 
	C.IdCheck,
	REPLACE(REPLACE(C.[MicrAuxOnUs],'d','-'),'c','/') MicrAuxOnUs, 
	'' MicrExternalProcessingCode, 
	SUBSTRING (C.[MicrRoutingTransitNumber],1,8) [MicrRoutingTransitNumber],
	SUBSTRING (C.[MicrRoutingTransitNumber],9,1) [MicrRoutingTransitNumberCheckDigit],
	C.Amount,
	REPLACE(REPLACE(C.MicrOnUs,'d','-'),'c','/') MicrOnUs,
	'0' CorrectionIndicator,
	 C.IdCheck ItemSequenceNumber,
	 @IssuerCheckPath+ convert(varchar(max),C.[IdIssuer])+'\Checks\'+ convert(varchar(max),C.IdCheck)+'\'+UF.[FileName]+UF.Extension FrontImagePath,
	 @IssuerCheckPath+ convert(varchar(max),C.[IdIssuer])+'\Checks\'+ convert(varchar(max),C.IdCheck)+'\'+UR.[FileName]+UR.Extension RearImagePath,
	 C.IdAgent
	from [dbo].[Checks] C with(nolock)
		inner join 
			(
				Select IdReference, Min(IdUploadFile) FrontIdUploadFile, Max(IdUploadFile) RearIdUploadFile
				from UploadFiles with(nolock) 
				Where IdDocumentType=69
				group by  IdReference
			)F on F.IdReference=C.IdCheck
		inner join UploadFiles UF with(nolock) on UF.IdUploadFile=F.FrontIdUploadFile
		inner join UploadFiles UR with(nolock) on UR.IdUploadFile=F.RearIdUploadFile
	where LTRIM(RTRIM(ISNULL(C.[MicrOriginal],''))) !='' and C.IdStatus=@IdStatusStandBy;
			--and idcheck not in (

			--				--184,
			--				--177,
			--				--146,
			--				--166,
			--				--125,
			--				--156,
			--				--153,
			--				--168,


			--				--137,
			--				180,

			--				--182,

			--				--118,
			--				154,

			--				--106,

			--				--124,
			--				172
			--			)

	update [dbo].[Checks] Set IdStatus=@IdStatusPendingGatewayResponse, IdCheckProcessorBank=1
	WHERE IdCheck  in (Select IdCheck from @Checks);

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
	FROM @Checks;

	INSERT INTO [dbo].[CheckCredit]
			   ([IdAgent]
			   ,[SubAccount]
			   ,[Amount]
			   ,[IdStatus]
			   ,[CreateDate])
	OUTPUT Inserted.[IdCheckCredit], Inserted.IdAgent, Inserted.SubAccount, Inserted.Amount, null INTO @Credits
	Select A.IdAgent
		, CASE WHEN LEN(ISNULL(A.SubAccount,''))=15 and SUBSTRING(ISNULL(A.SubAccount,''),1,5)='00000' THEN SUBSTRING(A.SubAccount,6,10) ELSE ISNULL(A.SubAccount,'') END
		, C.Amount, @IdStatusPendingGatewayResponse, @currentDate
	from Agent A  with(nolock)
		inner join (
			Select C.IdAgent, sum(C.Amount) Amount
			from @Checks C
			group by C.IdAgent
		)C on C.IdAgent=A.IdAgent;


	UPDATE C set C.IdCheckCredit=Cr.IdCheckCredit
	FROM @Checks C
		inner join @Credits Cr on Cr.IdAgent=C.IdAgent;

	UPDATE C set C.IdCheckCredit=Cr.IdCheckCredit
	FROM Checks C
		inner join @Checks Cv on Cv.IdCheck=C.IdCheck
		inner join @Credits Cr on Cr.IdAgent=C.IdAgent;


	declare @TempIdAgent int
	declare @BundleSequence int=0
	declare @IdCheckBundle int=0
	declare @FileIdentifier varchar(50)=NEWID()
	declare @CreditsOnBundle int=0

	Select top 1 @TempIdAgent=IdAgent
	FROM @Credits 
	Where BundleSequence is null
	Order by IdAgent;

	While (@TempIdAgent is not null )
	BEGIN
	
		Update @Credits set BundleSequence=@BundleSequence
		where IdAgent=@TempIdAgent;

		SET @CreditsOnBundle=1

		while ((Select count(1) from @Checks where IdAgent=@TempIdAgent and BundleSequence is null)>0)
		BEGIN		
			Update @Checks set BundleSequence=@BundleSequence
			where IdCheck in (Select top (@BundleMaxSize-@CreditsOnBundle) IdCheck from @Checks where IdAgent=@TempIdAgent and BundleSequence is null order by IdCheck );
		
			SET @CreditsOnBundle=0
			SET @BundleSequence=@BundleSequence+1
		END

		SET @TempIdAgent = null

		Select top 1 @TempIdAgent=IdAgent
		FROM @Credits 
		Where BundleSequence is null
		Order by IdAgent;

	END
	
	Insert into [dbo].[CheckBundle]([FileIdentifier],[BundleSequence],[Amount],[ItemsWithinBundleCount],[ImagesWithinBundleCount],[CreateDate])
	OUTPUT Inserted.[IdCheckBundle], Inserted.BundleSequence, Inserted.Amount, Inserted.ItemsWithinBundleCount, Inserted.ImagesWithinBundleCount  INTO @Bundles
	Select @FileIdentifier,BundleSequence, Sum(Amount) Amount, Count(1) ItemsWithinBundleCount, Sum([Type])*2 ImagesWithinBundleCount, @currentDate
	From (
		Select [IdCheckCredit] Id, 0 [Type], BundleSequence, 0 Amount
		FROM @Credits
		UNION ALL
		Select [IdCheck] Id, 1 [Type], BundleSequence, Amount
		FROM @Checks
		) L
	group by BundleSequence;


	Update C set C.[IdCheckBundle]= B.IdCheckBundle
	From Checks C
		inner join @Checks CT on CT.IdCheck=C.IdCheck
		inner join @Bundles B on B.BundleSequence = CT.BundleSequence;

	Update C set C.[IdCheckBundle]= B.IdCheckBundle
	From CheckCredit C
		inner join @Credits CT on CT.IdCheckCredit=C.IdCheckCredit
		inner join @Bundles B on B.BundleSequence = CT.BundleSequence;


	Select
	IdCheckBundle,
	BundleSequence,
	Amount,
	ItemsWithinBundleCount,
	ImagesWithinBundleCount
	From @Bundles ;

	Select
	[IdCheckCredit],
	IdAgent,
	SubAccount,
	Amount,
	BundleSequence
	FROM @Credits;

	select 
	C.IdCheck,
	C.[MicrAuxOnUs], 
	C.MicrExternalProcessingCode, 
	C.[MicrRoutingTransitNumber],
	C.[MicrRoutingTransitNumberCheckDigit],
	C.Amount,
	C.MicrOnUs,
	C.CorrectionIndicator,
	C.ItemSequenceNumber,
	C.FrontImagePath,
	C.RearImagePath,
	C.IdAgent,
	C.IdCheckCredit,
	C.BundleSequence
	 from @Checks C;

 End Try                                                                                            
	Begin Catch
		
		Declare @ErrorMessage nvarchar(max) =ERROR_MESSAGE()                                             
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetChecks',Getdate(),@ErrorMessage)                                                                                            
	End Catch


END



