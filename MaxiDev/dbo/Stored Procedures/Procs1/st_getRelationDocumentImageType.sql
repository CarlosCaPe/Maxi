create procedure st_getRelationDocumentImageType
(
    @IdDocumentType int = null,
    @IdLenguage int
)
as

select IdDocumentImageType,DocumentImageType,IdDocumentType from 
(
    select r.IdDocumentType,r.IdDocumentImageType,[dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,i.DocumentImageCode) DocumentImageType
    from [RelationDocumentImageType] r
    join 
        DocumentImageType i on r.IdDocumentImageType=i.IdDocumentImageType
    where 
        r.IdDocumentType=isnull(@IdDocumentType,r.IdDocumentType)
)t
order by IdDocumentType,DocumentImageType