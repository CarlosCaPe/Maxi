CREATE PROCEDURE [dbo].[st_GetFeeChecksHistoryDetail]
   @IdFee INT
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
FH.IdFeeChecksHistoryDetail, 
FH.IdFeeChecksDetail, 
FH.FromAmount, 
FH.ToAmount, 
FH.Fee, 
FH.IsFeePercentage, 
FH.DateOfLastChange, 
FH.EnterByIdUser, 
U.UserName
FROM            
FeeChecksHistoryDetail FH with(nolock) INNER JOIN
Users U with(nolock) ON FH.EnterByIdUser = U.IdUser
WHERE  IdFeeChecksDetail = @IdFee
order by DateOfLastChange desc 