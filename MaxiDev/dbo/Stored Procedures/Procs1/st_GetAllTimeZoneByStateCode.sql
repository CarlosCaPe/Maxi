
CREATE PROCEDURE [dbo].[st_GetAllTimeZoneByStateCode]
(
    @StateCode VARCHAR(MAX)
)
AS

SET NOCOUNT ON          
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 

SELECT T.IdTimeZone, T.TimeZone 
  FROM TimeZone T 
 INNER JOIN RelationTimeZoneState RS ON RS.IdTimeZone = T.IdTimeZone
 WHERE RS.IdState in (SELECT IdState FROM State WHERE StateCode = @StateCode)
