create Function [dbo].[funGetConvertAmount] 
(
    @AmountInMN money,
    @RefExrate money
)  
RETURNS 
    money  
Begin 
     declare @NewAmountInDollars money
     declare @AddMoney money

     set @AddMoney=0.0001

     set @NewAmountInDollars=round(@AmountInMN/@RefExrate,4)

     if(@NewAmountInDollars*@RefExrate<@AmountInMN)
     begin
        set @NewAmountInDollars=@NewAmountInDollars+@AddMoney
     end

     if(@NewAmountInDollars*@RefExrate<@AmountInMN)
     begin
        set @NewAmountInDollars=@NewAmountInDollars+@AddMoney
     end

     return @NewAmountInDollars
End