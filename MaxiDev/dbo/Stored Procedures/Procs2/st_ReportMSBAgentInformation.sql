CREATE Procedure [dbo].[st_ReportMSBAgentInformation]  
(  
@Year int  
)  
As  
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;
  
Create Table #Results1    
(    
IdAgent int,    
Num int,    
Amount money    
);    
Insert into #Results1    
exec st_TotalTransferByMonth @Year,1;
  
Create Table #Results2    
(    
IdAgent int,    
Num int,    
Amount money    
);    
Insert into #Results2    
exec st_TotalTransferByMonth @Year,2 ; 
  
  
Create Table #Results3    
(    
IdAgent int,    
Num int,    
Amount money    
);    
Insert into #Results3    
exec st_TotalTransferByMonth @Year,3;  
  
  
Create Table #Results4    
(    
IdAgent int,    
Num int,    
Amount money    
);    
Insert into #Results4    
exec st_TotalTransferByMonth @Year,4;  
  
Create Table #Results5    
(    
IdAgent int,    
Num int,    
Amount money    
);    
Insert into #Results5    
exec st_TotalTransferByMonth @Year,5;  
  
Create Table #Results6    
(    
IdAgent int,    
Num int,    
Amount money    
);    
Insert into #Results6    
exec st_TotalTransferByMonth @Year,6;  
  
Create Table #Results7    
(    
IdAgent int,    
Num int,    
Amount money    
);    
Insert into #Results7    
exec st_TotalTransferByMonth @Year,7;  
  
Create Table #Results8    
(    
IdAgent int,    
Num int,    
Amount money    
);    
Insert into #Results8    
exec st_TotalTransferByMonth @Year,8;  
  
Create Table #Results9    
(    
IdAgent int,    
Num int,    
Amount money    
);    
Insert into #Results9    
exec st_TotalTransferByMonth @Year,9;  
  
Create Table #Results10    
(    
IdAgent int,    
Num int,    
Amount money    
);    
Insert into #Results10    
exec st_TotalTransferByMonth @Year,10 ; 
  
Create Table #Results11    
(    
IdAgent int,    
Num int,    
Amount money    
) ;   
Insert into #Results11    
exec st_TotalTransferByMonth @Year,11 ; 
  
Create Table #Results12    
(    
IdAgent int,    
Num int,    
Amount money    
);    
Insert into #Results12    
exec st_TotalTransferByMonth @Year,12 ; 
  
  
  
Select    
B.AgentName as LegalName,  
ow.LastName as LastName,   
ow.Name as FirstName,  
B.AgentAddress as [Address],  
B.AgentCity as City,  
B.AgentState as [State],  
B.AgentZipcode as ZipCode,   
'USA' as Country,   
ow.SSN as TIN,   
AgentPhone as TelephoneNumber,   
'X' as MoneyTransmitter,   
Case when C.Amount>100000 then 'X' else '' End As January,  
Case when D.Amount>100000 then 'X' else '' End As February,  
Case when E.Amount>100000 then 'X' else '' End As March,  
Case when F.Amount>100000 then 'X' else '' End As April,  
Case when G.Amount>100000 then 'X' else '' End As May,  
Case when H.Amount>100000 then 'X' else '' End As June,  
Case when I.Amount>100000 then 'X' else '' End As July,  
Case when J.Amount>100000 then 'X' else '' End As August,  
Case when K.Amount>100000 then 'X' else '' End As September,  
Case when L.Amount>100000 then 'X' else '' End As October,  
Case when M.Amount>100000 then 'X' else '' End As November,  
Case when N.Amount>100000 then 'X' else '' End As December,
O.BankName as NameOfFinancialInstitution,
O.AccountNumber as AccountNumber  
from #Results12 A  
Left Join Agent B with(nolock) on (A.IdAgent=B.IdAgent)    
left join [Owner] ow with(nolock) on (b.IdOwner=ow.IdOwner)
Left Join #Results1 C on (A.IdAgent=C.IdAgent)    
Left Join #Results2 D on (A.IdAgent=D.IdAgent)    
Left Join #Results3 E on (A.IdAgent=E.IdAgent)    
Left Join #Results4 F on (A.IdAgent=F.IdAgent)    
Left Join #Results5 G on (A.IdAgent=G.IdAgent)    
Left Join #Results6 H on (A.IdAgent=H.IdAgent)    
Left Join #Results7 I on (A.IdAgent=I.IdAgent)    
Left Join #Results8 J on (A.IdAgent=J.IdAgent)    
Left Join #Results9 K on (A.IdAgent=K.IdAgent)    
Left Join #Results10 L on (A.IdAgent=L.IdAgent)    
Left Join #Results11 M on (A.IdAgent=M.IdAgent)    
Left Join #Results12 N on (A.IdAgent=N.IdAgent)  
Left Join AgentBankDeposit O with(nolock) on (O.IdAgentBankDeposit=B.IdAgentBankDeposit)
Order by B.AgentCode  
  
