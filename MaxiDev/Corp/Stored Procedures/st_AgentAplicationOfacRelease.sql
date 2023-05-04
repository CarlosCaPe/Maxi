CREATE PROCEDURE [Corp].[st_AgentAplicationOfacRelease]
(
    @IdAgentApplication int,
    @IdOfacChecked int, --bussines 1, Gurantor 2, owner 3
    @OfacBusinessChecked bit
)
as

/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

if @IdOfacChecked = 1 
    update AgentApplications set OfacBusinessChecked=@OfacBusinessChecked where IdAgentApplication=@IdAgentApplication;

if @IdOfacChecked = 2
    update AgentApplications set OfacGuarantorChecked=@OfacBusinessChecked where IdAgentApplication=@IdAgentApplication;

if @IdOfacChecked = 3
    update AgentApplications set OfacOwnerChecked=@OfacBusinessChecked where IdAgentApplication=@IdAgentApplication;
    
if @IdOfacChecked = 4
    UPDATE AgentApplications SET OfacComplianceOfficerChecked=@OfacBusinessChecked where IdAgentApplication=@IdAgentApplication;

