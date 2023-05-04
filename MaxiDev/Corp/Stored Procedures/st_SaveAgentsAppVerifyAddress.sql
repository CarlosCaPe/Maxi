CREATE PROCEDURE [Corp].[st_SaveAgentsAppVerifyAddress]

	-- Add the parameters for the stored procedure here

	@IdApp INT

AS

-- =============================================

-- Author:		Abraham Dominguez

-- Create date: 2018-10-17

-- Description:	This stored update field IsVerifiedAddress

-- =============================================



BEGIN

	update AgentApplications set IsVerifiedAddress = 1 where IdAgentApplication = @IdApp

END
