-- =============================================
-- Author:		Eneas Salazar
-- Create date: 17/04/2018
-- Description:	Agrega nuevos faxs que tuvieron status de no enviado 
-- =============================================
CREATE PROCEDURE [InterFAX].[st_InsertFailedInterfax]
	
	@status int,
	@path nvarchar(MAX),
	@idIF int

AS
BEGIN try
/********************************************************************
<Author> esalazar </Author>
<app>WinService InterFax</app>
<Description> Inserta los archivos con error al ser enviados </Description>

<ChangeLog>
<log Date="02/05/2018" Author="esalazar">Creacion</log>
</ChangeLog>
*********************************************************************/
	INSERT INTO [FAX].[InterFaxNotConfirmed]
           ([IdInterfax]
           ,[Path]
           ,[Status]
		   ,[CreationDate]
           ,[LastChangeDate]
		   ,[IsDel])
     VALUES
           (@idIF
           ,@path
           ,@status
		   ,GETDATE()
		   ,GETDATE()
		   ,0)
END try
BEGIN CATCH
	insert into [MAXILOG].[FAX].[ErrorLogForStoreProcedures] (StoreProcedure,ErrorMessage,ErrorLine,[Parameters])
	select 'InterFAX.st_InsertFailedInterfax', ERROR_MESSAGE(), ERROR_LINE(),('@status: ' + Convert(varchar(10),@status) + '; @path: ' + @path + '; @idIF: ' +Convert(varchar(10),@idIF)) as [Parameters]
END CATCH