CREATE PROCEDURE  [Corp].[st_GetAgentMonitorCallHistory] 
(@from datetime
,@to datetime
,@idAgent int
)
	as
BEGIN

	SET NOCOUNT ON;

	Declare @SysUser int
	Set @SysUser = (select Value from GlobalAttributes with (nolock) where name = 'SystemUserID')

SELECT
CH.[IdCallHistory]
      ,CH.[IdAgent]
      ,CH.[IdUser]
      ,CH.[IdCallStatus]
      ,CH.[DateOfLastChange]
      ,CH.[Note]
      ,CH.[IsDirectMessage]
	  ,CS.Description
	  ,U.UserName
  FROM [dbo].[CallHistory] CH with (nolock)
  INNER JOIN  dbo.CallStatus CS with (nolock) ON CS.IdCallStatus= CH.IdCallStatus
  INNER JOIN dbo.Users U with (nolock) ON U.IdUser= CH.IdUser
  WHERE CH.IdAgent=@idAgent 
  AND CH.[DateOfLastChange]> @from
  AND CH.[DateOfLastChange]<=@to
  AND (CH.IdCallStatus !=2 OR U.IdUser != @SysUser) /* system user */
  ORDER BY CH.DateOfLastChange DESC
END
