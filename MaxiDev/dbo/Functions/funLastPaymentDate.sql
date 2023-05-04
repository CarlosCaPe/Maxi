CREATE Function [dbo].[funLastPaymentDate] 
(
    @IdAgent int,
    @Today datetime    
)  
RETURNS 
    DateTime  
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
    Select @TodayNumber=(DATEPART(DW,@Today)-1) 

    Declare @temp2 table
    (
        DayToPay int,
        DayPay datetime
    );

    Declare @temp table
    (
        PayOn int,
        DayToPay int, 
    DayPay Datetime
    );

    Insert into @temp (PayOn,DayToPay,DayPay)
    Select DoneOnSundayPayOn,7, GETDATE() from Agent with(nolock) where IdAgent=@IdAgent;
    Insert into @temp (PayOn,DayToPay,DayPay)
    Select DoneOnMondayPayOn,1, GETDATE() from Agent with(nolock) where IdAgent=@IdAgent;
    Insert into @temp (PayOn,DayToPay,DayPay)
    Select DoneOnTuesdayPayOn,2, GETDATE() from Agent with(nolock) where IdAgent=@IdAgent;
    Insert into @temp (PayOn,DayToPay,DayPay)
    Select DoneOnWednesdayPayOn,3, GETDATE() from Agent with(nolock) where IdAgent=@IdAgent;
    Insert into @temp (PayOn,DayToPay,DayPay)
    Select DoneOnThursdayPayOn,4, GETDATE() from Agent with(nolock) where IdAgent=@IdAgent;
    Insert into @temp (PayOn,DayToPay,DayPay)
    Select DoneOnFridayPayOn,5, GETDATE() from Agent with(nolock) where IdAgent=@IdAgent;
    Insert into @temp (PayOn,DayToPay,DayPay)
    Select DoneOnSaturdayPayOn,6, GETDATE() from Agent with(nolock) where IdAgent=@IdAgent;

    --Insert into @temp2
    --Select  DayToPay,DayPay from @temp 
    --where DayToPay in (select distinct payon from @temp)
    --order by DayToPay

    Insert into @temp2
    Select  DayToPay,DayPay from @temp 
    where payon in (@Todaynumber)
    order by DayToPay;

    Update @temp2 set DayPay=@Today-(@TodayNumber-DayToPay) where DayToPay<@TodayNumber;
    Update @temp2 set DayPay=@Today-7+(DayToPay-@TodayNumber) where DayToPay>=@TodayNumber;
    update @temp2 set DayPay=@Today-7+(DayToPay-case (@TodayNumber) when 0 then 7 else @TodayNumber end) where case (@TodayNumber) when 0 then 7 else @TodayNumber end=daytopay and daytopay=7;
         
	set @FinalDate = (SELECT MAX(DayPay) FROM @temp2);    

    Return [dbo].[RemoveTimeFromDatetime](@FinalDate)
End