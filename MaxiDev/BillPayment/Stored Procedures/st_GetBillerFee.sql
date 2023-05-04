
CREATE PROCEDURE [BillPayment].[st_GetBillerFee]
(
    @IdAgent int
    ,@IdBiller int
)
AS
/********************************************************************
<Author></Author>
<app>MaxiCorp</app>
<Description>Get Fee Biller</Description>
<ChangeLog>
<log Date="16/08/2018" Author="snevarez">Creation</log>
<log Date="16/08/2018" Author="Azavala">Add IdAgent filter</log>
<log Date="14/11/2019" Author="Azavala">Get Ranges fees for billers with IsFixedFee=true</log>
</ChangeLog>
*************************/
BEGIN

    SET NOCOUNT ON;

    Begin try
 
	   Declare @IdFee int;

	   IF EXISTS( Select 1 From BillPayment.AgentForBillers WITH(NOLOCK)
				 Where idbiller = @IdBiller
				 and @IdAgent=IdAgent
				    And idStatus= 1)
	   BEGIN

		  SELECT
			 @idFee = idFee 
		  FROM
			 BillPayment.AgentForBillers 
		  WHERE
			 idbiller = @IdBiller
			 and @IdAgent=IdAgent
			 AND idStatus = 1;

	   END
	   ELSE
	   BEGIN
		  
		  DECLARE @IdState INT;
		  Select @IdState = IdState From [State] AS S WITH(NOLOCK)
			 Inner Join Agent AS A WITH(NOLOCK) On S.StateCode = A.AgentState
			 WHERE A.IdAgent = @IdAgent;

		  Select
			 @idFee = SB.IdFee 
		  From BillPayment.Billers AS B WITH(NOLOCK)
			 Inner Join BillPayment.StateForBillers As SB WITH(NOLOCK) On B.IdBiller = SB.IdBiller
		  Where B.IdStatus = 1
			 And B.IdBiller = @IdBiller
			 And SB.IdState = @IdState;

	   END

	   IF((Select IsFixedFee from BillPayment.Billers with(nolock) where IdBiller=@IdBiller)=1)
	   begin
			Select 
			 0 AS IdFee
			 ,isnull((select Min(FD.FromAmount) from FeeDetailByOtherProducts FD with(nolock) inner join FeeByOtherProducts F with(nolock) on F.IdFeeByOtherProducts=FD.IdFeeByOtherProducts where FD.IdFeeByOtherProducts=@IdFee and F.isEnable=1),0) as FromAmount
			 ,isnull((select MAX(FD.ToAmount) from FeeDetailByOtherProducts FD with(nolock) inner join FeeByOtherProducts F with(nolock) on F.IdFeeByOtherProducts=FD.IdFeeByOtherProducts where FD.IdFeeByOtherProducts=@IdFee and F.isEnable=1),5000) as ToAmount
			 ,MsrpFee as Fee
			 ,convert(bit,0) as IsFeePercentage
			 from BillPayment.Billers with(nolock) where IdBiller=@IdBiller
	   end

	   IF EXISTS( Select 1 From FeeByOtherProducts WITH(NOLOCK)
				    Where IdFeeByOtherProducts = @IdFee
				    And isEnable = 1)           
	   BEGIN
	    
		  Select 
			 IdFeeByOtherProducts AS IdFee
			 ,FromAmount
			 ,ToAmount
			 ,Fee
			 ,IsFeePercentage  
		  From FeeDetailByOtherProducts 
			 Where IdFeeByOtherProducts = @idFee;

	   END

    End Try
  begin catch	  
	   Declare @ErrorMessage nvarchar(max);
	   Select @ErrorMessage=ERROR_MESSAGE();
	   Insert into Soporte.InfoLogForStoreProcedure (StoreProcedure,InfoDate,InfoMessage)Values('st_GetBillerFee',Getdate(),'IdBiller:' + Convert(VARCHAR(250),@IdBiller) + ',' + @ErrorMessage);
  End Catch
    
END