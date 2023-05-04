CREATE procedure [dbo].[st_GetSellerParent]
(
    @IdUser int
)
as

/********************************************************************
<Author>--</Author>
<app>Corp</app>
<Description>---</Description>

<ChangeLog>
<log Date="04/01/2019" Author="jdarellano" Name="#1">Se aplica inclusión en filtrado para usuarios en estatus "Suspended".</log>
</ChangeLog>
*********************************************************************/

IF (exists(Select top 1 1 From [Users] where [IdUser] = @IdUser and [IdUserType] = 1)  or
	exists(Select top 1 1 From [Users] U inner join Seller s on s.IdUserSeller=u.IdUser where u.[IdUser] = @IdUser and  s.IdUserSellerParent is null))
	BEGIN
		Select iduser,username
			From [Users] U 
			inner join Seller s on s.IdUserSeller=u.IdUser 
		--where idgenericstatus=1  and  s.IdUserSellerParent is null
		where idgenericstatus in (1,3)  and  s.IdUserSellerParent is null--#1
		order by UserName
	END
ELSE
	BEGIN

		;WITH items AS (
			SELECT iduser,username,userlogin 
			, IdUserSellerParent
			FROM users u
			join seller s on u.iduser=s.iduserseller 
			--WHERE idgenericstatus=1 and u.IdUser=@IdUser
			WHERE idgenericstatus in (1,3) and u.IdUser=@IdUser--#1
    
			UNION ALL

			SELECT u.iduser,u.username,u.userlogin 
			, s.IdUserSellerParent
			FROM users u
			join seller s on u.iduser=s.iduserseller 
			INNER JOIN items itms ON itms.IdUserSellerParent = u.IdUser
			--WHERE idgenericstatus=1
			WHERE idgenericstatus in (1,3)--#1
		)
		SELECT iduser,username FROM items
		order by UserName
	END


