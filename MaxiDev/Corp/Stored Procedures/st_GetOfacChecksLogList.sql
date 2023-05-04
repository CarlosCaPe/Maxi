CREATE PROCEDURE [Corp].[st_GetOfacChecksLogList]
@CheckId int
AS
BEGIN
	
	-- Reviewed By
	SELECT 
		U.[FirstName] +' '+ U.[LastName] + ' ' + U.[SecondLastname] [DisplayName1]
		, COI.[DateOfRelease1] [ReleaseDate1]
		, CASE COI.[IdOFACAction1] WHEN 2 THEN 'Released' WHEN 3 THEN 'Rejected' ELSE '' END [ReleaseName1]
		, U2.[FirstName] +' '+ U2.[LastName] + ' ' + U2.[SecondLastname] [DisplayName2]
		, COI.[DateOfRelease2] [ReleaseDate2]
		, CASE COI.[IdOFACAction2] WHEN 2 THEN 'Released' WHEN 1 THEN 'Rejected' ELSE NULL END [ReleaseName2]
	FROM [dbo].[CheckOFACInfo] COI WITH (NOLOCK)
	JOIN [dbo].[Users] U WITH (NOLOCK) ON COI.[IdUserRelease1] = U.[IdUser]
	LEFT JOIN [dbo].[Users] U2 WITH (NOLOCK) ON COI.[IdUserRelease2] = U2.[IdUser]
	WHERE COI.[IdCheck] = @CheckId

	-- Consulted By
	SELECT
		U.[FirstName] +' '+ U.[LastName] + ' ' + U.[SecondLastname] [DisplayName]
		, COR.[DateOfReview]
	FROM [dbo].[CheckOFACReview] COR WITH (NOLOCK)
	JOIN [dbo].[Users] U WITH (NOLOCK) ON COR.[IdUserReview] = U.[IdUser]
	WHERE COR.[IdCheck] = @CheckId AND COR.[IdOFACAction] = 1

	
END
