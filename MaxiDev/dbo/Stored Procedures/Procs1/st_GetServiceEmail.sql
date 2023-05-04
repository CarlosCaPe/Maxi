create procedure st_GetServiceEmail
(
    @ServiceCode nvarchar(max)
)
as
select Email from Services.Email where code=@ServiceCode and idgenericstatus=1