CREATE procedure [Corp].[st_ReportQuarterTransferByAgent]  
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
<log Date="19/12/2018" Author="jmolina">Add with(nolock) and ;</log>
<log Date="01/02/2019" Author="jdarellano" Name="#1">Se mejora filtro en consulta para que muestre total de registros.</log>
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
IdAgent int,  
Num int,  
Amount money  
);  
  
Create Table #Results2  
(  
IdAgent int,  
Num int,  
Amount money  
) ; 
  
Create Table #Results3  
(  
IdAgent int,  
Num int,  
Amount money  
)  ;
  
  
Insert into #Results1  
exec [Corp].[st_TotalTransferByMonth] @Year, @Month1;  
  
Insert into #Results2  
exec [Corp].[st_TotalTransferByMonth] @Year, @Month2;  
  
Insert into #Results3  
exec [Corp].[st_TotalTransferByMonth] @Year, @Month3;  
  
  
  
Select  
A.AgentCode,  
A.AgentName,  
A.AgentAddress,  
A.AgentCity,  
A.AgentState,  
A.AgentZipcode,  
A.AgentPhone,  
isnull(B.Num,0) as Num1,  
isnull(C.Num,0) as Num2,  
isnull(D.Num,0) as Num3,  
isnull(B.Num,0)+isnull(C.Num,0)+isnull(D.Num,0) as TotalNum,  
isnull(B.Amount,0) as Amount1,  
isnull(C.Amount,0) as Amount2,  
isnull(D.Amount,0) as Amount3,  
isnull(B.Amount,0)+isnull(C.Amount,0)+isnull(D.Amount,0) as TotalAmount  
from Agent A with(nolock)  
Left Join #Results1 B on (A.IdAgent=B.IdAgent)  
Left Join #Results2 C on (A.IdAgent=C.IdAgent)  
Left Join #Results3 D on (A.IdAgent=D.IdAgent)  
--where isnull(B.Num,0)+isnull(C.Num,0)+isnull(D.Num,0)<>0  
where (isnull(B.Num,0)<>0 or isnull(C.Num,0)<>0 or isnull(D.Num,0)<>0 or isnull(B.Amount,0)<>0 or isnull(C.Amount,0)<>0 or isnull(D.Amount,0)<>0)--#1
Order by A.AgentCode
