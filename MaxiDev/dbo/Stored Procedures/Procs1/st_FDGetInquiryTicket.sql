CREATE PROCEDURE st_FDGetInquiryTicket
(
	@IdTicket	INT
)
AS
BEGIN
	SELECT
		it.*
	FROM FD_InquiryTicket it 
	WHERE it.Id = @IdTicket
END