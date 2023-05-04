CREATE PROCEDURE st_FetchTrainingCommuniqueAgentAnswer
(
	@IdTrainingCommunique		INT,
	@AgentCode					VARCHAR(MAX),
	@AgentName					VARCHAR(MAX),
	@IsACK						BIT
)
AS
BEGIN
	SELECT
		t.IdTrainingCommuniqueAgentAnswer,
		t.IdTrainingCommunique,
		t.IdAgent,
		a.AgentCode,
		a.AgentName,
		t.Acknowledgement,
		t.ReviewDate,
		t.IdUserReviewed,
		ur.UserName UserNameReviewed,
		t.CreationDate,
		t.IdUser,
		u.UserName
	FROM TrainingCommuniqueAgentAnswer t WITH(NOLOCK)
		JOIN Agent a WITH(NOLOCK) ON a.IdAgent = t.IdAgent
		JOIN Users u WITH(NOLOCK) ON t.IdUser = u.IdUser
		LEFT JOIN Users ur WITH(NOLOCK) ON t.IdUserReviewed = ur.IdUser
	WHERE 
		t.IdTrainingCommunique = @IdTrainingCommunique
		AND (ISNULL(@AgentCode, '') = '' OR a.AgentCode LIKE CONCAT('%', @AgentCode, '%'))
		AND (ISNULL(@AgentName, '') = '' OR a.AgentName LIKE CONCAT('%', @AgentName, '%'))
		AND (@IsACK IS NULL OR t.Acknowledgement = @IsACK)
END
