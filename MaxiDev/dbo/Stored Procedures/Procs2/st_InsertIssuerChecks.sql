
CREATE PROCEDURE [dbo].[st_InsertIssuerChecks](
@IdIssuer int, 
@Name varchar(MAX), 
@RoutingNumber varchar(100), 
@AccountNumber varchar(100), 
@EnteredByIdUser int,
@IssuerPhone varchar(30),  
@IdIssuerOut int output
)
AS
-- =============================================
-- Author:		Aldo Morán Márquez
-- Create date: 10/04/2015
-- Description:	Insert or Update IssuerTable
--
-- 
--
-- Control de Cambios
-- CC    Usuario      Fecha        Descripcion
-- 01    Fgonzalez  2016/11/28     Se agrega validacion para saber si existe el Routing Number y Account number antes de registrar un nuevo issuer.
-- jmolina  2018/12/19     Se agrega ; en cada insert/update.
-- =============================================
BEGIN
	Begin Try
		if(@IdIssuer > 0)
			Begin 
				Update [dbo].[IssuerChecks] set [Name] = @Name, DateOfLastChange = GETDATE(), EnteredByIdUser = @EnteredByIdUser, PhoneNumber = @IssuerPhone where IdIssuer = @IdIssuer;
				set @IdIssuerOut = @IdIssuer
			End
		else
			BEGIN
				--CC01
				IF NOT EXISTS (SELECT 1 FROM [dbo].[IssuerChecks] WHERE RoutingNumber = @RoutingNumber AND AccountNumber = @AccountNumber) BEGIN 
					
					insert into [dbo].[IssuerChecks] ([Name], RoutingNumber, AccountNumber, DateOfCreation, DateOfLastChange, EnteredByIdUser, PhoneNumber) values
					(@Name, @RoutingNumber, @AccountNumber, GETDATE(), GETDATE(), @EnteredByIdUser, @IssuerPhone);
					 Select @IdIssuerOut=Scope_Identity();       
					 
				 END ELSE BEGIN
				    --CC01
				    SELECT TOP 1 @IdIssuerOut = IdIssuer FROM [dbo].[IssuerChecks] WHERE RoutingNumber = @RoutingNumber AND AccountNumber = @AccountNumber		    
				    Update [dbo].[IssuerChecks] set [Name] = @Name, DateOfLastChange = GETDATE(), EnteredByIdUser = @EnteredByIdUser, PhoneNumber = @IssuerPhone where IdIssuer = @IdIssuerOut;
				 	
				 END 
			end
	End Try
	Begin Catch
		Declare @ErrorMessage nvarchar(max)                                                                                             
		Select @ErrorMessage=ERROR_MESSAGE()                                             
		Insert into [dbo].[ErrorLogForStoreProcedure] (StoreProcedure,ErrorDate,ErrorMessage)Values('st_InsertIssuerChecks',Getdate(),@ErrorMessage)                                                                                            
	End Catch
END

