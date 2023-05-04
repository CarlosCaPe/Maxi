CREATE FUNCTION [dbo].[fnFormatPhoneNumber](@PhoneNo VARCHAR(20))
RETURNS VARCHAR(25)
AS
/********************************************************************
<Author> Francisco Lara </Author>
<app> All </app>
<Description> Convierte Telefono a formato  </Description>

<ChangeLog>
<log Date="25/09/2017" Author="Fgonzalez"> Se agrega validacion con numeros 12 digitos</log>

</ChangeLog>

*********************************************************************/
BEGIN

SET @PhoneNo = replace(replace(replace(replace(ltrim(rtrim(@PhoneNo)),' ',''),'(',''),')',''),'-','') 
DECLARE @Formatted VARCHAR(25)

IF (LEN(@PhoneNo) <> 10)
    SET @Formatted = @PhoneNo
ELSE
    SET @Formatted = '('+LEFT(@PhoneNo, 3) + ') ' + SUBSTRING(@PhoneNo, 4, 3) + '-' + SUBSTRING(@PhoneNo, 7, 4)

IF (LEN(@PhoneNo) = 12) BEGIN 
    SET @Formatted = LEFT(@PhoneNo,2)+'+ ('+SUBSTRING(@PhoneNo,3,3) + ') ' + SUBSTRING(@PhoneNo,6, 3) + '-' + SUBSTRING(@PhoneNo,9, 12)
END 
IF (LEN(@PhoneNo) = 11) BEGIN 
    SET @Formatted = LEFT(@PhoneNo,1)+'+ ('+SUBSTRING(@PhoneNo,2,3) + ') ' + SUBSTRING(@PhoneNo,5, 3) + '-' + SUBSTRING(@PhoneNo,8, 11)
END 


RETURN @Formatted
END
