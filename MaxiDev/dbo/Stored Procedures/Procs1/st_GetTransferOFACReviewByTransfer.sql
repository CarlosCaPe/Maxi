CREATE procedure [dbo].[st_GetTransferOFACReviewByTransfer]
(
	@IdTransfer int
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/ 
set nocount on

SELECT 
	TransferOFACReview.IdTransferOFACReview, 
	TransferOFACReview.IdTransfer, 
	TransferOFACReview.DateOfReview, 
	Users.UserName
FROM TransferOFACReview with(nolock) 
	INNER JOIN Users with(nolock) ON TransferOFACReview.IdUserReview = Users.IdUser
WHERE        (TransferOFACReview.IdTransfer = @IdTransfer)
	and (TransferOFACReview.IdOFACAction =1)



