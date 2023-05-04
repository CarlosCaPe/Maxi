
create Procedure st_GetIdForNewIssuerInserted
@IdIssuer int,
@Status int,
@NoteIn varchar(max),
@NoteOut varchar(max)
as
Begin
	select IdDenyListIssuerCheck as Id from DenyListIssuerChecks as dl
	where	dl.IdIssuerCheck=@IdIssuer
			and dl.IdGenericStatus=@Status
			and dl.NoteInToList=@NoteIn
			and dl.NoteOutFromList is null
		
End