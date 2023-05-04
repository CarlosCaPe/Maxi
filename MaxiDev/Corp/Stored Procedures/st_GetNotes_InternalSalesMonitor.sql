CREATE PROCEDURE [Corp].[st_GetNotes_InternalSalesMonitor]
	@IdAgent INT,
	@IdNoteType INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@IdNoteType = 0)
	BEGIN
		SET @IdNoteType = NULL;
	END
	
	SELECT N.[IdNote]
		  ,N.[IdAgent]
		  ,N.[IdNoteType]
		  ,NT.[NoteType]
		  ,N.[Note]
		  ,N.[EnterByIdUser]
		  ,U.[UserLogin]
		  ,N.[CreationDate]
	FROM [InternalSalesMonitor].[Notes] AS N WITH(NOLOCK)
		INNER JOIN [InternalSalesMonitor].[NoteTypes] AS NT WITH(NOLOCK) ON N.[IdNoteType] = NT.[IdNoteType]
		--INNER JOIN [dbo].[Agent] AS A WITH(NOLOCK) ON N.[IdAgent] = A.[IdAgent]
		INNER JOIN [dbo].[Users] AS U WITH(NOLOCK) ON N.[EnterByIdUser]= U.[IdUser]
	WHERE 
		N.[IdAgent] = @IdAgent
		AND N.IdNoteType = ISNULL(@IdNoteType,N.IdNoteType)
	ORDER BY N.IdNoteType;

END

