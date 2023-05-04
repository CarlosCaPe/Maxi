CREATE PROCEDURE [dbo].[st_UpdateAgentPhoneNumbers]
	@IdAgent as int,
	@XmlPhoneNumbers xml,
	@HasError bit out 
AS
	
	Set nocount on     
	Begin Try  

	/******* DROP THE PREVIOUS PHONE NUMBERS **************/

		DELETE FROM AgentPhoneNumber where IdAgent=@IdAgent

	/********  READING AND INSERTING PHONE NUMBERS  ***************/
		 Declare @DocHandle int  
		 EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XmlPhoneNumbers     
		 Insert into AgentPhoneNumber   
		 (  
			IdAgent,  
			PhoneNumber,
            Comment
	     )    
		 Select @IdAgent,PhoneNumber,isnull(CommentPhone,'') From OPENXML (@DocHandle, '/Phones/Detail',2)    
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
		 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateAgentPhoneNumbers',Getdate(),@ErrorMessage)    
	End Catch