CREATE PROCEDURE [Corp].[st_GetDocumentImageType]

   @IdDocumentType int

as

select distinct d.IdDocumentImageType,
[dbo].[GetMessageFromMultiLenguajeResorces](1,isnull(d.DocumentImageCode,'FRONT1')) Name, 
[dbo].[GetMessageFromMultiLenguajeResorces](2,isnull(d.DocumentImageCode,'FRONT1')) NameEs  
from [DocumentImageType] d with(nolock)
left join [RelationDocumentImageType] r with(nolock) on d.IdDocumentImageType = r.IdDocumentImageType
left join [DocumentTypes] dt with(nolock) on dt.IdDocumentType = r.IdDocumentType
where  dt.IdDocumentType = @IdDocumentType or @IdDocumentType = 0
