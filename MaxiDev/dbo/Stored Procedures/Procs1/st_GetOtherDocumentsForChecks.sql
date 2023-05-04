CREATE procedure [dbo].[st_GetOtherDocumentsForChecks]
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

select IdDocumentType,dbo.GetMessageFromMultiLenguajeResorces(1,name) NameEn,dbo.GetMessageFromMultiLenguajeResorces(2,name) NameEs 
from DocumentTypes with(nolock) 
where idtype=4 and Name!='Transaction Receipt' and Name != 'Source of Funds'