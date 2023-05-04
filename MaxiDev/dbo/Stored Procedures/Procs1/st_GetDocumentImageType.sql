
CREATE PROCEDURE [dbo].[st_GetDocumentImageType]

   @IdDocumentType int

as

select distinct d.IdDocumentImageType,
[dbo].[GetMessageFromMultiLenguajeResorces](1,isnull(d.DocumentImageCode,'FRONT1')) Name, 
[dbo].[GetMessageFromMultiLenguajeResorces](2,isnull(d.DocumentImageCode,'FRONT1')) NameEs  
from [DocumentImageType] d
left join [RelationDocumentImageType] r on d.IdDocumentImageType = r.IdDocumentImageType
left join [DocumentTypes] dt on dt.IdDocumentType = r.IdDocumentType
where  dt.IdDocumentType = @IdDocumentType or @IdDocumentType = 0
