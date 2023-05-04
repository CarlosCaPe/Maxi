CREATE PROCEDURE [Operation].[st_GetMargin]
(
    @IdProvider INT = NULL,
    @IdCountry INT = NULL,
    @IdCarrier int = NULL,
    @IdProduct int = NULL,
    @Retail1 MONEY = NULL,
    @Retail2 MONEY = NULL
)
AS
-- =============================================
-- Author:  Francisco Lara
-- Create date: 2016-03-29
-- Description: Return margin for topup scheme // This stored is used in MaxiBackOffice-BillPayment (TopUp Scheme) // *** This stored use the same logic that [Operation].[fn_GetMarginByProvider]
-- =============================================
-- if @IdCarrier is null and @IdProduct is null begin 
--   WAITFOR DELAY '00:00:00:50'
-- end

 SELECT [Operation].[fn_GetMarginByProvider](
        @IdProvider
        , @IdCountry
        , @IdCarrier
        , @IdProduct
        , @Retail1
        , @Retail2) [Margin]