create procedure [dbo].[st_GetServiCentroCancel]
as
select
    IdServiCentro ConsecutivoCorresponsal,    
    ClaimCode ReferenciaAuxiliarCorresponsal,
    CustomerName+' '+CustomerFirstLastName+' '+CustomerSecondLastName NombreRemitente,    
    AmountInDollars ValordelGiroenDolares,
    isnull(r.reason,'') Motivo
from transfer t
join payer p on t.idpayer=p.idpayer
join ServiCentroSerial s on t.idtransfer=s.idtransfer
left join ReasonForCancel r on t.IdReasonForCancel=r.IdReasonForCancel
where idgateway=19 and idstatus=25