CREATE PROCEDURE [dbo].[st_GetTransferHoldById]
@IdTransfer int,
@IdStatusHold int
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="2013/02/06  Author="Aldo Romo">Created to fill Hold Detail screen using the new MultiHold Logic</log>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
Select T.IdAgent,  A.AgentCode, T.ClaimCode, T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName, 
	   A.AgentName, T.DateOfTransfer, T.IdTransfer, T.Folio, P.PayerName, T.AmountInDollars, T.IdStatus, S.StatusName, 
	   C.PhysicalIdCopy as CustomerPhysicalIdCopy, T.ReviewDenyList, T.ReviewOfac, T.ReviewKyc, T.ReviewGateway, T.ReviewReturned, 
	   T.IdBeneficiary, T.IdCustomer, 0 as ReviewId --T.ReviewId
From [Transfer] T with(nolock)
inner join [Agent] A with(nolock) on T.IdAgent = A.IdAgent
inner join [Customer] C with(nolock) on T.IdCustomer = C.IdCustomer
inner join [Payer] P with(nolock) on T.IdPayer = P.IdPayer
inner join [Status] S with(nolock) on S.IdStatus = @IdStatusHold
Where T.IdTransfer = @IdTransfer
Order by T.DateOfTransfer 

