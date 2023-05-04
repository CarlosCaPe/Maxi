CREATE  PROCEDURE [dbo].[st_GetFeeChecksHistory] 
@IdFee INT,
@FeeType VARCHAR(50)
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

SELECT        
FH.IdFeeChecksHistory, 
FH.IdFeeChecks, 
FH.FeeType, 
FH.Fee, 
FH.DateOfLastChange, 
FH.EnterByIdUser, 
U.UserName
FROM            
FeeChecksHistory FH with(nolock) INNER JOIN
Users U with(nolock) ON FH.EnterByIdUser = U.IdUser
WHERE FH.IdFeeChecks = @IdFee AND FH.FeeType = @FeeType
ORDER BY DateOfLastChange DESC 

