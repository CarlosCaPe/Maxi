create procedure st_GetFaxTypeCatalog
as
select IdFaxType,FaxTypeName from [FaxType] where idgenericstatus=1