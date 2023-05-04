CREATE PROCEDURE [dbo].[ST_TNC_CLAIM_CODE_GEN]
@straPayerName NVARCHAR (4000) NULL
AS EXTERNAL NAME [SQLCLRs].[StoredProcedures].[ST_TNC_CLAIM_CODE_GEN]


GO
EXECUTE sp_addextendedproperty @name = N'SqlAssemblyFile', @value = N'ST_TNC_CLAIM_CODE_GEN.cs', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'ST_TNC_CLAIM_CODE_GEN';


GO
EXECUTE sp_addextendedproperty @name = N'SqlAssemblyFileLine', @value = 10, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'ST_TNC_CLAIM_CODE_GEN';

