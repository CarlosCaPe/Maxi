CREATE procedure [dbo].[st_GetSearchedCheckImageData]
@IdCheck int
AS
BEGIN
	--declare @IdCheck int=4136
	SELECT
		ch.IdIssuer as IdIssuer,
		ch.IdCheck as IdCheck,
		uf.LastCHange_LastNoteChange as Description,
		uf.FileName as FileName
	FROM
		Checks ch (nolock),
		UploadFiles uf (nolock)
	WHERE
		ch.idCheck=@IdCheck
		AND uf.IdReference=@IdCheck
		AND uf.IdDocumentType=69
END