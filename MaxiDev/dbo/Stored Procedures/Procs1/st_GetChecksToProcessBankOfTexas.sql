
CREATE procedure [dbo].[st_GetChecksToProcessBankOfTexas]
AS
BEGIN

/********************************************************************

<Author> ??? </Author>
<app> Services </app>
<Description> Gets checks for Servce</Description>
<ChangeLog>
<log Date="03/12/2018" Author="amoreno">Se filtra que no tenga configuración</log>

</ChangeLog>

*********************************************************************/

BEGIN TRY

	declare @currentDate datetime =getDate();
	declare @IssuerCheckPath varchar(100)= (select value from GlobalAttributes where Name ='IssuerCheckPath')
	declare @IdUserSystem int =dbo.GetGlobalAttributeByName('SystemUserID') 
	declare @BundleMaxSize int =999
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
	ItemSequenceNumber int ,
	FrontImagePath varchar(max),
	RearImagePath varchar(max),
	IdAgent int,
	IdCheckCredit int,
	BundleSequence int,
	AgentCode varchar(100)
	)

	declare @Credits TABLE(
	[IdCheckCredit] int,
	IdAgent int,
	[SubAccount] varchar(50),
	[Amount] money,
	BundleSequence int
	)

	declare @Bundles TABLE (
	IdCheckBundle int,
	BundleSequence int,
	Amount money, 
	ItemsWithinBundleCount int, 
	ImagesWithinBundleCount int
	)


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
	IdAgent ,
	AgentCode
	)
	select 
	C.IdCheck,
	REPLACE(REPLACE(C.[MicrAuxOnUs],'d','-'),'c','/') MicrAuxOnUs, 
	'' MicrExternalProcessingCode, 
	SUBSTRING (C.[MicrRoutingTransitNumber],1,8) [MicrRoutingTransitNumber],
	SUBSTRING (C.[MicrRoutingTransitNumber],9,1) [MicrRoutingTransitNumberCheckDigit],
	C.Amount,
	REPLACE(REPLACE(C.MicrOnUs,'d','-'),'c','/') MicrOnUs,
	 C.IdCheck ItemSequenceNumber,
	 @IssuerCheckPath+ convert(varchar(max),C.[IdIssuer])+'\Checks\'+ convert(varchar(max),C.IdCheck)+'\'+UF.FileName+UF.Extension FrontImagePath,
	 @IssuerCheckPath+ convert(varchar(max),C.[IdIssuer])+'\Checks\'+ convert(varchar(max),C.IdCheck)+'\'+UR.FileName+UR.Extension RearImagePath,
	 C.IdAgent,
	 A.AgentCode
	from [dbo].[Checks] C (nolock)
		inner join 
			(
				Select IdReference, Min(u.IdUploadFile) FrontIdUploadFile
				from UploadFiles u (nolock)
				join UploadFilesDetail d (nolock) on u.IdUploadFile=d.IdUploadFile and d.IdDocumentImageType=1 
				Where IdDocumentType=69 and FileName like REPLACE('00000000-0000-0000-0000-000000000000', '0', '[0-9a-fA-F]')
				group by  IdReference
			)F on F.IdReference=C.IdCheck
		inner join 
			(
				Select IdReference,  Min(u.IdUploadFile) RearIdUploadFile
				from UploadFiles u (nolock)
				join UploadFilesDetail d (nolock) on u.IdUploadFile=d.IdUploadFile and d.IdDocumentImageType=2
				Where IdDocumentType=69 and FileName like REPLACE('00000000-0000-0000-0000-000000000000', '0', '[0-9a-fA-F]')
				group by  IdReference
			)F2 on F2.IdReference=C.IdCheck
		inner join UploadFiles UF (nolock) on UF.IdUploadFile=F.FrontIdUploadFile
		inner join UploadFiles UR (nolock) on UR.IdUploadFile=F2.RearIdUploadFile
		inner join Agent A on A.IdAgent =C.IdAgent AND A.AgentState <> 'NV'	AND A.AgentCode NOT IN ('5525-KS','6172-KS','4947-KS','5301-KS','7030-KY','4913-KS','5088-KS','6460-KY','5557-KY','8338-KY','5464-KY','6548-MO','4009-MO','9398-IL','11384-IL','9398-IN','11210-IL')	 
		--inner join Agent A on A.IdAgent =C.IdAgent AND A.AgentState <> 'NV'
	where LTRIM(RTRIM(ISNULL(C.MicrManual,''))) !='' and C.IdStatus=@IdStatusStandBy  
	and C.Idagent not in (select Aco.Idagent from  [dbo].[AgentBankConfigAccount] as Aco with (nolock) where Aco.IdStatus=1) --#2
	--and idcheck not in  (594796)

			

	update [dbo].[Checks] Set IdStatus=@IdStatusPendingGatewayResponse, IdCheckProcessorBank=3
	WHERE IdCheck  in (Select IdCheck from @Checks)

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
	FROM @Checks

	INSERT INTO [dbo].[CheckCredit]
			   ([IdAgent]
			   ,[SubAccount]
			   ,[Amount]
			   ,[IdStatus]
			   ,[CreateDate])
	OUTPUT Inserted.[IdCheckCredit], Inserted.IdAgent, Inserted.SubAccount, Inserted.Amount, null INTO @Credits
	Select A.IdAgent
		, SUBSTRING(A.agentcode,0,CHARINDEX('-', A.agentcode))
		, C.Amount, @IdStatusPendingGatewayResponse, @currentDate
	from Agent A 
		inner join (
			Select C.IdAgent, sum(C.Amount) Amount
			from @Checks C
			group by C.IdAgent
		)C on C.IdAgent=A.IdAgent 


	UPDATE C set C.IdCheckCredit=Cr.IdCheckCredit
	FROM @Checks C
		inner join @Credits Cr on Cr.IdAgent=C.IdAgent

	UPDATE C set C.IdCheckCredit=Cr.IdCheckCredit
	FROM Checks C
		inner join @Checks Cv on Cv.IdCheck=C.IdCheck
		inner join @Credits Cr on Cr.IdAgent=C.IdAgent


	declare @TempIdAgent int
	declare @BundleSequence int=0
	declare @IdCheckBundle int=0
	declare @FileIdentifier varchar(50)=NEWID()
	declare @CreditsOnBundle int=0

	Select top 1 @TempIdAgent=IdAgent
	FROM @Credits 
	Where BundleSequence is null
	Order by IdAgent

	While (@TempIdAgent is not null )
	BEGIN
	
		Update @Credits set BundleSequence=@BundleSequence
		where IdAgent=@TempIdAgent

		SET @CreditsOnBundle=1

		while ((Select count(1) from @Checks where IdAgent=@TempIdAgent and BundleSequence is null)>0)
		BEGIN		
			Update @Checks set BundleSequence=@BundleSequence
			where IdCheck in (Select top (@BundleMaxSize-@CreditsOnBundle) IdCheck from @Checks where IdAgent=@TempIdAgent and BundleSequence is null order by IdCheck )
		
			SET @CreditsOnBundle=0
			SET @BundleSequence=@BundleSequence+1
		END

		SET @TempIdAgent = null

		Select top 1 @TempIdAgent=IdAgent
		FROM @Credits 
		Where BundleSequence is null
		Order by IdAgent

	END
	
	Insert into [dbo].[CheckBundle]([FileIdentifier],[BundleSequence],[Amount],[ItemsWithinBundleCount],[ImagesWithinBundleCount],[CreateDate])
	OUTPUT Inserted.[IdCheckBundle], Inserted.BundleSequence, Inserted.Amount, Inserted.ItemsWithinBundleCount, Inserted.ImagesWithinBundleCount  INTO @Bundles
	Select @FileIdentifier,BundleSequence, Sum(Amount) Amount, Count(1) ItemsWithinBundleCount, Sum(Type)*2 ImagesWithinBundleCount, @currentDate
	From (
		Select [IdCheckCredit] Id, 1 Type, BundleSequence, Amount
		FROM @Credits
		UNION ALL
		Select [IdCheck] Id, 1 Type, BundleSequence, Amount
		FROM @Checks
		) L
	group by BundleSequence


	Update C set C.[IdCheckBundle]= B.IdCheckBundle
	From Checks C
		inner join @Checks CT on CT.IdCheck=C.IdCheck
		inner join @Bundles B on B.BundleSequence = CT.BundleSequence

	Update C set C.[IdCheckBundle]= B.IdCheckBundle
	From CheckCredit C
		inner join @Credits CT on CT.IdCheckCredit=C.IdCheckCredit
		inner join @Bundles B on B.BundleSequence = CT.BundleSequence


	declare @DestinationRoutingNumber varchar(100) = (select [Value] from [Services].[ServiceAttributes] where [Code]='BANKOFTEXASSEND' and [Key]='Field_DestinationRoutingNumber')
	declare @OriginRoutingNumber varchar(100) = (select [Value] from [Services].[ServiceAttributes] where [Code]='BANKOFTEXASSEND' and [Key]='Field_OriginRoutingNumber')

	Select
	IdCheckBundle,
	BundleSequence,
	Amount,
	ItemsWithinBundleCount,
	ImagesWithinBundleCount
	From @Bundles 

	
	Select
	C.[IdCheckCredit],
	C.IdAgent,
	C.SubAccount,
	C.Amount,
	C.BundleSequence,
	A.AgentCode+ ' '+ A.AgentName ImageDataAgentName,
	'Routing Number: '+@DestinationRoutingNumber+ CHAR(13)+CHAR(10)+'Account Number: '+@OriginRoutingNumber + CHAR(13)+CHAR(10)+'        Amount: $'+convert(varchar,C.Amount,0) ImageDataResume,
	dbo.fn_FormatCheckDetailForCredit(C.IdCheckCredit) ImageDataCheckDetail
	FROM @Credits C
		inner join Agent A on A.IdAgent =C.IdAgent

	select 
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
	C.AgentCode
	 from @Checks C

 End Try                                                                                            
	Begin Catch
		
		Declare @ErrorMessage nvarchar(max) =ERROR_MESSAGE()                                             
		Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetChecks',Getdate(),@ErrorMessage)                                                                                            
	End Catch


END
