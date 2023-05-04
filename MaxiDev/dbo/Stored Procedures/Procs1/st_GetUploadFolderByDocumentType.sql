CREATE PROCEDURE st_GetUploadFolderByDocumentType
(
	@DocumentTypeId	INT
)
AS
BEGIN
	DECLARE @IdType				INT,
			@GlobalAttrubuteKey	NVARCHAR(50)


	SELECT
		@IdType = dt.IdType,
		@GlobalAttrubuteKey = CASE dt.IdType
			WHEN 1 THEN 'CustomerPath'
			WHEN 2 THEN 'AgentPath'
			WHEN 3 THEN 'AgentAppPath'
			WHEN 4 THEN 'TransferPath'
			WHEN 5 THEN 'CollectByFaxPath'
			WHEN 6 THEN 'IssuerCheckPath'
		END
	FROM DocumentTypes dt 
	WHERE dt.IdDocumentType = @DocumentTypeId

	SELECT 
		@IdType		IdType,
		ga.Value	FolderPath
	FROM GlobalAttributes ga WITH(NOLOCK) WHERE ga.Name = @GlobalAttrubuteKey
END