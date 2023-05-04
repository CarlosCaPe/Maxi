-- =============================================
-- Author:			Eneas Salazar
-- Create date:		17/04/2018
-- Description:	Actualiza los status de los fax de interfax
-- =============================================
CREATE PROCEDURE [InterFAX].[st_UpdateFailedInterfax]
	
	@idIF int,
	@oldID int,
	@status int,
	@IsD bit
AS
BEGIN try
	/********************************************************************
<Author> esalazar </Author>
<app>WinService InterFax</app>
<Description> cambia a estatus de error </Description>

<ChangeLog>
<log Date="02/05/2018" Author="esalazar">Creacion</log>
</ChangeLog>
*********************************************************************/
	
	if (@IsD=1)
	begin
		Delete [FAX].[InterFaxNotConfirmed] where [IdInterfax]= @oldID
	end
	else
	begin
		UPDATE [FAX].[InterFaxNotConfirmed]
		SET  [IdInterfax]= @idIF
			,[Status] = @status
			,[LastChangeDate] = GETDATE()
			,[IsDel]= @IsD
		WHERE [IdInterfax]= @oldID
	end

END try
BEGIN CATCH
	insert into [MAXILOG].[FAX].[ErrorLogForStoreProcedures] (StoreProcedure,ErrorMessage,ErrorLine,[Parameters])
	select 'InterFAX.st_UpdateFailedInterfax', ERROR_MESSAGE(), ERROR_LINE(),('@idIF: ' + Convert(varchar(10),@idIF) + '; @oldID: ' +Convert(varchar(10),@oldID) + '; @status: ' +Convert(varchar(10),@status) + '; @IsD: ' + Convert(varchar(10),@IsD)) as [Parameters]
END CATCH
