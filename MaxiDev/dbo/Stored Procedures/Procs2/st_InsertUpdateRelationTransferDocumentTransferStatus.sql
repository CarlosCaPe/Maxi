CREATE PROCEDURE [dbo].[st_InsertUpdateRelationTransferDocumentTransferStatus]
(
	@IdTransfer INT, 
	@IdDocumentTransfertStatus INT,
	@IdUser INT,
	@IsTransferReceipt BIT
)
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY
SET NOCOUNT ON;

IF (SELECT 1 FROM RelationTransferDocumentStatus with(nolock) WHERE idtransfer = @IdTransfer AND IsTransferReceipt = @IsTransferReceipt) > 0
BEGIN
	UPDATE RelationTransferDocumentStatus SET IdDocumentTransfertStatus = @IdDocumentTransfertStatus, IdUserLastChange = @IdUser, DateLastChange = GETDATE() WHERE IdTransfer = @IdTransfer AND IsTransferReceipt = @IsTransferReceipt;
	-- Se obtienen todas las transferencias que esten sin leer del cliente para marcarlas como leidas
	IF @IdDocumentTransfertStatus = 2 AND @IsTransferReceipt = 0
	BEGIN
		UPDATE st
		SET st.IdDocumentTransfertStatus = @IdDocumentTransfertStatus, 
		st.IdUserLastChange = @IdUser, 
		st.DateLastChange = GETDATE() 
		FROM [Transfer] t JOIN RelationTransferDocumentStatus st
		ON t.IdTransfer = st.IdTransfer AND st.IsTransferReceipt = @IsTransferReceipt AND t.IdCustomer = (SELECT TOP 1 idCustomer FROM [Transfer] with(nolock) WHERE IdTransfer = @IdTransfer) AND st.IdDocumentTransfertStatus = 1;
	END
END
ELSE
BEGIN
	if(@IdDocumentTransfertStatus = 3)
	begin
		if(select top 1 1 from [Transfer] t with(nolock)
			join RelationTransferDocumentStatus r with(nolock)
			on t.idtransfer = r.idtransfer AND r.IsTransferReceipt = @IsTransferReceipt
			where t.idcustomer in (select idcustomer from [Transfer] with(nolock) where idtransfer = @IdTransfer) and r.IdDocumentTransfertStatus = 1) > 0
		begin
			insert into RelationTransferDocumentStatus values (@IdTransfer, 1, @IdUser, GETDATE(), @IdUser, GETDATE(), @IsTransferReceipt); -- Inserta estatus sin leer
		end
		else
		begin
			insert into RelationTransferDocumentStatus values (@IdTransfer, @IdDocumentTransfertStatus, @IdUser, GETDATE(), @IdUser, GETDATE(), @IsTransferReceipt); -- Inserta status usado
		end
	end
	else
	begin
		insert into RelationTransferDocumentStatus values (@IdTransfer, @IdDocumentTransfertStatus, @IdUser, GETDATE(), @IdUser, GETDATE(), @IsTransferReceipt); -- Inserta status sin leer o leido
	end
END





END TRY
BEGIN CATCH
	DECLARE @ErrorMessage varchar(max) = ERROR_MESSAGE();
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_InsertUpdateRelationTransferDocumentTransferStatus', GETDATE(), @ErrorMessage)
END CATCH
