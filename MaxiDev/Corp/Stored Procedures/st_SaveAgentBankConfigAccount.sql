CREATE PROCEDURE [Corp].[st_SaveAgentBankConfigAccount]    
(     
	@IdAgent 	Int,    
	@IdBank  	Int,   
	@Account 	nvarchar(255),
	@Aba      nvarchar(255),
	@IdUser  	Int,
	@HasError bit out,
	@ErrorMessage nvarchar(max) out      
)    
AS    
Set nocount on  

/********************************************************************
<Author> Amoreno </Author>
<app>Corporate </app>
<Description> Inserta Configuración de Agent - Bank </Description>

<ChangeLog>
<log Date="11/27/2018" Author="Amoreno">Create</log>
</ChangeLog>
*********************************************************************/
begin try     
    	
      update 
       dbo.AgentBankConfigAccount 
		  set IdStatus  = 0
		  where 
			   IdAgent = @IdAgent


if(@IdBank<>0)		
 begin 

		 Insert into dbo.AgentBankConfigAccount
		 (    
			IdAgent
			, IdBank
			, Account
			, Aba 
			, idStatus
			, IdUser
			, DateOfLastChange
			)    
			Values    
			(    
				@IdAgent    
				, @IdBank   
				, @Account
				, @Aba
				, 1
				, @IdUser
				, getdate()
			)    	
 end
end try
begin catch         
    set @HasError=1                                        
    set @ErrorMessage=ERROR_MESSAGE()                                                 
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('dbo.st_SaveAgentBankConfigAccount',Getdate(),@ErrorMessage)                                                                                            
end catch

