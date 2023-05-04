CREATE PROCEDURE st_FDGetInquiryTicketHistory
(
	@IdTransfer INT
)
AS
/********************************************************************
<Author>Unknown</Author>
<app> </app>
<Description> Get Inquiry Ticket History </Description>

<ChangeLog>
<log Date="10/02/2023" Author="cagarcia">BM-522 Se agrega campo 'InquiryReasonENG' </log>
</ChangeLog>
*********************************************************************/
BEGIN
	SELECT
		fit.Id,
		fit.IdTransfer,
		fit.SendInquiryLetter,
		fit.IdFileInquiryLetter,
		fit.CustomerEmail,
		fit.InquiryReason,
		fit.InquiryReasonENG,
		fit.ErrorResolution,
		fit.IdFileResolution,
		fit.ResolutionDate,
		fit.EnterByIdUser,
		fit.CreateDate,
		fit.ChangeByUser,
		fit.DateOfLastChange,
			
		U.UserLogin [User],

		ufInquiry.FileGuid		InquiryFileGuid,
		ufInquiry.FileName		InquiryFileName,
		ufInquiry.Extension		InquiryExtension,

		ufResolution.FileGuid	ResolutionFileGuid,
		ufResolution.FileName	ResolutionFileName,
		ufResolution.Extension	ResolutionExtension
	FROM FD_InquiryTicket fit WITH(NOLOCK)
		JOIN Users u WITH(NOLOCK) ON u.IdUser = fit.EnterByIdUser
		LEFT JOIN UploadFiles ufInquiry WITH(NOLOCK) ON fit.IdFileInquiryLetter = ufInquiry.IdUploadFile
		LEFT JOIN UploadFiles ufResolution WITH(NOLOCK) ON fit.IdFileResolution = ufResolution.IdUploadFile
	WHERE fit.IdTransfer = @IdTransfer
	ORDER BY fit.CreateDate DESC
END

