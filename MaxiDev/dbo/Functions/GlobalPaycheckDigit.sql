CREATE FUNCTION [dbo].[GlobalPaycheckDigit]
(@cusip NVARCHAR (MAX) NULL)
RETURNS NVARCHAR (20)
AS
 EXTERNAL NAME [CLRGlobalPay].[CLRGlobalPay.Functions].[GenerateCheckDigit]

