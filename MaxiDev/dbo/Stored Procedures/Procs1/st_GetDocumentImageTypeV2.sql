/********************************************************************
<Author>djuarez</Author>
<app>Corporative</app>
<Description>Get Image Type by IdType of DocumentTypes</Description>

<ChangeLog>
<log Date="28/10/2019" Author="djuarez">Create</log>
<log Date="01/11/2019" Author="djuarez">Add IdType, IdDocumentType & NameDocument & IF </log>
</ChangeLog>
********************************************************************/
CREATE procedure [dbo].[st_GetDocumentImageTypeV2]
   @IdType int
as

IF @IdType = 0
	BEGIN

	SELECT
		d.IdDocumentImageType
	   ,[dbo].[GetMessageFromMultiLenguajeResorces](1, ISNULL (d.DocumentImageCode, 'FRONT1')) Name
	   ,[dbo].[GetMessageFromMultiLenguajeResorces](2, ISNULL (d.DocumentImageCode, 'FRONT1')) NameEs
	   ,dt.IdDocumentType
	   ,dt.IdType
	   ,dt.Name NameDocument
	FROM [DocumentImageType] d WITH (NOLOCK)
	LEFT JOIN [RelationDocumentImageType] r WITH (NOLOCK)
		ON d.IdDocumentImageType = r.IdDocumentImageType
	LEFT JOIN [DocumentTypes] dt WITH (NOLOCK)
		ON dt.IdDocumentType = r.IdDocumentType
	ORDER by dt.IdDocumentType

	END
ELSE 
	BEGIN

	SELECT DISTINCT
		d.IdDocumentImageType
	   ,[dbo].[GetMessageFromMultiLenguajeResorces](1, ISNULL (d.DocumentImageCode, 'FRONT1')) Name
	   ,[dbo].[GetMessageFromMultiLenguajeResorces](2, ISNULL (d.DocumentImageCode, 'FRONT1')) NameEs
	   ,dt.IdDocumentType
	   ,dt.IdType
	   ,dt.Name NameDocument
	FROM [DocumentImageType] d WITH (NOLOCK)
	LEFT JOIN [RelationDocumentImageType] r WITH (NOLOCK)
		ON d.IdDocumentImageType = r.IdDocumentImageType
	LEFT JOIN [DocumentTypes] dt WITH (NOLOCK)
		ON dt.IdDocumentType = r.IdDocumentType
	WHERE dt.IdDocumentType IN (SELECT
			dtt.IdDocumentType
		FROM DocumentTypes AS dtt WITH (NOLOCK)
		LEFT JOIN CustomerIdentificationType AS ci WITH (NOLOCK)
			ON ci.IdCustomerIdentificationType = dtt.IdDocumentType
		WHERE dtt.IdType = @IdType)
	ORDER by dt.IdDocumentType

	END

