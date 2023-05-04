CREATE Function [dbo].[funPastPaymentDateN] (@IdAgent int,@Today datetime)  
RETURNS DateTime  
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
Begin  
Declare @FinalDate datetime  
Declare @TodayNumber int  
Select @TodayNumber=DATEPART(DW,@Today)-1  
  
Declare  @temp2 table  
(  
PayOn  int,  
DayPay datetime  
)  
  
Declare  @temp table  
(  
PayOn  int,  
DayPay datetime  
)  
  
Insert into @temp (PayOn,DayPay)  
Select DoneOnSundayPayOn,@Today from Agent with(nolock) where IdAgent=@IdAgent;
Insert into @temp (PayOn,DayPay)  
Select DoneOnMondayPayOn,@Today from Agent with(nolock) where IdAgent=@IdAgent;  
Insert into @temp (PayOn,DayPay)  
Select DoneOnTuesdayPayOn,@Today from Agent with(nolock) where IdAgent=@IdAgent;  
Insert into @temp (PayOn,DayPay)  
Select DoneOnWednesdayPayOn,@Today from Agent with(nolock) where IdAgent=@IdAgent;  
Insert into @temp (PayOn,DayPay)  
Select DoneOnThursdayPayOn,@Today from Agent with(nolock) where IdAgent=@IdAgent;  
Insert into @temp (PayOn,DayPay)  
Select DoneOnFridayPayOn,@Today from Agent with(nolock) where IdAgent=@IdAgent;  
Insert into @temp (PayOn,DayPay)  
Select DoneOnSaturdayPayOn,@Today from Agent with(nolock) where IdAgent=@IdAgent;  
  
  
Insert into @temp2  
Select Distinct payon,DayPay from @temp;  
  
Update @temp2 set DayPay=@Today-(@TodayNumber-PayOn) where PayOn<@TodayNumber;  
Update @temp2 set DayPay=@Today-7+(PayOn-@TodayNumber) where PayOn>@TodayNumber;  
 
If (Select COUNT(1) from  @temp2)=1
	Begin 
	Select  @FinalDate= DayPay-7 from @temp2;  
	End
Else
	Begin 
	Select top 1 @FinalDate= DayPay from @temp2  where DayPay<@Today order by DayPay desc;  
	End
	
Return dbo.RemoveTimeFromDatetime(@FinalDate  )
End
