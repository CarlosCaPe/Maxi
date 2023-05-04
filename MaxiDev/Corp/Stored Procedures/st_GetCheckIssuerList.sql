CREATE PROCEDURE [Corp].[st_GetCheckIssuerList]
@Search varchar(max)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Begin
	--declare @Search varchar(max)=''
	SELECT
	    dl.IdDenyListIssuerCheck as Id,
		dl.IdIssuerCheck as IssuerCheck,
		dl.IdGenericStatus as [Status],
		ic.Name as Name,
		ic.RoutingNumber as RoutingNumber,
		ic. AccountNumber as AccountNumber,
		ic.IdIssuer as IdIssuer,
		dl.NoteInToList as NoteInToList,
		dl.NoteOutFromList as NoteOutFromList
		
	FROM
		IssuerChecks ic with(nolock) join DenyListIssuerChecks dl with(nolock)
		on dl.IdIssuerCheck=ic.IdIssuer
	WHERE
		ic.Name like '%' + @Search  + '%' and dl.IdGenericStatus=1
End

