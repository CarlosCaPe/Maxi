CREATE FUNCTION [dbo].[fun_OfacnamePercentLetterPairs]
(@name NVARCHAR (MAX) NULL, @firstLastname NVARCHAR (MAX) NULL, @secondLastname NVARCHAR (MAX) NULL)
RETURNS FLOAT (53)
AS
 EXTERNAL NAME [BozOfac].[UserDefinedFunctionsV2].[fun_OfacnamePercentLetterPairs]

