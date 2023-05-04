
CREATE PROCEDURE [dbo].[st_GetCheckDetails]
	@IdCheck INT,
	@EnterByIdUser INT
--, @IsConsoulting INT
AS
/********************************************************************
<Author>Dario Almeida</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="15/05/2017" Author="Dario Almeida">Creación.</log>
<log Date="17/01/2018" Author="jdarellano" Name="#1">Performance: se agregan "with(nolock)".</log>
</ChangeLog>
*********************************************************************/


	DECLARE @isReview BIT


	--IF (EXISTS (SELECT IdUserReview FROM CheckOFACReview WHERE IdCheck = @IdCheck AND IdUserReview = @EnterByIdUser))
	IF (EXISTS (SELECT IdUserReview FROM [dbo].[CheckOFACReview] with(nolock) WHERE IdCheck = @IdCheck AND IdUserReview = @EnterByIdUser))--#1
	BEGIN
	  SET  @isReview = 1
	END
	ELSE
	BEGIN
	  SET @isReview = 0
	END

	SELECT 
			C.IdCheck,
			S.StatusName ,
			ISNULL(cn.EnterDate,c.DateOfMovement) DateOfMovement,			
			ISNULL(cn.Note,c.Note) AS Note,
			U.UserName,
			@isReview as isReview,
			--ISNULL((select top 1 IdCheckHold FROM [CheckHolds] ch where c.IdCheck = ch.IdCheck and ch.IsReleased is null and IdStatus = 15) ,0) as IdCheckHold,
			ISNULL((select top 1 IdCheckHold FROM [dbo].[CheckHolds] ch with(nolock) where c.IdCheck = ch.IdCheck and ch.IsReleased is null and IdStatus = 15) ,0) as IdCheckHold,--#1
			ISNULL(cnn.idMessage,0) AS IdMessage,
			ISNULL(cnn.idGenericStatus, 0) AS IdGenericStatus
	FROM [dbo].[CheckDetails] C with(nolock)--#1
	LEFT JOIN [dbo].[CheckNote] cn with(nolock) ON cn.IdCheckDetail = c.IdCheckDetail--#1
	LEFT JOIN [dbo].[Status] S with(nolock) ON (s.IdStatus = C.IdStatus )--#1
	LEFT JOIN [dbo].[Users] U with(nolock) ON (U.IdUser = C.EnterByIdUser )--#1
	LEFT JOIN [dbo].[CheckNoteNotification] cnn with(nolock) ON cnn.idCheckNote = cn.IdCheckNote--#1
	WHERE C.IdCheck = @IdCheck
	ORDER BY 3 DESC,c.IdCheckDetail DESC


