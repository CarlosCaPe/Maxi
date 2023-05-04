





CREATE function [dbo].[GetDateTo_SendAgentBalanceByFax]()
returns varchar(12)
Begin

Declare @DateForReport datetime,@DateStr varchar(12),@MonthStr varchar(2),@DayStr varchar(2),@YearStr varchar(4)

Select @DateForReport=dbo.RemoveTimeFromDatetime(GETDATE())    
    
Set @MonthStr=Convert(varchar,DATEPART(MONTH,@DateForReport))    
If LEN(@MonthStr)=1     
 Set @MonthStr='0'+@MonthStr    
     
Set @DayStr=Convert(varchar,DATEPART(DAY,@DateForReport))    
If LEN(@DayStr)=1    
 Set @DayStr='0'+@DayStr    
     
Set @YearStr=Convert(varchar,DATEPART(YEAR,@DateForReport))     
Set @DateStr=@MonthStr+'-'+@DayStr+'-'+@YearStr    
    
return @DateStr
    
End
