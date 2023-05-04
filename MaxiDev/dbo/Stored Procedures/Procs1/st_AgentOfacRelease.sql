CREATE procedure [dbo].[st_AgentOfacRelease]
(
    @IdAgent int,
    @IdOfacChecked int, --bussines 1, Gurantor 2, owner 3
    @OfacBusinessChecked bit
)
as

if @IdOfacChecked = 1 
    update Agent set OfacBusinessChecked=@OfacBusinessChecked where IdAgent=@IdAgent;

if @IdOfacChecked = 2
    update Agent set OfacGuarantorChecked=@OfacBusinessChecked where IdAgent=@IdAgent;

if @IdOfacChecked = 3
    update Agent set OfacOwnerChecked=@OfacBusinessChecked where IdAgent=@IdAgent;