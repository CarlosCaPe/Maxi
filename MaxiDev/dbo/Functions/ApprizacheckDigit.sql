CREATE FUNCTION [dbo].[ApprizacheckDigit]
(@sqlUrn NVARCHAR (MAX) NULL)
RETURNS INT
AS
 EXTERNAL NAME [CLRAppriza].[CLRAppriza.Functions].[GenerateCheckDigit]

