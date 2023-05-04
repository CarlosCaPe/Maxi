CREATE PROCEDURE st_executeOnLogout (@IdUser INT) 
AS 
BEGIN

	--Elimina asignaciones pendientes del usuario
	DELETE FROM TransferByHoldReserved WHERE IdUser = @idUser



END 
