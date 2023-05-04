/***************************/
/* fun_GetIdTransferDetail */
/***************************/
CREATE FUNCTION [dbo].[fun_GetIdTransferDetail](@idTransfer as int)
RETURNS int
AS
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
BEGIN
	-- Declare the return variable here
	Declare @IdTransferDetail int
	
	Select  top 1 @IdTransferDetail=IdTransferDetail from [Transfer] T WITH(NOLOCK)
	join TransferDetail Td WITH(NOLOCK) on (td.IdTransfer = t.IdTransfer and td.IdStatus = t.IdStatus) 
	Where T.IdTransfer=@IdTransfer  Order by IdTransferDetail desc  

	If @IdTransferDetail is null
	Begin
		Select top 1 @IdTransferDetail=IdTransferDetail from TransferDetail WITH(NOLOCK)
		Where IdTransfer = @IdTransfer Order by IdTransferDetail desc
	End

	Return @IdTransferDetail
END
