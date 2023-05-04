
--REVISAR QUE EXISTA EN GLOBAL ATTRIBUTES ESTA LLAVE CON VALOR.!!!!!!!!!!!!!!!!!!!!
--OBTENER LAS DIRECCIONES DE CORREO PARA NOTIFICACIONES
create PROCEDURE [dbo].[st_GetListEmailErrors]
(
@Destination as nvarchar(250) output
)	
AS
BEGIN
	SET @Destination = dbo.GetGlobalAttributeByName('ListEmailErrors')
END
