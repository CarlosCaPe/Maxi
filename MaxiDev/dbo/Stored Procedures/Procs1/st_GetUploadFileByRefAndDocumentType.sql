CREATE procedure [dbo].[st_GetUploadFileByRefAndDocumentType]
(
       @IdType int,
       @Idreference int,
       @IdDocumentType int
)
as 
begin
set nocount on


select top 1
u.CreationDate,
dt.Name as DocumentTypeName,
u.ExpirationDate,
u.Extension,
u.FileName,
u.FileGuid, 
u.IdUploadFile,
u.IdDocumentType,
u.IdReference,
u.IdStatus,
u.IdUser,
u.LastChange_LastDateChange,
case when dt.IdType= 1 then [dbo].[GetMessageFromMultiLenguajeResorces](1,isnull(DocumentImageCode,isnull(DocumentImageCode,'FRONT1'))) else '' end Name, 
case when dt.IdType= 1 then [dbo].[GetMessageFromMultiLenguajeResorces](2,isnull(DocumentImageCode,isnull(DocumentImageCode,'FRONT1'))) else '' end NameEs,
dt.IdType 
from uploadfiles u (nolock)
left join [UploadFilesDetail] d (nolock) on u.IdUploadFile=d.IdUploadFile
inner join documenttypes dt (nolock) on u.IdDocumentType = dt.IdDocumentType
left join [DocumentImageType] t (nolock) on d.[IdDocumentImageType]=t.[IdDocumentImageType]
where 
    dt.IdType = @IdType
    and u.idstatus=1 and u.IdReference =  @Idreference
       and dt.IdDocumentType = @IdDocumentType
order by u.IdUploadFile desc

end
