
CREATE PROCEDURE [Soporte].[sp_CheckStatusChangeOfPendingToStandby]
AS

/********************************************************************
<Author>Juan Diego Arellano</Author>
<app>---</app>
<Description>Procedimiento almacenado que cambia el estatus de los cheques que se quedan en estatus de "Pending Gateway Response", a estatus "Stand by".</Description>

<ChangeLog>
<log Date="29/05/2018" Author="jdarellano">Creación.</log>
</ChangeLog>
*********************************************************************/

BEGIN
	
	select IdCheck 
	into #tmp 
	from [dbo].[Checks] with(nolock)
	where IdStatus=21

	update [dbo].[Checks] 
	set IdStatus=20, 
		IdCheckBundle= null, 
		IdCheckCredit= null, 
		IdCheckProcessorBank= null 
	where IdCheck in (select idcheck from #tmp with (nolock))


	insert into CheckDetails
		select idcheck,20,GETDATE(),'Stand By by System',37 from #tmp

	drop table #tmp

END
