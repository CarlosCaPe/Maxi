CREATE procedure [Corp].[st_GetUserSeller]
(
    @IdUser int
)
as

/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="21/12/2018" Author="jdarellano" Name="#1">Performance: se agregan with(nolock) y se aplica drop de tabla temporal, y corchetes a palabras reservadas. Se modifica filtro para toma de estatus "suspended".</log>
</ChangeLog>
*********************************************************************/

--select iduser,username,userlogin from users where idgenericstatus=1 and iduser in (select iduserseller from seller) and iduser!=isnull(@IdUser,0) order by username
set nocount on;

declare @IdUserBaseText nvarchar(max)

;WITH items AS (
    SELECT iduser,username,userlogin 
    , 0 AS [Level]
    , CAST('/'+convert(varchar,iduser)+'/' as varchar(2000)) AS [Path]
    FROM users u with (nolock)
    join seller s with (nolock) on u.iduser=s.iduserseller 
    --WHERE idgenericstatus=1 and IdUserSellerParent is null
	WHERE idgenericstatus in (1,3) and IdUserSellerParent is null--#1
    
    UNION ALL

    SELECT u.iduser,u.username,u.userlogin 
    , [Level] + 1
    , CAST(itms.path+convert(varchar,isnull(u.iduser,''))+'/' as varchar(2000))  AS [Path]
    FROM users u with (nolock) 
    join seller s with (nolock) on u.iduser=s.iduserseller 
    INNER JOIN items itms ON itms.iduser = s.IdUserSellerParent
    --WHERE idgenericstatus=1
	WHERE idgenericstatus in (1,3)--#1
)
SELECT iduser,username,userlogin,[Level],[Path] into #SellerTree FROM items ORDER BY [Path]

set @IdUserBaseText='%/'+isnull(convert(varchar,@IdUser),'0')+'/%'

print (@IdUserBaseText)

--select * from #SellerTree

select iduser,username,userlogin 
from #SellerTree 
where [Path] not like @IdUserBaseText
order by username

drop table #SellerTree--#1
