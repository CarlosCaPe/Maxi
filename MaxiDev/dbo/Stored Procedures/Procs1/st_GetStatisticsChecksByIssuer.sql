CREATE procedure [dbo].[st_GetStatisticsChecksByIssuer]
(	@IdIssuer int) AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

 --Issuer Accepted
select count(idstatus) as TotalChecks, IdStatus as Status
  from Checks chks
 /* INNER JOIN @InvolvedIssuers iss
  ON iss.idIssuer = chks.IdIssuer
  */
  where IdStatus in (30,31)
--  AND chks.IssuerName = @IssuerName
  and IdIssuer = @IdIssuer
  --and DateStatusChange >= dateadd(day,-30,getDate())
  group by  idstatus

