Create procedure [dbo].[GetNextHSBCFolioNumber]  
@Number int out  
as  
  
Declare @currentNumber int  
Select @currentNumber= dbo.GetGlobalAttributeByName ('LastHSBCFolioNumber')  
set @currentNumber=@currentNumber+1  
while exists(select 1 from  HSBCNumbersUsedPesos where numberUsed=@currentNumber)  
Begin  
 --select 'rechasado '+convert(varchar,@currentNumber)  
 set @currentNumber=@currentNumber+1  
  
End  
  
update GlobalAttributes  set Value= convert(varchar,@currentNumber)  
where Name='LastHSBCFolioNumber'  
  
delete  HSBCNumbersUsedPesos where numberUsed<=@currentNumber   
  
set @Number=@currentNumber
