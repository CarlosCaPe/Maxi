CREATE Procedure [Corp].[st_TotalTransferByMonthByCountry]    
@Year int,     
@Month int    
as    
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Declare @FechaInicio datetime, @FechaFin datetime    
Select @FechaInicio=Convert(varchar,@Year)+'/'+Convert(varchar,@Month)+'/'+'01'    
Set @FechaFin=DATEADD(month,1,@FechaInicio)    


Select COUNT(1) as Num,SUM(AmountInDollars) as Amount,IdCountryCurrency into #temp from [Transfer] WITH(NOLOCK)     
Where DateOfTransfer>@FechaInicio and DateOfTransfer<@FechaFin    
Group by IdCountryCurrency    
Union
Select COUNT(1) as Num,SUM(AmountInDollars) as Amount,IdCountryCurrency from TransferClosed WITH(NOLOCK)     
Where DateOfTransfer>@FechaInicio and DateOfTransfer<@FechaFin    
Group by IdCountryCurrency    
Union
Select COUNT(1)*-1 as Num,SUM(AmountInDollars)*-1 as Amount, IdCountryCurrency from [Transfer] WITH(NOLOCK)     
Where DateStatusChange>@FechaInicio and DateStatusChange<@FechaFin    
and IdStatus in (31,22) -- rejected, cancelled    
Group by IdCountryCurrency
Union
Select COUNT(1)*-1 as Num,SUM(AmountInDollars)*-1 as Amount, IdCountryCurrency from TransferClosed WITH(NOLOCK)     
Where DateStatusChange>@FechaInicio and DateStatusChange<@FechaFin    
and IdStatus in (31,22) -- rejected, cancelled    
Group by IdCountryCurrency

Select SUM(Num) as Num,SUM(Amount) as Amount,C.CountryName from #temp A
Join CountryCurrency B with(nolock) on (A.IdCountryCurrency=B.IdCountryCurrency)
Join Country C with(nolock) on (C.IdCountry=B.IdCountry)
Group by C.CountryName
order by C.CountryName


