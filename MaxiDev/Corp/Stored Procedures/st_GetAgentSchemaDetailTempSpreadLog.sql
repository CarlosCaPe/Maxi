CREATE PROCEDURE [Corp].[st_GetAgentSchemaDetailTempSpreadLog]
(
	@IdAgentSchema INT
	,@IdPayerConfig INT
	,@IdAgent INT = NULL
)
/********************************************************************
<Author> ??? </Author>
<app> Corporative </app>
<Description>Get TRansfer Other Products</Description>

<ChangeLog>

<log Date="24/09/2018" Author="Adominguez,">Se agrega NoLock</log>
<log Date="24/09/2018" Author="Amoreno,">Se modifica el Join de User y se agrega el nombre como subconsulta </log>
<log Date="04/10/2018" Author="AZAVALA,">SE AGREGA IF PARA NO TOMAR EN CUENTA IdAgent como filtro si este viene null </log>
</ChangeLog>
*********************************************************************/ 
AS
	
IF(@IdAgent is NOT null)
	BEGIN
		SELECT 
		  UserName = ( 	select U.UserName From Users U (NOLOCK)  where U.IdUser=C.EnterByIdUser)
		  , C.DateOfLastChange
		  , C.CurrentTempSpread 
		  , C.CurrentEndDateTempSpread 
		FROM 
	 		AgentSchemaDetailTempSpreadLog C (NOLOCK)
		WHERE 
			IdAgentSchema=@IdAgentSchema
			AND IdPayerConfig=@IdPayerConfig
			AND IdAgent = @IdAgent
		ORDER BY C.DateOfLastChange DESC
	END
ELSE
	BEGIN
		SELECT 
		  UserName = ( 	select U.UserName From Users U (NOLOCK)  where U.IdUser=C.EnterByIdUser)
		  , C.DateOfLastChange
		  , C.CurrentTempSpread 
		  , C.CurrentEndDateTempSpread 
		FROM 
	 		AgentSchemaDetailTempSpreadLog C (NOLOCK)
		WHERE 
			IdAgentSchema=@IdAgentSchema
			AND IdPayerConfig=@IdPayerConfig
		ORDER BY C.DateOfLastChange DESC
	END

	/*
	SELECT U.UserName ,C.DateOfLastChange, C.CurrentTempSpread , C.CurrentEndDateTempSpread 
	FROM AgentSchemaDetailTempSpreadLog C with (NOLOCK)
		JOIN Users U with (NOLOCK)  ON C.EnterByIdUser =U.IdUser
	WHERE IdAgentSchema=@IdAgentSchema
		AND IdPayerConfig=@IdPayerConfig
	ORDER BY C.DateOfLastChange DESC
*/

