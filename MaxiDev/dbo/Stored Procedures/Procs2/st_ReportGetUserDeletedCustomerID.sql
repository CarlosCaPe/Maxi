
CREATE procedure [dbo].[st_ReportGetUserDeletedCustomerID]
(
    @BeginDate datetime,                      
    @EndDate datetime  
)
as

set @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)                      
set @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)    

select LastChange_LastUserChange iduser, us.username,IdUploadFile,IdReference,c.Name+ ' ' + c.FirstLastName+ ' ' +c.SecondLastName CustomerName,u.IdDocumentType, dt.name DocumentType,FileName+Extension FileName,LastChange_LastDateChange DateOfLastChange,LastChange_LastNoteChange Note,isnull(IsPhysicalDeleted,0) IsPhysicalDeleted,case when isnull(IsPhysicalDeleted,0)=0 then 'False' else 'True' end PhysicalDeleted,idstatus,case when idstatus=2 then 'Deleted' else 'Active' end FileStatus  
from 
    uploadfiles u  (nolock)
join 
    customer c  (nolock) on u.IdReference=c.idcustomer
join 
    DocumentTypes dt  (nolock) on u.IdDocumentType=dt.IdDocumentType
join
    users us  (nolock) on u.LastChange_LastUserChange=us.iduser
where 
    u.iddocumenttype in (select iddocumenttype from documenttypes where idtype=1) and u.idstatus=2 and
    LastChange_LastDateChange>@BeginDate and LastChange_LastDateChange<@EndDate
order by LastChange_LastDateChange desc