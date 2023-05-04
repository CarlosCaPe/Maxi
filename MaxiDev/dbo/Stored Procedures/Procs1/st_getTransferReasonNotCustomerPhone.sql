/********************************************************************
<Author>Miguel Prado</Author>
<date>19/Octubre/2022</date>
<app>MaxiAgente</app>
<Description>Sp para obtener TransferReasonNotCustomerPhone en base a un IdPretransfer</Description>
*********************************************************************/
CREATE PROCEDURE [dbo].[st_getTransferReasonNotCustomerPhone]
@IdPreTransfer	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT [IdTransferReasonNotCustomerPhone]
      ,[IdPreTransfer]
      ,[IdTransfer]
      ,[IdReasonNotCustomerCellphone]
      ,[NoteReasonNotCustomerPhone]
      ,[EnterByIdUser]
	FROM [TransferReasonNotCustomerPhone] WITH (NOLOCK)
	WHERE [IdPreTransfer] = @IdPreTransfer;

	SET NOCOUNT OFF;
END
