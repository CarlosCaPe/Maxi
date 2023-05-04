create procedure st_GetGlobalAttributebyName
(
    @Name nvarchar(max)
)
as
select [dbo].[GetGlobalAttributeByName](@Name) Value