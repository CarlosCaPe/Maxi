CREATE Procedure [Corp].[st_DenyListIssuerMatch]    
(    
@CustomerName nvarchar(max),    
@CustomerFirstLastName nvarchar(max),    
@CustomerSecondLastName nvarchar(max)    
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
Select B.Action ,A.MessageInEnglish ,A.MessageInSpanish  from [dbo].[DenyListIssuerCheckActions] A WITH(NOLOCK) Join KYCAction B WITH(NOLOCK) ON (A.IdKYCAction=B.IdKYCAction)  
Where IdDenyListIssuerCheck in  
(  
Select   
A.IdDenyListIssuerCheck                  
From DenyListIssuerChecks A JOIN [dbo].[IssuerChecks] B WITH(NOLOCK) ON (A.IdIssuerCheck =B.[IdIssuer])  
Join Users C WITH(NOLOCK) on (A.IdUserCreater=C.IdUser)                
Where A.IdGenericStatus=1 AND B.Name like '%'+@CustomerName+'%'             
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
A.[IdDenyListIssuerCheck],              
B.Name,    
'' FirstLastName,    
'' SecondLastName,    
'' Address,    
'' City,    
'' State,    
'' Country,    
'' Zipcode,    
'' PhoneNumber,    
'' CelullarNumber,    
'' SSNumber,    
'' BornDate,    
'' Occupation,    
'' IdentificationNumber,    
'' PhysicalIdCopy,  
C.UserName as EnterBy,  
A.NoteInToList as Note,  
A.DateInToList ,  
@Actions as Actions,
A.DateOfLastChange,
CA.UserName as ModifyBy
From dbo.DenyListIssuerChecks A WITH(NOLOCK) JOIN dbo.IssuerChecks B WITH(NOLOCK) ON (A.IdIssuerCheck=B.IdIssuer)  
left Join Users C WITH(NOLOCK) on (A.IdUserCreater=C.IdUser)                
left Join Users CA WITH(NOLOCK) on (A.EnterByIdUser = CA.IdUser)                
Where A.IdGenericStatus=1 AND B.Name like '%'+@CustomerName+'%'

