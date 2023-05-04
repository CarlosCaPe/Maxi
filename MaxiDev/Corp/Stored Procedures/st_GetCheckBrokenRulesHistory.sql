CREATE PROCEDURE [Corp].[st_GetCheckBrokenRulesHistory] 
( 
@IdCheck int,
@BrokenRule XML OUTPUT 
) 
as 
Set nocount on 

declare @IdIssuer Int 
declare @IdCustomer int
Declare @BrokenRules table 
( 
Action nvarchar(max), 
MessageInEnglish nvarchar(max), 
MessageInSpanish nvarchar(max) 
) 
 
 set @IdIssuer=(select IdIssuer from Checks where IdCheck=@IdCheck)
 set @IdCustomer=(select IdCustomer from Checks where IdCheck=@IdCheck)
 --Issuers
Insert into @BrokenRules (Action,MessageInEnglish,MessageInSpanish) 
Select B.Action,MessageInEnglish,MessageInSpanish from DenyListIssuerCheckActions A 
Join KYCAction B on (A.IdKYCAction=B.IdKYCAction) 
Join DenyListIssuerChecks C on(A.IdDenyListIssuerCheck=C.IdDenyListIssuerCheck)
JOIN IssuerChecks D on(C.IdIssuerCheck=D.IdIssuer)
Where D.IdIssuer=@IdIssuer

--Customers
Insert into @BrokenRules (Action,MessageInEnglish,MessageInSpanish) 
Select B.Action,MessageInEnglish,MessageInSpanish from DenyListCustomerActions A 
Join KYCAction B on (A.IdKYCAction=B.IdKYCAction) 
Join DenyListCustomer C on(A.IdDenyListCustomer=C.IdDenyListCustomer)
Where IdCustomer=@IdCustomer

if exists (Select 1 from @BrokenRules) 
 Set @BrokenRule=IsNull((Select * from @BrokenRules For Xml AUTO,elements,root('Rule')),'<Rule></Rule>') 
Else 
 Set @BrokenRule='<Rule></Rule>' 
 
 


