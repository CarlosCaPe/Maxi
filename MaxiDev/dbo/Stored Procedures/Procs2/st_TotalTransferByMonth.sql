
CREATE Procedure [dbo].[st_TotalTransferByMonth]
@Year int, 
@Month int
as
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="01/02/2019" Author="jdarellano" Name="#1">Se elimina filtro en consulta para que muestre total de registros.</log>
</ChangeLog>
*********************************************************************/

Declare @FechaInicio datetime, @FechaFin datetime
Select @FechaInicio=Convert(varchar,@Year)+'/'+Convert(varchar,@Month)+'/'+'01'
Set @FechaFin=DATEADD(month,1,@FechaInicio)

Select idAgent into #Q0 from Agent

--------------  Transfer ----------------------
Select COUNT(1) as Num,SUM(AmountInDollars) as Amount, IdAgent into #Q1 from Transfer WITH(NOLOCK) 
Where DateOfTransfer>@FechaInicio and DateOfTransfer<@FechaFin
Group by IdAgent

--------------  TransferClosed -----------------
Select COUNT(1) as Num,SUM(AmountInDollars) as Amount, IdAgent into #Q2 from TransferClosed  WITH(NOLOCK)
Where DateOfTransfer>@FechaInicio and DateOfTransfer<@FechaFin
Group by IdAgent


--------------  Transfer Rejected, Cancelled ----------------------
Select COUNT(1) as Num,SUM(AmountInDollars) as Amount, IdAgent into #Q3 from Transfer WITH(NOLOCK) 
Where DateStatusChange>@FechaInicio and DateStatusChange<@FechaFin
and IdStatus in (31,22) -- rejected, cancelled
Group by IdAgent

--------------  TransferClosed Rejected Cancelled -----------------
Select COUNT(1) as Num,SUM(AmountInDollars) as Amount, IdAgent into #Q4 from TransferClosed  WITH(NOLOCK)
Where DateStatusChange>@FechaInicio and DateStatusChange<@FechaFin
and IdStatus in (31,22) -- rejected, cancelled
Group by IdAgent



Select A.IdAgent,isnull(B.Num,0)+isnull(C.Num,0)-isnull(D.Num,0)-isnull(E.Num,0) as Num,
isnull(B.Amount,0)+isnull(C.Amount,0)-isnull(D.Amount,0)-isnull(E.Amount,0) as Amount from #Q0 A
Left Join #Q1 B on (A.IdAgent=B.IdAgent)
Left Join #Q2 C on (A.IdAgent=C.IdAgent)
Left Join #Q3 D on (A.IdAgent=D.IdAgent)
Left Join #Q4 E on (A.IdAgent=E.IdAgent)
--Where 
--isnull(B.Num,0)+isnull(C.Num,0)-isnull(D.Num,0)-isnull(E.Num,0) >0--#1


