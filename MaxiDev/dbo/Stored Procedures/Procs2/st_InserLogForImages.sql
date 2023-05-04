
CREATE PROCEDURE [dbo].[st_InserLogForImages] 
( 
	@Process varchar(50),
	@Proyect varchar(150),
	@LogType varchar(150),
	@IdUser int,
	@SessionGuid uniqueidentifier,
	@IdAgent int,	
	@IdCheck int,
	@CheckNumber varchar(150),
	@Note varchar(max),
	@ClientDateTime datetime,	
	@ExceptionMessage varchar(max) = NULL,
	@StackTrace varchar(max) = NULL,
	@InnerException varchar(max)= NULL	
) 
AS
/********************************************************************
<Author>Mario Delgado</Author>
<app>MaxiAgente</app>
<Description>Crea un registro de log de escaneo de cheques</Description>

<ChangeLog>
<log Date="12/12/2016" Author="mdelgado"> Creacion </log>
</ChangeLog>
*********************************************************************/
BEGIN 
	SET @ExceptionMessage = ISNULL(@ExceptionMessage,'')
	SET @StackTrace = ISNULL(@StackTrace,'')
	SET @InnerException = ISNULL(@InnerException,'')
	
	INSERT INTO DBO.LogForImages 
		(Process,Proyect,LogType,IdUser,SessionGuid,IdAgent,IdCheck,CheckNumber,Note,ClientDateTime,ServerDateTime,ExceptionMessage,StackTrace)
	VALUES
		(@Process,@Proyect,@LogType,@IdUser,@SessionGuid,@IdAgent,@IdCheck,@CheckNumber,@Note,@ClientDateTime,GETDATE(),@ExceptionMessage,@StackTrace)	
END