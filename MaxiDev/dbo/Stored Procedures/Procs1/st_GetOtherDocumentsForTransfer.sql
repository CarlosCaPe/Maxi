CREATE procedure [dbo].[st_GetOtherDocumentsForTransfer]
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

select IdDocumentType,dbo.GetMessageFromMultiLenguajeResorces(1,name) NameEn,dbo.GetMessageFromMultiLenguajeResorces(2,name) NameEs from DocumentTypes with(nolock) where idtype=4 and Name!='Transaction Receipt' and Name != 'CustomerPicture'


