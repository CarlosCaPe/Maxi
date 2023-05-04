CREATE PROCEDURE [Corp].[st_GetUploadFileByIdFile]
(
	@IdFile int
)
as 
begin
set nocount on

select top 1
						   u.IdUploadFile,
                           u.IdDocumentType,
                           IdReference,
                           IdStatus,
                           IdUser,
                           dt.Name as  DocumentTypeName,
                           Extension,
                           FileGuid,
                           FileName ,
                           LastChange_LastDateChange,
                           ExpirationDate,
                           CreationDate,
                           case when dt.IdType= 1 then [dbo].[GetMessageFromMultiLenguajeResorces](1,isnull(DocumentImageCode,isnull(DocumentImageCode,'FRONT1'))) else '' end Name, 
						   case when dt.IdType= 1 then [dbo].[GetMessageFromMultiLenguajeResorces](2,isnull(DocumentImageCode,isnull(DocumentImageCode,'FRONT1'))) else '' end NameEs,
						   dt.IdType                           
						   from UploadFiles u (nolock)
						   inner join DocumentTypes dt (nolock) on u.IdDocumentType = dt.IdDocumentType
						   left join [UploadFilesDetail] d (nolock) on u.IdUploadFile=d.IdUploadFile
						   left join [DocumentImageType] t (nolock) on d.[IdDocumentImageType]=t.[IdDocumentImageType]
						   where u.IdUploadFile = @IdFile
end
