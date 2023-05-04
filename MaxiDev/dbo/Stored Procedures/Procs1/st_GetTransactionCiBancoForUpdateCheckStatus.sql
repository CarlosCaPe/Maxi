CREATE procedure [dbo].[st_GetTransactionCiBancoForUpdateCheckStatus]    
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

Select 3 as ReturnCodeType, claimcode as BenefReferenceID, ClaimCode  from [Transfer] with(nolock)     
where IdGateway=10 and IdStatus in (23,26,28,40,29)  

