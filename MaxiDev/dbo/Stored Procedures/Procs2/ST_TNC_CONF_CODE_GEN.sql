CREATE PROCEDURE [dbo].[ST_TNC_CONF_CODE_GEN]
@straXmitterAbr NVARCHAR (4000) NULL, @straXmitterCode NVARCHAR (4000) NULL, @straClientFirstName NVARCHAR (4000) NULL, @straBeneficiaryFirstName NVARCHAR (4000) NULL, @straBeneficiaryLastName NVARCHAR (4000) NULL, @straBeneficiaryMotherMaidenName NVARCHAR (4000) NULL, @straMoney NVARCHAR (4000) NULL
AS EXTERNAL NAME [SQLCLRs].[StoredProcedures].[ST_TNC_CONF_CODE_GEN]


GO
EXECUTE sp_addextendedproperty @name = N'SqlAssemblyFile', @value = N'ST_TNC_CONF_CODE_GEN.cs', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'ST_TNC_CONF_CODE_GEN';


GO
EXECUTE sp_addextendedproperty @name = N'SqlAssemblyFileLine', @value = 10, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'ST_TNC_CONF_CODE_GEN';

