CREATE PROCEDURE [Corp].[st_BulkRejetedChek_Checks]
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
<log Date="15/01/2020" Author ="jrivera">Se agrego execute de notifificaciones desde bulk check reject</log>
</ChangeLog>
*********************************************************************/

	IF EXISTS(SELECT 1 FROM dbo.CheckDetails with(nolock) WHERE 1 = 1 AND IdCheck = @IdCheck AND IdStatus = 31)
	BEGIN
		INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage, ExtraData)
		VALUES('st_BulkRejetedChek', GETDATE(), 'Doble cancelación de cheque desde "Bulk Check Reject"', 'Parametros: ' + CONVERT(VARCHAR(15), @IdCheck) + ', ' + CONVERT(VARCHAR(5), @IdStatus) + ', ' + @Note + ', ' + CONVERT(VARCHAR(5), @IdUser))
		RETURN
	END

Update checks Set IdStatus=31,DateStatusChange=GETDATE() Where IdCheck=@IdCheck  

	execute [Corp].[st_CheckCancelToAgentBalance_Checks]
	  @IdCheck 					= @IdCheck,
	    @EnterByIdUser 	= @IdUser,
	    @IsReject  			= 1 
	
	execute [Corp].[st_SaveChangesToCheckLog_Checks]  
	    @Idcheck 			= @IdCheck          
	    , @IdStatus  	= @IdStatus         
	    , @Note    		= @Note     
	    , @IdUser  		= @IdUser  

	execute  [Corp].[st_RejectCheckNotificationFromBulkCheck]
		@IdCheck   = @IdCheck,
		@EnterByIdUser = @IdUser,
		@Note = @Note 
	
 select IdStatus, IdAgent, Amount  from checks with(nolock) where IdCheck=@IdCheck 


