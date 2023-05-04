
CREATE PROCEDURE [dbo].[st_GetFeeChecksDetail]
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
				IdFeeChecksDetail,
				IdFeeChecks,
				FromAmount,
				ToAmount,
				Fee,
				IsFeePercentage


		 FROM	FeeChecksDetail with(nolock)
		 WHERE  IdFeeChecks = @IdFee
