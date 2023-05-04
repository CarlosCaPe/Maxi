CREATE PROCEDURE [Corp].[st_GetListUserSellers] 

AS 
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="06/10/2021" Author="jdarellano" Name="#1">Modificación para dar solución a ticket 848.</log>
</ChangeLog>
*********************************************************************/
BEGIN
	SET NOCOUNT ON;

	SELECT 
       [IdUser]
      ,[UserName]
      ,[UserLogin]
      ,[UserPassword]
      ,[IdUserType]
      ,[IdGenericStatus]
      ,[salt]
  FROM dbo.Users WITH (NOLOCK)
  WHERE IdUserType = 3
  AND IdGenericStatus IN (1, 3);--#1
END
