CREATE PROCEDURE [dbo].[st_GetCheckBrokenRulesHistory] 
( 
@IdCheck int,
@BrokenRule XML OUTPUT 
) 
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

declare @IdIssuer Int 
declare @IdCustomer int
Declare @BrokenRules table 
( 
[Action] nvarchar(max), 
MessageInEnglish nvarchar(max), 
MessageInSpanish nvarchar(max) 
) 
 
 set @IdIssuer=(select IdIssuer from Checks with(nolock) where IdCheck=@IdCheck)
 set @IdCustomer=(select IdCustomer from Checks with(nolock) where IdCheck=@IdCheck)
 --Issuers
Insert into @BrokenRules ([Action],MessageInEnglish,MessageInSpanish) 
Select B.[Action],MessageInEnglish,MessageInSpanish from DenyListIssuerCheckActions A with(nolock) 
Join KYCAction B with(nolock) on (A.IdKYCAction=B.IdKYCAction) 
Join DenyListIssuerChecks C with(nolock) on(A.IdDenyListIssuerCheck=C.IdDenyListIssuerCheck)
JOIN IssuerChecks D with(nolock) on(C.IdIssuerCheck=D.IdIssuer)
Where D.IdIssuer=@IdIssuer

--Customers
Insert into @BrokenRules ([Action],MessageInEnglish,MessageInSpanish) 
Select B.[Action],MessageInEnglish,MessageInSpanish from DenyListCustomerActions A with(nolock) 
Join KYCAction B with(nolock) on (A.IdKYCAction=B.IdKYCAction) 
Join DenyListCustomer C with(nolock) on(A.IdDenyListCustomer=C.IdDenyListCustomer)
Where IdCustomer=@IdCustomer

if exists (Select 1 from @BrokenRules) 
 Set @BrokenRule=IsNull((Select * from @BrokenRules For Xml AUTO,elements,root('Rule')),'<Rule></Rule>') 
Else 
 Set @BrokenRule='<Rule></Rule>' 
 
 

