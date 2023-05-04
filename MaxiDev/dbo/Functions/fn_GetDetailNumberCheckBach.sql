
CREATE FUNCTION [dbo].[fn_GetDetailNumberCheckBach] (@CheckNumber nvarchar(max), @IdCheckProcessorBank int)
RETURNS NVARCHAR(MAX)
AS
BEGIN

DECLARE @result NVARCHAR(MAX) ='By Scanner Process. Check Number: '

	
SELECT @result = @result +(
				   SELECT ' '+ convert(varchar, CheckNumber) +','
					 FROM Checks ck WITH(NOLOCK)
					WHERE ck.IdStatus = 30
					  AND ck.BachCode IS NOT NULL
					  AND ck.BachCode = @CheckNumber
					  and ck.IdCheckProcessorBank=@IdCheckProcessorBank
					  FOR XML PATH('') 
				  ) 
				
			   FROM Checks ck WITH(NOLOCK)
			  WHERE ck.IdStatus = 30
			    AND ck.BachCode IS NOT NULL
				AND ck.BachCode = @CheckNumber
				and ck.IdCheckProcessorBank=@IdCheckProcessorBank
              GROUP BY BachCode

return  SUBSTRING(@result, 0, LEN(@result))

end
