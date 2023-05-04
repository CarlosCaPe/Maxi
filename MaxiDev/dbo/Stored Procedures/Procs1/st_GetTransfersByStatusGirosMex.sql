
-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-06-23
-- Description:	This stored gets claim numbers from transfer in status "Payment Ready", "Cancel Stand By" and "Gateway Info Required"
-- =============================================
CREATE PROCEDURE [dbo].[st_GetTransfersByStatusGirosMex]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @Now TIME = CAST(GETDATE() AS TIME)

	SELECT
		T.[ClaimCode]
	FROM
		[dbo].[Transfer] T (NOLOCK)
	WHERE
		T.[IdGateway] = 24
		AND (T.[IdStatus] IN (25,29)
			OR (T.[IdStatus] = 23 AND
				(	(@Now >= '05:00' AND @Now <= '05:10') OR
					(@Now >= '07:00' AND @Now <= '07:10') OR
					(@Now >= '09:00' AND @Now <= '09:10') OR
					(@Now >= '11:00' AND @Now <= '11:10') OR
					(@Now >= '13:00' AND @Now <= '13:10') OR
					(@Now >= '15:00' AND @Now <= '15:10') OR
					(@Now >= '17:00' AND @Now <= '17:10') OR
					(@Now >= '19:00' AND @Now <= '19:10') OR
					(@Now >= '21:00' AND @Now <= '21:10') OR
					(@Now >= '22:30' AND @Now <= '22:40')
			)))

END
