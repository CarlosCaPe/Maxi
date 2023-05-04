CREATE procedure [OfacAudit].st_GetReviewOfacAuditBydIdOfacAuditDetail
(
    @IdOfacAuditDetail int
)
as
select IdOfacAuditDetail,SDN_NAME from [OfacAudit].[OfacAuditMatchReview] where IdOfacAuditDetail=@IdOfacAuditDetail order by SDN_NAME
select IdOfacAuditDetail,IdUserReview,username,DateOfReview from [OfacAudit].[OfacAuditReview] r join users u on u.iduser=r.IdUserReview where IdOfacAuditDetail=@IdOfacAuditDetail order by DateOfReview,username