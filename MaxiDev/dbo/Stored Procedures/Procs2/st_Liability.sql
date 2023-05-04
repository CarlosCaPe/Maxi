CREATE Procedure [dbo].[st_Liability]
@StartDate  datetime,
@EndDate datetime,
@StartAmount Money
as
Set nocount on 
Select  @EndDate=@EndDate+1


Create Table #temp0
(
id int identity(1,1),
Date datetime,
VYear nvarchar(max),
VDay nvarchar(max),
Liability  money
)

Declare @TempDate Datetime,@VYear nvarchar(max),@VDay nvarchar(max)
Set @TempDate=@StartDate


While @TempDate<@EndDate
Begin
   
	Set @VYear= DATEPART(yy,@TempDate)
	Set @VDay= DATEPART(DY,@TempDate)
	Insert into #temp0 (date,vYear,vDay,Liability) values (CONVERT(CHAR(12),@TempDate, 106),@VYear,@VDay,0)
	Set @TempDate=@TempDate+1
End


------------------------  All transfer from Transfer ------------------------------
SELECT CONVERT(CHAR(12), T.DateOfTransfer, 106) AS [date],       
      Sum (T.AmountInDollars) as Amount
      Into #temp1
FROM Transfer T WITH(NOLOCK)
Join Agent A WITH(NOLOCK) on (T.IdAgent=A.IdAgent)
WHERE
T.DateOfTransfer >= @StartDate and
T.DateOfTransfer < @EndDate
GROUP BY
       CONVERT(CHAR(12), T.DateOfTransfer, 106)

------------------------  All transfer from TransferClosed ------------------------------

SELECT CONVERT(CHAR(12), T.DateOfTransfer, 106) AS [date],       
      Sum (T.AmountInDollars) as Amount
      Into #temp2
FROM TransferClosed T WITH(NOLOCK)
Join Agent A WITH(NOLOCK) on (T.IdAgent=A.IdAgent)
WHERE
T.DateOfTransfer >= @StartDate and
T.DateOfTransfer < @EndDate
GROUP BY
       CONVERT(CHAR(12), T.DateOfTransfer, 106)

       
------------------------  Substract  Paid, Rejected, Cancelled Tranfer  ----------------
SELECT CONVERT(CHAR(12), T.DateStatusChange, 106) AS [date],       
      Sum (T.AmountInDollars) as Amount
      Into #temp3
FROM Transfer T WITH(NOLOCK)
Join Agent A WITH(NOLOCK) on (T.IdAgent=A.IdAgent)
WHERE
T.DateStatusChange >= @StartDate and
T.DateStatusChange < @EndDate
 And T.IdStatus in (30,31,22)  -- 30 Paid,31 Rejected,22 Cancelled
GROUP BY
       CONVERT(CHAR(12), T.DateStatusChange, 106)


------------------------  Substract  Paid, Rejected, Cancelled TranferClosed  ----------------
SELECT CONVERT(CHAR(12), T.DateStatusChange, 106) AS [date],       
      Sum (T.AmountInDollars) as Amount
      Into #temp4
FROM TransferClosed T WITH(NOLOCK)
Join Agent A WITH(NOLOCK) on (T.IdAgent=A.IdAgent)
WHERE
T.DateStatusChange >= @StartDate and
T.DateStatusChange < @EndDate
 And T.IdStatus in (30,31,22)  -- 30 Paid,31 Rejected,22 Cancelled
GROUP BY
       CONVERT(CHAR(12), T.DateStatusChange, 106)



Select A.id, A.Date,A.VYear,A.VDay,ISNULL(B.Amount,0)+ISNULL(C.Amount,0) as Amount,ISNULL(D.Amount,0)+ISNULL(E.Amount,0) as AmountPCR,
A.Liability as Liability into #temp5 from #temp0 A
Full Join #temp1 B on (A.date=B.date)
Full Join #temp2 C on (A.date=C.date)
Full Join #temp3 D on (A.date=D.date)
Full Join #temp4 E on (A.date=E.date)


Declare @id int
Set @id=1

While exists (Select 1 from #temp5 where id>=@id )
Begin
	Update #temp5 set Liability=@StartAmount+Amount-AmountPCR where id=@id
	Select @StartAmount=@StartAmount+Amount-AmountPCR from #temp5  where id=@id
	Set @id=@id+1
End

Select * from #temp5
