
create PROCEDURE [BillPayment].[st_GetBillerExRate]
(
    @IdBiller int
)
AS
/********************************************************************
<Author></Author>
<app>MaxiCorp</app>
<Description>Get ExRate Biller</Description>
<ChangeLog>
<log Date="16/08/2018" Author="snevarez">Creation</log>
</ChangeLog>
*************************/
BEGIN

    SET NOCOUNT ON;

    Begin try

	   DECLARE @ExRate TABLE
	   (
		  IdCurrency INT
		  ,CurrencyName VARCHAR(150)
		  ,CurrencyCode VARCHAR(50)
		  ,ExRate DECIMAL(12,4)
		  ,Spread DECIMAL(12,4)
	   )

	   IF EXISTS(
				Select 1
				    From BillPayment.Billers AS B WITH(NOLOCK)
				    Where B.IdStatus = 1
					   And B.IsDomestic = 1
					   And B.IdBiller = @IdBiller)
	   BEGIN
		
		  INSERT INTO @ExRate (IdCurrency, CurrencyName, CurrencyCode, ExRate, Spread) 
			 SELECT IdCurrency,CurrencyName,CurrencyCode, 1.0 AS ExRate, 0.0 AS Spread
				FROM Currency WHERE CurrencyCode = 'USD';  

	   END
	   ELSE
	   BEGIN		 

		  IF EXISTS(Select 1 From BillPayment.Billers AS B
					   Inner Join BillPayment.Aggregator AS A On B.IdAggregator = A.IdAggregator
				    Where B.IdStatus = 1
					   And B.IsDomestic = 0
					   And B.IdBiller = @IdBiller)
		  BEGIN

			 INSERT INTO @ExRate (IdCurrency,CurrencyName,CurrencyCode,ExRate,Spread) 
				SELECT IdCurrency, CurrencyName, CurrencyCode, 1.0 AS ExRate, 0.0 AS Spread
				    FROM Currency WHERE CurrencyCode = 'USD';

			 DECLARE @IdAggregator INT;
			 DECLARE @AggregatorName VARCHAR(50);
			 DECLARE @IdBillerOriginal INT;
				
			 Select 
				@IdAggregator = A.IdAggregator
				,@AggregatorName = A.Name
				, @IdBillerOriginal = B.IdBillerAggregator
			 From BillPayment.Billers AS B
				    Inner Join BillPayment.Aggregator AS A On B.IdAggregator = A.IdAggregator
				Where B.IdBiller = @IdBiller

			 IF(@AggregatorName='Regalii')
			 BEGIN

				INSERT INTO @ExRate (IdCurrency, CurrencyName, CurrencyCode, ExRate, Spread) 
				    select    
					   c.IdCurrency
					   , CurrencyName
					   , cn.CurrencyCode
					   , c.Exchange AS ExRate
					   , isnull(s.Spread,0) AS Spread
				    from regalii.Currencies c
					   join Currency cn on c.IdCurrency=cn.IdCurrency
					   left join Regalii.CurrenciesSpread s on c.IdCurrency=s.IdCurrency and s.idagent is null
					   Inner Join Regalii.Billers AS b on c.IdCurrency = b.IdCurrency
				    where b.IdBiller = @IdBillerOriginal;

			 END

		  END

	   END

	   SELECT 
		  IdCurrency
		  --, CurrencyName
		  , CurrencyCode
		  , ExRate
		  , Spread
	   FROM @ExRate;

    End Try
    Begin catch	  
	   Declare @ErrorMessage nvarchar(max);
	   Select @ErrorMessage=ERROR_MESSAGE();
	   Insert into Soporte.InfoLogForStoreProcedure (StoreProcedure,InfoDate,InfoMessage)Values('st_GetBillerExRate',Getdate(),'IdBiller:' + Convert(VARCHAR(250),@IdBiller) + ',' + @ErrorMessage);
    End Catch
    
END