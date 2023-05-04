   
CREATE procedure [dbo].[st_ReportQuarterTransferByCountry]    
(    
@Year int,     
@Quarter int    
)    
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
    
Declare @Month1 int,@Month2 int,@Month3 int    
    
Select    
@Month1= Case when @Quarter=1 Then 1    
  when @Quarter=2 Then 4    
  when @Quarter=3 Then 7    
  when @Quarter=4 Then 10      
  End    
    
Set @Month2=@Month1+1    
Set @Month3=@Month1+2    
    
     
Create Table #Results1    
(    
Num int,    
Amount money,
Country nvarchar(max)    
);    
    
Create Table #Results2    
(    
Num int,    
Amount money,
Country nvarchar(max)    
);    
    
Create Table #Results3    
(    
Num int,    
Amount money,
Country nvarchar(max)    
);    
    
    
Insert into #Results1    
exec st_TotalTransferByMonthByCountry @Year, @Month1  ;  
    
Insert into #Results2    
exec st_TotalTransferByMonthByCountry @Year, @Month2  ;  
    
Insert into #Results3    
exec st_TotalTransferByMonthByCountry @Year, @Month3  ;  
    
    
    
Select    
A.CountryName,
isnull(B.Num,0) as Num1,    
isnull(C.Num,0) as Num2,    
isnull(D.Num,0) as Num3,    
isnull(B.Num,0)+isnull(C.Num,0)+isnull(D.Num,0) as TotalNum,    
isnull(B.Amount,0) as Amount1,    
isnull(C.Amount,0) as Amount2,    
isnull(D.Amount,0) as Amount3,    
isnull(B.Amount,0)+isnull(C.Amount,0)+isnull(D.Amount,0) as TotalAmount,    
Convert(Money,(isnull(B.Amount,0)+isnull(C.Amount,0)+isnull(D.Amount,0))/(isnull(B.Num,0)+isnull(C.Num,0)+isnull(D.Num,0))) as Average
from Country A with(nolock)    
Left Join #Results1 B on (A.CountryName=B.Country)    
Left Join #Results2 C on (A.CountryName=C.Country)    
Left Join #Results3 D on (A.CountryName=D.Country)    
where isnull(B.Num,0)+isnull(C.Num,0)+isnull(D.Num,0)<>0    
Order by A.CountryName
   
