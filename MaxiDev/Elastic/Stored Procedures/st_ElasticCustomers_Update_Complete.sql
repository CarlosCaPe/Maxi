


CREATE PROCEDURE elastic.st_ElasticCustomers_Update_Complete (
@data xml,
@result varchar(max) output,
@Error bit output
)
AS 
/********************************************************************
<Author> Alexis Zavala </Author>
<app> WinService (Maxi_ElasticSearchCustomerProcess) </app>
<Description> Actualización de usuarios con update pendiente </Description>

<ChangeLog>
<log Date="31/07/2018" Author="azavala">Creacion</log>
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
		SET    T1.UpdateCompleted=1, T1.RequestUpdate=0
		FROM   dbo.Customer T1
			   JOIN @XMLTable T2
				 ON T1.IdCustomer = T2.IdCustomer

SELECT @result = 'Base de Datos OK', @Error = 0

END try
BEGIN CATCH
	SELECT @result = 'Ocurrio un problema al actualizar los datos ' + ERROR_MESSAGE(), @Error = 1
END CATCH
