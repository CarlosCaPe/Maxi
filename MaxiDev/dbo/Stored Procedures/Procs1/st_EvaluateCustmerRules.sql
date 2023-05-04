/********************************************************************
<Author>Not Known</Author>
<app>MaxiAgent</app>
<Description></Description>

<ChangeLog>
<log Date="27/05/2019" Author="azavala">Coincidencia de Customer y Beneficiario por ID o por 100% match en nombre, apellidos, Direccion, Ciudad y estado; Ref:: 270520190150_azavala </log>
</ChangeLog>
********************************************************************/
CREATE PROCEDURE [dbo].[st_EvaluateCustmerRules]
(
@CustomerName nvarchar(max),
@CustomerFirstLastName nvarchar(max),
@CustomerSecondLastName nvarchar(max),
@IdCustomer int 
)
AS
Set nocount on
SET ARITHABORT ON

-------------------------------  Incremento Performance , uso de Customer.FullName y Beneficiary.FullName ---------------------------------

Declare @CustomerFullName nvarchar(120)

Set @CustomerFullName=REPLACE ( Substring(@CustomerName,1,40)+Substring(@CustomerFirstLastName,1,40)+Substring(@CustomerSecondLastName,1,40), ' ','')

-----------------------------Tabla temporal de reglas-----------------------------------------
Declare @Rules Table
				(
				Id int identity(1,1),
				IdRule int,
				RuleName nvarchar(max),
				IdPayer int,
				IdPaymentType int,
				IdAgent int,
				IdCountry int,
				IdGateway int,
				Actor nvarchar(max),
				Symbol nvarchar(max),
				Amount money,
				AgentAmount bit,
				IdCountryCurrency int,
				TimeInDays int,
				Action int,
				MessageInSpanish nvarchar(max),
				MessageInEnglish nvarchar(max),
				IsDenyList bit,
				Factor Decimal (18,2),
				SSNRequired bit not null default 0
				)

-----------------------------------------Se inserta regla general  -----------------------------------------------

Insert into @Rules (RuleName,Action,MessageInEnglish,MessageInSpanish,IsDenyList)
Select
'Required Fields' as RuleName,
1 as Action,
'ID is required' as MessageInEnglish,
'ID es requerida' as MessageInSpanish,
0 as SSNRequired

----------------------------------------------------  black list --------------------------------------------------

Insert into @Rules (RuleName,Action,MessageInEnglish,MessageInSpanish,IsDenyList)
select RuleNameInEnglish RuleName,r.IdCBLaction [Action],MessageInEnglish,MessageInSpanish,0 IsDenyList
from customerblacklist b
left join customerblacklistrule r on b.IdCustomerBlackListRule=r.idcustomerblacklistrule
where r.idgenericstatus=1 and b.idgenericstatus=1 and b.idcustomer=@IdCustomer

------------------------------------------- end black list --------------------------------------------------------

----------------------------------------- variables for Deny List -----------------------------------------------

Declare @CustomerIdKYCAction int
Declare @BeneficiaryIdKYCAction int
Declare @DenyListMessageInSpanish nvarchar(max)
Declare @DenyListMessageInEnglish nvarchar(max)
Set @CustomerIdKYCAction=0
Set @BeneficiaryIdKYCAction=0


--------------------------- Deny List for customer -------------------------------------------------------------------------------------
/*Start 270520190150_azavala */
Declare @tempCustomer Table    
(  
Id int,  
[Name] varchar(max),  
[FirstLastName] varchar(max),  
[SecondLastName] varchar(max),
[Address] varchar(max),
[City] varchar(max),
[State] varchar(max)
)
Insert into @tempCustomer (Id,[Name], [FirstLastName],SecondLastName,[Address],[City],[State])
select C.IdCustomer, [Name], FirstLastName, SecondLastName, [Address], [City], [State] 
from Customer C with(nolock) inner join DenyListCustomer D with(nolock) on C.IdCustomer=D.IdCustomer
where D.IdGenericStatus=1 and C.IdCustomer=@IdCustomer

if not exists (select 1 from @tempCustomer)
begin
	Insert into @tempCustomer (Id,[Name], [FirstLastName],SecondLastName,[Address],[City],[State])
	Select t.IdCustomer, Cu.[Name], Cu.FirstLastName, Cu.SecondLastName, Cu.[Address], Cu.[City], Cu.[State] from 
	(select C.IdCustomer, C.[Name], C.FirstLastName, C.SecondLastName, C.[Address], C.[City], C.[State] 
	from Customer C with(nolock) inner join DenyListCustomer D with(nolock) on C.IdCustomer=D.IdCustomer
	where D.IdGenericStatus=1 and C.FullName=@CustomerFullName) t, Customer Cu with(nolock)
	where Cu.IdCustomer=@IdCustomer and Cu.[Address]=t.[Address] and Cu.City=t.City and Cu.[State]=t.[State]
end

/*End 270520190150_azavala */

Insert into @Rules (RuleName,Action,MessageInEnglish,MessageInSpanish,IsDenyList)
Select
'Deny List' as RuleName,
C.IdKYCAction,
C.MessageInEnglish,
C.MessageInSpanish,
1 as IsDenyList
From dbo.DenyListCustomer A With (nolock)
JOIN Customer B With (nolock) ON (A.IdCustomer=B.IdCustomer)
JOIN DenyListCustomerActions C With (nolock) ON (C.IdDenyListCustomer=A.IdDenyListCustomer)
join @tempCustomer t on t.id=B.IdCustomer --270520190150_azavala
Where A.IdGenericStatus=1 AND B.FullName=@CustomerFullName

Select RuleName,Action,MessageInSpanish,MessageInEnglish,IsDenyList,SSNRequired from @Rules