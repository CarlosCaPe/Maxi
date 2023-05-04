CREATE PROCEDURE Corp.st_GetOfacValidationDetail
	@IdOfacValidation	INT,
	@Status				NVARCHAR(50),
	@Type				INT,
	@Name				NVARCHAR(100)
AS
BEGIN
	
	SELECT OD.IdOfacValidationDetail, 
		OD.Name, 
		S.Name AS 'GeneralStatus', 
		E.Name AS 'Entitytype', 
		isnull(U.UserNAme, '') AS ChangeStatusUserName, 
		OD.DateOfApproval,
		OD.StatusChangeNote,
		OD.DateOfBirth,
		OD.CountryOfBirth
	FROM Corp.OfacValidationDetail OD WITH(NOLOCK) INNER JOIN
		Corp.OfacValidationEntityType E WITH(NOLOCK) ON E.IdOfacValidationEntityType = OD.IdOfacValidationEntityType INNER JOIN
		Corp.OfacValidationStatus S WITH(NOLOCK) ON S.Code = OD.GeneralStatus LEFT JOIN
		Users U WITH(NOLOCK) ON U.IdUser = OD.IdUserApprove
	WHERE OD.IdOfacValidation = @IdOfacValidation
		AND OD.Name LIKE '%' + @Name + '%'
		AND (OD.IdOfacValidationEntityType = @Type OR isnull(@Type, 0) = 0)
		AND (OD.GeneralStatus = @Status OR isnull(nullif(@Status, ''), 'All') = 'All')
	
	
END

