CREATE PROCEDURE [dbo].[st_GetLogDetailFromGenericTable]
(
    @IdGeneric bigint,
    @ObjectName nvarchar(max)
)
as
select top 10 l.EnterByIdUser,UserName,l.DateOfLastChange from [MAXILOG].[dbo].[GenericTableLog] l
join users u on u.IdUser=l.EnterByIdUser
where IdGeneric=@IdGeneric and ObjectName=@ObjectName 
order by DateOfLastChange desc
