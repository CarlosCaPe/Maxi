create procedure st_GetFaxFileHistory
(
    @IdFaxType int
)
as
declare @DateDelete datetime
declare @Days int

select @Days=[ExpireDays] from [FaxType] where IdFaxType=@IdFaxType

set @Days=isnull(@Days,0)

select @DateDelete=DATEADD (Day , -1*@Days, getdate())

select idFaxFileHistory,FileName from [FaxFileHistory] where IdFaxType=@IdFaxType and isdeleted=0 and dateofcreation<=@DateDelete