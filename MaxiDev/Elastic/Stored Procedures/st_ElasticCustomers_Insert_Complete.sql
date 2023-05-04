
CREATE PROCEDURE [Elastic].[st_ElasticCustomers_Insert_Complete] (
@data xml,
@result varchar(max) output,
@Error bit output
)
AS 
/********************************************************************
<Author> Alexis Zavala </Author>
<app> Elastic Search </app>
<Description> Introduce el id de elastic search dentro de la tabla Customers </Description>

<ChangeLog>
	<log Date="18/01/2018" Author="azavala">Creacion</log>
</ChangeLog>
*********************************************************************/
BEGIN try
DECLARE @XMLTable TABLE (IdCustomer int, idElasticCustomer VARCHAR(200))


DECLARE @DocHandle INT 
EXEC sp_xml_preparedocument @DocHandle OUTPUT, @data;

INSERT INTO @XMLTable (IdCustomer,idElasticCustomer)
SELECT 
idBase,idIndex
FROM OPENXML (@DocHandle, 'ArrayOfLocationMapper/LocationMapper',2)    
WITH ( 
idBase int,   
idIndex VARCHAR(200)
)

UPDATE T1
		SET    T1.idElasticCustomer = T2.idElasticCustomer
		FROM   dbo.Customer T1
			   JOIN @XMLTable T2
				 ON T1.IdCustomer = T2.IdCustomer

INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage, ExtraData) VALUES('st_ElasticCustomers_Insert_Complete', GETDATE(), 'Validando actualizado de customers', CONVERT(VARCHAR(MAX), @data))

SELECT @result = 'Base de Datos OK', @Error = 0

END try
BEGIN CATCH
	SELECT @result = 'Ocurrio un problema al actualizar los datos ' + ERROR_MESSAGE(), @Error = 1
END CATCH
