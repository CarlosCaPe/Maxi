CREATE FUNCTION [dbo].[sf_RemoveExtraChars] (@NAME nvarchar(4000))
RETURNS nvarchar(50)
AS
BEGIN
  declare @TempString varchar(8000)
  set @TempString = @NAME 
  --set @TempString = LOWER(@TempString)
  --set @TempString =  replace(@TempString,' ', '')
  set @TempString =  replace(@TempString,'Á', 'A')
  set @TempString =  replace(@TempString,'è', 'e')
  set @TempString =  replace(@TempString,'é', 'e')
  set @TempString =  replace(@TempString,'Í', 'I')
  set @TempString =  replace(@TempString,'Ó', 'O')
  set @TempString =  replace(@TempString,'Ú', 'U')
  set @TempString =  replace(@TempString,'ç', 'c')
  --set @TempString =  replace(@TempString,'''', '')
  --set @TempString =  replace(@TempString,'`', '')
  --set @TempString =  replace(@TempString,'-', '')
  return @TempString
END