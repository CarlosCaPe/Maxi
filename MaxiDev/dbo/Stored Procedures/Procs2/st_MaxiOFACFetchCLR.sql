CREATE PROCEDURE [dbo].[st_MaxiOFACFetchCLR]
@name NVARCHAR (MAX) NULL, @firstLastname NVARCHAR (MAX) NULL, @secondLastname NVARCHAR (MAX) NULL
AS EXTERNAL NAME [MaxiOFAC].[MaxiOFAC.StoredProcedures].[st_MaxiOFACFetchCLR]

