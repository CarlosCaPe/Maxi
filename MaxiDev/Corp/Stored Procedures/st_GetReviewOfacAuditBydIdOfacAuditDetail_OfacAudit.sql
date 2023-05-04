CREATE PROCEDURE [Corp].[st_GetReviewOfacAuditBydIdOfacAuditDetail_OfacAudit]
(
    @IdOfacAuditDetail int
)
as
select IdOfacAuditDetail,SDN_NAME from [OfacAudit].[OfacAuditMatchReview] with(nolock) where IdOfacAuditDetail=@IdOfacAuditDetail order by SDN_NAME
select IdOfacAuditDetail,IdUserReview,username,DateOfReview from [OfacAudit].[OfacAuditReview] r with(nolock) join users u with(nolock) on u.iduser=r.IdUserReview where IdOfacAuditDetail=@IdOfacAuditDetail order by DateOfReview,username
