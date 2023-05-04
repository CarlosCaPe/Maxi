/********************************************************************
<Author>JCSierra</Author>
<app>??</app>
<Description>??</Description>

<ChangeLog>
<log Date="05/12/2018" Author="smacias"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [dbo].[st_GetPendingCommuniques]
(
	@IdAgent					INT,
	@IdUser						INT,
	@IdLanguage					INT = NULL
)
AS
BEGIN
	DECLARE @Result TABLE(IdTrainingCommuniqueAgentAnswer INT, IdTrainingCommunique INT)

	INSERT INTO @Result(IdTrainingCommuniqueAgentAnswer, IdTrainingCommunique)
	SELECT 
		ta.IdTrainingCommuniqueAgentAnswer,
		tc.IdTrainingCommunique
	FROM TrainingCommuniqueAgentAnswer ta WITH(NOLOCK)
		JOIN TrainingCommunique tc WITH(NOLOCK) ON tc.IdTrainingCommunique = ta.IdTrainingCommunique
		JOIN AgentUser au WITH(NOLOCK) ON au.IdAgent = ta.IdAgent
	WHERE 
		ta.IdAgent = @IdAgent
		AND au.IdUser = @IdUser
		AND tc.IdStatus = 1
        AND tc.StartDate <= GETDATE()

	SELECT
		ta.IdTrainingCommuniqueAgentAnswer,
		ta.IdAgent,
		ta.Acknowledgement,
		ta.ReviewDate,
		ta.IdUserReviewed,
        ur.UserName UserNameReviewed,
		ta.CreationDate,
		ta.IdUser,
		CASE 
			WHEN CONVERT(DATE, GETDATE()) > CONVERT(DATE, tc.EndingDate) AND ta.Acknowledgement = 0 THEN 1 
			ELSE 0 
		END ForcedToAccept,

		tc.IdTrainingCommunique TrainingCommunique_IdTrainingCommunique,
		tc.StartDate TrainingCommunique_StartDate,
		tc.EndingDate TrainingCommunique_EndingDate,
		tc.Title TrainingCommunique_Title,
		tc.Description TrainingCommunique_Description,
		tc.IdStatus TrainingCommunique_IdStatus,
		tc.Active TrainingCommunique_Active,
		tc.CreationDate TrainingCommunique_CreationDate,
		tc.IdUser TrainingCommunique_IdUser
	FROM TrainingCommunique tc WITH(NOLOCK) 
		JOIN TrainingCommuniqueAgentAnswer ta WITH(NOLOCK) ON ta.IdTrainingCommunique = tc.IdTrainingCommunique
		JOIN @Result r ON r.IdTrainingCommuniqueAgentAnswer = ta.IdTrainingCommuniqueAgentAnswer

        LEFT JOIN Users ur WITH(NOLOCK) ON ur.IdUser = ta.IdUserReviewed
	ORDER BY
        ta.Acknowledgement,
        ForcedToAccept DESC,
        tc.EndingDate

	DECLARE @DownloadHandler NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName] ('DownloadHandler')

	SELECT 
		uf.IdUploadFile,
		uf.IdReference,
		uf.FileName Name,
		uf.FileName NameEs,
		CONCAT(@DownloadHandler, '?resourceType=5&fileName=', uf.FileGuid, uf.Extension, '&Id=', 'ComplianceTraining/', uf.IdReference) WebUri,
		'pack://application:,,,/MaxiFrontOffice.Infrastructure;component/Resources/Document.png' ImagePath
	FROM UploadFiles uf WITH(NOLOCK)
		JOIN @Result r ON r.IdTrainingCommunique = uf.IdReference
		JOIN DocumentTypes dt WITH(NOLOCK) ON dt.IdDocumentType = uf.IdDocumentType
	WHERE dt.IdType = 7
	AND
	(
		@IdLanguage IS NULL
		OR (uf.IdLanguage = @IdLanguage OR uf.IdLanguage IS NULL)
	)
END
