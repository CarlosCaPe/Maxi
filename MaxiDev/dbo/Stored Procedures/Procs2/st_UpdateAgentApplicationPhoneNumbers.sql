CREATE PROCEDURE [dbo].[st_UpdateAgentApplicationPhoneNumbers]
	@IdAgentApplication as int,
	@XmlPhoneNumbers xml,
	@HasError bit out 
AS
	
	Set nocount on     
	Begin Try  

	/******* DROP THE PREVIOUS PHONE NUMBERS **************/

		DELETE FROM AgentApplicationPhoneNumber where IdAgentApplication=@IdAgentApplication

	/********  READING AND INSERTING PHONE NUMBERS  ***************/
		 Declare @DocHandle int  
		 EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XmlPhoneNumbers     
		 Insert into AgentApplicationPhoneNumber   
		 (  
			IdAgentApplication,  
			PhoneNumber,
            Comment
	     )    
		 Select @IdAgentApplication,PhoneNumber,isnull(CommentPhone,'') From OPENXML (@DocHandle, '/Phones/Detail',2)    
		 WITH (    		   
		 PhoneNumber nvarchar(max),
         CommentPhone nvarchar(max)   		 
		 )     
		 Exec sp_xml_removedocument @DocHandle   

		 Set @HasError=0    
	End Try    
	Begin Catch    
		 Set @HasError=1    
		 Declare @ErrorMessage nvarchar(max)     
		 Select @ErrorMessage=ERROR_MESSAGE()    
		 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateAgentApplicationPhoneNumbers',Getdate(),@ErrorMessage)    
	End Catch

