
CREATE FUNCTION dbo.FunTNWAmountToString (@Amount Money)  
Returns varchar(8)  
AS  
Begin  
 Declare @TotalCharges varchar(8)  
 Declare @TempChar varchar(50)  
 Set @TotalCharges='00000000'  
 Set @TempChar=REPLACE(CONVERT(varchar(max),@Amount),'.','')  
 Set @TempChar=@TotalCharges+@TempChar  
 Set @TotalCharges=Substring(@TempChar,Len(@TempChar)-7,8)  
 Return @TotalCharges  
End