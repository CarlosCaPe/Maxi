CREATE FUNCTION dbo.GetUploadFilePath
(
	@IdUploadFile INT
)
RETURNS VARCHAR(1000)
AS
BEGIN

	DECLARE @IdReference			INT,
			@IdDocumentType			INT,
			@Path					VARCHAR(1000),
			@FileName				VARCHAR(100),
			@Extension				VARCHAR(100)


	SELECT
		@IdReference = uf.IdReference,
		@IdDocumentType = uf.IdDocumentType,
		@FileName = uf.FileGuid,
		@Extension = uf.Extension
	FROM UploadFiles uf WITH(NOLOCK)
	WHERE uf.IdUploadFile = @IdUploadFile

	SET @Path = dbo.GetFolderPathByDocumentType(@IdDocumentType, @IdReference)
	SET @Path = CONCAT(@Path, '\', @FileName, @Extension)

	RETURN @Path

END