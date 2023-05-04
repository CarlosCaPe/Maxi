CREATE PROCEDURE st_GetPendingImportedFiles
AS
BEGIN
	SELECT
		ibf.*
	FROM Acc_ImportedBankFormat ibf
	WHERE ibf.Processed <> 2
	ORDER BY ibf.ProcessingRequestDate 
END
