
CREATE procedure [dbo].[st_GetAgentHoldToReview]
@OfacOwnerChecked int out, 
@OfacBusinessChecked int out,
@OfacGuarantorChecked int out,
@OfacVerification int out

AS 


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


SELECT @OfacGuarantorChecked = COUNT(1)
from agentapplications ap
left join UploadAgentApp ua on ap.IdAgentApplication = ua.IdAgentApp
where IdAgentApplicationStatus = 5


select @OfacVerification = COUNT(1)
from agentapplications ap
left join UploadAgentApp ua on ap.IdAgentApplication = ua.IdAgentApp
where IdAgentApplicationStatus = 2


-- Exception
SELECT @OfacOwnerChecked = COUNT(1)
from agentapplications ap
left join UploadAgentApp ua on ap.IdAgentApplication = ua.IdAgentApp
where IdAgentApplicationStatus = 6

--Agreement
SELECT @OfacBusinessChecked = COUNT(1)
from agentapplications ap
left join UploadAgentApp ua on ap.IdAgentApplication = ua.IdAgentApp
where IdAgentApplicationStatus = 16





