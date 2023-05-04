
CREATE function [dbo].[GetDateFrom_SendAgentBalanceByFax]( @IdAgent int)
returns varchar(12)
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
Begin

	declare @dayList table
	(	Id int identity(1,1),	day int	);

	insert into @dayList (day) values(7);
	insert into @dayList (day) values(6);
	insert into @dayList (day) values(5);
	insert into @dayList (day) values(4);
	insert into @dayList (day) values(3);
	insert into @dayList (day) values(2);
	insert into @dayList (day) values(1);
	insert into @dayList (day) values(7);
	insert into @dayList (day) values(6);
	insert into @dayList (day) values(5);
	insert into @dayList (day) values(4);
	insert into @dayList (day) values(3);
	insert into @dayList (day) values(2);
	insert into @dayList (day) values(1);

	declare @Id int, @day int

	declare @today int, @findingDay bit, @daysBefore int
	set @daysBefore =0
	set @today = dbo.GetToday() 
	set @findingDay =1

	select top 1 @Id =id , @day= day from @dayList order by id
	--select @today	,'today'
	while (@Id is not null)
	Begin
		--select @day		
		if(@findingDay=1)
			Begin
				if (@day<=@today or @day=1)
					Begin
						set @findingDay=0		
						--select @day	,'find day'			
					End
			End
		Else
			Begin
				set @daysBefore =@daysBefore+1
				if(exists(Select 1 From Agent A with(nolock) 
							Where IdAgent=@IdAgent and (DoneOnSundayPayOn=@day or DoneOnMondayPayOn=@day or DoneOnTuesdayPayOn=@day or    
								DoneOnWednesdayPayOn=@day or DoneOnThursdayPayOn=@day or DoneOnFridayPayOn=@day or DoneOnSaturdayPayOn=@day)))
					Begin
						--select @daysBefore, 'daysBefore'
						break;			
					End	
			End
		delete @dayList where id =@id
		set @id=null
		select top 1 @Id =id , @day= day from @dayList order by id
	End


	Declare @DateForReport datetime,@DateStr varchar(12),@MonthStr varchar(2),@DayStr varchar(2),@YearStr varchar(4)
	Select @DateForReport=dbo.RemoveTimeFromDatetime(GETDATE()-@daysBefore)    
	    
	Set @MonthStr=Convert(varchar,DATEPART(MONTH,@DateForReport))    
	If LEN(@MonthStr)=1     
	 Set @MonthStr='0'+@MonthStr    
	     
	Set @DayStr=Convert(varchar,DATEPART(DAY,@DateForReport))    
	If LEN(@DayStr)=1    
	 Set @DayStr='0'+@DayStr    
	     
	Set @YearStr=Convert(varchar,DATEPART(YEAR,@DateForReport))     
	Set @DateStr=@MonthStr+'-'+@DayStr+'-'+@YearStr    
	    
	--select @DateStr
	return @DateStr

End

