CREATE procedure [dbo].[st_GetUserValidIds](@IdCustomer int)
as
Declare @CurrentDate datetime = [dbo].[RemoveTimeFromDatetime](getdate())


select * from(
select u.FileGuid, u.Extension, u.IdUploadFile,u.IdDocumentType,d.IdDocumentImageType,[dbo].[GetMessageFromMultiLenguajeResorces](1,isnull(DocumentImageCode,'FRONT1')) Name, [dbo].[GetMessageFromMultiLenguajeResorces](2,isnull(DocumentImageCode,'FRONT1')) NameEs from uploadfiles u  (nolock)
join customer c  (nolock) on u.idreference=c.idcustomer
left join [UploadFilesDetail] d  (nolock) on u.IdUploadFile=d.IdUploadFile
left join [DocumentImageType] t  (nolock) on d.[IdDocumentImageType]=t.[IdDocumentImageType]
where 
    IdDocumentType in (select IdDocumentType from documenttypes where idtype=1) 
    and ExpirationDate>=@CurrentDate
    and c.idcustomer=@IdCustomer
    and u.idstatus=1
) t
group by FileGuid, Extension, IdUploadFile, IdDocumentType, IdDocumentImageType, Name, NameES
--select idreference,count(1) tot from uploadfiles u
--join customer c on u.idreference=c.idcustomer
--where 
--    IdDocumentType in (select IdDocumentType from documenttypes where idtype=1) 
--    and ExpirationIdentification>=[dbo].[RemoveTimeFromDatetime](getdate())
--    and c.idcustomer=@IdCustomer
--    and u.idstatus=1
--group by u.idreference