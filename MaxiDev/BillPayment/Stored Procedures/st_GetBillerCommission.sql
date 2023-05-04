
CREATE PROCEDURE [BillPayment].[st_GetBillerCommission]
(
    @IdAgent int
    ,@IdBiller int
)
AS
/********************************************************************
<Author></Author>
<app>MaxiCorp</app>
<Description>Get Commission Biller</Description>
<ChangeLog>
<log Date="16/08/2018" Author="snevarez">Creation</log>
<log Date="16/08/2018" Author="azavala">Add IdAgent Filter</log>
</ChangeLog>
*************************/
BEGIN

    SET NOCOUNT ON;

    Begin try
 
	   Declare @IdCommission int;
	   Declare @CommissionSpecial varchar(MAX)
	   SET @CommissionSpecial = '0';
 
	   IF EXISTS(Select 1 From BillPayment.AgentForBillers WITH(NOLOCK)
				 Where idbiller = @IdBiller
				 and @IdAgent=IdAgent
				    And idStatus= 1)
	   BEGIN

		  DECLARE @DateForCommision DATETIME;

		  SELECT
			 @IdCommission	= IdCommission
			 ,@CommissionSpecial = Convert(varchar,CommionSpecial)
			 ,@DateForCommision = DateForCommision
		  FROM
			 BillPayment.AgentForBillers 
		  WHERE
			 idbiller = @IdBiller
				 and @IdAgent=IdAgent
			 AND idStatus = 1;

		  IF (@DateForCommision < GETDATE())
		  BEGIN
			 Set @CommissionSpecial  = '0';
		  END

	   END
	   ELSE
	   BEGIN
		  
		  DECLARE @IdState INT;
		  Select @IdState = IdState From [State] AS S WITH(NOLOCK)
			 Inner Join Agent AS A WITH(NOLOCK) On S.StateCode = A.AgentState
			 WHERE A.IdAgent = @IdAgent;

		  Select
			 @IdCommission = SB.IdCommission 
		  From BillPayment.Billers AS B WITH(NOLOCK)
			 Inner Join BillPayment.StateForBillers As SB WITH(NOLOCK) On B.IdBiller = SB.IdBiller
		  Where B.IdStatus = 1
			 And B.IdBiller = @IdBiller
			 And SB.IdState = @IdState;

	   END


	   IF EXISTS( Select 1 From CommissionByOtherProducts WITH(NOLOCK)
				    Where IdCommissionByOtherProducts = @IdCommission
				    And isEnable = 1)           
	   BEGIN
	    
		  Select 
			 IdCommissionByOtherProducts AS IdCommission
			 , FromAmount
			 , ToAmount
			 , @CommissionSpecial AS CommissionSpecial
			 , AgentCommissionInPercentage
			 , CorporateCommissionInPercentage
			 , ExtraAmount  
		  From CommissionDetailByOtherProducts 
			 Where IdCommissionByOtherProducts = @IdCommission;

	   END

    End Try
  begin catch	  
	   Declare @ErrorMessage nvarchar(max);
	   Select @ErrorMessage=ERROR_MESSAGE();
	   Insert into Soporte.InfoLogForStoreProcedure (StoreProcedure,InfoDate,InfoMessage)Values('st_GetBillerCommission',Getdate(),'IdBiller:' + Convert(VARCHAR(250),@IdBiller) + ',' + @ErrorMessage);
  End Catch
    
END