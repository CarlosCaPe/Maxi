CREATE procedure [dbo].[st_GetTransferDetailByIdTransfer]
(
	@IdTransfer int, 
	@Start int = 1, 
	@PageSize int = 10,  
	@PageCount int output,
	@isAll bit = 0
)
as
/********************************************************************
<Author>Francisco Lara</Author>
<app>MaxiCorporate</app>
<Description>This Stored Procedure gets Status History of a transfer</Description>

<ChangeLog>
<log Date="25/01/2016" Author="FranciscoLara">Creacion del Store</log>
<log Date="26/12/2016" Author="Fgonzalez"> En estatus cancelados, se obtiene el motivo de la cancelacion junto con la nota</log>
<log Date="03/09/2019" Author="OscarAMurillo"> Se agrego parametro isAll y se agrego una consulta para poder obtener todos los registros si isAll es igual a 1</log>
<log Date="15/12/2020" Author="jgomez"> CR - M00249 Se agrego funcionalidad para que muestre en status history el orden de los status previos de la remesa</log>
</ChangeLog>
*********************************************************************/
    set @Start = @Start-1

	Declare @Detail table 
		(
			Id int IDENTITY(1,1),
			IdStatus INT,
			StatusName nvarchar(max),
			DateDeatil datetime,
			Users nvarchar(max),
			Note nvarchar(max),
			IdMessage int,
			IdGenericStatus INT,
			idReasonForCancel INT NULL ,
			NoteTypeId INT NULL
		)

		CREATE TABLE #Detail2 (
		    Id int,
			IdStatus int,
			StatusName nvarchar(max),
			DateDeatil datetime,
			Users nvarchar(max),
			Note nvarchar(max),
			IdMessage int,
			IdGenericStatus INT)   -- CR - M00249

	-- Add the T-SQL statements to compute the return value here

	If exists(Select 1 From [Transfer] with(nolock) where IdTransfer=@IdTransfer) 
	BEGIN

		insert into @Detail (IdStatus, StatusName, DateDeatil, Users, Note, IdMessage, IdGenericStatus,idReasonForCancel,NoteTypeId)
		SELECT IsNull(A.IdStatus,0) as IdStatus, 
			IsNull(E.StatusName,'Nota de lo migrado') as StatusName,
			IsNull(B.EnterDate, A.DateOfMovement) as DateDetail,
			IsNull(D.UserName,'System') as Users,
			IsNull(B.Note ,'') as Note,
			IsNull(TNN.IdMessage,0) as IdMessage,
			IsNull(TNN.IdGenericStatus,0) as IdGenericStatus,
			T.idReasonForCancel,
			b.IdTransferNoteType
		From TransferDetail A with(nolock)
		INNER JOIN [Transfer] T with(nolock)
		ON T.IdTransfer = A.IdTransfer
			Left Join TransferNote B with(nolock) on (A.IdTransferDetail=B.IdTransferDetail)
			Left Join Users D with(nolock) on (B.IdUser=D.IdUser)
			Left Join [Status] E with(nolock) on (A.IdStatus=E.IdStatus)
			Left Join TransferNoteNotification TNN with(nolock) on (B.IdTransferNote= TNN.IdTransferNote)
		Where A.IdTransfer=@IdTransfer 
		ORDER BY IsNull(B.EnterDate, A.DateOfMovement) DESC, A.IdStatus DESC; -- CR - M00249
	End 
	Else 
	Begin
		insert into @Detail (IdStatus, StatusName, DateDeatil, Users, Note, IdMessage, IdGenericStatus,idReasonForCancel,NoteTypeId)
		SELECT 
			Isnull(A.IdStatus,0) as IdStatus,
			Isnull(E.StatusName,'Nota de lo migrado') as StatusName,
			Isnull(B.EnterDate,A.DateOfMovement) as DateDetail,
			Isnull(D.UserName,'System') as Users,
			Isnull(B.Note,'') as Note,
			IsNull(TCNN.IdMessage,0) as IdMessage,
			IsNull(TCNN.IdGenericStatus,0) as IdGenericStatus,
			NULL, 
			b.IdTransferNoteType
		From TransferClosedDetail A with(nolock) 
			Left Join TransferClosedNote B with(nolock) on (A.IdTransferClosedDetail=B.IdTransferClosedDetail) 
			Left Join Users D with(nolock) on (B.IdUser=D.IdUser) 
			Left Join [Status] E with(nolock) on (A.IdStatus=E.IdStatus) 
			Left Join TransferClosedNoteNotification TCNN with(nolock) on (B.IdTransferClosedNote = TCNN.IdTransferClosedNote)
		Where IdTransferClosed=@IdTransfer 
		ORDER BY IsNull(B.EnterDate, A.DateOfMovement) DESC, A.IdStatus DESC; -- CR - M00249
	End

	-- result
	if(@isAll = 0)
	BEGIN
	insert into #Detail2 -- CR - M00249
	select 
	Id, 
	IdStatus, 
	StatusName, 
	DateDeatil, 
	Users, 
	Note=isnull(CASE WHEN det.IdStatus = 22 AND Det.NoteTypeId = 2 THEN 'Reason: '+RC.ReasonEn+' ' END,'') +Note, 
	IdMessage, 
	det.IdGenericStatus
	 FROM @Detail Det
	 LEFT JOIN ReasonForCancel RC with(nolock)
	 ON RC.IdReasonForCancel = det.idReasonForCancel
	 WHERE Id BETWEEN @Start + 1 AND @Start + @PageSize;

	 select Id, IdStatus, StatusName, DateDeatil,Users, Note, IdMessage, IdGenericStatus from #Detail2 order by DateDeatil desc -- CR - M00249
	 END
	 ELSE
	 BEGIN
	insert into #Detail2 -- CR - M00249
	select 
	Id, 
	IdStatus, 
	StatusName, 
	DateDeatil, 
	Users, 
	Note=isnull(CASE WHEN det.IdStatus = 22 AND Det.NoteTypeId = 2 THEN 'Reason: '+RC.ReasonEn+' ' END,'') +Note, 
	IdMessage, 
	det.IdGenericStatus
	 FROM @Detail Det
	 LEFT JOIN ReasonForCancel RC with(nolock)
	 ON RC.IdReasonForCancel = det.idReasonForCancel;

	 select Id, IdStatus, StatusName, DateDeatil,Users, Note, IdMessage, IdGenericStatus from #Detail2 order by DateDeatil desc -- CR - M00249
	 END
	-- total 
	select @PageCount = COUNT(*) from @Detail ;
	
    drop table #Detail2


