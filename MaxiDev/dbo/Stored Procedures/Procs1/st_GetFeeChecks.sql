CREATE PROCEDURE [dbo].[st_GetFeeChecks] 
@IdAgent INT

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


 DECLARE @TypeAgent INT
 SET @TypeAgent = (SELECT TOP 1 IdAgentType FROM Agent with(nolock) WHERE IdAgent = @IdAgent)

--IF (1 = @TypeAgent)
--BEGIN

SELECT  F.IdAgent, 
			F.IdFeeChecks, 
			F.TransactionFee, 
			FC.Fee, 
			FC.FromAmount, 
			FC.ToAmount,
			@TypeAgent AS TypeAgent,
			IsFeePercentage
	FROM FeeChecks AS F with(nolock)
	inner JOIN FeeChecksDetail AS FC with(nolock) ON (F.IdFeeChecks = FC.IdFeeChecks )
	WHERE IdAgent = @IdAgent

--END
--ELSE
--BEGIN
--	SELECT  F.IdAgent, 
--			F.IdFeeChecks, 
--			F.TransactionFee, 
--			FC.Fee, 
--			FC.FromAmount, 
--			FC.ToAmount,
--			@TypeAgent AS TypeAgent
--	FROM FeeChecks AS F
--	inner JOIN FeeChecksDetail AS FC ON (F.IdFeeChecks = FC.IdFeeChecks )
--	WHERE IdAgent = @IdAgent
--END

