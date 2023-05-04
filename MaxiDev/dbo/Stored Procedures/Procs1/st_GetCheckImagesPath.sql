/********************************************************************
<Author> azavala </Author>
<app>Maxi API Utils</app>
<Description> Obtiene la ruta de las imagenes de Cheques (Frontal y Posterior) por AgentCode </Description>

<ChangeLog>
<log Date="31/07/2018" Author="azavala">Creacion</log>
</ChangeLog>
*********************************************************************/
CREATE PROCEDURE dbo.st_GetCheckImagesPath
	@AgentCode varchar(MAX),
	@DateStart varchar(MAX),
	@DateEnd varchar(MAX)
AS
BEGIN TRY
	SET NOCOUNT ON;
	--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetCheckImagesPath',Getdate(),'DateStart: ' + CONVERT(varchar(MAX), @DateStart) + ' DateEnd: ' + CONVERT(varchar(MAX), @DateEnd))        
	declare @IssuerCheckPath varchar(100)= (select value from GlobalAttributes where Name ='IssuerCheckPath')
	declare @IdStatusStandBy int =30

	select 
		C.IdCheck ItemSequenceNumber,
		@IssuerCheckPath+ convert(varchar(max),C.[IdIssuer])+'\Checks\'+ convert(varchar(max),C.IdCheck)+'\'+UF.FileName+UF.Extension FrontImagePath,
		@IssuerCheckPath+ convert(varchar(max),C.[IdIssuer])+'\Checks\'+ convert(varchar(max),C.IdCheck)+'\'+UR.FileName+UR.Extension RearImagePath,
		C.CheckNumber,
		A.AgentCode
		from [dbo].[Checks] C WITH(NOLOCK)
		inner join 
			(
				Select IdReference, Min(u.IdUploadFile) FrontIdUploadFile
				from UploadFiles u WITH(NOLOCK)
				join UploadFilesDetail d WITH(NOLOCK) on u.IdUploadFile=d.IdUploadFile and d.IdDocumentImageType=1 
				Where IdDocumentType=69 and FileName like REPLACE('00000000-0000-0000-0000-000000000000', '0', '[0-9a-fA-F]')
				group by  IdReference
			)F on F.IdReference=C.IdCheck
		inner join 
			(
				Select IdReference,  Min(u.IdUploadFile) RearIdUploadFile
				from UploadFiles u WITH(NOLOCK)
				join UploadFilesDetail d WITH(NOLOCK) on u.IdUploadFile=d.IdUploadFile and d.IdDocumentImageType=2
				Where IdDocumentType=69 and FileName like REPLACE('00000000-0000-0000-0000-000000000000', '0', '[0-9a-fA-F]')
				group by  IdReference
			)F2 on F2.IdReference=C.IdCheck
		inner join UploadFiles UF WITH(NOLOCK) on UF.IdUploadFile=F.FrontIdUploadFile
		inner join UploadFiles UR WITH(NOLOCK) on UR.IdUploadFile=F2.RearIdUploadFile
		inner join Agent A on A.IdAgent =C.IdAgent and AgentCode = @AgentCode
		AND C.DateOfMovement >= @DateStart AND C.DateOfMovement <= @DateEnd
END TRY
BEGIN CATCH
	Declare @MessageError nvarchar(max)                                                                                             
	Select @MessageError=ERROR_MESSAGE()+convert(varchar, ERROR_LINE())
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetCheckImagesPath',Getdate(),@MessageError)        
END CATCH
