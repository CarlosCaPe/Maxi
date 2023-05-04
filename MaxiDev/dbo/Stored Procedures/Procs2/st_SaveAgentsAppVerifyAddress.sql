--exec [dbo].[st_SaveAgentsAppVerifyAddress]  3873

create PROCEDURE [dbo].[st_SaveAgentsAppVerifyAddress] 

	-- Add the parameters for the stored procedure here

	@IdApp INT

AS

/********************************************************************
<Author>adominguez</Author>
<app>MaxiCorp</app>
<Description>This stored update field IsVerifiedAddress</Description>

<ChangeLog>
<log Date="17/10/2018" Author="adominguez">Create</log>
<log Date="17/10/2018" Author="adominguez">Change Field to return</log>
</ChangeLog>
********************************************************************/



BEGIN TRY

	update AgentApplications set IsVerifiedAddress = 1 where IdAgentApplication = @IdApp

END TRY
BEGIN CATCH
	DECLARE @ErroMessage varchar(max) = ERROR_MESSAGE()
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_SaveAgentsAppVerifyAddress', GETDATE(), @ErroMessage)
END CATCH