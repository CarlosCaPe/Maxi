CREATE FUNCTION [dbo].[fnCreatePasswordHash]
(@password NVARCHAR (4000) NULL, @salt NVARCHAR (4000) NULL)
RETURNS NVARCHAR (4000)
AS
 EXTERNAL NAME [SharedDb].[CommonSecurity].[fnCreatePasswordHash]


GO
EXECUTE sp_addextendedproperty @name = N'SqlAssemblyFile', @value = N'Security.cs', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'FUNCTION', @level1name = N'fnCreatePasswordHash';


GO
EXECUTE sp_addextendedproperty @name = N'SqlAssemblyFileLine', @value = N'21', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'FUNCTION', @level1name = N'fnCreatePasswordHash';

