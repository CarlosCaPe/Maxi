CREATE PROCEDURE [Corp].[st_AgentOfacRelease]
(
    @IdAgent int,
    @IdOfacChecked int, --bussines 1, Gurantor 2, owner 3, Compliance Officer 4
    @OfacBusinessChecked bit
)
AS

/********************************************************************
<Author>Unknown</Author>
<app>Corporative (Chronos)</app>
<Description></Description>

<ChangeLog>
<log Date="27/01/2023" Author="cagarcia">BM-583 Se agrega opcion 4 - Compliance Officer</log>
</ChangeLog>
*********************************************************************/

if @IdOfacChecked = 1 
    update Agent set OfacBusinessChecked=@OfacBusinessChecked where IdAgent=@IdAgent;

if @IdOfacChecked = 2
    update Agent set OfacGuarantorChecked=@OfacBusinessChecked where IdAgent=@IdAgent;

if @IdOfacChecked = 3
    update Agent set OfacOwnerChecked=@OfacBusinessChecked where IdAgent=@IdAgent;
    
IF @IdOfacChecked = 4
	UPDATE Agent SET OfacComplianceOfficerChecked = @OfacBusinessChecked WHERE IdAgent = @IdAgent

