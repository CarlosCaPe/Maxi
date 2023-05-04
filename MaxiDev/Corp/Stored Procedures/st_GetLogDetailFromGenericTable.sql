
-- =============================================
-- ChangeLog--
-- Author:	omurillo
-- Modify date: 2020-10-28
-- Description:	Se cambio el nombre de la base de datos donde se guardan los logs de historial [MAXI_LOG] por [MAXILOG] 
-- =============================================
CREATE PROCEDURE [Corp].[st_GetLogDetailFromGenericTable]
(
    @IdGeneric bigint,
    @ObjectName nvarchar(max)
)
as
select top 10 l.EnterByIdUser,UserName,l.DateOfLastChange from [MAXILOG].[dbo].[GenericTableLog] l
join users u on u.IdUser=l.EnterByIdUser
where IdGeneric=@IdGeneric and ObjectName=@ObjectName 
order by DateOfLastChange desc
