CREATE FUNCTION fn_searchItemStr (@Text NVARCHAR(max),@Param VARCHAR(200))
RETURNS VARCHAR(max)
/********************************************************************
<Author>Fabián González</Author>
<app>Agente</app>
<Description>Busca valores JSON en una cadena y los devuelve concatenados</Description>

<ChangeLog>
<log Date="15/11/2016" Author="fgonzalez"> Creación </log>
</ChangeLog>
*********************************************************************/
AS BEGIN

DECLARE @CurrStr VARCHAR(max) , @Cadena VARCHAR(max), @cont INT 
SET @cont=0
SET @cadena =''
SELECT @CurrStr=@Text

WHILE charindex(@Param,@CurrStr) > 0 AND  @cont < 20 BEGIN 

SET @CurrStr = substring(@CurrStr,charindex(@Param,@CurrStr)+1+(len(@Param)+2),1000)
IF (charindex('"',@CurrStr) > 1)
SET @cadena = @cadena + substring(@CurrStr,1,charindex('"',@CurrStr)-1)+', '
SET @cont =  @cont+1
END 

IF (ltrim(@cadena) ='ull,,')
SET @cadena=''

IF substring(@cadena,len(@cadena),1) = ','
SET @cadena = substring(@cadena,1,len(@cadena)-1)

RETURN isnull(@cadena,'')

END 


