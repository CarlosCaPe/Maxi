CREATE PROCEDURE Corp.st_GetMultiIRDPrintReport
	@ReportGUID VARCHAR(max)
AS
BEGIN 
	 
	SELECT M.ImgBytes,  M.ReportText, M.IsCheckImg, M.MaxiLine1, M.MaxiLine2, M.MaxiLine3, M.AgentLine1, M.AgentLine2, M.AgentLine3
	FROM Corp.MultiIRDPrintReport M
	WHERE ReportGUID = @ReportGUID
	ORDER BY ImgOrder

END
