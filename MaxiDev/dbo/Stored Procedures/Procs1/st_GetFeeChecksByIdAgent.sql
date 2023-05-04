
CREATE PROCEDURE [dbo].[st_GetFeeChecksByIdAgent]
       @IdAgent INT
AS 

		SELECT 
				IdFeeChecks,
				IdAgent,
                AllowChecks,
				FeeName,
				TransactionFee,
				ReturnCheckFee,
				FeeCheckScanner
		 FROM	FeeChecks WITH(NOLOCK)
		 WHERE  IdAgent = @IdAgent;

