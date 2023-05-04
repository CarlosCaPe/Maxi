CREATE FUNCTION [dbo].[fnCreateSalt]
(@size INT NULL)
RETURNS NVARCHAR (4000)
AS
 EXTERNAL NAME [SharedDb].[CommonSecurity].[fnCreateSalt]


GO
EXECUTE sp_addextendedproperty @name = N'SqlAssemblyFile', @value = N'Security.cs', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'FUNCTION', @level1name = N'fnCreateSalt';


GO
EXECUTE sp_addextendedproperty @name = N'SqlAssemblyFileLine', @value = N'13', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'FUNCTION', @level1name = N'fnCreateSalt';

