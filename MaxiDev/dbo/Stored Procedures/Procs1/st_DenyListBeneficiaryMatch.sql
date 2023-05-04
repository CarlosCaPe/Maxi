CREATE Procedure [dbo].[st_DenyListBeneficiaryMatch]  
(  
@BeneficiaryName nvarchar(max),  
@BeneficiaryFirstLastName nvarchar(max),  
@BeneficiarySecondLastName nvarchar(max)  
)  
as  
Set nocount on 

Declare @temp Table  
(
Id int identity(1,1),
Action nvarchar(max),
MessageInEnglish nvarchar(max),
MessageInSpanish nvarchar(max)
) 

Insert into @temp (Action,MessageInEnglish,MessageInSpanish)
Select B.Action ,A.MessageInEnglish ,A.MessageInSpanish  from DenyListBeneficiaryActions A Join KYCAction B ON (A.IdKYCAction=B.IdKYCAction)
Where IdDenyListBeneficiary in
(
Select 
A.IdDenyListBeneficiary                
From dbo.DenyListBeneficiary A JOIN Beneficiary B ON (A.IdBeneficiary=B.IdBeneficiary)
Join Users C on (A.IdUserCreater=C.IdUser)              
Where A.IdGenericStatus=1 AND B.Name like '%'+@BeneficiaryName+'%' AND B.FirstLastName like '%'+@BeneficiaryFirstLastName+'%' AND B.SecondLastName like '%'+@BeneficiarySecondLastName+'%'              
)

Declare @Actions nvarchar(max), @Id int
Set @Actions=''
Set @Id=1

While exists (Select 1 from @temp )
Begin
  Select @Actions=@Actions+'Action:'+Action+ ' ,Message in English :'+MessageInEnglish+' ,Message in Spanish :'+MessageInSpanish  from @temp where Id=@id
  Delete @temp where Id=@id
  Set @Id=@Id+1
end


Select
	A.IdDenyListBeneficiary,
	B.Name,  
	B.FirstLastName,  
	B.SecondLastName,  
	B.Address,  
	B.City,  
	B.State,  
	B.Country,  
	B.Zipcode,  
	B.PhoneNumber,  
	B.CelullarNumber,  
	B.SSnumber,  
	B.BornDate,  
	B.Occupation,  
	C.UserName as EnterBy,  
	A.NoteInToList as Note,  
	A.DateInToList ,  
	@Actions as Actions,
	A.DateOfLastChange,
	CA.UserName as ModifyBy
From dbo.DenyListBeneficiary A JOIN Beneficiary B ON (A.IdBeneficiary=B.IdBeneficiary)
	left Join Users C on (A.IdUserCreater=C.IdUser) 
	left Join Users CA on (A.EnterByIdUser = CA.IdUser)                
Where A.IdGenericStatus=1 AND B.Name like '%'+ @BeneficiaryName +'%' AND B.FirstLastName like '%'+ @BeneficiaryFirstLastName +'%' AND B.SecondLastName like '%'+ @BeneficiarySecondLastName +'%';