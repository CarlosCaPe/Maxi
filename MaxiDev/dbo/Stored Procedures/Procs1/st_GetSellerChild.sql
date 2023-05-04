CREATE procedure [dbo].[st_GetSellerChild]
(
    @IdUser int
)
as

/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="28/11/2018" Author="jdarellano" Name="#1">Performance: se agregan with(nolock) y se eliminan tablas temporales; Se incluye búsqueda de usuarios en estatus "Suspended".</log>
</ChangeLog>
*********************************************************************/


declare @IsAllSeller bit 
set @IsAllSeller = (Select top 1 1 From [Users] where [IdUser] = @IdUser and [IdUserType] = 1) 

Create Table #SellerSubordinates
	(
		IdSeller int,
        UserName nvarchar(max)
	)

declare @IdUserBaseText nvarchar(max) ='%%'

if isnull(@IsAllSeller,0)=0
    set @IdUserBaseText='%/'+isnull(convert(varchar,@IdUser),'0')+'/%'

;WITH items AS (
    SELECT iduser,username,userlogin 
    , 0 AS [Level]
    , CAST('/'+convert(varchar,iduser)+'/' as varchar(2000)) AS [Path]
    FROM dbo.Users as u with (nolock)
    inner join dbo.Seller as s with (nolock) on u.iduser=s.iduserseller
    --WHERE idgenericstatus=1 and IdUserSellerParent is null
	WHERE idgenericstatus in (1,3) and IdUserSellerParent is null--#1
   
    UNION ALL

    SELECT u.iduser,u.username,u.userlogin 
    , [Level] + 1
    , CAST(itms.[Path]+convert(varchar,isnull(u.iduser,''))+'/' as varchar(2000))  AS [Path]
    FROM dbo.Users as u with (nolock)
    inner join dbo.Seller as s with (nolock) on u.iduser=s.iduserseller 
    INNER JOIN items itms ON itms.iduser = s.IdUserSellerParent
    --WHERE idgenericstatus=1
	WHERE idgenericstatus in (1,3)--#1
)
SELECT iduser,username,userlogin,[Level],[Path] into #SellerTree  FROM items

Insert into #SellerSubordinates 
select iduser,username from #SellerTree where [Path] like @IdUserBaseText

select IdSeller,username from #SellerSubordinates order by username



drop table #SellerTree
drop table #SellerSubordinates
