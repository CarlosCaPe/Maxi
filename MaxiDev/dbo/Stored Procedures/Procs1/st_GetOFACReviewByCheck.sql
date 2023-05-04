CREATE procedure [dbo].[st_GetOFACReviewByCheck]
(
	@IdCheck int
)
as 
set nocount on

;with cte as (
SELECT
    p.IdCheckOFACReview,
    p.IdCheck,
    p.IdUserReview,
    p.DateOfReview,
    ROW_NUMBER() OVER (PARTITION BY  p.IdCheck,p.IdUserReview ORDER BY DateOfReview desc) AS firstValue
FROM
    CheckOFACReview p
WHERE        (p.IdCheck = @IdCheck)
 and (p.IdOFACAction =1)
) 
SELECT IdCheckOFACReview,IdCheck,IdUserReview,UserName,DateOfReview from cte 
INNER JOIN Users ON IdUserReview = Users.IdUser
WHERE firstValue=1 Order by DateOfReview desc