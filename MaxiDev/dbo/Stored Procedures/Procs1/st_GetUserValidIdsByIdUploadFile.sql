CREATE procedure [dbo].[st_GetUserValidIdsByIdUploadFile](@IdUploadFile int)
as
select u.FileGuid, u.Extension, c.idcustomer from uploadfiles u
join customer c on u.idreference=c.idcustomer
where 
    IdDocumentType in (select IdDocumentType from documenttypes where idtype in(1,4)) 
    --and ExpirationIdentification>=getdate()+1
    and u.IdUploadFile=@IdUploadFile
    and u.idstatus=1
group by u.FileGuid, u.Extension, c.idcustomer
--select idreference,count(1) tot from uploadfiles u
--join customer c on u.idreference=c.idcustomer
--where 
--    IdDocumentType in (select IdDocumentType from documenttypes where idtype=1) 
--    and ExpirationIdentification>=[dbo].[RemoveTimeFromDatetime](getdate())
--    and c.idcustomer=@IdCustomer
--    and u.idstatus=1
--group by u.idreference
