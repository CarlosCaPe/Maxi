CREATE PROCEDURE [dbo].[st_GetAditionalInfo]
(
    @IdUser int
)
AS
/********************************************************************
<Author>mhinojo</Author>
<app>Corporate and Agent</app>
<Description>Get Aditional info</Description>

<ChangeLog>
<log Date="23/07/2018" Author="mhinojo">Create SP</log>
</ChangeLog>
*********************************************************************/
SELECT IdUser, DateOfChangeLastPassword, AttemptsToLogin
  FROM dbo.UsersAditionalInfo with(nolock)
 WHERE 1 = 1
   AND IdUser = @IdUser

