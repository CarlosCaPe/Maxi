-- =============================================
-- Author:		<Author,,bortega>
-- Create date: <15/11/2019,,>
-- Description:	<Actualizar registros a mostrar con status en Payment Ready para Fax Android,,>
-- =============================================
CREATE PROCEDURE [dbo].[st_UpdateDaysFaxPaymentReady]
	-- Add the parameters for the stored procedure here
	@Days int,
	@HasError bit out,
	@ResultMessage nvarchar(max) out
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
BEGIN TRY
	if exists (select 1 from dbo.GlobalAttributes with(nolock) where Name = 'PaymentReadyRecordsInDays')
	begin 
		UPDATE dbo.GlobalAttributes set Value= @Days where Name= 'PaymentReadyRecordsInDays'
		SELECT @ResultMessage='Days has been successfully saved'
		Set @HasError=0
	end

END TRY

BEGIN CATCH
	 Set @HasError = 1 
	 Select @ResultMessage=ERROR_MESSAGE()                                                                
	 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateDaysFaxPaymentReady', Getdate(),@ResultMessage)    
END CATCH

END
