
CREATE procedure [dbo].[st_getFilesToDelete]
as

DECLARE @date DateTime
SET @date = GetDate()
SET @date = DateAdd(day, ((Convert(int ,(select value from GlobalAttributes where name = 'DaysToDelete'))) * -1) , @date)
select 
	U.IdUploadFile,
	U.IdReference,
	U.IdDocumentType,
	U.FileName,
	U.FileGuid,
	U.Extension,
	U.IdStatus,
	U.LastChange_LastDateChange as DateOfLastChange
from UploadFiles U  (nolock)
join DocumentTypes DT  (nolock) on U.IdDocumentType = DT.IdDocumentType 
where DT.IdType = 1 and U.IdStatus = 2 and U.LastChange_LastDateChange <= @date and ISNULL(U.IsPhysicalDeleted, 0) = 0  order by U.LastChange_LastDateChange desc
