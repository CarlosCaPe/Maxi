

CREATE PROCEDURE [dbo].[st_InsertOrUpdateUploadFile]
(
    @Id INT,
    @IdReference INT = null,
    @FileName NVARCHAR(MAX),
    @FileGuid NVARCHAR(MAX) = null,
    @Extension NVARCHAR(MAX) = null,
    @IdStatus INT = null,
    @ExpirationDate DATE = null,
    @IdDocumentType INT = null,
    @IdUser INT = null,
    @IdDocumentImageType INT,
	@LastIpChange NVARCHAR(max) = null,
    @LastNoteChange NVARCHAR(max)= null,
    @LastUserChange NVARCHAR(max)= null,
    @IdCountry INT= null,
    @IdState INT= null,
	@DateOfBirth DATE = null,
    @IdOut INT OUT,
    @HasError BIT OUT
)
AS
/********************************************************************
<Author></Author>
<app> </app>
<Description></Description>

<ChangeLog>
<log Date=" Author="">  </log>

</ChangeLog>

*********************************************************************/
DECLARE @IdUploadFile INT

BEGIN TRY

DECLARE @AgentCode VARCHAR(MAX)
DECLARE @IdAgent INT
DECLARE @IdDocumentTypeDad INT
DECLARE @IdDocumentTypeFax INT

DECLARE @DocType NVARCHAR(MAX)
DECLARE @IdentificationNumber NVARCHAR(MAX)
DECLARE @CountryName NVARCHAR(MAX)
DECLARE @StateCode NVARCHAR(MAX)
DECLARE @newName NVARCHAR(MAX)

	IF(@Id = 0)
	BEGIN
		SELECT TOP 1 @DocType = Name FROM  DocumentTypes with(nolock) where IdDocumentType = @IdDocumentType
		SELECT TOP 1 @IdentificationNumber = IdentificationNumber FROM Customer with(nolock) where IdCustomer = @IdReference
		SELECT TOP 1 @StateCode = StateCode  from state with(nolock) where IdState = @IdState
		SELECT TOP 1 @CountryName  = CountryName from country with(nolock) where IdCountry = @IdCountry
		SELECT TOP 1 @IdDocumentTypeFax = IdDocumentType FROM  DocumentTypes with(nolock) where name = 'Fax Training'

		if(@IdDocumentType != @IdDocumentTypeFax)
		begin
			SELECT @newName = ISNULL(@DocType, '') + ' ' + ISNULL(@StateCode, '') + ' ' + ISNULL(@CountryName, '') + ' - ' + ISNULL(@IdentificationNumber,'')
		end
		else
		begin
			set @newName = @FileName
			set @FileGuid=(select Substring(@newName,1,LEN(@newName)-4))
		end

		INSERT INTO [dbo].[UploadFiles]
				([IdReference]
			   ,[IdDocumentType]
			   ,[FileName] 
			   ,[FileGuid]
			   ,[Extension]
			   ,[IdStatus]
			   ,[IdUser]
			   ,[LastChange_LastDateChange]
			   ,[LastChange_LastUserChange]
			   ,[ExpirationDate]
			   ,[CreationDate]
			   ,[LastChange_LastIpChange]
			   ,[LastChange_LastNoteChange]
			   ,[DateOfBirth]
			   )
		 VALUES
			   (
			   @IdReference,
			   @IdDocumentType,
			   @newName,  -- @FileName 
			   @FileGuid,
			   @Extension,
			   @IdStatus,
			   @IdUser,
			   GETDATE(),
			   @LastUserChange,
			   @ExpirationDate,
			   GETDATE(),
			   @LastIpChange,
			   @LastNoteChange,
			   @DateOfBirth
			   )           

			SET @IdUploadFile = SCOPE_IDENTITY()

            SET @IdOut = @IdUploadFile

		IF (EXISTS (SELECT IdType FROM documenttypes with(nolock) WHERE IdDocumentType =  @IdDocumentType AND IdType IN (1,6,4)))
		begin

			if (isnull(@IdDocumentImageType,0))>0 
            begin            
                INSERT INTO [dbo].[UploadFilesDetail]
				    ([IdUploadFile],
					[IdDocumentImageType],
					[IdCountry],
					[IdState]
					)
			    VALUES
			    (
				    @IdUploadFile
			        ,@IdDocumentImageType
					,@IdCountry
					,@IdState
			    )
			end
         end

		 DECLARE @IdType INT

		 SET @IdType = (SELECT TOP 1 IdType FROM  documenttypes with(nolock) WHERE IdDocumentType = @IdDocumentType) 
		 
		 IF(@IdType = 3)
		 BEGIN
			--Crear imagen en Agencia si se agrego a AgentAplication
			SET @AgentCode = (select AgentCode FROM AgentApplications with(nolock) WHERE IdAgentApplication = @IdReference)
		       
			SET @IdAgent =  (SELECT IdAgent FROM Agent with(nolock) WHERE AgentCode = @AgentCode)

			IF(@IdAgent > 0)
			BEGIN 

		
			SET	@IdDocumentTypeDad = (SELECT IdDocumentTypeDad FROM  documenttypes with(nolock) WHERE IdDocumentType = @IdDocumentType)
			SET @IdDocumentType = (SELECT IdDocumentType FROM  documenttypes with(nolock) WHERE IdDocumentType = @IdDocumentTypeDad AND IdType = 2)

				IF(@IdDocumentType IS NOT NULL)
				BEGIN
					INSERT INTO [dbo].[UploadFiles]
					([IdReference]
				   ,[IdDocumentType]
				   ,[FileName]
				   ,[FileGuid]
				   ,[Extension]
				   ,[IdStatus]
				   ,[IdUser]
				   ,[LastChange_LastDateChange]
				   ,[LastChange_LastUserChange]
				   ,[ExpirationDate]
				   ,[CreationDate]
				   ,[LastChange_LastIpChange]
				   ,[LastChange_LastNoteChange]
				   )
			 VALUES
				   (
				   @IdAgent,
				   @IdDocumentType,
				   @FileName,
				   @FileGuid,
				   @Extension,
				   @IdStatus,
				   @IdUser,
				   GETDATE(),
				   @LastUserChange,
				   @ExpirationDate,
				   GETDATE(),
				   @LastIpChange,
				   @LastNoteChange
				   )           

					SET @IdUploadFile = SCOPE_IDENTITY()

					--SET @IdOut = @IdUploadFile

					IF (EXISTS (SELECT IdType FROM documenttypes with(nolock) WHERE IdDocumentType =  @IdDocumentType AND IdType IN (1,6,4)))
			BEGIN

				IF (ISNULL(@IdDocumentImageType,0))>0 
				BEGIN            
					INSERT INTO [dbo].[UploadFilesDetail]
						([IdUploadFile],
						[IdDocumentImageType],
						[IdCountry],
						[IdState]
						)
					VALUES
					(
						@IdUploadFile
						,@IdDocumentImageType
						,@IdCountry
						,@IdState
					)
				END
			 END
				END
			END

		END
    END 
	ELSE
	BEGIN
 
		UPDATE	[dbo].[UploadFiles] 
		SET    
				[FileName] =  @FileName,
				[LastChange_LastUserChange] =  @LastUserChange,
				[LastChange_LastDateChange] =   GETDATE(),
				[ExpirationDate] =  @ExpirationDate,
                IdDocumentType=@IdDocumentType,
				DateOfBirth = @DateOfBirth
		WHERE   IdUploadFile = @Id 

        SET @IdOut = @Id


		--declare @IdDocumentTypeTemp int 
		--set @IdDocumentTypeTemp  = (select IdDocumentType from [dbo].[UploadFiles]  where   IdUploadFile = @Id) 

		IF (EXISTS (SELECT IdType FROM documenttypes with(nolock) WHERE IdDocumentType = @IdDocumentType AND IdType IN (1,6,4) ))
		BEGIN

			IF(EXISTS (SELECT IdUploadFile FROM [dbo].[UploadFilesDetail] with(nolock) WHERE  IdUploadFile = @Id ))
				BEGIN
                    IF (ISNULL(@IdDocumentImageType,0))>0 
                    BEGIN
					    UPDATE [dbo].[UploadFilesDetail]
					    SET    [IdDocumentImageType] = @IdDocumentImageType, [IdCountry] = @IdCountry, [IdState] = @IdState

					    WHERE  IdUploadFile = @Id 
                    END
				END

			ELSE
			BEGIN

			   IF (isnull(@IdDocumentImageType,0))>0 
               BEGIN
                    INSERT INTO [dbo].[UploadFilesDetail]
				        ([IdUploadFile]
				        ,[IdDocumentImageType]
						,[IdCountry]
						,[IdState])
				    VALUES
				    (
					    @Id
				        ,@IdDocumentImageType
						,@IdCountry
						,@IdState
				    )
                END
	
		   END

	END
	   
END

SET @HasError=0
END TRY
BEGIN CATCH
SET @HasError=1

    DECLARE @ErrorMessage nvarchar(max)                                                                                             
    SELECT @ErrorMessage=ERROR_MESSAGE()                                             
    INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_InsertOrUpdateUploadFile',GETDATE(),@ErrorMessage) 
    --INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_InsertOrUpdateUploadFile',GETDATE(),CONVERT(VARCHAR,ISNULL(@Id,0)))
    --INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_InsertOrUpdateUploadFile',GETDATE(),CONVERT(VARCHAR,ISNULL(@IdReference,0)))
    --INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_InsertOrUpdateUploadFile',GETDATE(),CONVERT(VARCHAR,ISNULL(@IdDocumentType,0)))
    --INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_InsertOrUpdateUploadFile',GETDATE(),CONVERT(VARCHAR,ISNULL(@IdDocumentImageType,0)))
END CATCH

