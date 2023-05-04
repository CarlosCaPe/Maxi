CREATE procedure [dbo].[st_GetUploadFile]
@Idreference int,
@IdType int,
@PageIndex int = 1,
@PageSize int = 30,
@AllCollection bit,
@IsDocChecks bit = 0,
@PageCount INT OUTPUT

as
/********************************************************************
<Author></Author>
<app> </app>
<Description></Description>

<ChangeLog>
<log Date=" Author="adominguez">Agregar campos necesarios para mostrar el recibo guardado desde fax android #MOBILE </log>

</ChangeLog>

*********************************************************************/
SET  @PageIndex=@PageIndex-1

create table #result1
(
Id int IDENTITY (1,1),
CreationDate datetime,
DocuemntTypeName nvarchar(max),
ExpirationDate datetime,
Extension nvarchar(max),
FileName nvarchar(max),
FileGuid  nvarchar(max), 
IdUploadFile int,
IdDocumentType int,
IdReference int,
IdStatus int,
IdUser int,
LastChange_LastDateChange  datetime,
Name nvarchar(max), 
NameEs nvarchar(max),
IdType int,
IdDocumentImageType int,
IdIssuer int,
IdCountry int, 
IdState int,
CountryName nvarchar(max),
StateName nvarchar(max),
DateOfBirth datetime,
FolderNameMobile nvarchar(max),--#MOBILE
FileNameMobile nvarchar(max),--#MOBILE
FileTypeMobile nvarchar(max),--#MOBILE
IsMobile bit--#MOBILE
)
if(@IsDocChecks = 0)
begin

insert into #result1
			select
			u.CreationDate,
		    case when dt.Name = 'CustomerPicture' then 'Customer Picture' 
			when dt.Name = 'Fax Training' then 'Compliance Exam' 
			else dt.Name end as DocuemntTypeName,
			u.ExpirationDate,
			u.Extension,
			u.[FileName],
			u.FileGuid, 
			u.IdUploadFile,
			u.IdDocumentType,
			u.IdReference,
			u.IdStatus,
			u.IdUser,
			u.LastChange_LastDateChange,
			case when dt.IdType in (1,6) then [dbo].[GetMessageFromMultiLenguajeResorces](1,isnull(DocumentImageCode,isnull(DocumentImageCode,'FRONT1'))) else '' end Name, 
			case when dt.IdType in (1,6)  then [dbo].[GetMessageFromMultiLenguajeResorces](2,isnull(DocumentImageCode,isnull(DocumentImageCode,'FRONT1'))) else '' end NameEs,
			dt.IdType,
			t.IdDocumentImageType, 
			C.IdIssuer,
			d.IdCountry,
			d.IdState,
			isnull(co.CountryName, '') as CountryName,
			isnull(s.StateName, '') as StateName,
			isnull(u.DateOfBirth, GETDATE()) as DateOfBirth,
			tuf.FolderName as FolderNameMobile, /*MOBILE*/
			tuf.FileName as FileNameMobile,     /*MOBILE*/
			tuf.FileType as FileTypeMobile     /*MOBILE*/
			,case when tuf.FileName is not null then 1 else 0 end IsMobile /*MOBILE*/
			from uploadfiles u (nolock)
			left join [UploadFilesDetail] d with(nolock) on u.IdUploadFile=d.IdUploadFile
			inner join documenttypes dt with(nolock) on u.IdDocumentType = dt.IdDocumentType
			left join [DocumentImageType] t with(nolock) on d.[IdDocumentImageType]=t.[IdDocumentImageType]
			left join [Checks] C with(nolock) on C.IdCheck=U.IdReference
			left join [Country] co with(nolock) on d.IdCountry = co.IdCountry
			left join [State] s with(nolock) on d.IdState = s.IdState

			LEFT JOIN (SELECT IdTransfer, MAX(IdTransactionUploadFile) IdTransactionUploadFile FROM TransactionUploadFile GROUP BY IdTransfer) lastUF ON lastUF.IdTransfer = U.IdReference
			LEFT JOIN TransactionUploadFile tuf with(NOLOCK) on (tuf.IdTransactionUploadFile = lastUF.IdTransactionUploadFile)  /*MOBILE*/
			where 
				dt.IdType = @IdType
				and u.idstatus=1 and u.IdReference =  @Idreference
				order by case 
			  when dt.IdDocumentType in (10,47,48) then 2
			  else 1
			 end, u.CreationDate desc,dt.Name

SELECT @PageCount = COUNT(1) FROM #result1

if(@AllCollection = 0)
begin
	select * from #result1 where Id BETWEEN @PageIndex + 1 AND @PageIndex + @PageSize
end
else
begin
	select * from #result1
end
end
else
Begin

insert into #result1
			select
			u.CreationDate,
			case when dt.Name = 'CustomerPicture' then 'Customer Picture' 
			when dt.Name = 'Fax Training' then 'Compliance Exam' 
			else dt.Name end as DocuemntTypeName,
			u.ExpirationDate,
			u.Extension,
			u.[FileName],
			u.FileGuid, 
			u.IdUploadFile,
			u.IdDocumentType,
			u.IdReference,
			u.IdStatus,
			u.IdUser,
			u.LastChange_LastDateChange,
			case when dt.IdType in (1,4) then [dbo].[GetMessageFromMultiLenguajeResorces](1,isnull(DocumentImageCode,isnull(DocumentImageCode,'FRONT1'))) else '' end Name, 
			case when dt.IdType in (1,4) then [dbo].[GetMessageFromMultiLenguajeResorces](2,isnull(DocumentImageCode,isnull(DocumentImageCode,'FRONT1'))) else '' end NameEs,
			dt.IdType,
			t.IdDocumentImageType,
			C.IdIssuer,
			d.IdCountry,
			d.IdState,
			isnull(co.CountryName, '') as CountryName,
			isnull(s.StateName, '') as StateName,
			isnull(u.DateOfBirth, GETDATE()) as DateOfBirth,
			tuf.FolderName as FolderNameMobile, /*MOBILE*/
			tuf.FileName as FileNameMobile,     /*MOBILE*/
			tuf.FileType as FileTypeMobile     /*MOBILE*/
			,case when tuf.FileName is not null then 1 else 0 end IsMobile /*MOBILE*/
			from uploadfiles u with(nolock)
			left join [UploadFilesDetail] d with(nolock) on u.IdUploadFile=d.IdUploadFile
			inner join documenttypes dt with(nolock) on u.IdDocumentType = dt.IdDocumentType
			left join [DocumentImageType] t with(nolock) on d.[IdDocumentImageType]=t.[IdDocumentImageType]
			left join [Checks] C with(nolock) on C.IdCheck=U.IdReference
			left join [Country] co with(nolock) on d.IdCountry = co.IdCountry
			left join [State] s with(nolock) on d.IdState = s.IdState

			LEFT JOIN (SELECT IdTransfer, MAX(IdTransactionUploadFile) IdTransactionUploadFile FROM TransactionUploadFile GROUP BY IdTransfer) lastUF ON lastUF.IdTransfer = U.IdReference
			LEFT JOIN TransactionUploadFile tuf with(NOLOCK) on (tuf.IdTransactionUploadFile = lastUF.IdTransactionUploadFile)  /*MOBILE*/
			where 
				dt.IdType in (1,4)
				and u.idstatus=1 and u.IdReference =  @Idreference
				order by case 
			  when dt.IdDocumentType in (10,47,48) then 2
			  else 1
			 end, u.CreationDate desc,dt.Name

SELECT @PageCount = COUNT(1) FROM #result1

if(@AllCollection = 0)
begin
	select * from #result1 where Id BETWEEN @PageIndex + 1 AND @PageIndex + @PageSize
end
else
begin
	select * from #result1
end


end
