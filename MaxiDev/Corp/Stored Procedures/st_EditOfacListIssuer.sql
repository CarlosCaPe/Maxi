CREATE PROCEDURE [Corp].[st_EditOfacListIssuer]
@Id int,
@IssuerId int,
@CurrentUser int,
@NoteOutFromList varchar(max),
@NoteInFromList varchar(max),
@Status int,
@IsNewItem int
as
Begin
  IF(@IsNewItem=0)--Editing
   Begin
	IF(@Status=2)
		Begin
			update DenyListIssuerChecks set DateOutFromList=GETDATE(),
											IdUserDeleter=@CurrentUser,
											EnterByIdUser=@CurrentUser,
											NoteOutFromList=@NoteOutFromList,
											IdGenericStatus=@Status,
											DateOfLastChange=GETDATE()
					where IdDenyListIssuerCheck=@Id
		End
	ELSE
		Begin
			update DenyListIssuerChecks set DateOfLastChange=GETDATE(),
											EnterByIdUser=@CurrentUser,
											NoteInToList=@NoteInFromList,
											NoteOutFromList='',
											DateOutFromList=null,
											IdGenericStatus=1
							where IdDenyListIssuerCheck=@Id
		End
   End
  ELSE--New Issuer
   Begin
    INSERT INTO DenyListIssuerChecks(IdIssuerCheck,DateInToList,IdUserCreater,NoteInToList,IdGenericStatus,EnterByIdUser,DateOfLastChange,NoteOutFromList) values (
		@IssuerId,GETDATE(),@CurrentUser,@NoteInFromList,@Status,@CurrentUser,GETDATE(),@NoteOutFromList
											)

   End
End


--select * from [dbo].[DenyListIssuerChecks]
