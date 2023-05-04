
-- =============================================
-- Author:		el pep
-- Create date: 2013-02-08
-- Description: Returns a string representing transfer's hold status
-- =============================================
CREATE FUNCTION [dbo].[fun_GetTransferHoldSemaphore]
(
	-- Add the parameters for the function here
	@IdTransfer Int
)
RETURNS NVARCHAR(50)
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
	DECLARE @Result NVARCHAR(50)

	-- Add the T-SQL statements to compute the return value here


SELECT @Result =
	CASE WHEN [1] IS NULL THEN '0' ELSE 'S,G' END + '|' + 
	CASE WHEN [2] IS NULL THEN '0' ELSE 'A,B' END + '|' + 
	CASE WHEN [3] IS NULL THEN '0' ELSE 'K,R' END + '|' + 
	CASE WHEN [4] IS NULL THEN '0' ELSE 'D,R' END + '|' + 
	CASE WHEN [5] IS NULL THEN '0' ELSE 'O,R' END + '|' +
	CASE WHEN [6] IS NULL THEN '0' ELSE 'DP,T' END 
FROM(
	Select distinct
		CASE 
		    WHEN TH.IdStatus =3   THEN 1	--Signature Hold
			WHEN TH.IdStatus =6   THEN 2	--AR Hold
			WHEN TH.IdStatus =9   THEN 3	--KYC Hold
			WHEN TH.IdStatus =12  THEN 4	--Deny List Hold
			WHEN TH.IdStatus =15  THEN 5	--OFAC Hold
			WHEN TH.IdStatus =18  THEN 6	--Deposit Hold
			ELSE 0
		END	as Semaphore	
	From [Transfer] T WITH(NOLOCK) 
		inner join [TransferHolds] TH WITH(NOLOCK) on T.IdTransfer = TH.IdTransfer	
		Where T.IdStatus = 41 		
			and TH.IsReleased is null
			and T.IdTransfer = @IdTransfer
	) sem
PIVOT (
		Max(Semaphore) FOR Semaphore IN ([1], [2], [3],[4], [5], [6])
	) p

	-- Return the result of the function
	RETURN ISNULL(@Result,'0|0|0|0|0|0')

END
