CREATE procedure [dbo].[st_GetSearchedCustomerPictureData]
@IdCustomer int
AS
BEGIN
	--declare @IdCheck int=4136
	SELECT TOP 1
		U.LastCHange_LastNoteChange as Description,
		U.FileName as FileName
	FROM
		UploadFiles AS U WITH(NOLOCK)
	WHERE
		U.IdReference=@IdCustomer
		AND U.IdDocumentType = 70;
		
END