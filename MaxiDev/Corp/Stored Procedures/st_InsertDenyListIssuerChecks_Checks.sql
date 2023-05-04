-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Corp].[st_InsertDenyListIssuerChecks_Checks]
	-- Add the parameters for the stored procedure here
	--declare  
	@IdUser INT,
	@IdCheck INT,
	@ReturnDate DATETIME,
	@FileName NVARCHAR(100),
	@IsFromFile BIT
AS
BEGIN TRY

	declare @EnteredByIdUser int, @NoteInToList nvarchar(1000), @DateOfMovement datetime, @AgentUser nvarchar(100), @IdIssuer int, @NameUser nvarchar(max)

	Select @EnteredByIdUser = EnteredByIdUser, @DateOfMovement = DateOfMovement, @IdIssuer = IdIssuer  from Checks with(Nolock) where IdCheck = @IdCheck

	Select @AgentUser = AgentCode + ' ' + AgentName from Agent A with(nolock)inner join AgentUser AU  with(nolock) on A.IdAgent = AU.IdAgent where AU.IdUser = @EnteredByIdUser
				
	--formato de fechas MM/DD/YYYY


	if (@IsFromFile = 1)
	begin 
		set @NoteInToList = 'Fecha en que se presentó el cheque: ' + FORMAT (@DateOfMovement, 'MM/dd/yyyy') + '
							Fecha en la que se rechazó el cheque: ' + FORMAT (@ReturnDate, 'MM/dd/yyyy') +'
							Numero de Cheque: ' + cast(@IdCheck as nvarchar) + '
							Agente: ' + @AgentUser +'
							Motivo: Closed Account
							Origen: Importacion automatica de archivo: "'+ @FileName + '"'
	end
	else
	begin

		Select @NameUser = FirstName + ' ' + LastName + ' ' + SecondLastName from Users with(nolock) where idUser = @IdUser

		set @NoteInToList = 'Fecha en que se presentó el cheque: ' + FORMAT (@DateOfMovement, 'MM/dd/yyyy') + '
											Fecha en la que se rechazó el cheque: ' + FORMAT (getdate(), 'MM/dd/yyyy') +'
											Numero de Cheque: ' + cast(@IdCheck as nvarchar) + '
											Agente: ' + @AgentUser +'
											Motivo: Closed Account
											Origen: Proceso manual: "'+ @NameUser + '"'
	end
					

	INSERT INTO [dbo].[DenyListIssuerChecks]
				(IdIssuerCheck
				,DateInToList
				,DateOutFromList
				,IdUserCreater
				,IdUserDeleter
				,NoteInToList
				,NoteOutFromList
				,IdGenericStatus
				,EnterByIdUser
				,DateOfLastChange)
			VALUES
				(@IdIssuer
				,@DateOfMovement
				,@ReturnDate
				,@EnteredByIdUser
				,@IdUser
				,@NoteInToList
				,''
				,1
				,@IdUser
				,GetDate())

END TRY                                       
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('[Corp].[st_InsertDenyListIssuerChecks_Checks]', GETDATE(), @ErrorMessage)
END CATCH
