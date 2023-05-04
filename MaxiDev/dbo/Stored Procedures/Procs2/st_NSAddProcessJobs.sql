CREATE PROCEDURE st_NSAddProcessJobs
(
	@IdProcessType		INT,
	@IdJob				NVARCHAR(200)
)
AS
BEGIN
	INSERT INTO NSProcessJob
	VALUES
	(
		@IdProcessType,
		@IdJob,
		GETDATE()
	)
END