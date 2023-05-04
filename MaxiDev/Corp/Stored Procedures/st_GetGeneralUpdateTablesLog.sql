CREATE PROCEDURE Corp.st_GetGeneralUpdateTablesLog
	@TableName 	VARCHAR(30),
	@IdRow		INT,
	@IdTextRow	VARCHAR(255)
AS
BEGIN

 SELECT L.IdLog, L.TableName, L.RowName, L.OldValue, L.NewValue, L.IdUser, U.UserLogin, L.IdRow, L.IdTextRow, L.DateOfCreation, L.Description 
 FROM dbo.GeneralUpdateTablesLog L WITH(NOLOCK)
 	INNER JOIN dbo.Users U WITH(NOLOCK) ON U.IdUser = L.IdUser
 WHERE TableName = @TableName
 	AND (IdTextRow = @IdTextRow OR IdRow = @IdRow)

END