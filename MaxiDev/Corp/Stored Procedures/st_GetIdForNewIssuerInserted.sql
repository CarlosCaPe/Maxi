CREATE PROCEDURE [Corp].[st_GetIdForNewIssuerInserted]
@IdIssuer int,
@Status int,
@NoteIn varchar(max),
@NoteOut varchar(max)
AS

BEGIN
	/********************************************************************
	<Author> Unknown </Author>
	<Date> </Date>
	<app>Cronos</app>
	<Description>  </Description>

	<ChangeLog>
	<log Date="20/05/2022" Author="cagarcia">Ajuste para Deny List / https://maxitransfersllc.freshservice.com/helpdesk/tickets/2671</log>
	</ChangeLog>
	*********************************************************************/
	
	SELECT TOP 1 IdDenyListIssuerCheck AS Id 
	FROM DenyListIssuerChecks as dl with(nolock)
	WHERE dl.IdIssuerCheck=@IdIssuer
		AND dl.IdGenericStatus=@Status
		AND dl.NoteInToList=@NoteIn
		AND isnull(dl.NoteOutFromList, '') = ''
		
End

