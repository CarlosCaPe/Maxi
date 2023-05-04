
CREATE PROCEDURE [dbo].[st_GetDialingCodePhoneNumber] 
AS
/********************************************************************
<Author>Unknow</Author>
<date>Unknow</date>
<app>MaxiAgente</app>
<Description>Sp para obtener datos de codigo de area de telefono de paises</Description>

<ChangeLog>
<log Date="03/10/2022" Author="maprado">Add MinPhoneLength, MaxPhoneLength  </log>
</ChangeLog>
*********************************************************************/
BEGIN
	
	SET NOCOUNT ON;

	SELECT IdDialingCodePhoneNumber
		,IdCountry
		,DialingCode
		,Prefix
		,MinPhoneLength
		,MaxPhoneLength
		,PhoneLength
	FROM DialingCodePhoneNumber WITH (NOLOCK)
	ORDER BY DialingCode;

END
