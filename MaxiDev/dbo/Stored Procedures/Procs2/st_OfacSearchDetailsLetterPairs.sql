CREATE PROCEDURE [dbo].[st_OfacSearchDetailsLetterPairs]
@f_name NVARCHAR (MAX) NULL, @l_name_1 NVARCHAR (MAX) NULL, @l_name_2 NVARCHAR (MAX) NULL
AS EXTERNAL NAME [BozOfac].[UserDefinedFunctionsV2].[st_OfacSearchDetailsLetterPairs]

