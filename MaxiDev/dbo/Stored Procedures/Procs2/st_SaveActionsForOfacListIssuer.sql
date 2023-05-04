
CREATE Procedure [dbo].[st_SaveActionsForOfacListIssuer]
@Id int,
@IdIssuer int,
@IdAction int,
@EnglishMsg varchar(max),
@SpanishMsg varchar(max),
@DeleteItem int
as
Begin
	IF (NOT EXISTS(SELECT * FROM DenyListIssuerCheckActions WHERE IdDenyListIssuerCheckAction=@Id))
		Begin
			INSERT into DenyListIssuerCheckActions values(
			@IdIssuer,@IdAction,@EnglishMsg,@SpanishMsg)
		End
	ELSE
		Begin
			if(@DeleteItem=0)
				Begin
					Update DenyListIssuerCheckActions set IdDenyListIssuerCheck=@IdIssuer,IdKYCAction=@IdAction,MessageInEnglish=@EnglishMsg,MessageInSpanish=@SpanishMsg
					where IdDenyListIssuerCheckAction=@Id
				End
			else
				Begin
					delete from DenyListIssuerCheckActions where IdDenyListIssuerCheckAction=@Id
				End
		End

	
End
