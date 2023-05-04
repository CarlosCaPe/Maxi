CREATE   PROCEDURE Corp.st_GetInquiryTicketCustomMessages
(
	@GetSecondary BIT -- 0 Primary, 1 Secondary
)
AS
/********************************************************************
<Author>Cesar Garcia</Author>
<app>MaxiCorp</app>
<Description>Get Custom Messages for Inquiry Letters</Description>
<CreationDate>03/04/2023</CreationDate>

*********************************************************************/

BEGIN
	
	SELECT A.MessageESP, A.MessageENG 
	FROM dbo.FD_InquiryTicketCustomMessages A WITH(NOLOCK)
	WHERE IsSecondary = @GetSecondary
	
END