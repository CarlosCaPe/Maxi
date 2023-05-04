CREATE PROCEDURE [dbo].[st_GetStatusARHold]
@IdStatus int out
as
EXEC @IdStatus = [st_GetTransfersByHoldStatus] @IdStatus = 6  
select @IdStatus = @@ROWCOUNT 

