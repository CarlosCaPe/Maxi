-- =============================================
-- Author:		Aldo Morán Márquez
-- Create date: 01/04/2015
-- Description:	GetAllOthers Images by customer
-- =============================================
CREATE PROCEDURE st_GetCustomerOtherImages(@IdCustomer int)
AS
BEGIN

	select * from(
		select u.FileGuid, u.Extension, u.IdUploadFile,u.IdDocumentType,d.IdDocumentImageType,'Customer Pic' as Name, 'Foto del Cliente' as NameEs from uploadfiles u
		join customer c on u.idreference=c.idcustomer
		left join [UploadFilesDetail] d on u.IdUploadFile=d.IdUploadFile
		left join [DocumentImageType] t on d.[IdDocumentImageType]=t.[IdDocumentImageType]
	where 
		IdDocumentType in (select IdDocumentType from documenttypes where idtype=4 and Name = 'CustomerPicture') 
		and c.idcustomer=@IdCustomer
		and u.idstatus=1
	) t
	group by FileGuid, Extension, IdUploadFile, IdDocumentType, IdDocumentImageType, Name, NameES

END
