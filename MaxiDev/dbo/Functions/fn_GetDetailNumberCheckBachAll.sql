
CREATE FUNCTION [dbo].[fn_GetDetailNumberCheckBachAll] 
(@IdAgent int, @IdCheckProcessorBank INT, @PayDate DATETIME)
RETURNS NVARCHAR(MAX)
AS
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
BEGIN

         
     

DECLARE @result NVARCHAR(MAX) ='By Scanner Process, Batch Number: '

	
set @result = @result +(
								SELECT ' '+ convert(varchar, CheckNumber) +','
								FROM Checks ck with(nolock)
								WHERE   ck.IdStatus = 30
										AND ck.IdAgent = @IdAgent
										AND ck.IdCheckProcessorBank=@IdCheckProcessorBank
										AND ck.DateStatusChange =@PayDate
								FOR XML PATH('') 
						  ) 	
    

RETURN  SUBSTRING(@result, 0, LEN(@result))

END
