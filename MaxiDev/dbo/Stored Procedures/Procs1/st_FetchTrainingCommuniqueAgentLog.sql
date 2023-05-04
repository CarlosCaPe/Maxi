CREATE PROCEDURE st_FetchTrainingCommuniqueAgentLog
(
	@IdTrainingCommuniqueAgentAnswer		INT
)
AS
BEGIN
	SELECT
		l.IdTrainingCommuniqueAgentLog,
		l.IdTrainingCommuniqueAgentAnswer,
		l.Action,
		l.LogDate,
		l.IdUser,
		u.UserName
	FROM TrainingCommuniqueAgentLog l WITH(NOLOCK)
		JOIN Users u WITH(NOLOCK) ON u.IdUser = l.IdUser
	WHERE l.IdTrainingCommuniqueAgentAnswer = @IdTrainingCommuniqueAgentAnswer
	ORDER BY l.LogDate DESC
END
