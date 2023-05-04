CREATE FUNCTION [dbo].[GetFolderPathByDocumentType]
(
	@IdDocumentType			INT,
	@IdReference			INT
)
RETURNS VARCHAR(1000)
AS
BEGIN
	DECLARE @GlobalAttrubuteKey		VARCHAR(100),
			@Path					VARCHAR(1000),
			@IdOwnerType			INT

	SELECT
		@GlobalAttrubuteKey = CASE dt.IdType
			WHEN 1 THEN 'CustomerPath'
			WHEN 2 THEN 'AgentPath'
			WHEN 3 THEN 'AgentAppPath'
			WHEN 4 THEN 'TransferPath'
			WHEN 5 THEN 'CollectByFaxPath'
			WHEN 6 THEN 'IssuerCheckPath'
			WHEN 7 THEN 'ComplianceTrainingPath'
		END,
		@IdOwnerType = dt.IdType
	FROM DocumentTypes dt WITH(NOLOCK) 
	WHERE dt.IdDocumentType = @IdDocumentType


	SELECT 
		@Path = ga.Value
	FROM GlobalAttributes ga WITH(NOLOCK) 
	WHERE ga.Name = @GlobalAttrubuteKey

	IF @Path LIKE '%\'
		SET @Path = SUBSTRING(@Path, 0, LEN(@Path))

	IF @IdOwnerType = 6
	BEGIN
		DECLARE @IdIssuer INT
		SELECT @IdIssuer = c.IdIssuer FROM Checks c WITH(NOLOCK) WHERE c.IdCheck = @IdReference
	
		SET @Path = CONCAT(@Path, '\', @IdIssuer, '\Checks')
	END

	SET @Path = CONCAT(@Path, '\', @IdReference)

	RETURN @Path
END