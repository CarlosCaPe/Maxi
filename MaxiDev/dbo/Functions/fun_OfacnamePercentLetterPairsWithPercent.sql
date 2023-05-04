CREATE FUNCTION [dbo].[fun_OfacnamePercentLetterPairsWithPercent]
(@name NVARCHAR (MAX) NULL, @firstLastname NVARCHAR (MAX) NULL, @secondLastname NVARCHAR (MAX) NULL, @minPercent FLOAT (53) NULL)
RETURNS FLOAT (53)
AS
 EXTERNAL NAME [BozOfac].[UserDefinedFunctionsV2].[fun_OfacnamePercentLetterPairsWithPercent]

