
CREATE PROCEDURE [Checks].[st_BulkRejetedChek]
   @IdCheck int  
   , @IdStatus int
   , @Note nvarchar(max)       
   , @IdUser int    
  
AS

/********************************************************************
<Author>Amoreno</Author>
<app>MaxiAgente</app>
<Description>Rechazar Cheque</Description>

<ChangeLog>

<log Date="30/05/2018" Author="amoreno">Creation</log>
<log Date="05/10/2018" Author="jmolina">Se agrego validación de si existe cheque rechazado no continue con el proceso</log>
</ChangeLog>
*********************************************************************/

	IF EXISTS(SELECT 1 FROM dbo.CheckDetails with(nolock) WHERE 1 = 1 AND IdCheck = @IdCheck AND IdStatus = 31)
	BEGIN
		INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage, ExtraData)
		VALUES('st_BulkRejetedChek', GETDATE(), 'Doble cancelación de cheque desde "Bulk Check Reject"', 'Parametros: ' + CONVERT(VARCHAR(15), @IdCheck) + ', ' + CONVERT(VARCHAR(5), @IdStatus) + ', ' + @Note + ', ' + CONVERT(VARCHAR(5), @IdUser))
		RETURN
	END

Update checks Set IdStatus=31,DateStatusChange=GETDATE() Where IdCheck=@IdCheck  

	execute [Checks].[st_CheckCancelToAgentBalance]
	  @IdCheck 					= @IdCheck,
	    @EnterByIdUser 	= @IdUser,
	    @IsReject  			= 1 
	
	
	
	execute[Checks].[st_SaveChangesToCheckLog]  
	    @Idcheck 			= @IdCheck          
	    , @IdStatus  	= @IdStatus         
	    , @Note    		= @Note     
	    , @IdUser  		= @IdUser  
	
 select IdStatus, IdAgent, Amount  from checks where IdCheck=@IdCheck 

