CREATE PROCEDURE [Corp].[st_GetCollectionGroupsByUserId_Collection]
(
    @IdUser int = NULL
)
AS
IF @IdUser = 0 
	SET @IdUser = NULL
ELSE
BEGIN
	DECLARE @IsAdmin INT
	SELECT @IsAdmin=isadmin FROM [CollectionUsers] WHERE iduser=@IdUser
	SET @IsAdmin=isnull(@IsAdmin,0)
END
IF (@IsAdmin > 0)
	SELECT DISTINCT IdGroups IdGroup, groupName [Group] FROM [Collection].[Groups] with(nolock) where idgenericstatus=1 order by [Group] 
ELSE
	SELECT DISTINCT IdGroups IdGroup, groupName [Group] FROM [Collection].[Groups] with(nolock) WHERE idgenericstatus=1 and IdUserAssign = ISNULL(@IdUser, IdUserAssign) order by [Group]
