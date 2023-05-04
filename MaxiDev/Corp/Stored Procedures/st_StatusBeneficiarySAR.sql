﻿CREATE PROCEDURE [Corp].[st_StatusBeneficiarySAR]
	
	@IdBeneficiary int,
	@IdUser int,
	@StatusSAR bit,
	--
	@IdLenguage int,
	@HasError bit output,
	@ResultMessage nvarchar(max) output
	--
AS
BEGIN
	-- 
	SET NOCOUNT ON;
    -- 
		BEGIN TRY 				
				 BEGIN 
					  INSERT INTO [dbo].[StatusBeneficiarySAR]
									      ( [IdBeneficiary]
										   ,[IdUser]
										   ,[StatusSAR]
										   ,[DataLastChange]
										    )
								   VALUES (
											@IdBeneficiary ,
											@IdUser ,
											@StatusSAR ,
											getdate()
										  )						

					END
					 SET @HasError=0        
						SELECT @ResultMessage = [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SQROK') -- Mensaje 					   				  
		END TRY

		BEGIN CATCH					  
					  		 DECLARE @ErrorMessage NVARCHAR(MAX)         
						      SELECT @ErrorMessage=ERROR_MESSAGE()        
							     SET @HasError = 1 --si hay error = 1, si la tarea fue correcta 0						
						 -----------
						 INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES('[Corp].[st_StatusBeneficiarySAR]',GETDATE(),@ErrorMessage) 
							  SELECT @ResultMessage = [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SQRERR') --id del Mensaje


		END CATCH
    --	
END


