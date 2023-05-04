CREATE PROCEDURE st_getDocumenExceptions 
(
@DocumentType INT,
@StateCode VARCHAR(5)
)
AS
/********************************************************************
<Author>Fabián González</Author>
<app>Corporativo [Seller]</app>
<Description>Busca excepciones por estado y tipo de documento</Description>

<ChangeLog>
<log Date="15/12/2016" Author="fgonzalez"> Creación </log>
</ChangeLog>
*********************************************************************/
BEGIN  

SELECT DocumentType,StateCode,DocumentPath FROM DocumentTypeExceptions WHERE StateCode =@StateCode AND DocumentType =@DocumentType

END 