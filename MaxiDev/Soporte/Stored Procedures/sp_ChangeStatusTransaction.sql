
CREATE PROCEDURE [Soporte].[sp_ChangeStatusTransaction]
	@Claimcode varchar(30),
	@Note varchar (max),
	@IdStatus int,
	@Confirm bit=0
AS 

/********************************************************************
<Author>Juan Diego Arellano</Author>
<app>---</app>
<Description>Procedimiento almacenado que aplica cambio de estatus a envíos con su respectivo detalle y nota.</Description>

<ChangeLog>
<log Date="27/09/2018" Author="jdarellano">Creación</log>
</ChangeLog>
*********************************************************************/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;       

BEGIN

	declare @IdTransfer int=(select IdTransfer from dbo.[Transfer] with (nolock) where ClaimCode=@Claimcode)

	select * from dbo.[Transfer] with (nolock) where IdTransfer=@IdTransfer

	select * from dbo.TransferDetail with (nolock) where IdTransfer=@IdTransfer order by 1 desc

	select * from dbo.TransferNote with (nolock) where IdTransferDetail in (select IdTransferDetail from dbo.TransferDetail with (nolock) where IdTransfer=@IdTransfer) order by 1 desc


	begin tran

		update dbo.[Transfer] set IdStatus=@IdStatus, DateStatusChange=GETDATE() where IdTransfer=@IdTransfer

		insert into dbo.TransferDetail
			select IdStatus,IdTransfer,DateStatusChange
			from dbo.[Transfer] with (nolock)
			where IdTransfer=@IdTransfer

		insert into dbo.TransferNote
			select IdTransferDetail,3,37,@Note,DateOfMovement
			from dbo.TransferDetail with (nolock)
			where IdTransferDetail=(select MAX(IdTransferDetail) from dbo.TransferDetail with (nolock) where IdTransfer=@IdTransfer and IdStatus=@IdStatus)


		select * from dbo.[Transfer] with (nolock) where IdTransfer=@IdTransfer

		select * from dbo.TransferDetail with (nolock) where IdTransfer=@IdTransfer order by 1 desc

		select * from dbo.TransferNote with (nolock) where IdTransferDetail in (select IdTransferDetail from dbo.TransferDetail with (nolock) where IdTransfer=@IdTransfer) order by 1 desc

	if (@Confirm=0)
		rollback
	else
		commit


END


