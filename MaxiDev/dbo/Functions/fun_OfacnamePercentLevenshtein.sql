CREATE FUNCTION [dbo].[fun_OfacnamePercentLevenshtein]
(@name NVARCHAR (MAX) NULL, @firstLastname NVARCHAR (MAX) NULL, @secondLastname NVARCHAR (MAX) NULL)
RETURNS FLOAT (53)
AS
 EXTERNAL NAME [BozOfac].[UserDefinedFunctionsV2].[fun_OfacnamePercentLevenshtein]

