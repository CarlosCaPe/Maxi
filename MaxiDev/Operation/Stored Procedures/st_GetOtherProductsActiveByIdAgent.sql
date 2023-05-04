create procedure operation.st_GetOtherProductsActiveByIdAgent
(
    @IdAgent int
)
as
select ap.IdOtherProducts,op.Description
from 
    AgentProducts ap
left join
    OtherProducts op on ap.IdOtherProducts=op.IdOtherProducts
where 
    idagent=@IdAgent  and idgenericstatus=1