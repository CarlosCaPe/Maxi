CREATE Procedure [Corp].[st_GetNewAgentCode]
(
@StateCode varchar(max),
@EnterByIdUser int,
@AgentCode varchar(max) Output,
@IsValid bit Output
)
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Declare @Folio int;

If Exists (Select 1 from ZipCode with(nolock) where StateCode=@StateCode)
	Begin
		                                                                                         
		 Update AgentCode Set Folio=Folio+1, @Folio=Folio+1;                                                                                            
		
		Set @AgentCode=CONVERT(Varchar,@Folio)+'-'+Upper(@StateCode);
		Insert into [dbo].AgentCodeGenerationLog 
		(
		AgentCode,
		EnterByIdUser,
		DateOfCreation
		)
		Values
		(
		@AgentCode,
		@EnterByIdUser,
		GETDATE()
		);
		
		Set @IsValid=1
	End
Else
	Begin
		Set @IsValid=0
	End


