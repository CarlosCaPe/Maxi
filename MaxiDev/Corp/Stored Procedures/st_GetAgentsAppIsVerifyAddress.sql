CREATE PROCEDURE [Corp].[st_GetAgentsAppIsVerifyAddress] 

	-- Add the parameters for the stored procedure here

	@IdApp INT

AS

/********************************************************************
<Author>adominguez</Author>
<app>MaxiCorp</app>
<Description>This stored gets field IsVerifiedAddress</Description>

<ChangeLog>
<log Date="17/10/2018" Author="adominguez">Create</log>
</ChangeLog>
********************************************************************/



BEGIN

	

	Select IsVerifiedAddress from AgentApplications WITH(NOLOCK) where IdAgentApplication = @IdApp

	--Select IsVerifiedAddress = 1



END
