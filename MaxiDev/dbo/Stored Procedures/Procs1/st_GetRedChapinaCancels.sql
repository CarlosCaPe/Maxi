create procedure [dbo].[st_GetRedChapinaCancels]        
as        
Set Nocount on       
select
 t.claimcode ID_OPERACION ,
 '' CORRELATIVO_ID,
 'Solicitud de Cancelacion' RAZON_ANULACION ,
 'Solicitud de Cancelacion' COMENTARIO_ANULACION ,
 CONVERT(VARCHAR(10), t.dateoftransfer, 120) FECHA_VENTA,
 CONVERT(VARCHAR(5), t.dateoftransfer, 108) HORA_VENTA
from transfer t
Where IdGateway=18 and IdStatus=25


--select
-- '1' ID_OPERACION ,
-- '' CORRELATIVO_ID ,
-- 'ad' RAZON_ANULACION ,
-- 'detalle' COMENTARIO_ANULACION ,
-- '2013-01-04' FECHA_VENTA ,
-- '18:00' HORA_VENTA 