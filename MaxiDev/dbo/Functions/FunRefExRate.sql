CREATE function  [dbo].[FunRefExRate] (@IdCountryCurrency money, @IdGateway money, @IdPayer money)  
RETURNS Money
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
BEGIN   
  
        Declare @RefExRate  Money  
        Set @RefExRate=0  
        If Exists (Select 1 From RefExRate with(nolock) where IdCountryCurrency=@IdCountryCurrency and Active=1 and RefExRate<>0 and IdGateway=@IdGateway and IdPayer=@IdPayer)  
        Begin
			Select @RefExRate=RefExRate from RefExRate with(nolock) where IdCountryCurrency=@IdCountryCurrency and Active=1 and RefExRate<>0 and @IdGateway=IdGateway and @IdPayer=IdPayer  
        End 
   else
      Begin  
			If exists (Select 1 From RefExRate with(nolock) where IdCountryCurrency=@IdCountryCurrency and Active=1 and RefExRate<>0 and @IdGateway=IdGateway and IdPayer is NUll  )  
			    Begin
					Select @RefExRate=RefExRate from RefExRate with(nolock) where IdCountryCurrency=@IdCountryCurrency and Active=1 and  RefExRate<>0 and @IdGateway=IdGateway   and IdPayer is NUll
				End
			Else  
			   Begin	
				If exists (Select 1 From RefExRate with(nolock) where IdCountryCurrency=@IdCountryCurrency and Active=1 and IdGateway is NULL and IdPayer is NULL )  
					Select @RefExRate=RefExRate from RefExRate with(nolock) where IdCountryCurrency=@IdCountryCurrency and Active=1 and IdGateway is NULL and IdPayer is NULL
				Else  
					Set @RefExRate=0  
			End
      End  
        
           
        Return @RefExRate  
END
