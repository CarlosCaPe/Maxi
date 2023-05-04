
CREATE FUNCTION [dbo].[fnAMLPGetKYCAlerts]()
RETURNS TABLE
AS
RETURN
(
	SELECT
		cl.IdReference IdRule
	FROM AMLP_ParameterConsiderationList cl 
	WHERE cl.IdParameter = 9


	--SELECT 
	--	TRY_CONVERT(INT, fs.item) IdRule
	--FROM dbo.fnSplit(ISNULL((SELECT TOP 1 ms.Notes FROM AMLP_MonitorSettings ms WITH(NOLOCK) WHERE ms.IdMonitorSettings= 9), ''), ',') fs
	--WHERE 
	--	TRY_CONVERT(INT, fs.item) IS NOT NULL
)
