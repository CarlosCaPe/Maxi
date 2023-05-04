create procedure st_GetTicketInfo
(
    @IdProduct int,
    @IdTransaction int
)
as

select 
    t.IdTicket,
    t.IdPriority,
    t.IdProduct,
    t.IdStatus,
    t.IdTicketCloseReason,
    t.IdTransaction,
    t.IdUser,
    t.Note,    
    p.Description PriorityDescription,
    isnull(c.Description,'') TicketCloseReasonDescription,
    t.TicketDate,
    u.UserName,
    p.value PriorityValue, 
    o.Description ProductDescription,
    t.Reference Reference,
    t.OperationDate,
    t.IdAgent,
    a.AgentCode,
    a.AgentName
from tickets t
join TicketPriorities p on t.IdPriority=p.IdTicketPriority
left join TicketCloseReasons c on t.IdTicketCloseReason=c.IdTicketCloseReason
join users u on t.iduser=u.iduser
join otherproducts o on t.IdProduct=o.IdOtherProducts
join agent a on t.idagent=a.idagent
where t.idproduct=@IdProduct and t.IdTransaction=@IdTransaction

select c.IdTicketDetails,c.IdTicket,c.IdUser,c.Note,c.NoteDate,UserName 
from TicketDetails c 
join users u on c.iduser=u.iduser
where idticket in (select t.IdTicket from tickets t where t.idproduct=@IdProduct and t.IdTransaction=@IdTransaction)
