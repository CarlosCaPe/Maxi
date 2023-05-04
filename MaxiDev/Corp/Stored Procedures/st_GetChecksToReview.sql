CREATE procedure [Corp].[st_GetChecksToReview]
@OfacChecks int out, 
@DenyChecks int out,
@EndorseChecks int out,
@DuplicateChecks int out,
@EditedChecks int out

as 

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2020/01/13" Author="jgomez"> Fix: Ticket 2058 - No se muestran notificaciones de cheques en Corp</log>
</ChangeLog>

********************************************************************/  

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


SELECT @DenyChecks = CONVERT(int,COUNT(1)) FROM CheckHolds CH
INNER JOIN Checks C on (C.IdCheck = CH.IdCheck )
WHERE CH.IsReleased is NULL AND CH.IdStatus = 12 and C.IdStatus = 41 

SELECT @OfacChecks = isnull(Count(DISTINCT CH.IdCheck), 0) FROM CheckHolds CH
INNER JOIN Checks C on (C.IdCheck = CH.IdCheck )
WHERE CH.IsReleased is NULL AND CH.IdStatus = 15 and C.IdStatus = 41 
GROUP BY CH.IdCheck

SELECT @EndorseChecks = CONVERT(int,COUNT(1)) FROM CheckHolds CH
INNER JOIN Checks C on (C.IdCheck = CH.IdCheck )
WHERE CH.IsReleased is NULL AND CH.IdStatus = 57 and C.IdStatus = 41 

SELECT @DuplicateChecks = CONVERT(int,COUNT(1)) FROM CheckHolds CH
INNER JOIN Checks C on (C.IdCheck = CH.IdCheck )
WHERE CH.IsReleased is NULL AND CH.IdStatus = 61 and C.IdStatus = 41 

SELECT @EditedChecks = CONVERT(int,COUNT(1)) FROM CheckHolds CH
INNER JOIN Checks C on (C.IdCheck = CH.IdCheck )
WHERE CH.IsReleased is NULL AND CH.IdStatus = 64 and C.IdStatus = 41 


SELECT @OfacChecks = isnull(@OfacChecks, 0)
