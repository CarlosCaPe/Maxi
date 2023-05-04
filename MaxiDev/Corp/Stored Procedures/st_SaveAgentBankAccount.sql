CREATE PROCEDURE [Corp].[st_SaveAgentBankAccount]    
(   
@IdConfig Int,    
@IdAgent Int,    
@IdBank Int,   
@IdAccount Int,
@EnteredByIdUser Int,
@HasError bit out,
@Message nvarchar(max) out      
)    
AS    
Set nocount on  

/********************************************************************
<Author> DAlmeida </Author>
<app>Corporate </app>
<Description> Inserta o actualiza </Description>

<ChangeLog>
<log Date="09/13/2017" Author="DAlmeida">Create</log>
<log Date="19/12/2019" Author="jmolina">Add with(nolock) and ;</log>
</ChangeLog>
*********************************************************************/
Begin       

IF @IdConfig = 0
	BEGIN
		IF EXISTS (SELECT 1 FROM AgentBankConfig with(nolock) WHERE IdAgent = @IdAgent AND IdBank = @IdBank AND IdAccount = @IdAccount )
			BEGIN
				SET @HasError = 1
				SET @Message = 'Ya existe esa configuración'
				RETURN @HasError;
			END

		 Insert into AgentBankConfig (    
			IdAgent,
			IdBank,
			IdAccount,
			EnteredByIdUser
			)    
			Values    
			(    
			@IdAgent,    
			@IdBank,   
			@IdAccount,
			@EnteredByIdUser 
			);    
	END
ELSE
	BEGIN
		UPDATE AgentBankConfig 
		   SET IdBank = @IdBank,
			   IdAccount = @IdAccount,
			   EnteredByIdUser = @EnteredByIdUser
		WHERE IdConfig = @IdConfig;
	END
SET @HasError = 0;
RETURN @HasError;
End 
