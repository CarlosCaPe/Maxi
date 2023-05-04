CREATE PROCEDURE [dbo].[st_DenyListCustomerMatch]    
(    
@CustomerName nvarchar(max),    
@CustomerFirstLastName nvarchar(max),    
@CustomerSecondLastName nvarchar(max)    
)    
as    
--Set nocount on   
  
Declare @temp Table    
(  
Id int identity(1,1),  
Action nvarchar(max),  
MessageInEnglish nvarchar(max),  
MessageInSpanish nvarchar(max)  
)   
  
Insert into @temp (Action,MessageInEnglish,MessageInSpanish)  
Select B.Action ,A.MessageInEnglish ,A.MessageInSpanish  from DenyListCustomerActions A Join KYCAction B ON (A.IdKYCAction=B.IdKYCAction)  
Where IdDenyListCustomer in  
(  
Select   
A.IdDenyListCustomer                  
From dbo.DenyListCustomer A JOIN Customer B ON (A.IdCustomer=B.IdCustomer)  
Join Users C on (A.IdUserCreater=C.IdUser)                
Where A.IdGenericStatus=1 AND B.Name like '%'+ @CustomerName +'%' AND B.FirstLastName like '%'+@CustomerFirstLastName+'%' AND B.SecondLastName like '%'+ @CustomerSecondLastName +'%'               
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
	A.IdDenyListCustomer,              
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
	B.SSNumber,    
	B.BornDate,    
	B.Occupation,    
	B.IdentificationNumber,    
	B.PhysicalIdCopy,  
	C.UserName as EnterBy,  
	A.NoteInToList as Note,  
	A.DateInToList ,  
	@Actions as Actions,
	A.DateOfLastChange,
	CA.UserName as ModifyBy
From dbo.DenyListCustomer A JOIN Customer B ON (A.IdCustomer=B.IdCustomer)  
	left Join Users C on (A.IdUserCreater=C.IdUser)                
	left Join Users CA on (A.EnterByIdUser = CA.IdUser)                
Where A.IdGenericStatus=1 AND B.Name like '%'+ @CustomerName +'%' AND B.FirstLastName like '%'+@CustomerFirstLastName+'%' AND B.SecondLastName like '%'+ @CustomerSecondLastName +'%';              
