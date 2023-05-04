-- =============================================
-- Author:		<Juan Diego Arellano>
-- Create date: <17 de julio de 2017>
-- Description:	<Procedimiento almacenado que se encarga de identificar las transferencias en estatus "Origin" por día.>
-- =============================================
CREATE PROCEDURE [Soporte].[sp_GetTransactionInOrigin]
	@FechaIni Datetime
AS
BEGIN
	
	declare @FechaFin Datetime
	--set @FechaFin=DATEADD(D,1,CONVERT(date,getdate()))
	set @FechaFin=DATEADD(MINUTE,-15,getdate())

	select 
		T.IdTransfer
	from 
		Transfer T with(nolock)
	where
		T.DateOfTransfer between @FechaIni and @FechaFin
		and		T.IdStatus=1
END
