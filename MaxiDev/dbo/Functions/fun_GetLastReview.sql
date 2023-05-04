-- =============================================
-- Author:		JPadilla
-- Create date: 2013-02-25
-- Description:	Returns the transfer's last review date
-- =============================================
CREATE FUNCTION [dbo].[fun_GetLastReview](@idTransfer as int)
RETURNS datetime
AS
BEGIN
	-- Declare the return variable here
	DECLARE @result as datetime

	-- Add the T-SQL statements to compute the return value here
	SELECT @result = MAX(Isnull(B.EnterDate,A.DateOfMovement))
	FROM TransferDetail A  (nolock)                      
	Left Join TransferNote B (nolock)   on (A.IdTransferDetail=B.IdTransferDetail)                          
	WHERE  IdTransfer=@idTransfer  

	-- Return the result of the function
	RETURN @result

END
