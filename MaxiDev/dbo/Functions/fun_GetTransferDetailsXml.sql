-- ==============================================
-- Author:	 Aldo Romo
-- Create date: 2013-06-19
-- Description: Returns a xml representing 
--			 transfer's details
-- ==============================================
CREATE FUNCTION [dbo].[fun_GetTransferDetailsXml]
(
	-- Add the parameters for the function here
	@IdTransfer Int
)
RETURNS XML
AS
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
BEGIN
	-- Declare the return variable here
	DECLARE @Result XML

	Declare @Detail table 
		(
		IdStatus INT,
		StatusName nvarchar(max),
		DateDeatil datetime,
		Users nvarchar(max),
		Note nvarchar(max),
		IdMessage int,
		IdGenericStatus int
		) 

	-- Add the T-SQL statements to compute the return value here

	If exists(Select 1 From [Transfer] with(nolock) where IdTransfer=@IdTransfer) 
	Begin
		Insert into @Detail (IdStatus,StatusName,DateDeatil,Users,Note, IdMessage, IdGenericStatus)
		Select 
			IsNull(A.IdStatus,0),
			IsNull(E.StatusName,'Nota de lo migrado'),
			IsNull(B.EnterDate,A.DateOfMovement) as DateDetail,
			IsNull(D.UserName,'System') as Users,
			IsNull(B.Note,'') as Note,
			IsNull(TNN.IdMessage,0) as IdMessage,
			IsNull(TNN.IdGenericStatus,0) as IdGenericStatus
		From TransferDetail A with(nolock)
			Left Join TransferNote B with(nolock) on (A.IdTransferDetail=B.IdTransferDetail)
			Left Join Users D with(nolock) on (B.IdUser=D.IdUser)
			Left Join [Status] E with(nolock) on (A.IdStatus=E.IdStatus)
			Left Join TransferNoteNotification TNN with(nolock) on (B.IdTransferNote= TNN.IdTransferNote)
		Where IdTransfer=@IdTransfer order by DateDetail
 
	End Else Begin
		Insert into @Detail (IdStatus,StatusName,DateDeatil,Users,Note,IdMessage,IdGenericStatus) 
		Select 
			Isnull(A.IdStatus,0),
			Isnull(E.StatusName,'Nota de lo migrado'),
			Isnull(B.EnterDate,A.DateOfMovement) as DateDetail,
			Isnull(D.UserName,'System') as Users,
			Isnull(B.Note,'') as Note,
			IsNull(TCNN.IdMessage,0) as IdMessage,
			IsNull(TCNN.IdGenericStatus,0) as IdGenericStatus
		 From TransferClosedDetail A with(nolock) 
			 Left Join TransferClosedNote B with(nolock) on (A.IdTransferClosedDetail=B.IdTransferClosedDetail) 
			 Left Join Users D with(nolock) on (B.IdUser=D.IdUser) 
			 Left Join [Status] E with(nolock) on (A.IdStatus=E.IdStatus) 
			 Left Join TransferClosedNoteNotification TCNN with(nolock) on (B.IdTransferClosedNote = TCNN.IdTransferClosedNote)
		 Where IdTransferClosed=@IdTransfer order by DateDetail 

	End

	If exists(Select 1 from @Detail ) 
		Set @Result=IsNull((Select * from @Detail order by DateDeatil For Xml AUTO,elements,root('TransferDetail')),'<TransferDetail></TransferDetail>') 
	Else 
		Set @Result='<TransferDetail></TransferDetail>' 

	-- Return the result of the function
	RETURN @Result
END
